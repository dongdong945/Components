//
//  ToastHelper.swift
//  Components
//
//  Created by DongDong on 11/30/25.
//

import SwiftUI

/// Toast 提示框管理器
@MainActor
@Observable
public final class ToastHelper {
    // MARK: - Properties

    /// Toast 展示协议实现者
    public weak var presenter: ToastPresenting?

    /// 是否正在显示
    public var isPresented: Bool {
        presenter?.isPresented ?? false
    }

    // MARK: - Initializer

    public init(presenter: ToastPresenting? = nil) {
        self.presenter = presenter
    }

    // MARK: - Public Methods

    /// 隐藏 Toast
    public func dismiss() {
        presenter?.dismiss()
    }

    // MARK: - LocalizedStringResource

    /// 显示加载状态提示
    public func loading(_ title: LocalizedStringResource? = nil, appearance: ToastAppearance? = nil) {
        let localizedTitle = title.map { String(localized: $0) }
        let config = ToastConfiguration(
            type: .loading,
            title: localizedTitle,
            duration: 0, // loading 不自动隐藏
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 显示信息提示
    public func info(_ title: LocalizedStringResource, appearance: ToastAppearance? = nil) {
        let localizedTitle = String(localized: title)
        let config = ToastConfiguration(
            type: .info,
            title: localizedTitle,
            duration: 3.0,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 显示成功提示
    public func success(_ title: LocalizedStringResource, appearance: ToastAppearance? = nil) {
        let localizedTitle = String(localized: title)
        let config = ToastConfiguration(
            type: .success,
            title: localizedTitle,
            duration: 3.0,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 显示错误提示
    public func error(_ title: LocalizedStringResource, appearance: ToastAppearance? = nil) {
        let localizedTitle = String(localized: title)
        let config = ToastConfiguration(
            type: .error,
            title: localizedTitle,
            duration: 3.0,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 显示错误提示
    public func error(_ error: Error, appearance: ToastAppearance? = nil) {
        let config = ToastConfiguration(
            type: .error,
            title: error.localizedDescription,
            duration: 3.0,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    // MARK: - String

    /// 显示信息提示
    public func info(verbatim title: String, appearance: ToastAppearance? = nil, duration: TimeInterval = 3.0) {
        let config = ToastConfiguration(
            type: .info,
            title: title,
            duration: duration,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 显示成功提示
    public func success(verbatim title: String, appearance: ToastAppearance? = nil, duration: TimeInterval = 3.0) {
        let config = ToastConfiguration(
            type: .success,
            title: title,
            duration: duration,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }

    /// 显示错误提示
    public func error(verbatim title: String, appearance: ToastAppearance? = nil, duration: TimeInterval = 3.0) {
        let config = ToastConfiguration(
            type: .error,
            title: title,
            duration: duration,
            appearance: appearance ?? .default
        )
        presenter?.present(config: config)
    }
}
