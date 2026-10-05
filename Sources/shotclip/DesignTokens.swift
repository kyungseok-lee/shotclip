import AppKit
import CoreText

// One source for app-owned typography, spacing, surfaces and component metrics.
// App-owned menus use the same body font; macOS-owned dialogs retain system typography.
enum DesignTokens {
    static let primaryText = NSColor.labelColor
    static let secondaryText = NSColor.secondaryLabelColor
    static let windowSurface = NSColor.windowBackgroundColor
    static let cardSurface = NSColor.windowBackgroundColor
    static let ready = NSColor.systemGreen
    static let attention = NSColor.systemOrange

    static var body: NSFont { AppTypography.font(size: 13) }
    static var caption: NSFont { AppTypography.font(size: 12) }
    static var section: NSFont { AppTypography.font(size: 14, weight: .semibold) }
    static var title: NSFont { AppTypography.font(size: 18, weight: .semibold) }
    static var shortcut: NSFont { AppTypography.font(size: 13, weight: .medium) }
    static var toolbarLabel: NSFont { AppTypography.font(size: 13, weight: .medium) }
    static var measurement: NSFont { AppTypography.font(size: 11, weight: .medium) }

    static let tight: CGFloat = 4
    static let inline: CGFloat = 8
    static let group: CGFloat = 12
    static let sectionGap: CGFloat = 16
    static let inset: CGFloat = 20
    static let panelInset: CGFloat = 24
    static let rowInset: CGFloat = 16
    static let rowPadding: CGFloat = 12
    static let borderRadius: CGFloat = 12
    static let cardRadius: CGFloat = 8
    static let controlSize: CGFloat = 44
    static let railWidth: CGFloat = 72
    static let railRadius: CGFloat = 10
    static let settingsInset: CGFloat = 28
    static let settingsSectionGap: CGFloat = 24
    static let settingsHeaderHeight: CGFloat = 56
    static let settingsActionWidth: CGFloat = 160
    static let settingsButtonHeight: CGFloat = 28
    static let settingsBodyLineHeight: CGFloat = 20
    static let settingsCaptionLineHeight: CGFloat = 18
    static let settingsSectionLineHeight: CGFloat = 22
    static let settingsTitleLineHeight: CGFloat = 28
    static let settingsSize = NSSize(width: 720, height: 580)
    static let settingsMinimumSize = NSSize(width: 620, height: 480)
    static let noticeWidth: CGFloat = 420
    static let updateWidth: CGFloat = 520
    static let releaseNotesHeight: CGFloat = 188
    static let toolbarInset: CGFloat = 8
    static let toolbarHeight: CGFloat = 62
    static let toolbarRadius: CGFloat = 13
    static let toolbarModeWidth: CGFloat = 46
    static let screenInset: CGFloat = 24
    static let thumbnailWidth: CGFloat = 220
    static let thumbnailHeight: CGFloat = 152
    static let previewImagePadding: CGFloat = 20
    static let previewToolbarHeight: CGFloat = 58
    static let previewDefaultSize = NSSize(width: 840, height: 600)
    static let previewMinimumSize = NSSize(width: 440, height: 300)
}

