import SwiftUI

// MARK: - Font Extensions

extension Font {
    /// 创建 Lexend Deca 字体
    /// - Parameters:
    ///   - weight: 字体粗细
    ///   - size: 字体大小
    /// - Returns: Font
    public static func lexendDeca(_ weight: UIFont.Weight = .regular, fontSize size: CGFloat) -> Font {
        Font(UIFont.lexendDeca(weight, fontSize: size))
    }

    /// 创建 New York 字体
    /// - Parameters:
    ///   - weight: 字体粗细
    ///   - size: 字体大小
    /// - Returns: Font
    public static func newYork(_ weight: UIFont.Weight = .regular, fontSize size: CGFloat) -> Font {
        Font(UIFont.newYork(weight, fontSize: size))
    }

    /// 创建 SF Pro 字体
    /// - Parameters:
    ///   - weight: 字体粗细
    ///   - size: 字体大小
    /// - Returns: Font
    public static func sfPro(_ weight: UIFont.Weight = .regular, fontSize size: CGFloat) -> Font {
        Font(UIFont.sfPro(weight, fontSize: size))
    }
}
