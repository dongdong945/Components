import UIKit

// MARK: - UIImage Extensions

extension UIImage {
    /// 水平翻转图片
    /// - Returns: 翻转后的图片，如果失败返回 nil
    public func horizontallyFlipped() -> UIImage? {
        guard let cgImage else { return nil }

        return UIImage(cgImage: cgImage, scale: scale, orientation: .leftMirrored)
    }
}
