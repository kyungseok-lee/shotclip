import AppKit

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift scripts/generate-app-icon.swift OUTPUT.iconset\n", stderr); exit(1)
}
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

// Original geometric artwork, drawn in a 1024-point coordinate space.
// Transparent outer margin follows the visual proportions of macOS app icons.
func render(_ pixels: Int) throws -> Data {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    bitmap.size = NSSize(width: pixels, height: pixels)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    defer { NSGraphicsContext.restoreGraphicsState() }
    let context = NSGraphicsContext.current!.cgContext
    context.scaleBy(x: CGFloat(pixels)/1024, y: CGFloat(pixels)/1024)
    let plate = NSBezierPath(roundedRect: NSRect(x: 96, y: 96, width: 832, height: 832), xRadius: 185, yRadius: 185)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = 36; shadow.shadowOffset = NSSize(width: 0, height: -18); shadow.set()
    NSColor(calibratedRed: 0.22, green: 0.28, blue: 0.85, alpha: 1).setFill(); plate.fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGradient(starting: NSColor(calibratedRed: 0.34, green: 0.42, blue: 0.97, alpha: 1),
               ending: NSColor(calibratedRed: 0.19, green: 0.23, blue: 0.70, alpha: 1))!.draw(in: plate, angle: -70)
    NSColor.white.withAlphaComponent(0.14).setStroke(); plate.lineWidth = 4; plate.stroke()
    let field = NSBezierPath(roundedRect: NSRect(x: 264, y: 308, width: 496, height: 408), xRadius: 28, yRadius: 28)
    NSColor.white.withAlphaComponent(0.09).setFill(); field.fill()
    // Four separated selection corners remain legible at 16 px.
    NSColor.white.setStroke()
    for (x, y, dx, dy) in [(264.0, 716.0, 106.0, -106.0), (760.0, 716.0, -106.0, -106.0),
                           (264.0, 308.0, 106.0, 106.0), (760.0, 308.0, -106.0, 106.0)] {
        let path = NSBezierPath(); path.lineWidth = 45; path.lineCapStyle = .round; path.lineJoinStyle = .round
        path.move(to: NSPoint(x: x+dx, y: y)); path.line(to: NSPoint(x: x, y: y)); path.line(to: NSPoint(x: x, y: y+dy)); path.stroke()
    }
    let accent = NSBezierPath(ovalIn: NSRect(x: 638, y: 252, width: 142, height: 142))
    NSColor(calibratedRed: 0.39, green: 0.91, blue: 0.91, alpha: 1).setFill(); accent.fill()
    let tick = NSBezierPath(); tick.lineWidth = 22; tick.lineCapStyle = .round; tick.lineJoinStyle = .round
    tick.move(to: NSPoint(x: 677, y: 323)); tick.line(to: NSPoint(x: 701, y: 300)); tick.line(to: NSPoint(x: 743, y: 346))
    NSColor(calibratedRed: 0.12, green: 0.22, blue: 0.48, alpha: 1).setStroke(); tick.stroke()
    return bitmap.representation(using: .png, properties: [:])!
}
for size in [16, 32, 128, 256, 512] {
    try render(size).write(to: output.appendingPathComponent("icon_\(size)x\(size).png"))
    try render(size*2).write(to: output.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}
print("Generated original ShotClip icon: 10 PNG representations, 16–1024 pixels")
