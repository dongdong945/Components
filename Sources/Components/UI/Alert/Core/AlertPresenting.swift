//
//  AlertPresenting.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

// MARK: - Alert Action

/// Alert 按钮数据模型
public struct AlertAction: Identifiable {
    /// 唯一标识
    public let id = UUID()
    /// 按钮标题
    public let title: String
    /// 按钮角色（确定/取消/破坏）
    public let role: ButtonRole?
    /// 点击回调
    public let handler: () -> Void

    /// 创建一个 Alert 按钮
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - role: 按钮角色
    ///   - handler: 点击回调
    public init(title: String, role: ButtonRole? = nil, handler: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.handler = handler
    }

    /// 默认的“OK”按钮
    public static func defaultOK() -> AlertAction {
        AlertAction(title: "OK", role: nil)
    }
}

// MARK: - Alert Configuration

/// Alert 配置数据模型
public struct AlertConfiguration {
    /// 标题
    public let title: String
    /// 描述信息
    public let message: String?
    /// 按钮列表
    public let actions: [AlertAction]

    /// 创建 Alert 配置
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述信息
    ///   - actions: 按钮列表，默认提供“确定”
    public init(title: String, message: String? = nil, actions: [AlertAction] = []) {
        self.title = title
        self.message = message
        self.actions = actions.isEmpty ? [.defaultOK()] : actions
    }
}

// MARK: - Alert Presenting Protocol

/// Alert 展示协议
@MainActor
public protocol AlertPresenting: AnyObject {
    /// 是否正在显示
    var isPresented: Bool { get set }
    /// 展示 Alert
    /// - Parameter config: Alert 配置
    func present(config: AlertConfiguration)
    /// 隐藏 Alert
    func dismiss()
}
