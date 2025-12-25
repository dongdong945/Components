import SwiftUI

// MARK: - View Extensions

extension View {
    /// 监听设备摇动事件
    /// - Parameter action: 摇动时执行的动作
    /// - Returns: 修改后的视图
    public func onShake(perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
            action()
        }
    }

    /// 将视图渲染为 UIImage
    /// - Returns: 渲染后的图片，如果失败返回 nil
    @MainActor
    public func asImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

// MARK: - UIDevice Extensions

extension UIDevice {
    /// 设备摇动通知
    public static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

// MARK: - UIWindow Extensions

extension UIWindow {
    /// 监听设备摇动动作
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with _: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
