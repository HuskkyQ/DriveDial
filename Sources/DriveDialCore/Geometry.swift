import Foundation

/// Plain geometry so layout math can run without CoreGraphics, including on Linux.
public struct LayoutSize: Equatable, Sendable {
    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public static let zero = LayoutSize(width: 0, height: 0)

    public var isEmpty: Bool { width <= 0 || height <= 0 }
}

public struct LayoutInsets: Equatable, Sendable {
    public var top: Double
    public var leading: Double
    public var bottom: Double
    public var trailing: Double

    public init(top: Double, leading: Double, bottom: Double, trailing: Double) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    public static let zero = LayoutInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

public struct LayoutRect: Equatable, Sendable {
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
    public var minX: Double { x }
    public var maxX: Double { x + width }
    public var minY: Double { y }
    public var maxY: Double { y + height }

    public func contains(_ other: LayoutRect, slop: Double = 0.01) -> Bool {
        other.minX >= minX - slop
            && other.maxX <= maxX + slop
            && other.minY >= minY - slop
            && other.maxY <= maxY + slop
    }

    public func intersects(_ other: LayoutRect) -> Bool {
        maxX > other.minX && minX < other.maxX && maxY > other.minY && minY < other.maxY
    }
}

public enum AspectFit {
    /// Largest size with the image's width/height ratio that fits inside `container`.
    public static func size(container: LayoutSize, image: LayoutSize) -> LayoutSize {
        guard !container.isEmpty, !image.isEmpty else { return .zero }
        let scale = min(container.width / image.width, container.height / image.height)
        return LayoutSize(width: image.width * scale, height: image.height * scale)
    }
}
