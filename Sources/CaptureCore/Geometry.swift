import Foundation
import CoreGraphics

public enum SelectionGeometry {
    public enum Corner { case bottomLeft, bottomRight, topLeft, topRight }
    public static func rect(from start: CGPoint, to end: CGPoint, within bounds: CGRect) -> CGRect {
        guard start.x.isFinite, start.y.isFinite, end.x.isFinite, end.y.isFinite, finite(bounds) else { return .null }
        return CGRect(x: min(start.x, end.x), y: min(start.y, end.y), width: abs(end.x-start.x), height: abs(end.y-start.y)).intersection(bounds)
    }
    public static func captureRect(_ global: CGRect, screen: CGRect) -> CGRect {
        CGRect(x: global.minX-screen.minX, y: screen.maxY-global.maxY, width: global.width, height: global.height)
    }
    public static func finite(_ rect: CGRect) -> Bool { !rect.isNull && rect.origin.x.isFinite && rect.origin.y.isFinite && rect.width.isFinite && rect.height.isFinite && rect.maxX.isFinite && rect.maxY.isFinite }
    public static func valid(_ rect: CGRect) -> Bool { finite(rect) && rect.width >= 2 && rect.height >= 2 }
    /// Display-local top-left points, rounded outward to native pixel boundaries.
    public static func snappedCaptureRect(_ global: CGRect, screen: CGRect, scale: CGFloat) -> CGRect? {
        guard valid(global), valid(screen), scale.isFinite, scale > 0 else { return nil }
        let local = captureRect(global.intersection(screen), screen: screen)
        guard valid(local) else { return nil }
        let minX = floor(local.minX * scale), minY = floor(local.minY * scale)
        let maxX = ceil(local.maxX * scale), maxY = ceil(local.maxY * scale)
        guard minX.isFinite, minY.isFinite, maxX.isFinite, maxY.isFinite else { return nil }
        return CGRect(x: minX / scale, y: minY / scale, width: (maxX-minX) / scale, height: (maxY-minY) / scale)
    }
    /// Moves a rectangle into the display while preserving its size when possible.
    public static func clamped(_ rect: CGRect, within bounds: CGRect) -> CGRect {
        guard valid(rect), valid(bounds) else { return .null }
        let width = min(rect.width, bounds.width), height = min(rect.height, bounds.height)
        return CGRect(x: min(max(rect.minX, bounds.minX), bounds.maxX-width), y: min(max(rect.minY, bounds.minY), bounds.maxY-height), width: width, height: height)
    }
    public static func translated(_ rect: CGRect, by delta: CGSize, within bounds: CGRect) -> CGRect {
        guard delta.width.isFinite, delta.height.isFinite else { return .null }
        return clamped(rect.offsetBy(dx: delta.width, dy: delta.height), within: bounds)
    }
    public static func resized(_ rect: CGRect, corner: Corner, by delta: CGSize, within bounds: CGRect, minimumSize: CGFloat = 2) -> CGRect {
        guard valid(rect), valid(bounds), delta.width.isFinite, delta.height.isFinite, minimumSize.isFinite, minimumSize >= 2, bounds.contains(rect) else { return .null }
        let minimumWidth = min(minimumSize, rect.width), minimumHeight = min(minimumSize, rect.height)
        var left = rect.minX, right = rect.maxX, bottom = rect.minY, top = rect.maxY
        switch corner {
        case .bottomLeft, .topLeft: left = min(max(left + delta.width, bounds.minX), right - minimumWidth)
        case .bottomRight, .topRight: right = max(min(right + delta.width, bounds.maxX), left + minimumWidth)
        }
        switch corner {
        case .bottomLeft, .bottomRight: bottom = min(max(bottom + delta.height, bounds.minY), top - minimumHeight)
        case .topLeft, .topRight: top = max(min(top + delta.height, bounds.maxY), bottom + minimumHeight)
        }
        return CGRect(x: left, y: bottom, width: right-left, height: top-bottom)
    }
}

public struct SessionGate {
    public private(set) var active: UUID?
    public init() {}
    public mutating func begin() -> UUID? { guard active == nil else { return nil }; let id = UUID(); active=id; return id }
    public func accepts(_ id: UUID) -> Bool { active == id }
    public mutating func end() { active=nil }
}

public enum ClipboardTransaction {
    public enum Result: Equatable { case success, externalChange, writeFailedRestored, rollbackFailed }
    // A backend snapshots every representation before this algorithm is called.
    public static func commitResult(snapshot: [[String: Data]], expectedGeneration: Int? = nil, clear: () -> Int, write: ([[String: Data]]) -> Bool, count: () -> Int, image: [[String: Data]]) -> Result {
        if let expectedGeneration, count() != expectedGeneration { return .externalChange }
        let owned = clear()
        guard count() == owned else { return .externalChange }
        let written = write(image)
        guard count() == owned else { return .externalChange }
        if written { return .success }
        // Writes can partially mutate; the backend must only return its own change count.
        let failedCount = count()
        guard failedCount == owned else { return .externalChange }
        let restoring = clear()
        guard count() == restoring else { return .externalChange }
        let restored = snapshot.isEmpty || write(snapshot)
        guard count() == restoring else { return .externalChange }
        return restored ? .writeFailedRestored : .rollbackFailed
    }
    public static func commit(snapshot: [[String: Data]], clear: () -> Int, write: ([[String: Data]]) -> Bool, count: () -> Int, image: [[String: Data]]) -> Bool {
        commitResult(snapshot: snapshot, clear: clear, write: write, count: count, image: image) == .success
    }
}
