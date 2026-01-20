//
//  View+Extensions.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import AVFoundation
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

    /// 为视图添加渐变前景色
    public func gradientForeground(
        stops: [Gradient.Stop] = [
            Gradient.Stop(color: Color.white.opacity(0.5), location: 0.00),
            Gradient.Stop(color: Color.white, location: 1.00)
        ],
        startPoint: UnitPoint = UnitPoint(x: 0, y: 0.5),
        endPoint: UnitPoint = UnitPoint(x: 1, y: 0.5)
    ) -> some View {
        modifier(GradientForegroundModifier(stops: stops, startPoint: startPoint, endPoint: endPoint))
    }

    /// 添加自定义图片背景
    /// - Parameters:
    ///   - image: 背景图片资源
    ///   - fillColor: 填充颜色
    ///   - contentMode: 内容缩放模式（.fit 或 .fill）
    ///   - alignment: 对齐方式（.top, .center, .bottom 等）
    public func customImageBackground(
        image: ImageResource,
        fillColor: Color = .black,
        contentMode: ContentMode = .fit,
        alignment: Alignment = .top
    ) -> some View {
        modifier(CustomImageBackgroundModifier(
            image: image,
            fillColor: fillColor,
            contentMode: contentMode,
            alignment: alignment
        ))
    }

    /// 添加自定义视频背景
    /// - Parameters:
    ///   - video: 视频文件名（不含扩展名）
    ///   - fillColor: 填充颜色
    ///   - contentMode: 内容缩放模式（.fit 或 .fill）
    ///   - alignment: 对齐方式（.top, .center, .bottom 等）
    public func customVideoBackground(
        video: String,
        fillColor: Color = .black,
        contentMode: ContentMode = .fit,
        alignment: Alignment = .top
    ) -> some View {
        modifier(CustomVideoBackgroundModifier(
            videoName: video,
            fillColor: fillColor,
            contentMode: contentMode,
            alignment: alignment
        ))
    }
}
