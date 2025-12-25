import Foundation

// MARK: - Bundle Extensions

extension Bundle {
    /// 获取应用版本号
    public var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// 获取构建版本号
    public var buildVersion: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// 获取应用显示名称
    public var appDisplayName: String {
        infoDictionary?["CFBundleDisplayName"] as? String ??
            infoDictionary?["CFBundleName"] as? String ?? "App"
    }
}
