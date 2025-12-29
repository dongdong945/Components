//
//  PresentationRootView.swift
//  Components
//
//  Created by DongDong on 12/26/25.
//

import SwiftUI

/// Presentation 根视图（封装递归构建逻辑）
///
/// 在 ContentView 上方叠加一个透明层，用于承载根级别的 Sheet 和 FullScreenCover
public struct PresentationRootView<ViewMapper: PresentationViewMapping>: View {
    /// Presentation 助手
    @Bindable
    public var helper: PresentationHelper

    /// 视图映射器
    public let viewMapper: ViewMapper

    public init(helper: PresentationHelper, viewMapper: ViewMapper) {
        self.helper = helper
        self.viewMapper = viewMapper
    }

    public var body: some View {
        Color.clear
            .sheet(item: makeBinding(at: 0, for: .sheet) as Binding<SheetWrapper?>) { wrapper in
                presentationView(for: wrapper.item, at: 0)
            }
            .fullScreenCover(item: makeBinding(at: 0, for: .fullScreenCover) as Binding<CoverWrapper?>) { wrapper in
                presentationView(for: wrapper.item, at: 0)
            }
    }

    // MARK: - Private Methods

    /// 递归构建 Presentation 视图
    ///
    /// 为指定索引的 PresentationItem 创建对应的视图，并附加下一层级的 sheet/fullScreenCover 支持
    /// - Parameters:
    ///   - item: 要展示的 Presentation 数据项
    ///   - index: 当前 Presentation 在堆栈中的索引位置
    /// - Returns: 包装后的视图，支持递归嵌套展示
    private func presentationView(for item: PresentationItem, at index: Int) -> AnyView {
        let contentView = viewMapper.view(for: item.viewType)
        let nextIndex = index + 1

        let result = contentView
            .sheet(item: makeBinding(at: nextIndex, for: .sheet) as Binding<SheetWrapper?>) { wrapper in
                presentationView(for: wrapper.item, at: nextIndex)
            }
            .fullScreenCover(item: makeBinding(at: nextIndex, for: .fullScreenCover) as Binding<CoverWrapper?>) { wrapper in
                presentationView(for: wrapper.item, at: nextIndex)
            }

        return AnyView(result)
    }

    /// 统一的 Binding 生成器
    ///
    /// 为指定索引和展示样式创建双向绑定，支持泛型 Wrapper 类型
    /// - Parameters:
    ///   - index: Presentation 堆栈中的索引位置
    ///   - style: 展示样式（sheet 或 fullScreenCover）
    /// - Returns: 绑定到 PresentationHelper 的可选 Wrapper 对象
    private func makeBinding<Wrapper: PresentationWrapping>(
        at index: Int,
        for style: PresentationStyle
    ) -> Binding<Wrapper?> {
        Binding(
            get: {
                guard let item = helper.item(at: index),
                      item.style == style else { return nil }
                return Wrapper(item: item)
            },
            set: { newValue in
                if newValue == nil {
                    if index == 0 {
                        helper.dismissAll()
                    } else {
                        helper.dismissFrom(index: index - 1)
                    }
                }
            }
        )
    }
}
