//
//  NetworkReachabilityManager.swift
//  Components
//
//  Originally from Alamofire (https://github.com/Alamofire/Alamofire)
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(SystemConfiguration)

import Foundation
import SystemConfiguration

/// 网络可达性管理器，监听主机和地址的可达性变化（蜂窝和 WiFi 网络接口）
///
/// 可达性用于确定网络操作失败的背景信息，或在建立连接时重试网络请求。
/// 不应用于阻止用户发起网络请求，因为可能需要初始请求来建立可达性。
public final class NetworkReachabilityManager: @unchecked Sendable {
    /// 网络可达性状态
    public enum NetworkReachabilityStatus: Equatable, Sendable {
        /// 未知网络是否可达
        case unknown
        /// 网络不可达
        case notReachable
        /// 网络可达，关联 `ConnectionType`
        case reachable(ConnectionType)

        init(_ flags: SCNetworkReachabilityFlags) {
            guard flags.isActuallyReachable else { self = .notReachable; return }

            var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)

            if flags.isCellular { networkStatus = .reachable(.cellular) }

            self = networkStatus
        }

        /// 连接类型
        public enum ConnectionType: Sendable {
            /// 以太网或 WiFi 连接
            case ethernetOrWiFi
            /// 蜂窝网络连接
            case cellular
        }
    }

    /// 网络可达性状态变化时执行的闭包
    public typealias Listener = @Sendable (NetworkReachabilityStatus) -> Void

    // MARK: - Properties

    /// 网络是否当前可达
    public var isReachable: Bool { isReachableOnCellular || isReachableOnEthernetOrWiFi }

    /// 网络是否当前通过蜂窝接口可达
    public var isReachableOnCellular: Bool { status == .reachable(.cellular) }

    /// 网络是否当前通过以太网或 WiFi 接口可达
    public var isReachableOnEthernetOrWiFi: Bool { status == .reachable(.ethernetOrWiFi) }

    /// 可达性更新的调度队列
    public let reachabilityQueue = DispatchQueue(label: "com.components.reachabilityQueue")

    /// 当前可达性类型的标志
    public var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()

        return SCNetworkReachabilityGetFlags(reachability, &flags) ? flags : nil
    }

    /// 当前网络可达性状态
    public var status: NetworkReachabilityStatus {
        flags.map(NetworkReachabilityStatus.init) ?? .unknown
    }

    /// 可变状态存储
    struct MutableState {
        /// 网络可达性状态变化时执行的闭包
        var listener: Listener?
        /// 调用监听器的调度队列
        var listenerQueue: DispatchQueue?
        /// 之前计算的状态
        var previousStatus: NetworkReachabilityStatus?
    }

    /// 提供通知的 `SCNetworkReachability` 实例
    private let reachability: SCNetworkReachability

    /// 可变状态的受保护存储
    private let mutableState = Protected(MutableState())

    // MARK: - Initialization

    /// 使用指定主机创建实例
    ///
    /// - Note: `host` 值不能包含 scheme，只能是主机名
    /// - Parameter host: 用于评估网络可达性的主机，不能包含 scheme（如 `https`）
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }

        self.init(reachability: reachability)
    }

    /// 创建监控地址 0.0.0.0 的实例
    ///
    /// 可达性将 0.0.0.0 地址视为特殊令牌，使其监控设备的通用路由状态（IPv4 和 IPv6）
    public convenience init?() {
        var zero = sockaddr()
        zero.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zero.sa_family = sa_family_t(AF_INET)

        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zero) else { return nil }

        self.init(reachability: reachability)
    }

    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
    }

    deinit {
        stopListening()
    }

    // MARK: - Listening

    /// 开始监听网络可达性状态变化
    ///
    /// - Note: 停止并移除任何现有监听器
    /// - Parameters:
    ///   - queue: 调用 `listener` 闭包的 `DispatchQueue`，默认为 `.main`
    ///   - listener: 可达性变化时调用的 `Listener` 闭包
    /// - Returns: 如果成功开始监听返回 `true`，否则返回 `false`
    @preconcurrency
    @discardableResult
    public func startListening(onQueue queue: DispatchQueue = .main,
                               onUpdatePerforming listener: @escaping Listener) -> Bool {
        stopListening()

        mutableState.write { state in
            state.listenerQueue = queue
            state.listener = listener
        }

        let weakManager = WeakManager(manager: self)

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passUnretained(weakManager).toOpaque(),
            retain: { info in
                let unmanaged = Unmanaged<WeakManager>.fromOpaque(info)
                _ = unmanaged.retain()

                return UnsafeRawPointer(unmanaged.toOpaque())
            },
            release: { info in
                let unmanaged = Unmanaged<WeakManager>.fromOpaque(info)
                unmanaged.release()
            },
            copyDescription: { info in
                let unmanaged = Unmanaged<WeakManager>.fromOpaque(info)
                let weakManager = unmanaged.takeUnretainedValue()
                let description = weakManager.manager?.flags?.readableDescription ?? "nil"

                return Unmanaged.passRetained(description as CFString)
            }
        )
        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info else { return }

            let weakManager = Unmanaged<WeakManager>.fromOpaque(info).takeUnretainedValue()
            weakManager.manager?.notifyListener(flags)
        }

        let queueAdded = SCNetworkReachabilitySetDispatchQueue(reachability, reachabilityQueue)
        let callbackAdded = SCNetworkReachabilitySetCallback(reachability, callback, &context)

        // 手动调用监听器以给出初始状态，因为框架可能不会这样做
        if let currentFlags = flags {
            reachabilityQueue.async {
                self.notifyListener(currentFlags)
            }
        }

        return callbackAdded && queueAdded
    }

    /// 停止监听网络可达性状态变化
    public func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        mutableState.write { state in
            state.listener = nil
            state.listenerQueue = nil
            state.previousStatus = nil
        }
    }

    // MARK: - Internal - Listener Notification

    /// 如果计算的状态没有变化，则在 `listenerQueue` 上调用 `listener` 闭包
    ///
    /// - Note: 只应从 `reachabilityQueue` 调用
    /// - Parameter flags: 用于计算状态的 `SCNetworkReachabilityFlags`
    func notifyListener(_ flags: SCNetworkReachabilityFlags) {
        let newStatus = NetworkReachabilityStatus(flags)

        mutableState.write { [newStatus] (state: inout MutableState) in
            guard state.previousStatus != newStatus else { return }

            state.previousStatus = newStatus

            let listener = state.listener
            state.listenerQueue?.async { listener?(newStatus) }
        }
    }

    private final class WeakManager {
        weak var manager: NetworkReachabilityManager?

        init(manager: NetworkReachabilityManager?) {
            self.manager = manager
        }
    }
}