// Register only in this process. Fonts never change the user's installed fonts.
// Google Fonts' Roboto is used for Latin text; Noto Sans KR supplies Korean.
enum AppTypography {
    private static let registered: [String: URL] = {
        var registered = [String: URL]()
        for name in ["Roboto", "NotoSansKR"] {
            let url = L10n.bundle.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
                ?? L10n.bundle.url(forResource: name, withExtension: "ttf")
            if let url, CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) {
                registered[name] = url.standardizedFileURL
            }
        }
        return registered
    }()
    static func font(size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
        _ = registered
        let face = NSFont(name: "Roboto-Regular", size: size) ?? NSFont(name: "Roboto", size: size)
        guard let face else { return .systemFont(ofSize: size, weight: weight) }
        let fontWeight: CGFloat = weight == .semibold ? 600 : weight == .medium ? 500 : weight == .bold ? 700 : 400
        let variation: [NSNumber: CGFloat] = [NSNumber(value: 0x77676874): fontWeight] // OpenType 'wght'.
        let korean = NSFontDescriptor(fontAttributes: [.name: "NotoSansKR-Thin", .variation: variation])
        let descriptor = face.fontDescriptor.addingAttributes([
            .variation: variation,
            .cascadeList: [korean]
        ])
        return NSFont(descriptor: descriptor, size: size) ?? face
    }
    #if SHOTCLIP_QA
    static var bundledFontsAvailable: Bool {
        guard let latinURL = registered["Roboto"], let koreanURL = registered["NotoSansKR"],
              let latin = NSFont(name: "Roboto-Regular", size: 13), let korean = NSFont(name: "NotoSansKR-Thin", size: 13),
              let resolvedLatin = CTFontCopyAttribute(latin as CTFont, kCTFontURLAttribute) as? URL,
              let resolvedKorean = CTFontCopyAttribute(korean as CTFont, kCTFontURLAttribute) as? URL else { return false }
        return resolvedLatin.standardizedFileURL == latinURL && resolvedKorean.standardizedFileURL == koreanURL
    }
    static var auditEvidence: [String: Any] {
        let font = DesignTokens.body
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: "Shot Clip 캡처 ⌃⇧⌘", attributes: [.font: font]))
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        let names = runs.map { run -> String in
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let font = attributes[kCTFontAttributeName] as! CTFont
            return CTFontCopyPostScriptName(font) as String
        }
        let sectionVariation = CTFontCopyVariation(DesignTokens.section as CTFont) as? [NSNumber: NSNumber]
        let sectionWeight = sectionVariation?[NSNumber(value: 0x77676874)]?.intValue ?? 400
        let koreanRuns = runs.filter { run in
            let attributes = CTRunGetAttributes(run) as NSDictionary
            return (CTFontCopyPostScriptName(attributes[kCTFontAttributeName] as! CTFont) as String).hasPrefix("NotoSansKR")
        }
        let koreanRegular = koreanRuns.allSatisfy { run in
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let variation = CTFontCopyVariation(attributes[kCTFontAttributeName] as! CTFont) as? [NSNumber: NSNumber]
            return variation?[NSNumber(value: 0x77676874)]?.intValue == 400
        }
        let verified = bundledFontsAvailable && names.contains(where: { $0.hasPrefix("Roboto") })
            && !koreanRuns.isEmpty && koreanRegular && sectionWeight == 600
            && names.contains(where: { !$0.hasPrefix("Roboto") && !$0.hasPrefix("NotoSansKR") })
        return ["result": verified ? "PASS" : "FAIL", "processRegistration": true,
            "bundledFontURLsVerified": bundledFontsAvailable, "syntheticRunFontNames": names,
            "koreanRegularWeight": koreanRegular, "sectionWeight": sectionWeight,
            "shortcutSystemGlyphFallback": true]
    }
    #endif
}

