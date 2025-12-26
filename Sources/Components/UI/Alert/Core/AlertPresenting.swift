//
//  AlertPresenting.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

// MARK: - Alert Action

/// Alert 按钮数据模型
public struct AlertAction: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole?
    public let handler: () -> Void

    public init(title: String, role: ButtonRole? = nil, handler: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.handler = handler
    }

    public static func defaultOK() -> AlertAction {
        AlertAction(title: "OK", role: nil)
    }
}

// MARK: - Alert Configuration

/// Alert 配置数据模型
public struct AlertConfiguration {
    public let title: String
    public let message: String?
    public let actions: [AlertAction]

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
    var isPresented: Bool { get set }
    func present(config: AlertConfiguration)
    func dismiss()
}
