//
//  GradientForegroundModifier.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

/// 渐变前景色修饰符
/// 为视图的前景色应用线性渐变效果
public struct GradientForegroundModifier: ViewModifier {
    /// 渐变色停点数组
    var stops: [Gradient.Stop]
    /// 渐变起始点
    var startPoint: UnitPoint
    /// 渐变结束点
    var endPoint: UnitPoint

    public func body(content: Content) -> some View {
        content.foregroundStyle(
            LinearGradient(
                stops: stops,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }
}
