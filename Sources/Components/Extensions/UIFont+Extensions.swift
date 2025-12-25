import UIKit

// MARK: - UIFont.Weight Extensions

extension UIFont.Weight {
    /// 将 UIFont.Weight 转换为字体名称后缀字符串
    public var fontNameSuffix: String {
        switch self {
        case .ultraLight: return "UltraLight"
        case .thin: return "Thin"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "Semibold"
        case .bold: return "Bold"
        case .heavy: return "Heavy"
        case .black: return "Black"
        default: return "Regular"
        }
    }
}

// MARK: - UIFont Extensions

extension UIFont {
    /// 检查字体是否可用
    /// - Parameters:
    ///   - name: 字体名称
    ///   - size: 字体大小
    /// - Returns: 是否可用
    public static func isFontAvailable(_ name: String, size: CGFloat = 16) -> Bool {
        guard let font = UIFont(name: name, size: size) else {
            return false
        }
        return font.fontName == name
    }

    /// 创建自定义字体，如果不可用则返回系统字体
    /// - Parameters:
    ///   - name: 字体名称
    ///   - size: 字体大小
    ///   - weight: 字体粗细
    /// - Returns: UIFont
    public static func customFont(_ name: String, size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if isFontAvailable(name, size: size) {
            return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
        } else {
            #if DEBUG
                assertionFailure("字体 '\(name)' 不可用，请检查字体文件是否正确添加到项目中")
            #endif
            return .systemFont(ofSize: size, weight: weight)
        }
    }

    /// Lexend Deca 字体系列
    /// - Parameters:
    ///   - weight: 字体粗细
    ///   - size: 字体大小
    /// - Returns: UIFont
    public static func lexendDeca(_ weight: UIFont.Weight = .regular, fontSize size: CGFloat) -> UIFont {
        let fontNameSuffix = weight == .semibold ? "SemiBold" : weight.fontNameSuffix
        let fontName = "LexendDeca-\(fontNameSuffix)"
        return customFont(fontName, size: size, weight: weight)
    }

    /// New York 字体系列
    /// - Parameters:
    ///   - weight: 字体粗细
    ///   - size: 字体大小
    /// - Returns: UIFont
    public static func newYork(_ weight: UIFont.Weight = .regular, fontSize size: CGFloat) -> UIFont {
        let fontName = "NewYork-\(weight.fontNameSuffix)"
        return customFont(fontName, size: size, weight: weight)
    }

    /// SF Pro 字体系列
    /// - Parameters:
    ///   - weight: 字体粗细
    ///   - size: 字体大小
    /// - Returns: UIFont
    public static func sfPro(_ weight: UIFont.Weight = .regular, fontSize size: CGFloat) -> UIFont {
        let fontName = "SFPro-\(weight.fontNameSuffix)"
        return customFont(fontName, size: size, weight: weight)
    }
}
