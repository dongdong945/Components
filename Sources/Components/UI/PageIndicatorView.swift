//
//  PageIndicatorView.swift
//  Components
//
//  Created by DongDong on 01/08/26.
//
import SwiftUI

/// 简单页码指示器：当前页高亮，其余为圆点
public struct PageIndicatorView: View {
    public let totalPages: Int
    public let currentPage: Int
    public let selectedColor: Color
    public let normalColor: Color

    public init(
        totalPages: Int,
        currentPage: Int,
        selectedColor: Color = .accentColor,
        normalColor: Color = Color.white.opacity(0.08)
    ) {
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.selectedColor = selectedColor
        self.normalColor = normalColor
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< totalPages, id: \.self) { index in
                if currentPage == index {
                    selectedColor
                        .frame(width: 12, height: 8)
                        .clipShape(Capsule())
                } else {
                    normalColor
                        .frame(width: 8, height: 8)
                        .clipShape(Circle())
                }
            }
        }
    }
}
