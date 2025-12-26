//
//  AlertHelper.swift
//  Components
//
//  Created by DongDong on 12/01/25.
//

import SwiftUI

/// Alert 管理器
@MainActor
@Observable
public final class AlertHelper {
    // MARK: - Properties

    public weak var presenter: AlertPresenting?

    public var isPresented: Bool {
        presenter?.isPresented ?? false
    }

    // MARK: - Initializer

    public init(presenter: AlertPresenting? = nil) {
        self.presenter = presenter
    }

    // MARK: - Public API - Core Methods

    public func show(_ title: String, message: String? = nil, actions: [AlertAction]) {
        let config = AlertConfiguration(title: title, message: message, actions: actions)
        presenter?.present(config: config)
    }

    public func show(_ title: String, message: String) {
        let config = AlertConfiguration(title: title, message: message)
        presenter?.present(config: config)
    }

    public func show(_ title: String) {
        let config = AlertConfiguration(title: title)
        presenter?.present(config: config)
    }

    // MARK: - Convenience API

    public func showConfirm(
        _ title: String,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void
    ) {
        let actions = [
            AlertAction(title: confirmTitle, handler: onConfirm),
            AlertAction(title: cancelTitle, role: .cancel)
        ]
        show(title, message: message, actions: actions)
    }

    public func showDestructive(
        _ title: String,
        message: String? = nil,
        destructiveTitle: String = "Delete",
        cancelTitle: String = "Cancel",
        onDestruct: @escaping () -> Void
    ) {
        let actions = [
            AlertAction(title: destructiveTitle, role: .destructive, handler: onDestruct),
            AlertAction(title: cancelTitle, role: .cancel)
        ]
        show(title, message: message, actions: actions)
    }

    public func showError(_ error: Error) {
        show("Error", message: error.localizedDescription)
    }

    public func dismiss() {
        presenter?.dismiss()
    }
}
