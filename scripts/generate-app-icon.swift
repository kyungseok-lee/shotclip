import AppKit

// Original, flattened artwork for the macOS 14+ ICNS pipeline. The same vector
// drawing commands also produce the public SVG/PNG brand assets. No screenshots
// or external images are used. This does not claim Icon Composer/Liquid Glass.
let arguments = CommandLine.arguments
let hasBrandOutput = arguments.count == 4 && arguments[2] == "--brand-assets"
guard arguments.count == 2 || hasBrandOutput else {
    fputs("Usage: swift scripts/generate-app-icon.swift OUTPUT.iconset [--brand-assets OUTPUT_DIRECTORY]\n", stderr)
    exit(1)
}
let output = URL(fileURLWithPath: arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: alpha)
}
func hex(_ value: UInt32) -> String { String(format: "#%06X", value) }
func number(_ value: CGFloat) -> String { String(format: "%.3f", Double(value)) }
func xml(_ value: String) -> String {
    value.replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}
func rounded(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: NSRect(x: x, y: y, width: width, height: height), xRadius: radius, yRadius: radius)
}
func path(_ points: [(CGFloat, CGFloat)], close: Bool = false) -> NSBezierPath {
    let result = NSBezierPath()
    for (index, point) in points.enumerated() {
        if index == 0 { result.move(to: NSPoint(x: point.0, y: point.1)) }
        else { result.line(to: NSPoint(x: point.0, y: point.1)) }
    }
    if close { result.close() }
    return result
}
func svgPath(_ path: NSBezierPath) -> String {
    let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
    defer { points.deallocate() }
    var parts: [String] = []
    func point(_ index: Int) -> String { "\(number(points[index].x)) \(number(points[index].y))" }
    for index in 0..<path.elementCount {
        switch path.element(at: index, associatedPoints: points) {
        case .moveTo: parts.append("M \(point(0))")
        case .lineTo: parts.append("L \(point(0))")
        case .cubicCurveTo: parts.append("C \(point(0)) \(point(1)) \(point(2))")
        case .quadraticCurveTo: parts.append("Q \(point(0)) \(point(1))")
        case .closePath: parts.append("Z")
        @unknown default: break
        }
    }
    return parts.joined(separator: " ")
}

// Each operation draws in AppKit and records the equivalent SVG command.
// This keeps the repository's source icon and the installed ICNS in sync.
final class Artwork {
    var definitions: [String] = []
    var elements: [String] = []
    private var identifier = 0
    func fill(_ path: NSBezierPath, _ value: UInt32, alpha: CGFloat = 1) {
        color(value, alpha: alpha).setFill(); path.fill()
        elements.append("<path d=\"\(svgPath(path))\" fill=\"\(hex(value))\" fill-opacity=\"\(number(alpha))\"/>")
    }
    func stroke(_ path: NSBezierPath, _ value: UInt32, width: CGFloat, alpha: CGFloat = 1) {
        color(value, alpha: alpha).setStroke()
        path.lineWidth = width; path.lineCapStyle = .round; path.lineJoinStyle = .round; path.stroke()
        elements.append("<path d=\"\(svgPath(path))\" fill=\"none\" stroke=\"\(hex(value))\" stroke-width=\"\(number(width))\" stroke-opacity=\"\(number(alpha))\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>")
    }
    func gradient(_ path: NSBezierPath, _ first: UInt32, _ last: UInt32, angle: CGFloat) {
        NSGradient(starting: color(first), ending: color(last))!.draw(in: path, angle: angle)
        identifier += 1
        let name = "gradient\(identifier)"
        let radians = angle * .pi / 180
        let dx = cos(radians) * 50, dy = sin(radians) * 50
        definitions.append("<linearGradient id=\"\(name)\" x1=\"\(number(50-dx))%\" y1=\"\(number(50-dy))%\" x2=\"\(number(50+dx))%\" y2=\"\(number(50+dy))%\"><stop stop-color=\"\(hex(first))\"/><stop offset=\"1\" stop-color=\"\(hex(last))\"/></linearGradient>")
        elements.append("<path d=\"\(svgPath(path))\" fill=\"url(#\(name))\"/>")
    }
    func shadow(_ value: UInt32, alpha: CGFloat, blur: CGFloat, x: CGFloat = 0, y: CGFloat, draw: () -> Void) {
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow(); shadow.shadowColor = color(value, alpha: alpha)
        shadow.shadowBlurRadius = blur; shadow.shadowOffset = NSSize(width: x, height: y); shadow.set()
        identifier += 1
        let name = "shadow\(identifier)"
        definitions.append("<filter id=\"\(name)\" x=\"-40%\" y=\"-40%\" width=\"180%\" height=\"180%\"><feDropShadow dx=\"\(number(x))\" dy=\"\(number(y))\" stdDeviation=\"\(number(blur/2))\" flood-color=\"\(hex(value))\" flood-opacity=\"\(number(alpha))\"/></filter>")
        elements.append("<g filter=\"url(#\(name))\">")
        draw()
        elements.append("</g>")
        NSGraphicsContext.restoreGraphicsState()
    }
    func transformed(_ transform: AffineTransform, svg: String, draw: () -> Void) {
        NSGraphicsContext.saveGraphicsState()
        (transform as NSAffineTransform).concat()
        elements.append("<g transform=\"\(svg)\">")
        draw()
        elements.append("</g>")
        NSGraphicsContext.restoreGraphicsState()
    }
    func text(_ value: String, at point: NSPoint, size: CGFloat, weight: NSFont.Weight, value ink: UInt32) {
        let font = NSFont.systemFont(ofSize: size, weight: weight)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color(ink)]
        (value as NSString).draw(at: point, withAttributes: attributes)
        // SVG text is locally flipped so it stays upright in the bottom-up canvas.
        let style = weight == .bold ? "700" : weight == .semibold ? "600" : weight == .medium ? "500" : "400"
        let baseline = point.y - font.descender
        elements.append("<g transform=\"translate(\(number(point.x)) \(number(baseline))) scale(1 -1)\"><text fill=\"\(hex(ink))\" font-family=\"-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif\" font-size=\"\(number(size))\" font-weight=\"\(style)\">\(xml(value))</text></g>")
    }
    func svg(width: Int, height: Int, title: String, description: String) -> String {
        """
        <svg xmlns="http://www.w3.org/2000/svg" width="\(width)" height="\(height)" viewBox="0 0 \(width) \(height)" role="img" aria-labelledby="title description">
          <title id="title">\(xml(title))</title>
          <desc id="description">\(xml(description))</desc>
          <defs>\(definitions.joined(separator: "\n"))</defs>
          <g transform="translate(0 \(height)) scale(1 -1)">\(elements.joined(separator: "\n"))</g>
        </svg>
        """
    }
}

