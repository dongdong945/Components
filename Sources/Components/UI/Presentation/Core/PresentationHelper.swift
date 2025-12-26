//
//  PresentationHelper.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

/// Presentation 管理器
@MainActor
@Observable
public final class PresentationHelper: PresentationPresenting {
    // MARK: - Properties

    /// Presentation 栈（从 root 到最上层）
    public private(set) var stack: [PresentationItem] = []

    // MARK: - Initializer

    public init() {}

    // MARK: - Public API

    /// 展示一个视图
    /// - Parameters:
    ///   - viewType: 视图类型（必须是 Hashable）
    ///   - style: 展示样式
    public func present<T: Hashable>(_ viewType: T, as style: PresentationStyle) {
        let item = PresentationItem(viewType: AnyHashable(viewType), style: style)
        present(item)
    }

    /// 关闭最顶层视图
    public func dismiss() {
        if !stack.isEmpty {
            stack.removeLast()
        }
    }

    /// 关闭所有视图
    public func dismissAll() {
        stack.removeAll()
    }

    // MARK: - PresentationPresenting

    public func present(_ item: PresentationItem) {
        stack.append(item)
    }

    public func dismissFrom(index: Int) {
        guard index >= 0, index < stack.count else { return }
        stack.removeSubrange((index + 1)...)
    }

    // MARK: - Query Methods

    /// 获取指定索引的 item
    /// - Parameter index: 索引位置
    /// - Returns: 对应的 PresentationItem，如果索引超出范围则返回 nil
    public func item(at index: Int) -> PresentationItem? {
        guard index < stack.count else { return nil }
        return stack[index]
    }

    /// 当前栈深度
    public var depth: Int {
        stack.count
    }

    /// 当前最顶层样式
    public var currentStyle: PresentationStyle? {
        stack.last?.style
    }
}
