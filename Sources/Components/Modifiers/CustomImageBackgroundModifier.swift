//
//  CustomImageBackgroundModifier.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

/// 图片背景修饰符：铺满画布的图片 + 填充色
public struct CustomImageBackgroundModifier: ViewModifier {
    /// 背景图片资源
    public let image: ImageResource
    /// 背景填充色
    public let fillColor: Color
    /// 内容缩放模式
    public let contentMode: ContentMode
    /// 对齐方式
    public let alignment: Alignment

    public init(
        image: ImageResource,
        fillColor: Color = .black,
        contentMode: ContentMode = .fit,
        alignment: Alignment = .top
    ) {
        self.image = image
        self.fillColor = fillColor
        self.contentMode = contentMode
        self.alignment = alignment
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                GeometryReader { geometry in
                    fillColor
                        .ignoresSafeArea()
                        .overlay {
                            Image(image)
                                .resizable()
                                .aspectRatio(contentMode: contentMode)
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height,
                                    alignment: alignment
                                )
                                .ignoresSafeArea()
                        }
                }
                .ignoresSafeArea()
            }
    }
}
