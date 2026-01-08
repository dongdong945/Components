//
//  AppLogger.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import Foundation
import OSLog

// MARK: - App Logger

/// 应用日志工具
///
/// 基于 OSLog 的统一日志封装，支持多种日志级别
public final class AppLogger: Sendable {
    // MARK: - Properties

    /// OSLog 日志实例
    private let logger: Logger

    // MARK: - Initialization

    /// 初始化日志工具
    /// - Parameters:
    ///   - subsystem: 子系统标识，默认使用应用名称
    ///   - category: 日志分类
    public init(subsystem: String = Bundle.main.appDisplayName, category: String) {
        logger = Logger(subsystem: subsystem, category: category)
    }

    // MARK: - Public Methods

    /// 记录普通信息日志
    /// - Parameter message: 日志消息
    public func info(_ message: String) {
        logger.info("ℹ️ \(message)")
    }

    /// 记录警告日志
    /// - Parameter message: 日志消息
    public func warning(_ message: String) {
        logger.warning("⚠️ \(message)")
    }

    /// 记录调试日志
    /// - Parameter message: 日志消息
    public func debug(_ message: String) {
        logger.debug("🐛 \(message)")
    }

    /// 记录错误日志
    /// - Parameter message: 日志消息
    public func error(_ message: String) {
        logger.error("❌ \(message)")
    }

    /// 记录严重错误日志
    /// - Parameter message: 日志消息
    public func critical(_ message: String) {
        logger.critical("🔥 \(message)")
    }
}
