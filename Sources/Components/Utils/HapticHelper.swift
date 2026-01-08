//
//  HapticHelper.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI
import UIKit

/// 触觉反馈管理器
///
/// 提供简单、独立的触觉反馈功能，支持所有 UIKit 冲击反馈样式。
///
/// ## 使用示例
///
/// ### 基本用法
/// ```swift
/// // 使用便捷方法
/// HapticHelper.shared.medium()
///
/// // 使用特定样式
/// HapticHelper.shared.impact(style: .heavy)
///
/// // 禁用触觉反馈
/// HapticHelper.shared.isEnabled = false
/// ```
///
/// ### SwiftUI 集成
/// ```swift
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(HapticHelper.shared)
///         }
///     }
/// }
///
/// struct ContentView: View {
///     @Environment(HapticHelper.self) private var haptic
///
///     var body: some View {
///         Button("Tap") {
///             haptic.medium()
///         }
///     }
/// }
/// ```
///
/// ## 特性
/// - ✅ 单例模式 - 通过 `HapticHelper.shared` 访问
/// - ✅ 运行时配置 - `isEnabled` 属性控制启用/禁用（默认启用）
/// - ✅ 零外部依赖 - 无需 UserDefaults 或其他配置对象
/// - ✅ 5 种触觉样式 - light, medium, soft, heavy, rigid
/// - ✅ SwiftUI 友好 - 支持 @Observable 和 Environment
@MainActor
@Observable
public final class HapticHelper {
    // MARK: - 单例

    /// 共享单例实例
    public static let shared = HapticHelper()

    // MARK: - 属性

    /// 是否启用触觉反馈
    ///
    /// 默认为 `true`。设置为 `false` 将禁用所有触觉反馈。
    ///
    /// - Note: 此属性仅在运行时有效，不会持久化。应用重启后将重置为 `true`。
    public var isEnabled: Bool = true

    // MARK: - 初始化

    /// 私有初始化方法，强制使用单例
    private init() {}

    // MARK: - 核心方法

    /// 触发指定样式的触觉反馈
    ///
    /// - Parameter style: UIKit 触觉反馈样式（.light, .medium, .soft, .heavy, .rigid）
    ///
    /// ## 样式说明
    /// - `.light` - 轻触，适用于选择和轻量级交互
    /// - `.medium` - 中等，适用于按钮点击和标准交互
    /// - `.soft` - 柔和，适用于微妙的反馈
    /// - `.heavy` - 重击，适用于删除或重要警告
    /// - `.rigid` - 刚性，适用于精确交互和机械反馈
    ///
    /// - Note: 如果 `isEnabled` 为 `false`，此方法将不执行任何操作
    public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - 样式便捷方法

    /// 触发轻触觉反馈（.light）
    ///
    /// 适用于选择和轻量级交互场景。
    public func light() {
        impact(style: .light)
    }

    /// 触发中等触觉反馈（.medium）
    ///
    /// 适用于按钮点击和标准交互场景。
    public func medium() {
        impact(style: .medium)
    }

    /// 触发柔和触觉反馈（.soft）
    ///
    /// 适用于微妙的反馈场景。
    public func soft() {
        impact(style: .soft)
    }

    /// 触发重触觉反馈（.heavy）
    ///
    /// 适用于删除或重要警告场景。
    public func heavy() {
        impact(style: .heavy)
    }

    /// 触发刚性触觉反馈（.rigid）
    ///
    /// 适用于精确交互和机械反馈场景。
    public func rigid() {
        impact(style: .rigid)
    }
}
