//
//  Protected.swift
//  Components
//
//  Originally from Alamofire (https://github.com/Alamofire/Alamofire)
//  Copyright (c) 2014-2020 Alamofire Software Foundation (http://alamofire.org/)
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

import Foundation

/// 线程安全锁协议
private protocol Lock: Sendable {
    func lock()
    func unlock()
}

extension Lock {
    /// 在获取锁的情况下执行闭包并返回值
    ///
    /// - Parameter closure: 要运行的闭包
    /// - Returns: 闭包生成的值
    func around<T>(_ closure: () throws -> T) rethrows -> T {
        lock(); defer { unlock() }
        return try closure()
    }

    /// 在获取锁的情况下执行闭包
    ///
    /// - Parameter closure: 要运行的闭包
    func around(_ closure: () throws -> Void) rethrows {
        lock(); defer { unlock() }
        try closure()
    }
}

#if canImport(Darwin)
/// `os_unfair_lock` 包装器
final class UnfairLock: Lock, @unchecked Sendable {
    private let unfairLock: os_unfair_lock_t

    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    fileprivate func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    fileprivate func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}

#elseif canImport(Foundation)
extension NSLock: Lock {}
#else
#error("This platform needs a Lock-conforming type without Foundation.")
#endif

/// 线程安全的值包装器
public final class Protected<Value> {
    #if canImport(Darwin)
    private let lock = UnfairLock()
    #elseif canImport(Foundation)
    private let lock = NSLock()
    #else
    #error("This platform needs a Lock-conforming type without Foundation.")
    #endif

    private nonisolated(unsafe) var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    /// 同步读取或转换包含的值
    ///
    /// - Parameter closure: 要执行的闭包
    /// - Returns: 传入闭包的返回值
    public func read<U>(_ closure: (Value) throws -> U) rethrows -> U {
        try lock.around { try closure(self.value) }
    }

    /// 同步修改受保护的值
    ///
    /// - Parameter closure: 要执行的闭包
    /// - Returns: 修改后的值
    @discardableResult
    public func write<U>(_ closure: (inout Value) throws -> U) rethrows -> U {
        try lock.around { try closure(&self.value) }
    }

    /// 同步更新受保护的值
    ///
    /// - Parameter value: 新的值
    public func write(_ value: Value) {
        write { $0 = value }
    }
}

#if compiler(>=6)
extension Protected: Sendable {}
#endif

extension Protected: Equatable where Value: Equatable {
    public static func == (lhs: Protected<Value>, rhs: Protected<Value>) -> Bool {
        lhs.read { left in rhs.read { right in left == right } }
    }
}

extension Protected: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        read { hasher.combine($0) }
    }
}
