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

private struct CustomImageBackgroundHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct CustomImageBackgroundLayer<BackgroundContent: View>: View {
    let fillColor: Color
    let style: CustomImageBackgroundStyle
    let scrollOffset: CGFloat
    let backgroundContent: BackgroundContent

    @State
    private var measuredHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let layout = CustomImageBackgroundLayout.make(style: style, scrollOffset: scrollOffset)

            fillColor
                .overlay(alignment: .top) {
                    visibleBackground(width: geometry.size.width, extraHeight: layout.extraHeight)
                        .offset(y: layout.yOffset)
                }
                .overlay(alignment: .top) {
                    measuredBackground(width: geometry.size.width)
                        .hidden()
                        .allowsHitTesting(false)
                }
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func visibleBackground(width: CGFloat, extraHeight: CGFloat) -> some View {
        let height = max(measuredHeight + extraHeight, 0)

        if measuredHeight > 0 {
            backgroundContent
                .frame(width: width, height: height, alignment: .top)
                .clipped()
        } else {
            backgroundContent
                .frame(width: width, alignment: .top)
        }
    }

    private func measuredBackground(width: CGFloat) -> some View {
        backgroundContent
            .frame(width: width, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: CustomImageBackgroundHeightPreferenceKey.self,
                        value: geometry.size.height
                    )
                }
            }
            .onPreferenceChange(CustomImageBackgroundHeightPreferenceKey.self) { newValue in
                measuredHeight = newValue
            }
    }
}

struct CustomImageBackgroundContentModifier<BackgroundContent: View>: ViewModifier {
    let fillColor: Color
    let style: CustomImageBackgroundStyle
    let backgroundContent: BackgroundContent

    @State
    private var scrollOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                CustomImageBackgroundLayer(
                    fillColor: fillColor,
                    style: style,
                    scrollOffset: scrollOffset,
                    backgroundContent: backgroundContent
                )
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            } action: { _, newValue in
                scrollOffset = newValue
            }
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
        content.modifier(
            CustomImageBackgroundContentModifier(
                fillColor: fillColor,
                style: style,
                backgroundContent: Image(image)
                    .resizable()
                    .scaledToFill()
            )
        )
    }
}
