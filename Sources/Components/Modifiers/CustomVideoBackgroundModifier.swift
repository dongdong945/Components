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

    public init(videoName: String, fillColor: Color = .black) {
        self.videoName = videoName
        self.fillColor = fillColor
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                GeometryReader { geometry in
                    fillColor
                        .ignoresSafeArea()
                        .overlay {
                            VideoPlayerView(videoName: videoName)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .ignoresSafeArea()
                        }
                }
                .ignoresSafeArea()
            }
    }
}

// MARK: - Private Player Wrapper

private struct VideoPlayerView: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> PlayerView {
        let playerView = PlayerView()

        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            return playerView
        }

        let player = AVPlayer(url: url)
        playerView.playerLayer.player = player
        playerView.playerLayer.videoGravity = .resizeAspect
        playerView.alpha = 0

        context.coordinator.player = player
        context.coordinator.playerView = playerView
        context.coordinator.observePlayerReadiness()

        return playerView
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        // playerView 的 layerClass 是 AVPlayerLayer，frame 会自动等于 view.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject {
        var player: AVPlayer?
        var playerView: PlayerView?
        private var observer: NSKeyValueObservation?

        /// 监听视频准备状态并启动播放
        func observePlayerReadiness() {
            guard let player else { return }

            observer = player.observe(\.currentItem?.status, options: [.new]) { [weak self] player, _ in
                guard let self,
                      let playerView,
                      let item = player.currentItem,
                      item.status == .readyToPlay
                else { return }

                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        playerView.alpha = 1.0
                    }
                    player.play()
                }

                observer?.invalidate()
                observer = nil
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

/// UIView 容器，主 layer 为 AVPlayerLayer
private final class PlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}
