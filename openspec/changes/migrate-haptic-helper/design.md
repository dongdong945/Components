# 设计：HapticHelper 迁移与优化

## 背景

HapticHelper 目前存在于 SwiftUILab 中，具有以下特性：
- 使用 `@MainActor` 和 `@Observable` 实现 SwiftUI 集成
- 与 AppSettings 紧密耦合以实现全局配置
- 支持使用独立 UserDefaults 键的测试模式
- 提供单一的 `impact(style:)` 方法触发触觉反馈

Components 库需要一个通用、可复用的触觉反馈 helper，要求：
- 独立工作，无外部依赖
- 支持灵活配置
- 与现有 helper 模式保持一致（AlertHelper、ToastHelper）
- 保持简单易用

## 目标 / 非目标

### 目标
- 创建独立、可复用的触觉反馈 helper
- 移除所有外部依赖（AppSettings、UserDefaults）
- 提供简单的运行时启用/禁用控制
- 保持 SwiftUI 友好的 API（使用 `@Observable` 和 `@MainActor`）
- 支持全部 5 种 UIKit 触觉反馈样式
- 提供基于样式的便捷方法（非语义化）
- 遵循 Components 项目约定
- 保持最大程度的简单性

### 非目标
- 不持久化配置到 UserDefaults
- 不支持基于实例的使用（仅单例）
- 不创建语义化方法（success/error）
- 不创建复杂的触觉模式引擎
- 初期不与特定 UI 组件集成

## 决策

### 决策 1：仅运行时配置
**选择**：简单的 `isEnabled` 属性，无持久化，默认为 `true`

**原因**：
- 消除所有外部依赖（AppSettings、UserDefaults）
- 调用方根据需要在运行时控制状态
- 最大简化 - 无需持久化层
- 跨应用启动无状态（始终以启用状态开始）

**实现**：
```swift
public var isEnabled: Bool = true
```

### 决策 2：仅单例模式
**选择**：仅提供单例，不支持基于实例的使用

**原因**：
- 最简单的 API
- 触觉反馈本质上是全局关注点
- 减少 API 表面积和复杂度
- 在整个应用中保持一致状态

**实现**：
```swift
@MainActor
@Observable
public final class HapticHelper {
    public static let shared = HapticHelper()
    private init() {}
}
```

### 决策 3：项目结构中的位置
**选择**：放置在 `Sources/Components/Utils/HapticHelper.swift`

**原因**：
- Utils 目录包含工具类（AppState、AppLogger、NetworkMonitor、TaskState）
- HapticHelper 是工具类，而非 UI 组件
- 不需要 Alert/Toast 的复杂结构（Core/Protocols/Views）
- 与现有简单工具类保持一致

**考虑的替代方案**：
- 创建 `Sources/Components/Helpers/` - 否决：没有现有的 Helpers 目录，会破坏一致性
- 放在 UI 目录 - 否决：它不是视觉组件
- 创建像 Alert 那样的嵌套结构 - 否决：对简单工具来说过于复杂

### 决策 4：API 设计
**选择**：保持简单的 `impact(style:)` + 添加基于样式的便捷方法

**原因**：
- 核心方法用于直接控制：`HapticHelper.shared.impact(style: .medium)`
- 样式便捷方法：`light()`, `medium()`, `soft()`, `heavy()`, `rigid()`
- 无语义化方法（success/error）- 保持简单直接
- 每个便捷方法与 UIKit 样式 1:1 映射

**实现**：
```swift
// 核心方法
public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle)

// 样式便捷方法（1:1 映射）
public func light()   // → .light
public func medium()  // → .medium
public func soft()    // → .soft
public func heavy()   // → .heavy
public func rigid()   // → .rigid
```

### 决策 5：移除所有状态持久化
**选择**：无 UserDefaults、无 AppSettings、完全无持久化

**原因**：
- 最大简化
- 调用方根据需要管理状态
- 无副作用或隐藏存储
- 始终以全新状态（启用）启动应用

## 架构

### 类结构
```swift
@MainActor
@Observable
public final class HapticHelper {
    // MARK: - 单例
    public static let shared = HapticHelper()

    // MARK: - 属性
    public var isEnabled: Bool = true

    // MARK: - 初始化
    private init() {}

    // MARK: - 核心方法
    public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle)

    // MARK: - 样式便捷方法
    public func light()
    public func medium()
    public func soft()
    public func heavy()
    public func rigid()
}
```

### 使用模式

#### 基本用法
```swift
// 直接使用单例
Button("点击我") {
    HapticHelper.shared.medium()
}

// 切换启用/禁用
Button("切换触觉反馈") {
    HapticHelper.shared.isEnabled.toggle()
}

// 使用特定样式
HapticHelper.shared.impact(style: .heavy)
```

#### 与 Environment 集成
```swift
// 在 App 文件中
@main
struct ComponentsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(HapticHelper.shared)
        }
    }
}
```

## 风险 / 权衡

### 风险：跨启动无持久化
**影响**：isEnabled 在应用重启时始终重置为 true
**缓解**：调用方根据需要管理持久化（例如在他们自己的设置中）

### 风险：单例全局状态
**影响**：在整个应用中共享状态
**缓解**：这对于触觉反馈是可接受的（本质上是全局的）

### 权衡：简单性 vs 功能
**决策**：v1 最大程度简化
- ✅ 基础触觉样式
- ✅ 运行时启用/禁用
- ✅ 仅单例
- ❌ 持久化（调用方的责任）
- ❌ 基于实例的使用
- ❌ 语义化方法
- ❌ 自定义模式

## 迁移计划

### 阶段 1：实施（本次变更）
1. 在 Components/Utils 中创建 HapticHelper
2. 实现核心功能
3. 添加便捷方法
4. 编写 API 文档

### 阶段 2：SwiftUILab 迁移（未来）
1. 在 SwiftUILab 中导入 Components 库
2. 用 Components 版本替换本地 HapticHelper
3. 如需持久化，在 AppSettings 层包装
4. 更新使用方式为单例模式

### 回滚
如果发现问题：
- 保持 SwiftUILab 使用其本地版本
- 将 Components 版本标记为实验性
- 收集反馈并迭代

## 待解决问题

1. **是否应该添加 NotificationFeedback 和 SelectionFeedback 支持？**
   - NotificationFeedback：.success, .warning, .error
   - SelectionFeedback：用于选择变更
   - 决策：先从 Impact 开始，如有需要再添加其他

2. **是否应该支持触觉模式（序列）？**
   - 示例："轻触-轻触-暂停-轻触" 用于特定操作
   - 决策：初始版本不支持，根据使用情况评估

3. **是否应该与 Alert/Toast 系统集成？**
   - 示例：在错误 toast 时自动触发触觉反馈
   - 决策：初期不集成，由用户显式调用
