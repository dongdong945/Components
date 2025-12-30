# 变更：迁移并优化 HapticHelper

## 为什么

目前 HapticHelper 仅存在于 SwiftUILab 项目中，与 AppSettings 紧密耦合。为了使其成为 Components 库中的可复用组件，我们需要迁移并简化其设计，以实现更好的独立性和易用性。

## 变更内容

- 将 HapticHelper 从 SwiftUILab 迁移到 Components 库
- 移除所有外部依赖（AppSettings、UserDefaults）
- 简化为单例模式（HapticHelper.shared）
- 提供仅运行时的 `isEnabled` 控制（默认：true，无持久化）
- 支持全部 5 种 UIKit 触觉反馈样式（.light, .medium, .soft, .heavy, .rigid）
- 提供基于样式的便捷方法（light(), medium(), soft(), heavy(), rigid()）
- 放置在 Sources/Components/Utils/ 目录，遵循 Components 项目结构

## 影响范围

### 受影响的规范
- 新增能力：`haptic-feedback` - 核心触觉反馈管理系统

### 受影响的代码
- Components 中的新文件：
  - `Sources/Components/Utils/HapticHelper.swift` - 主 Helper 类（单例）
- 潜在使用场景：
  - Alert 系统（确认/错误反馈）
  - Toast 系统（通知反馈）
  - 自定义 UI 组件（按钮点击、手势）

### 迁移影响
- SwiftUILab 项目可以从 Components 库导入
- 比原始版本更简单的 API（无 AppSettings 依赖）
