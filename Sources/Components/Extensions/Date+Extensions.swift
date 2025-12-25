import Foundation

// MARK: - Date Extensions

extension Date {
    /// 从字符串和格式创建日期
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - format: 日期格式
    public init?(from string: String, format: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }

    /// 将日期转换为指定格式的字符串
    /// - Parameter format: 日期格式
    /// - Returns: 格式化后的日期字符串
    public func string(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// 判断当前日期是否是今天
    public var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
