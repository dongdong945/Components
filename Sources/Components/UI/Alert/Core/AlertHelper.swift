//
//  AlertHelper.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

/// Alert 管理器
@MainActor
@Observable
public final class AlertHelper {
    // MARK: - Properties

    /// Alert 展示协议实现者
    public weak var presenter: AlertPresenting?

    /// 是否正在显示
    public var isPresented: Bool {
        presenter?.isPresented ?? false
    }

    // MARK: - Initializer

    /// 初始化 Alert 管理器
    /// - Parameter presenter: 展示协议实现者
    public init(presenter: AlertPresenting? = nil) {
        self.presenter = presenter
    }

    // MARK: - Public API - Core Methods

    /// 展示 Alert（自定义按钮）
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - actions: 按钮列表
    ///   - appearance: 外观配置
    public func show(
        _ title: String?,
        message: String? = nil,
        actions: [AlertAction],
        appearance: AlertAppearance? = nil
    ) {
        let config = AlertConfiguration(
            title: title,
            message: message,
            actions: actions,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 展示 Alert（含消息）
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - appearance: 外观配置
    public func show(_ title: String?, message: String, appearance: AlertAppearance? = nil) {
        let config = AlertConfiguration(
            title: title,
            message: message,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 展示 Alert（仅标题）
    /// - Parameters:
    ///   - title: 标题
    ///   - appearance: 外观配置
    public func show(_ title: String?, appearance: AlertAppearance? = nil) {
        let config = AlertConfiguration(title: title, appearance: appearance ?? .default)
        presenter?.present(config: config)
    }

    // MARK: - Convenience API

    /// 展示确认/取消弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - appearance: 外观配置
    ///   - onConfirm: 确认回调
    public func showConfirm(
        _ title: String?,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        appearance: AlertAppearance? = nil,
        onConfirm: @escaping () -> Void
    ) {
        let actions = [
            AlertAction(title: confirmTitle, handler: onConfirm),
            AlertAction(title: cancelTitle, role: .cancel)
        ]
        show(title, message: message, actions: actions, appearance: appearance)
    }

    /// 展示破坏性操作弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - destructiveTitle: 破坏性按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - appearance: 外观配置
    ///   - onDestruct: 破坏性操作回调
    public func showDestructive(
        _ title: String?,
        message: String? = nil,
        destructiveTitle: String = "Delete",
        cancelTitle: String = "Cancel",
        appearance: AlertAppearance? = nil,
        onDestruct: @escaping () -> Void
    ) {
        let actions = [
            AlertAction(title: destructiveTitle, role: .destructive, handler: onDestruct),
            AlertAction(title: cancelTitle, role: .cancel)
        ]
        show(title, message: message, actions: actions, appearance: appearance)
    }

    /// 展示错误弹窗
    /// - Parameters:
    ///   - error: 错误对象
    ///   - appearance: 外观配置
    public func showError(_ error: Error, appearance: AlertAppearance? = nil) {
        show("Error", message: error.localizedDescription, appearance: appearance)
    }

    /// 隐藏 Alert
    public func dismiss() {
        presenter?.dismiss()
    }
}