// MARK: - SCNetworkReachabilityFlags Extension

extension SCNetworkReachabilityFlags {
    var isReachable: Bool { contains(.reachable) }
    var isConnectionRequired: Bool { contains(.connectionRequired) }
    var canConnectAutomatically: Bool { contains(.connectionOnDemand) || contains(.connectionOnTraffic) }
    var canConnectWithoutUserInteraction: Bool { canConnectAutomatically && !contains(.interventionRequired) }
    var isActuallyReachable: Bool { isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction) }
    var isCellular: Bool {
        #if os(iOS) || os(tvOS) || os(visionOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }

    /// 所有状态的可读 `String`，用于调试
    var readableDescription: String {
        let W = isCellular ? "W" : "-"
        let R = isReachable ? "R" : "-"
        let c = isConnectionRequired ? "c" : "-"
        let t = contains(.transientConnection) ? "t" : "-"
        let i = contains(.interventionRequired) ? "i" : "-"
        let C = contains(.connectionOnTraffic) ? "C" : "-"
        let D = contains(.connectionOnDemand) ? "D" : "-"
        let l = contains(.isLocalAddress) ? "l" : "-"
        let d = contains(.isDirect) ? "d" : "-"
        let a = contains(.connectionAutomatic) ? "a" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)\(a)"
    }
}
#endif
