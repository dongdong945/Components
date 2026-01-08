//
//  AppState.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

// MARK: - App State

/// App 状态枚举
///
/// 用于管理应用的全局状态流转
public enum AppState: Sendable, CaseIterable, Identifiable {
    /// 启动页
    case splash
    /// 引导页
    case onboarding
    /// 主界面
    case main

    public var id: Self { self }
}

// MARK: - Environment Key

/// AppState 环境键
private struct AppStateKey: EnvironmentKey {
    static let defaultValue: Binding<AppState> = .constant(.splash)
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    /// App 状态绑定
    public var appState: Binding<AppState> {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
