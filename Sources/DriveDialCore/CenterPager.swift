import Foundation

/// Bounded pages for the center strip: 车模, 胎压, 本次行程.
/// The v6 HTML wrapped with modulo. This app does not: the end arrows stop.
public struct CenterPagerState: Equatable, Sendable {
    public static let pages: [ClusterModule] = [.car, .tires, .trip]
    public static let dragThresholdFraction = 0.2

    public private(set) var index: Int

    public init(module: ClusterModule) {
        index = Self.pages.firstIndex(of: module) ?? 0
    }

    public var module: ClusterModule { Self.pages[index] }
    public var selectedDot: Int { index }
    public var canRetreat: Bool { index > 0 }
    public var canAdvance: Bool { index + 1 < Self.pages.count }

    /// Moves one page. Returns false at either end, and does not wrap.
    @discardableResult
    public mutating func move(_ delta: Int) -> Bool {
        let next = index + delta
        guard Self.pages.indices.contains(next) else { return false }
        index = next
        return true
    }

    /// Commits a horizontal drag. Negative translation advances toward 行程.
    @discardableResult
    public mutating func settle(translation: Double, pageWidth: Double) -> Bool {
        guard pageWidth > 0, translation.isFinite else { return false }
        let threshold = pageWidth * Self.dragThresholdFraction
        if translation <= -threshold { return move(1) }
        if translation >= threshold { return move(-1) }
        return false
    }

    public func resistedTranslation(_ translation: Double) -> Double {
        if !translation.isFinite { return 0 }
        if index == 0, translation > 0 { return translation * 0.25 }
        if index == Self.pages.count - 1, translation < 0 { return translation * 0.25 }
        return translation
    }
}

public enum CenterStrip {
    /// Between the center arrows: previous button ends at 312, next begins at 562.
    public static let originX = 312.0
    public static let originY = CenterGroup.stripOriginY
    public static let width = 250.0
    public static let height = 224.0

    public static var maxX: Double { originX + width }
    public static var maxY: Double { originY + height }
}