func drawIcon(_ art: Artwork, small: Bool = false) {
    // A recognizable filled silhouette: capture corners surround a clipped image.
    // Small representations omit the landscape details and use sturdier strokes.
    let tile = rounded(96, 96, 832, 832, 186)
    art.shadow(0x101A4D, alpha: 0.24, blur: small ? 20 : 32, y: -18) {
        art.fill(tile, 0x2554DB)
    }
    art.gradient(tile, 0x5285FA, 0x14379F, angle: -64)
    if !small {
        art.stroke(rounded(99, 99, 826, 826, 182), 0xD1E8FF, width: 3, alpha: 0.35)
    }
    let frameWidth: CGFloat = small ? 63 : 55
    for (x, y, dx, dy) in [(249.0, 729.0, 135.0, -126.0), (745.0, 729.0, -135.0, -126.0),
                           (249.0, 326.0, 135.0, 126.0), (745.0, 326.0, -135.0, 126.0)] {
        art.stroke(path([(x+dx,y), (x,y), (x,y+dy)]), 0x6EF1D9, width: frameWidth)
    }
    // The forward card is the clipboard result, not a UI screenshot.
    var tilt = AffineTransform()
    tilt.translate(x: 564, y: 476); tilt.rotate(byDegrees: -8); tilt.translate(x: -564, y: -476)
    art.transformed(tilt, svg: "translate(564 476) rotate(-8) translate(-564 -476)") {
        let card = rounded(360, 222, 388, 486, 42)
        art.shadow(0x071D60, alpha: 0.38, blur: small ? 20 : 30, x: 5, y: -17) { art.fill(card, 0xFFFFFF) }
        art.gradient(card, 0xFFFFFF, 0xE5EEFF, angle: -85)
        if !small { art.stroke(rounded(362, 224, 384, 482, 40), 0xFFFFFF, width: 3, alpha: 0.78) }
        // A captured region and offset copy sheet, shared with the menu mark.
        // No landscape/photo-editor cue: the symbol describes capture and copy.
        let region = rounded(417, 357, 229, 240, 20)
        art.gradient(region, 0x82B0F8, 0x4575D7, angle: -90)
        art.stroke(region, 0x2450A4, width: small ? 15 : 10, alpha: 0.24)
        let sheet = rounded(484, 311, 192, 224, 19)
        art.shadow(0x183E91, alpha: 0.20, blur: 13, x: 2, y: -7) { art.fill(sheet, 0xFFFFFF) }
        art.gradient(sheet, 0xF8FFFF, 0xDCF6EF, angle: -90)
        art.stroke(path([(526,473), (631,473)]), 0x338CBA, width: small ? 18 : 15)
        art.stroke(path([(526,431), (607,431)]), 0x338CBA, width: small ? 18 : 15)
        if !small { art.fill(rounded(470, 264, 169, 10, 5), 0xC0D0E6) }
        // A broad mint clip bridges the paper edge and gives the brand its “Clip”.
        let clip = rounded(471, 655, 168, 77, 23)
        art.shadow(0x10245B, alpha: 0.20, blur: 12, y: -8) { art.fill(clip, 0x123479) }
        art.gradient(rounded(477, 674, 156, 57, 20), 0xC4FFF0, 0x68E4CB, angle: -90)
        if !small { art.stroke(path([(503,711), (607,711)]), 0xFFFFFF, width: 5, alpha: 0.68) }
    }
}

