//
//  ToastViewProtocol.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

/// Toast 自定义视图协议
///
/// App 可以实现此协议来提供自定义的 Toast 视图样式
@MainActor
public protocol ToastViewProtocol: View {
    /// 创建 Toast 视图
    /// - Parameter modal: Toast 状态管理器（包含 isPresented、currentConfig 等）
    init(modal: ToastModal)
}
