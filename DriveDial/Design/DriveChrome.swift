import SwiftUI
import UIKit
import DriveDialCore

extension Double {
    var pt: CGFloat { CGFloat(self) }
}

extension RGB {
    var color: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension Color {
    init(rgb: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum DriveColor {
    static var background: Color { DrivePalette.background.color }
    static var primary: Color { DrivePalette.primary.color }
    static var secondary: Color { DrivePalette.secondary.color }
    static var tertiary: Color { DrivePalette.tertiary.color }
    static var hairline: Color { DrivePalette.hairline.color }
    static var track: Color { DrivePalette.track.color }
    static var ok: Color { DrivePalette.ok.color }
    static var caution: Color { DrivePalette.caution.color }
    static var danger: Color { DrivePalette.danger.color }
    static var cyan: Color { DrivePalette.cyan.color }

    static func tone(_ tone: ReadoutTone) -> Color {
        switch tone {
        case .neutral: return primary
        case .ok: return ok
        case .caution: return caution
        }
    }
}

enum DriveFont {
    /// Outfit ExtraLight, taken from the v6 HTML. Chinese stays the system face (PingFang SC).
    static func figure(_ size: CGFloat, weight: Font.Weight = .ultraLight) -> Font {
        switch weight {
        case .medium, .semibold, .bold, .heavy, .black:
            return medium(size)
        case .regular:
            return regular(size)
        default:
            return .custom("Outfit-ExtraLight", size: size)
        }
    }

    static func regular(_ size: CGFloat) -> Font {
        .custom("Outfit-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Outfit-Medium", size: size)
    }

    static func cjk(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func label(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
        cjk(size, weight: weight)
    }
}

enum CarImageAspect {
    static func rear() -> Double {
        aspect(named: "CarRear") ?? CarArtMetrics.provisional.rearWidthOverHeight
    }

    static func top() -> Double {
        aspect(named: "CarTop") ?? CarArtMetrics.provisional.topWidthOverHeight
    }

    static func hasRearBitmap() -> Bool { UIImage(named: "CarRear") != nil }
    static func hasTopBitmap() -> Bool { UIImage(named: "CarTop") != nil }

    private static func aspect(named name: String) -> Double? {
        guard let image = UIImage(named: name), image.size.height > 0 else { return nil }
        return image.size.width / image.size.height
    }
}

extension ClusterModule {
    var resolvedArtAspect: Double {
        switch self {
        case .car: return CarImageAspect.rear()
        case .tires: return CarImageAspect.top()
        case .trip: return artAspect
        }
    }
}
