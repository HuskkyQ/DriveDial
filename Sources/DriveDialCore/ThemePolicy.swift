import Foundation

public enum ThemeChangeResult: Equatable, Sendable {
    case updated(ClusterTheme)
    case blocked(String)
}

public enum ThemePolicy {
    /// v6 locks the theme from the parked flag, not from the highlighted PRND letter.
    public static func blockReason(parked: Bool) -> String? {
        parked ? nil : Copy.themeBlockedWhileMoving
    }

    public static func change(to theme: ClusterTheme, parked: Bool) -> ThemeChangeResult {
        if let reason = blockReason(parked: parked) {
            return .blocked(reason)
        }
        return .updated(theme)
    }
}

public enum ThemePreference {
    public static let defaultsKey = "drivedial.theme"

    public static func load(from defaults: UserDefaults) -> ClusterTheme {
        guard
            let raw = defaults.string(forKey: defaultsKey),
            let theme = ClusterTheme(rawValue: raw)
        else {
            return .digital
        }
        return theme
    }

    public static func save(_ theme: ClusterTheme, to defaults: UserDefaults) {
        defaults.set(theme.rawValue, forKey: defaultsKey)
    }
}
