import Foundation

/// The center cluster (car, road, tire and trip pages, dots, and the swiper arrows)
/// sits above the v6 coordinates. Top bar, bottom bar, PRND, and the speed/power
/// heroes are not part of this shift.
public enum CenterGroup {
    /// Design points upward on the 874×402 board.
    /// 12 keeps every page inside the existing clip: the road's bottom clearance
    /// stays 0.29pt, so the strip does not need to grow and the drag rect stays
    /// the same size. Dots then sit 26pt above the bottom bar.
    public static let lift = 12.0

    public enum Source {
        public static let rearCar = DesignRect(x: 406.37, y: 228.05, width: 60.41, height: 83.23)
        public static let dualCar = DesignRect(x: 402.05, y: 222.10, width: 69.04, height: 95.12)
        public static let topCar = DesignRect(x: 409.69, y: 171.90, width: 55.48, height: 89.02)
        public static let road = DesignRect(x: 350.79, y: 149.81, width: 172.41, height: 213.90)
        public static let stripOriginY = 140.0
        public static let dotsBottomInset = 52.0
        public static let arrowTop = 200.0
        public static let tripCenterY = 225.0
        public static let tireFrontY = 182.0
        public static let tireRearY = 252.0
        public static let tireLeftX = 358.0
        public static let tireRightX = 516.0
        public static let tripCenterX = 437.0
    }

    public static func lifted(_ rect: DesignRect) -> DesignRect {
        DesignRect(x: rect.x, y: rect.y - lift, width: rect.width, height: rect.height)
    }

    public static var rearCar: DesignRect { lifted(Source.rearCar) }
    public static var dualCar: DesignRect { lifted(Source.dualCar) }
    public static var topCar: DesignRect { lifted(Source.topCar) }
    public static var road: DesignRect { lifted(Source.road) }

    public static var stripOriginY: Double { Source.stripOriginY - lift }
    public static var dotsBottomInset: Double { Source.dotsBottomInset + lift }
    public static var arrowTop: Double { Source.arrowTop - lift }
    public static var tripCenter: BoardPoint {
        BoardPoint(x: Source.tripCenterX, y: Source.tripCenterY - lift)
    }

    /// 左前、右前、左后、右后. Same order as the labels in the tire page.
    public static var tireSpots: [BoardPoint] {
        [
            BoardPoint(x: Source.tireLeftX, y: Source.tireFrontY - lift),
            BoardPoint(x: Source.tireRightX, y: Source.tireFrontY - lift),
            BoardPoint(x: Source.tireLeftX, y: Source.tireRearY - lift),
            BoardPoint(x: Source.tireRightX, y: Source.tireRearY - lift)
        ]
    }

    public static func layoutRect(_ rect: DesignRect) -> LayoutRect {
        LayoutRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
    }
}

/// Stroked lane marks in road-local coordinates. Two open slants and the center dash.
/// There is no top segment, no bottom segment, and nothing is closed.
public struct RoadStroke: Equatable, Sendable {
    public var points: [BoardPoint]
    public var dashed: Bool
    public var closed: Bool

    public init(points: [BoardPoint], dashed: Bool, closed: Bool) {
        self.points = points
        self.dashed = dashed
        self.closed = closed
    }

    public var isHorizontal: Bool {
        guard let first = points.first, let last = points.last, points.count >= 2 else { return false }
        return first.y == last.y && first.x != last.x
    }
}

public enum RoadOutline {
    public static func strokes() -> [RoadStroke] {
        let width = DesignSpec.Road.width
        let height = DesignSpec.Road.height
        let left = RoadStroke(
            points: [
                BoardPoint(x: DesignSpec.Road.topLeftX, y: 0),
                BoardPoint(x: 0, y: height)
            ],
            dashed: false,
            closed: false
        )
        let right = RoadStroke(
            points: [
                BoardPoint(x: DesignSpec.Road.topRightX, y: 0),
                BoardPoint(x: width, y: height)
            ],
            dashed: false,
            closed: false
        )
        let dash = RoadStroke(
            points: [
                BoardPoint(x: DesignSpec.Road.centerLocalX, y: DesignSpec.Road.centerLocalY1),
                BoardPoint(x: DesignSpec.Road.centerLocalX, y: DesignSpec.Road.centerLocalY2)
            ],
            dashed: true,
            closed: false
        )
        return [left, right, dash]
    }

    /// Fill corners only. The view fills this and does not stroke it.
    public static func fillCorners() -> [BoardPoint] {
        let edges = strokes().filter { !$0.dashed }
        let left = edges[0].points
        let right = edges[1].points
        return [left[0], right[0], right[1], left[1]]
    }
}
