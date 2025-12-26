//
//  AlertModal.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

// MARK: - Alert Modal

/// Alert 模态展示器
@MainActor
@Observable
public final class AlertModal: AlertPresenting {
    // MARK: - Properties

    public var isPresented: Bool = false
    public private(set) var currentConfig: AlertConfiguration?

    // MARK: - Initializer

    public init() {}

    // MARK: - AlertPresenting

    public func present(config: AlertConfiguration) {
        currentConfig = config
        isPresented = true
    }

    public func dismiss() {
        isPresented = false
    }
}
