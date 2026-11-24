import Foundation

/// Numbers copied from the v6 HTML and the extracted design baseline.
/// Views read these instead of inventing coordinates.
public enum DesignSpec {
    public static let artboardWidth = 874.0
    public static let artboardHeight = 402.0

    public enum Background {
        public static let cluster = "#05070C"
        public static let gradientTop = "#070B12"
        public static let gradientMiddle = "#05070C"
        public static let gradientMiddleOffset = 0.55
        public static let gradientBottom = "#04060A"
        public static let glowCenter = "#15283C"
        public static let glowCenterOpacity = 0.55
        public static let glowMid = "#163056"
        public static let glowMidOpacity = 0.22
        public static let glowMidOffset = 0.40
        public static let glowEdgeOpacity = 0.0
        public static let ellipseCX = 437.0
        public static let ellipseCY = 210.0
        public static let ellipseRX = 390.0
        public static let ellipseRY = 165.0
    }

    public enum Ready {
        public static let text = "READY"
        public static let left = 58.89
        public static let top = 22.0
        public static let fontSize = 11.0
        public static let fontWeight = 500
        public static let letterSpacingEm = 0.22
        public static let color = "#3EE0A4"
    }

    public enum Telltales {
        public static let left = 128.0
        public static let top = 16.0
        public static let height = 20.0
        public static let gap = 14.0
        public static let icon = 16.0
        public static let count = 5
    }

    public enum DemoBadge {
        public static let text = "演示模式"
        public static let top = 14.0
        public static let fontSize = 10.0
        public static let cornerRadius = 8.0
        public static let paddingTop = 3.0
        public static let paddingTrailing = 8.0
        public static let paddingBottom = 2.0
        public static let paddingLeading = 8.0
    }

    public enum TopRight {
        public static let right = 56.0
        public static let top = 12.0
        public static let height = 28.0
        public static let gap = 8.0
        public static let dot = 6.0
        public static let label = "车辆数据"
    }

    public enum SettingsButton {
        public static let right = 10.0
        public static let top = 4.0
        public static let side = 44.0
    }

    public enum CleanHero {
        public static let fontSize = 134.24
        public static let fontWeight = 200
        public static let letterSpacing = -2.8
        public static let speedText = "36"
        public static let powerText = "12"
        public static let speedX = 149.37
        public static let powerX = 721.22
        public static let baselineY = 244.62
        public static let visualCenterY = 198.92
        public static let labelY = 74.91
        public static let labelSize = 11.0
        public static let labelTracking = 2.4
        public static let unitY = 262.17
        public static let unitSize = 12.0
        public static let unitTracking = 1.6
        public static let unitOpacity = 0.85
        /// The v6 rule under the figures is not drawn. Units stay on `unitY`.
        public static let drawsUnderline = false
    }

    public enum Road {
        public static let x = CenterGroup.road.x
        public static let y = CenterGroup.road.y
        public static let width = CenterGroup.Source.road.width
        public static let height = CenterGroup.Source.road.height
        public static let topLeftX = 67.43
        public static let topRightX = 104.99
        public static let centerLocalX = 86.21
        public static let centerLocalY1 = 6.0
        public static let centerLocalY2 = 208.0
        public static let dash = 7.0
        public static let dashGap = 14.0
        public static let centerStroke = 1.6
        public static let edgeStroke = 1.0
    }

    public enum RearCar {
        public static let x = CenterGroup.rearCar.x
        public static let y = CenterGroup.rearCar.y
        public static let width = CenterGroup.rearCar.width
        public static let height = CenterGroup.rearCar.height
        public static let pixelWidth = 630.0
        public static let pixelHeight = 868.0
    }

    public enum Dots {
        public static let bottom = CenterGroup.dotsBottomInset
        public static let gap = 6.0
        public static let diameter = 5.0
        public static let count = 3
    }

    public enum Arrows {
        public static let previousLeft = 268.0
        public static let nextLeft = 562.0
        public static let top = CenterGroup.arrowTop
        public static let side = 44.0
    }

    public enum DualHero {
        public static let leftX = 174.97
        public static let rightX = 704.15
        public static let labelBaseline = 186.0
        public static let numberBaseline = 236.18
        public static let unitBaseline = 254.0
        public static let fontSize = 58.0
        public static let letterSpacing = -1.2
    }

    public enum DialHero {
        public static let x = 437.0
        public static let labelBaseline = 138.0
        public static let numberBaseline = 211.37
        public static let unitBaseline = 232.0
        public static let fontSize = 92.0
        public static let letterSpacing = -2.0
        public static let circleCenterY = 180.0
        public static let radius = 120.0
    }

    public enum BottomBar {
        public static let x = 59.0
        public static let y = 364.0
        public static let width = 756.0
        public static let height = 22.0
        public static let fontSize = 12.0
        public static let prndSize = 13.0
        public static let prndWeight = 500
        public static let gap = 12.0
        public static let prndGap = 10.0
    }

    public static func wholeHero(_ value: Double) -> String {
        String(Int(value.rounded()))
    }

    public static var rearHeightFraction: Double { RearCar.height / artboardHeight }

    public static var dotsBottomEdgeY: Double { artboardHeight - Dots.bottom }

    public static var arrowCenterY: Double { Arrows.top + Arrows.side / 2 }
}

/// Converts a measured SwiftUI text view into an artboard frame.
/// `baselineFromTop` is the distance from the top of that view to `firstTextBaseline`.
public struct GlyphFrame: Equatable, Sendable {
    public var minX: Double
    public var minY: Double
    public var width: Double
    public var height: Double
    public var baselineY: Double
    public var centerX: Double

    public var maxY: Double { minY + height }
}

public enum GlyphFrameLayout {
    public static func centeredOnBaseline(
        centerX: Double,
        baselineY: Double,
        width: Double,
        height: Double,
        baselineFromTop: Double
    ) -> GlyphFrame {
        GlyphFrame(
            minX: centerX - width / 2,
            minY: baselineY - baselineFromTop,
            width: width,
            height: height,
            baselineY: baselineY,
            centerX: centerX
        )
    }
}

public struct BoardPoint: Equatable, Sendable {
    public var x: Double
    public var y: Double
}

public enum BoardTransform {
    /// One scale, then one translation. Design points are not inset again here.
    public static func screen(_ design: BoardPoint, placed: PlacedBoard) -> BoardPoint {
        BoardPoint(
            x: placed.originX + design.x * placed.scale,
            y: placed.originY + design.y * placed.scale
        )
    }
}

/// Pulls the gear and the status label out of the real side inset.
/// Hero numbers stay on the design coordinates.
public struct ChromeClearance: Equatable, Sendable {
    public var readyLeft: Double
    public var telltaleLeft: Double
    public var gearRight: Double
    public var statusRight: Double
}

public enum ChromeClearanceLayout {
    public static func place(safeLeading: Double, safeTrailing: Double, scale: Double) -> ChromeClearance {
        let lead = scale > 0 ? max(0, safeLeading) / scale : 0
        let trail = scale > 0 ? max(0, safeTrailing) / scale : 0
        let readyLeft = max(DesignSpec.Ready.left, lead)
        let telltaleLeft = max(DesignSpec.Telltales.left, readyLeft + 52)
        let gearRight = max(DesignSpec.SettingsButton.right, trail)
        let statusRight = gearRight + DesignSpec.SettingsButton.side + 2
        return ChromeClearance(
            readyLeft: readyLeft,
            telltaleLeft: telltaleLeft,
            gearRight: gearRight,
            statusRight: statusRight
        )
    }
}
