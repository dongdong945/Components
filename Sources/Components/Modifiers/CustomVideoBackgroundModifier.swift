//
//  CustomVideoBackgroundModifier.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import AVFoundation
import SwiftUI
import UIKit

/// 视频背景修饰符：铺满画布的本地 mp4 视频 + 填充色
public struct CustomVideoBackgroundModifier: ViewModifier {
    /// 视频文件名（不含扩展名）
    public let videoName: String
    /// 背景填充色
    public let fillColor: Color
    /// 内容缩放模式
    public let contentMode: ContentMode
    /// 对齐方式
    public let alignment: Alignment

    public init(
        videoName: String,
        fillColor: Color = .black,
        contentMode: ContentMode = .fit,
        alignment: Alignment = .top
    ) {
        self.videoName = videoName
        self.fillColor = fillColor
        self.contentMode = contentMode
        self.alignment = alignment
    }

    public func body(content: Content) -> some View {
        let videoGravity = contentModeToVideoGravity(contentMode)

        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                GeometryReader { geometry in
                    fillColor
                        .ignoresSafeArea()
                        .overlay {
                            VideoPlayerView(videoName: videoName, videoGravity: videoGravity, alignment: alignment)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .ignoresSafeArea()
                        }
                }
                .ignoresSafeArea()
            }
    }

    /// 将 SwiftUI ContentMode 转换为 AVLayerVideoGravity
    private func contentModeToVideoGravity(_ mode: ContentMode) -> AVLayerVideoGravity {
        switch mode {
        case .fit:
            return .resizeAspect
        case .fill:
            return .resizeAspectFill
        }
    }
}

// MARK: - Private Player Wrapper

private struct VideoPlayerView: UIViewRepresentable {
    let videoName: String
    let videoGravity: AVLayerVideoGravity
    let alignment: Alignment

    func makeUIView(context: Context) -> PlayerView {
        let playerView = PlayerView()
        playerView.videoGravity = videoGravity
        playerView.videoAlignment = alignment

        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            return playerView
        }

        let player = AVPlayer(url: url)
        playerView.playerLayer.player = player
        playerView.playerLayer.videoGravity = .resize // 使用 resize，手动控制 layer frame
        playerView.alpha = 0

        context.coordinator.player = player
        context.coordinator.playerView = playerView
        context.coordinator.observePlayerReadiness()

        return playerView
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        // 更新对齐方式（如果需要支持动态修改）
        uiView.videoGravity = videoGravity
        uiView.videoAlignment = alignment
        uiView.updatePlayerLayerFrame()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, @unchecked Sendable {
        var player: AVPlayer?
        var playerView: PlayerView?
        private var observer: NSKeyValueObservation?

        /// 监听视频准备状态并启动播放
        func observePlayerReadiness() {
            guard let player else { return }

            observer = player.observe(\.currentItem?.status, options: [.new]) { [weak self] player, _ in
                guard let self,
                      let item = player.currentItem,
                      item.status == .readyToPlay
                else { return }

                // 提取需要的引用，避免在闭包中捕获 self
                guard let playerView = self.playerView else { return }

                // 切换到主线程执行 UI 操作
                DispatchQueue.main.async {
                    // 视频准备好后，更新 layer frame（确保使用正确的视频尺寸）
                    playerView.updatePlayerLayerFrame()

                    UIView.animate(withDuration: 0.3) {
                        playerView.alpha = 1.0
                    }
                    player.play()
                }

                self.observer?.invalidate()
                self.observer = nil
            }
        }

        deinit {
            observer?.invalidate()
            player?.pause()
            player = nil
            playerView = nil
        }
    }
}

/// UIView 容器，包含 AVPlayerLayer sublayer
private final class PlayerView: UIView {
    let playerLayer = AVPlayerLayer()
    var videoGravity: AVLayerVideoGravity = .resizeAspect
    var videoAlignment: Alignment = .center

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlayerLayerFrame()
    }

    /// 根据视频尺寸和对齐方式更新 playerLayer 的 frame
    func updatePlayerLayerFrame() {
        guard let videoSize = playerLayer.player?.currentItem?.presentationSize,
              videoSize.width > 0, videoSize.height > 0 else {
            // 视频尚未加载，使用全屏
            playerLayer.frame = bounds
            return
        }

        let containerSize = bounds.size
        let videoAspectRatio = videoSize.width / videoSize.height
        let containerAspectRatio = containerSize.width / containerSize.height

        var layerFrame: CGRect

        switch videoGravity {
        case .resizeAspect:
            // 保持宽高比，完整显示视频
            if videoAspectRatio > containerAspectRatio {
                // 视频更宽，以宽度为准
                let height = containerSize.width / videoAspectRatio
                layerFrame = CGRect(x: 0, y: 0, width: containerSize.width, height: height)
            } else {
                // 视频更高，以高度为准
                let width = containerSize.height * videoAspectRatio
                layerFrame = CGRect(x: 0, y: 0, width: width, height: containerSize.height)
            }

        case .resizeAspectFill:
            // 保持宽高比，填充整个容器
            if videoAspectRatio > containerAspectRatio {
                // 视频更宽，以高度为准
                let width = containerSize.height * videoAspectRatio
                layerFrame = CGRect(x: 0, y: 0, width: width, height: containerSize.height)
            } else {
                // 视频更高，以宽度为准
                let height = containerSize.width / videoAspectRatio
                layerFrame = CGRect(x: 0, y: 0, width: containerSize.width, height: height)
            }

        default:
            // .resize - 拉伸填充
            layerFrame = bounds
        }

        // 根据 alignment 调整位置
        layerFrame = alignFrame(layerFrame, in: bounds, alignment: videoAlignment)
        playerLayer.frame = layerFrame
    }

    /// 根据对齐方式调整 frame 位置
    private func alignFrame(_ frame: CGRect, in container: CGRect, alignment: Alignment) -> CGRect {
        var alignedFrame = frame

        // 水平对齐
        switch alignment.horizontal {
        case .leading:
            alignedFrame.origin.x = 0
        case .trailing:
            alignedFrame.origin.x = container.width - frame.width
        default: // .center
            alignedFrame.origin.x = (container.width - frame.width) / 2
        }

        // 垂直对齐
        switch alignment.vertical {
        case .top:
            alignedFrame.origin.y = 0
        case .bottom:
            alignedFrame.origin.y = container.height - frame.height
        default: // .center
            alignedFrame.origin.y = (container.height - frame.height) / 2
        }

        return alignedFrame
    }
}
