//
//  UIWindow+Extensions.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import UIKit

// MARK: - UIWindow Extensions

extension UIWindow {
    /// 检测设备摇动事件
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
