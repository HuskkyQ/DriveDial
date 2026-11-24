import Foundation

public struct RGB: Equatable, Sendable {
    public var r: Double
    public var g: Double
    public var b: Double
    public var a: Double

    public init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

/// Black field, white type, green for calm / regen, orange for attention.
/// Exact v6 CSS values were not available on the build machine; see DESIGN.md.
public enum DrivePalette {
    public static let background = RGB(r: 5.0 / 255, g: 7.0 / 255, b: 12.0 / 255)
    public static let primary = RGB(r: 243.0 / 255, g: 246.0 / 255, b: 250.0 / 255)
    public static let secondary = RGB(r: 154.0 / 255, g: 164.0 / 255, b: 178.0 / 255)
    public static let tertiary = RGB(r: 110.0 / 255, g: 119.0 / 255, b: 133.0 / 255)
    public static let hairline = RGB(r: 1, g: 1, b: 1, a: 0.08)
    public static let track = RGB(r: 196.0 / 255, g: 206.0 / 255, b: 218.0 / 255, a: 0.42)
    public static let ok = RGB(r: 62.0 / 255, g: 224.0 / 255, b: 164.0 / 255)
    public static let caution = RGB(r: 1, g: 176.0 / 255, b: 32.0 / 255)
    public static let danger = RGB(r: 1, g: 90.0 / 255, b: 90.0 / 255)
    public static let cyan = RGB(r: 90.0 / 255, g: 173.0 / 255, b: 1)
}

public enum ReadoutTone: String, Sendable {
    case neutral
    case ok
    case caution
}

public enum ReadoutToneRule {
    public static let lowBatteryPercent = 15.0
    public static let tireLowBar = 2.2
    public static let tireHighBar = 3.0

    public static func battery(_ percent: Double) -> ReadoutTone {
        percent < lowBatteryPercent ? .caution : .neutral
    }

    public static func tire(bar: Double) -> ReadoutTone {
        (bar < tireLowBar || bar > tireHighBar) ? .caution : .ok
    }

    public static func power(kilowatts: Double) -> ReadoutTone {
        if kilowatts <= -1 { return .ok }
        if kilowatts >= 1 { return .caution }
        return .neutral
    }

    public static func gear(_ gear: Gear) -> ReadoutTone {
        switch gear {
        case .park, .neutral: return .neutral
        case .drive: return .ok
        case .reverse: return .caution
        }
    }
}

public enum ReadoutScale {
    public static let speedMaxKmh = 160.0
    public static let powerLimitKw = 80.0

    public static func speedFraction(_ kmh: Double) -> Double {
        min(1, max(0, kmh / speedMaxKmh))
    }

    public static func powerFraction(_ kilowatts: Double) -> Double {
        let clamped = min(powerLimitKw, max(-powerLimitKw, kilowatts))
        return (clamped + powerLimitKw) / (powerLimitKw * 2)
    }
}
