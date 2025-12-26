//
//  AlertViewProtocol.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

/// Alert 自定义视图协议
///
/// App 可以实现此协议来提供自定义的 Alert 视图样式
@MainActor
public protocol AlertViewProtocol: View {
    /// 创建 Alert 视图
    /// - Parameter modal: Alert 状态管理器（包含 isPresented、currentConfig 等）
    init(modal: AlertModal)
}
