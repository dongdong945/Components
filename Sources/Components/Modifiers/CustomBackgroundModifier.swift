//
//  CustomBackgroundModifier.swift
//  Components
//
//  Created by DongDong on 2025-12-29.
//

import SwiftUI

/// 自定义背景修饰符
/// 提供图片背景 + 颜色填充的组合背景效果
public struct CustomBackgroundModifier: ViewModifier {
    /// 背景图片资源
    let imageResource: ImageResource
    /// 填充颜色
    let color: Color

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                color
                    .ignoresSafeArea()
                    .overlay(alignment: .top) {
                        Image(imageResource)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea()
                    }
            }
    }
}
