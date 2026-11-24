import Foundation

public struct DesignRect: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var midX: Double { x + width / 2 }
    public var midY: Double { y + height / 2 }
}

/// v6 artboard. These numbers are the design coordinates, not a list of supported devices.
public enum DesignBoard {
    public static let width = 874.0
    public static let height = 402.0
    public static let reservedLeading = 59.0
    public static let reservedTrailing = 59.0
    public static let reservedBottom = 21.0
    public static let rearCar = CenterGroup.rearCar
    public static let dualCar = CenterGroup.dualCar
    public static let topCar = CenterGroup.topCar
    public static let road = CenterGroup.road
    public static let rearPixelSize = LayoutSize(width: 630, height: 868)
    public static let topPixelSize = LayoutSize(width: 626, height: 1004)

    public static var rearHeightFraction: Double { rearCar.height / height }

    public static func carSlot(theme: ClusterTheme, module: ClusterModule) -> DesignRect? {
        switch (theme, module) {
        case (.digital, .car):
            return rearCar
        case (.dualDial, .car):
            return dualCar
        case (.digital, .tires), (.dualDial, .tires):
            return topCar
        default:
            return nil
        }
    }
}

public struct PlacedBoard: Equatable, Sendable {
    public var scale: Double
    public var originX: Double
    public var originY: Double

    public var boardWidth: Double { DesignBoard.width * scale }
    public var boardHeight: Double { DesignBoard.height * scale }

    /// Fits the 874×402 board on the canvas. The design already reserves 59/21.
    /// When that reserved margin covers the real safe area, the board stays full-bleed.
    /// A larger inset shrinks the board into the safe rect instead of hardcoding a phone.
    public static func place(canvas: LayoutSize, safe: LayoutInsets) -> PlacedBoard {
        let canvasW = canvas.width.isFinite ? max(0, canvas.width) : 0
        let canvasH = canvas.height.isFinite ? max(0, canvas.height) : 0
        guard canvasW > 0, canvasH > 0 else {
            return PlacedBoard(scale: 0, originX: 0, originY: 0)
        }
        let full = fitted(width: canvasW, height: canvasH, originX: 0, originY: 0)
        let insetL = min(max(0, safe.leading.isFinite ? safe.leading : 0), canvasW)
        let insetR = min(max(0, safe.trailing.isFinite ? safe.trailing : 0), max(0, canvasW - insetL))
        let insetT = min(max(0, safe.top.isFinite ? safe.top : 0), canvasH)
        let insetB = min(max(0, safe.bottom.isFinite ? safe.bottom : 0), max(0, canvasH - insetT))
        let marginL = full.originX + DesignBoard.reservedLeading * full.scale
        let marginR = canvasW - (full.originX + full.boardWidth) + DesignBoard.reservedTrailing * full.scale
        let marginT = full.originY
        let marginB = canvasH - (full.originY + full.boardHeight) + DesignBoard.reservedBottom * full.scale
        if marginL + 0.01 >= insetL, marginR + 0.01 >= insetR, marginT + 0.01 >= insetT, marginB + 0.01 >= insetB {
            return full
        }
        let safeW = max(0, canvasW - insetL - insetR)
        let safeH = max(0, canvasH - insetT - insetB)
        return fitted(width: safeW, height: safeH, originX: insetL, originY: insetT)
    }

    private static func fitted(width: Double, height: Double, originX: Double, originY: Double) -> PlacedBoard {
        guard width > 0, height > 0 else {
            return PlacedBoard(scale: 0, originX: originX, originY: originY)
        }
        let scale = min(width / DesignBoard.width, height / DesignBoard.height)
        let boardW = DesignBoard.width * scale
        let boardH = DesignBoard.height * scale
        return PlacedBoard(
            scale: scale,
            originX: originX + (width - boardW) / 2,
            originY: originY + (height - boardH) / 2
        )
    }
}
