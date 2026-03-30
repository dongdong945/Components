//
//  CustomImageBackgroundModifier.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

public enum CustomImageBackgroundStyle: Sendable {
    case fixed
    case scroll
    case stickyTop
    case stretchyTop
}

struct CustomImageBackgroundLayout: Equatable {
    let yOffset: CGFloat
    let extraHeight: CGFloat

    static func make(style: CustomImageBackgroundStyle, scrollOffset: CGFloat) -> Self {
        switch style {
        case .fixed:
            .init(yOffset: 0, extraHeight: 0)
        case .scroll:
            .init(yOffset: -scrollOffset, extraHeight: 0)
        case .stickyTop:
            .init(yOffset: min(-scrollOffset, 0), extraHeight: 0)
        case .stretchyTop:
            .init(
                yOffset: min(-scrollOffset, 0),
                extraHeight: max(-scrollOffset, 0)
            )
        }
    }
}

struct CustomImageBackgroundLayer: View {
    let image: ImageResource
    let fillColor: Color
    let style: CustomImageBackgroundStyle
    let scrollOffset: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let layout = CustomImageBackgroundLayout.make(style: style, scrollOffset: scrollOffset)
            let baseHeight = resolvedImageHeight(for: geometry.size.width)

            fillColor
                .overlay(alignment: .top) {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: max(baseHeight + layout.extraHeight, 0),
                            alignment: .top
                        )
                        .clipped()
                        .offset(y: layout.yOffset)
                }
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    private func resolvedImageHeight(for width: CGFloat) -> CGFloat {
        let imageSize = UIImage(resource: image).size
        let safeWidth = max(imageSize.width, 1)
        return width * (imageSize.height / safeWidth)
    }
}

/// 图片背景修饰符：宽度填充、顶部对齐，并支持滚动行为样式
public struct CustomImageBackgroundModifier: ViewModifier {
    /// 背景图片资源
    public let image: ImageResource
    /// 背景填充色
    public let fillColor: Color
    /// 背景滚动样式
    public let style: CustomImageBackgroundStyle

    @State
    private var scrollOffset: CGFloat = 0

    public init(
        image: ImageResource,
        fillColor: Color = .black,
        style: CustomImageBackgroundStyle = .fixed
    ) {
        self.image = image
        self.fillColor = fillColor
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                CustomImageBackgroundLayer(
                    image: image,
                    fillColor: fillColor,
                    style: style,
                    scrollOffset: scrollOffset
                )
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            } action: { _, newValue in
                scrollOffset = newValue
            }
    }
}
