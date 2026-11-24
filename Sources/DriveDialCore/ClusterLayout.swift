import Foundation

/// Provisional width/height ratios used only until a real bitmap's pixel size is known.
/// The view passes the loaded image's ratio into the solver and draws it aspect-fit.
public struct CarArtMetrics: Equatable, Sendable {
    public var rearWidthOverHeight: Double
    public var topWidthOverHeight: Double

    public init(rearWidthOverHeight: Double, topWidthOverHeight: Double) {
        self.rearWidthOverHeight = rearWidthOverHeight
        self.topWidthOverHeight = topWidthOverHeight
    }

    public static let provisional = CarArtMetrics(rearWidthOverHeight: 2.15, topWidthOverHeight: 1.55)
}

public struct ClusterLayout: Equatable, Sendable {
    public var scale: Double
    public var content: LayoutRect
    public var topBar: LayoutRect
    public var stage: LayoutRect
    public var bottomBar: LayoutRect
    public var carSlot: LayoutRect
    /// Stage region above the car slot, where the speed readout sits.
    public var speedArea: LayoutRect
}

public enum ClusterLayoutSolver {
    /// Design coordinate space from the v6 reference frame. Not a supported-device check.
    public static let referenceWidth = 874.0
    public static let referenceHeight = 402.0
    public static let topBarDesign = 34.0
    public static let bottomBarDesign = 46.0
    /// Car artwork height as a fraction of the full canvas height on the reference frame.
    public static let carHeightFraction = 0.207
    public static let carMaxWidthFraction = 0.62
    public static let carBottomGapDesign = 10.0

    public static func solve(canvas: LayoutSize, safe: LayoutInsets, artAspect: Double) -> ClusterLayout {
        let width = finite(canvas.width)
        let height = finite(canvas.height)
        let leading = clamp(finite(safe.leading), upper: width)
        let trailing = clamp(finite(safe.trailing), upper: max(0, width - leading))
        let top = clamp(finite(safe.top), upper: height)
        let bottom = clamp(finite(safe.bottom), upper: max(0, height - top))
        let content = LayoutRect(
            x: leading,
            y: top,
            width: max(0, width - leading - trailing),
            height: max(0, height - top - bottom)
        )

        let widthScale = content.width > 0 ? content.width / referenceWidth : 0
        let heightScale = height > 0 ? height / referenceHeight : 0
        let scale = min(widthScale, heightScale)

        var topH = max(32, topBarDesign * scale)
        var botH = max(44, bottomBarDesign * scale)
        if topH + botH > content.height, topH + botH > 0 {
            let fit = content.height / (topH + botH)
            topH *= fit
            botH *= fit
        }

        let topBar = LayoutRect(x: content.x, y: content.y, width: content.width, height: topH)
        let bottomBar = LayoutRect(
            x: content.x,
            y: content.maxY - botH,
            width: content.width,
            height: botH
        )
        let stage = LayoutRect(
            x: content.x,
            y: topBar.maxY,
            width: content.width,
            height: max(0, bottomBar.minY - topBar.maxY)
        )

        let aspect = max(finite(artAspect), 0.01)
        var carH = height * carHeightFraction
        var carW = carH * aspect
        let maxW = content.width * carMaxWidthFraction
        if maxW > 0, carW > maxW {
            carW = maxW
            carH = carW / aspect
        }
        if stage.height > 0, carH > stage.height {
            carH = stage.height
            carW = min(maxW > 0 ? maxW : carW, carH * aspect)
            carH = carW / aspect
        }

        let gap = carBottomGapDesign * scale
        var carY = bottomBar.minY - gap - carH
        if carY < stage.minY {
            carY = stage.minY
        }
        if carY + carH > bottomBar.minY, stage.height > 0 {
            carY = max(stage.minY, bottomBar.minY - carH)
        }
        let carX = content.width > 0 ? content.midX - carW / 2 : content.x
        let carSlot = LayoutRect(x: carX, y: carY, width: max(0, carW), height: max(0, carH))
        let speedArea = LayoutRect(
            x: stage.x,
            y: stage.y,
            width: stage.width,
            height: max(0, min(stage.height, carSlot.minY - stage.minY))
        )

        return ClusterLayout(
            scale: scale,
            content: content,
            topBar: topBar,
            stage: stage,
            bottomBar: bottomBar,
            carSlot: carSlot,
            speedArea: speedArea
        )
    }

    private static func finite(_ value: Double) -> Double {
        value.isFinite ? value : 0
    }

    private static func clamp(_ value: Double, upper: Double) -> Double {
        min(max(0, value), max(0, upper))
    }
}
