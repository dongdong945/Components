//
//  AlertModal.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

// MARK: - Alert Modal

/// Alert 模态展示器
@MainActor
@Observable
public final class AlertModal: AlertPresenting {
    // MARK: - Properties

    /// 是否正在显示
    public var isPresented: Bool = false
    /// 当前 Alert 配置
    public private(set) var currentConfig: AlertConfiguration?

    // MARK: - Initializer

    public init() {}

    // MARK: - AlertPresenting

    /// 展示 Alert
    /// - Parameter config: Alert 配置
    public func present(config: AlertConfiguration) {
        currentConfig = config
        isPresented = true
    }

    /// 隐藏 Alert
    public func dismiss() {
        isPresented = false
    }
}
