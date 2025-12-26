//
//  PresentationViewMapping.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

// MARK: - Presentation View Mapping Protocol

/// Presentation 视图映射协议
///
/// 使用者实现此协议来定义 viewType → View 的映射关系
@MainActor
public protocol PresentationViewMapping {
    associatedtype Content: View

    /// 根据视图类型返回对应视图
    /// - Parameter viewType: 视图类型标识符
    /// - Returns: 对应的视图
    @ViewBuilder
    func view(for viewType: AnyHashable) -> Content
}
