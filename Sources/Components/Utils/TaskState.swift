//
//  TaskState.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import Foundation

// MARK: - Task State

/// 任务状态枚举
///
/// 用于表示异步任务的执行状态
public enum TaskState<Event>: Equatable, Sendable where Event: Equatable, Event: Sendable {
    /// 空闲状态
    case idle
    /// 加载中状态
    case loading
    /// 完成状态
    case completed(Event)

    /// 是否正在加载
    public var isLoading: Bool {
        self == .loading
    }

    /// 相等性判断
    public static func == (lhs: TaskState<Event>, rhs: TaskState<Event>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.completed(let lhsEvent), .completed(let rhsEvent)):
            return lhsEvent == rhsEvent
        default:
            return false
        }
    }
}