func render(width: Int, height: Int, logicalWidth: Int, logicalHeight: Int, drawing: (Artwork) -> Void) throws -> (Data, Artwork) {
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
        let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "Shot ClipArtwork", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create image context"])
    }
    bitmap.size = NSSize(width: width, height: height)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = context
    defer { NSGraphicsContext.restoreGraphicsState() }
    context.cgContext.scaleBy(x: CGFloat(width)/CGFloat(logicalWidth), y: CGFloat(height)/CGFloat(logicalHeight))
    let art = Artwork(); drawing(art)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "Shot ClipArtwork", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG"])
    }
    return (data, art)
}

for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let (data, _) = try render(width: pixels, height: pixels, logicalWidth: 1024, logicalHeight: 1024) {
            drawIcon($0, small: pixels <= 32)
        }
        let suffix = scale == 2 ? "@2x" : ""
        try data.write(to: output.appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
    }
}

if hasBrandOutput {
    let brand = URL(fileURLWithPath: arguments[3], isDirectory: true)
    try FileManager.default.createDirectory(at: brand, withIntermediateDirectories: true)
    let (icon, iconArt) = try render(width: 1024, height: 1024, logicalWidth: 1024, logicalHeight: 1024) { drawIcon($0) }
    try icon.write(to: brand.appendingPathComponent("shotclip-icon.png"))
    try iconArt.svg(width: 1024, height: 1024, title: "Shot Clip app icon",
                    description: "Mint capture corners surround an ivory clipboard with an offset copy sheet on a cobalt tile.")
        .write(to: brand.appendingPathComponent("shotclip-icon.svg"), atomically: true, encoding: .utf8)
    let (hero, heroArt) = try render(width: 1600, height: 800, logicalWidth: 1600, logicalHeight: 800) { art in
        art.gradient(rounded(0, 0, 1600, 800, 0), 0xFAFCFF, 0xECF3FF, angle: -18)
        art.fill(NSBezierPath(ovalIn: NSRect(x: 1000, y: -155, width: 660, height: 660)), 0xD9F4EF, alpha: 0.54)
        art.fill(NSBezierPath(ovalIn: NSRect(x: 1150, y: 442, width: 650, height: 650)), 0xDBE7FF, alpha: 0.66)
        art.text("CAPTURE TO CLIPBOARD", at: NSPoint(x: 112, y: 635), size: 19, weight: .semibold, value: 0x267B8B)
        art.text("Shot Clip", at: NSPoint(x: 106, y: 512), size: 96, weight: .bold, value: 0x172852)
        art.text("Capture. Copy. Continue.", at: NSPoint(x: 112, y: 443), size: 38, weight: .medium, value: 0x2C446C)
        art.text("Keep your ideas moving.", at: NSPoint(x: 114, y: 360), size: 28, weight: .regular, value: 0x657894)
        art.text("One small utility for macOS.", at: NSPoint(x: 114, y: 320), size: 28, weight: .regular, value: 0x657894)
        let labels = [("Select", 114.0, 116.0), ("Capture", 274.0, 144.0), ("Paste", 462.0, 112.0)]
        for (label, x, width) in labels {
            art.fill(rounded(x, 194, width, 49, 24), 0xFFFFFF, alpha: 0.94)
            art.stroke(rounded(x, 194, width, 49, 24), 0xCAD9EB, width: 1)
            art.text(label, at: NSPoint(x: x+24, y: 207), size: 20, weight: .medium, value: 0x385176)
        }
        for x in [242.0, 429.0] {
            art.stroke(path([(x,217), (x+16,217), (x+10,224), (x+16,217), (x+10,210)]), 0x869AB7, width: 2.5)
        }
        art.text("English + 한국어", at: NSPoint(x: 114, y: 113), size: 20, weight: .regular, value: 0x657894)
        var placement = AffineTransform()
        placement.translate(x: 952, y: 107); placement.scale(0.56)
        art.transformed(placement, svg: "translate(952 107) scale(0.56)") { drawIcon(art) }
    }
    try hero.write(to: brand.appendingPathComponent("shotclip-hero.png"))
    try heroArt.svg(width: 1600, height: 800, title: "Shot Clip — Capture. Copy. Continue.",
                    description: "Original illustration of the Shot Clip capture-and-copy-sheet icon beside a Select, Capture, Paste flow. English and Korean supported. No captured screen content.")
        .write(to: brand.appendingPathComponent("shotclip-hero.svg"), atomically: true, encoding: .utf8)
    print("Generated original Shot Clip brand SVG/PNG assets")
}
print("Generated original Shot Clip icon: 10 PNG representations, 16–1024 pixels")
