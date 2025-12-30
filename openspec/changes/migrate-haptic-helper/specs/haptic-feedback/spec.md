# 规范：触觉反馈

## ADDED Requirements

### Requirement: 核心触觉反馈支持
系统 SHALL 提供支持所有 UIKit 冲击反馈样式的触觉反馈 helper，并具备运行时启用/禁用控制。

#### Scenario: 触发特定样式的触觉反馈
- **WHEN** 用户调用 `impact(style: .medium)`
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发中等强度冲击触觉反馈

#### Scenario: 触觉反馈已禁用
- **WHEN** 用户调用任何触觉方法
- **AND** `isEnabled` 为 `false`
- **THEN** 系统不触发任何触觉反馈

#### Scenario: 支持全部五种冲击样式
- **WHEN** 用户调用 `impact(style:)` 并传入 `.light`, `.medium`, `.soft`, `.heavy`, 或 `.rigid` 中的任一样式
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发相应的触觉反馈样式

### Requirement: 运行时配置
系统 SHALL 提供仅运行时的启用/禁用控制，无持久化。

#### Scenario: 默认启用状态
- **WHEN** 应用启动时
- **THEN** `HapticHelper.shared.isEnabled` 为 `true`

#### Scenario: 在运行时禁用触觉反馈
- **WHEN** 用户设置 `isEnabled = false`
- **THEN** 所有后续触觉调用都被忽略，直到重新启用

#### Scenario: 在运行时启用触觉反馈
- **WHEN** 用户设置 `isEnabled = true`
- **THEN** 所有后续触觉调用都触发反馈

#### Scenario: 无状态持久化
- **WHEN** 应用重启时
- **THEN** `isEnabled` 始终重置为 `true`（默认值）

### Requirement: 样式便捷方法
系统 SHALL 提供与 UIKit 冲击反馈样式 1:1 映射的便捷方法。

#### Scenario: 轻触觉反馈
- **WHEN** 用户调用 `light()`
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发 `.light` 冲击反馈

#### Scenario: 中等触觉反馈
- **WHEN** 用户调用 `medium()`
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发 `.medium` 冲击反馈

#### Scenario: 柔和触觉反馈
- **WHEN** 用户调用 `soft()`
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发 `.soft` 冲击反馈

#### Scenario: 重触觉反馈
- **WHEN** 用户调用 `heavy()`
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发 `.heavy` 冲击反馈

#### Scenario: 刚性触觉反馈
- **WHEN** 用户调用 `rigid()`
- **AND** `isEnabled` 为 `true`
- **THEN** 系统触发 `.rigid` 冲击反馈

### Requirement: 单例模式
系统 SHALL 提供仅单例访问模式。

#### Scenario: 访问共享单例
- **WHEN** 用户访问 `HapticHelper.shared`
- **THEN** 系统返回共享单例实例

#### Scenario: 私有初始化
- **WHEN** 用户尝试使用 `HapticHelper()` 创建实例
- **THEN** 编译器阻止初始化（private init）

### Requirement: SwiftUI 集成
系统 SHALL 与 SwiftUI 观察模式兼容。

#### Scenario: 可观察状态变更
- **WHEN** 用户更改 `isEnabled` 属性
- **THEN** 任何观察该 helper 的 SwiftUI 视图都相应更新

### Requirement: 主线程安全
系统 SHALL 确保所有触觉操作在主线程上执行。

#### Scenario: MainActor 隔离
- **WHEN** HapticHelper 标记为 `@MainActor`
- **THEN** 所有属性和方法都隔离到主 actor
- **AND** 编译器强制主线程使用

### Requirement: 零外部依赖
系统 SHALL 独立运行，无需外部配置对象或持久化。

#### Scenario: 独立单例
- **WHEN** 用户访问 `HapticHelper.shared`
- **THEN** 系统立即工作，无需任何设置
- **AND** 不需要任何外部依赖

#### Scenario: 无持久化层
- **WHEN** 配置发生变更
- **THEN** 系统不持久化到 UserDefaults 或任何存储
- **AND** 状态仅存在于内存中
