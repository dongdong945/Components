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

    public init(image: ImageResource, fillColor: Color = .black) {
        self.image = image
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
                            Image(image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .ignoresSafeArea()
                        }
                }
                .ignoresSafeArea()
            }
    }
}