// AppKit labels recalculate their height using the actual assigned width.
// Every composed row reserves padding for the complete wrapping label.
final class WrappingLabel: NSTextField {
    // Settings reserve the complete bilingual copy at the actual allocated
    // width. These alternatives are read-only localization snapshots, never a
    // process language override. Other app-owned wrapping labels keep their
    // existing adaptive behavior.
    private var settingsAlternatives = [String]()
    private var settingsAttributes: [NSAttributedString.Key: Any]?
    func setSettingsText(_ value: String, alternatives: [String], lineHeight: CGFloat) {
        settingsAlternatives = alternatives
        let face = font ?? DesignTokens.body
        let shapedHeight = (alternatives + [value]).map { text -> CGFloat in
            let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: face]))
            var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            let ink = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
            return ceil(max(ascent, ink.maxY) + max(descent, -ink.minY) + leading)
        }.max() ?? lineHeight
        let paragraph = NSMutableParagraphStyle()
        // Never cap below the resolved Korean/system fallback line metrics:
        // Apple's maximumLineHeight contract warns that taller glyphs overlap.
        paragraph.minimumLineHeight = max(lineHeight, shapedHeight)
        paragraph.maximumLineHeight = paragraph.minimumLineHeight
        paragraph.alignment = alignment
        paragraph.lineBreakMode = cell?.lineBreakMode ?? .byWordWrapping
        settingsAttributes = [.font: face, .foregroundColor: textColor ?? DesignTokens.primaryText, .paragraphStyle: paragraph]
        attributedStringValue = NSAttributedString(string: value, attributes: settingsAttributes!)
        invalidateIntrinsicContentSize()
    }
    // Cell metrics describe the primary face and can underestimate a line
    // containing Korean or shortcut glyphs from a cascading font. TextKit
    // resolves those glyphs using the same attributed text as the cell.
    func requiredHeight(forWidth width: CGFloat) -> CGFloat {
        guard width > 0, let cell, !stringValue.isEmpty else { return super.intrinsicContentSize.height }
        let strings = settingsAttributes == nil ? [attributedStringValue] : (settingsAlternatives + [stringValue]).map {
            NSAttributedString(string: $0, attributes: settingsAttributes!)
        }
        return strings.map { measuredHeight($0, forWidth: width, cell: cell) }.max() ?? 0
    }
    private func measuredHeight(_ text: NSAttributedString, forWidth width: CGFloat, cell: NSCell) -> CGFloat {
        let probe = NSRect(x: 0, y: 0, width: width, height: 100_000)
        let drawing = cell.drawingRect(forBounds: probe)
        let storage = NSTextStorage(attributedString: text)
        let layout = NSLayoutManager()
        let container = NSTextContainer(containerSize: NSSize(width: max(1, drawing.width), height: 100_000))
        container.lineFragmentPadding = 0; container.lineBreakMode = cell.lineBreakMode
        storage.addLayoutManager(layout); layout.addTextContainer(container); layout.ensureLayout(for: container)
        let glyphs = layout.glyphRange(for: container)
        let used = layout.usedRect(for: container)
        let ink = layout.boundingRect(forGlyphRange: glyphs, in: container)
        let drawingInsets = max(0, probe.height - drawing.height)
        let nativeMinimum = settingsAttributes == nil ? max(super.intrinsicContentSize.height, cell.cellSize(forBounds: probe).height) : 0
        return ceil(max(nativeMinimum, max(used.maxY, ink.maxY) + drawingInsets + 2))
    }
    override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        let singleLine = cell?.wraps == false
        if singleLine, !stringValue.isEmpty {
            let strings = settingsAttributes == nil ? [attributedStringValue] : (settingsAlternatives + [stringValue]).map {
                NSAttributedString(string: $0, attributes: settingsAttributes!)
            }
            size.width = strings.map { text in
                ceil(CGFloat(CTLineGetTypographicBounds(CTLineCreateWithAttributedString(text), nil, nil, nil)) + 4)
            }.max() ?? size.width
        }
        let width = singleLine ? size.width : (preferredMaxLayoutWidth > 0 ? preferredMaxLayoutWidth : (bounds.width > 0 ? bounds.width : size.width))
        if width > 0 { size.height = requiredHeight(forWidth: width) }
        return size
    }
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        if cell?.wraps == true, newSize.width > 0, preferredMaxLayoutWidth != newSize.width {
            preferredMaxLayoutWidth = newSize.width
            invalidateIntrinsicContentSize()
        }
    }
}

final class SettingsCard: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: DesignTokens.cardRadius, yRadius: DesignTokens.cardRadius)
        DesignTokens.cardSurface.setFill(); path.fill()
        NSColor.separatorColor.setStroke(); path.lineWidth = 1; path.stroke()
    }
    override func viewDidChangeEffectiveAppearance() { super.viewDidChangeEffectiveAppearance(); needsDisplay = true }
}
