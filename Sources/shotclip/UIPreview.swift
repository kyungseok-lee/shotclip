import AppKit
import CaptureCore
import Darwin

// Inert view fixtures, not desktop screenshots. This path runs before preference
// preparation and AppDelegate, and never starts a hotkey, updater, capture or TCC.
enum UIPreview {
    @MainActor static func run() -> Never {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: "--ui-preview"), arguments.indices.contains(index + 1),
              !arguments[index + 1].hasPrefix("--"),
              let languageIndex = arguments.firstIndex(of: "--language"), arguments.indices.contains(languageIndex + 1),
              let language = AppLanguage(rawValue: arguments[languageIndex + 1]),
              let appearanceIndex = arguments.firstIndex(of: "--appearance"), arguments.indices.contains(appearanceIndex + 1),
              ["light", "dark"].contains(arguments[appearanceIndex + 1]) else {
            fputs("Usage: shotclip --ui-preview OUTPUT_DIRECTORY --language en|ko --appearance light|dark\n", stderr); exit(64)
        }
        let output = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
        let appearanceName = arguments[appearanceIndex + 1]
        let appearance = NSAppearance(named: appearanceName == "dark" ? .darkAqua : .aqua)!
        let application = NSApplication.shared; application.setActivationPolicy(.prohibited)
        application.appearance = appearance
        let empty: () -> Void = {}
        var previewWindow: SettingsWindow!
        appearance.performAsCurrentDrawingAppearance {
            previewWindow = SettingsWindow(actions: .init(mask: empty, drag: empty, shortcut: empty, login: empty,
                request: empty, settings: empty, recheck: empty, restart: empty, reveal: empty,
                update: empty, automatic: { _ in }, language: { _ in }))
            previewWindow.appearance = appearance
        }
        let window = previewWindow!
        let permission = { (ready: Bool) in PermissionStatus(isReady: ready, isAdHoc: true,
            bundleURL: URL(fileURLWithPath: "/Applications/Shot Clip.app"), version: "0.5.0 (7)") }
        let prefix = "\(language.rawValue)-\(appearanceName)"
        var files: [String] = []
        do {
            try verifyOverlayKeyboardInvariants()
            try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
            for (ready, state) in [(true, "ready"), (false, "access-needed")] {
                window.refresh(permission: permission(ready), shortcut: "⌃⇧⌘5", login: L10n.text("login.off"),
                    update: L10n.text("updates.ready"), automaticEnabled: false, configured: true, canCheck: true)
                for (section, label) in [(SettingsWindow.Section.general, "general"), (.permission, "access"), (.updates, "updates")] {
                    window.select(section)
                    for (minimum, size) in [(false, "default"), (true, "minimum")] {
                        if minimum { window.setFrame(NSRect(origin: .zero, size: window.minSize), display: false) }
                        else { window.setContentSize(NSSize(width: 620, height: 510)) }
                        let filename = "\(prefix)-\(label)-\(size)-\(state).png"
                        try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
                    }
                }
            }
            window.setContentSize(NSSize(width: 620, height: 510)); window.select(.permission)
            window.showTroubleshootingForPreview()
            var filename = "\(prefix)-access-troubleshooting.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            window.select(.general)
            window.refresh(permission: permission(true), shortcut: "⌃⇧⌘5", login: L10n.text("login.approval"), loginNeedsApproval: true,
                update: L10n.text("updates.busy"), automaticEnabled: false, configured: true, canCheck: false,
                languageSelection: LanguageSelection(active: language, selected: language == .english ? .korean : .english))
            filename = "\(prefix)-general-pending-approval.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            window.select(.updates)
            filename = "\(prefix)-updates-busy.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            let fakeActions = CaptureMenu.Actions(area: Selector(("fixtureArea")), fixed: Selector(("fixtureFixed")),
                permission: Selector(("fixturePermission")), settings: Selector(("fixtureSettings")), updates: Selector(("fixtureUpdates")), quit: Selector(("fixtureQuit")))
            for (mode, label) in [(SelectionMode.drag, "area"), (.mask, "fixed")] {
                let menu = CaptureMenu.make(ready: true, mode: mode, shortcut: Shortcut(), canCheck: true, target: nil, actions: fakeActions)
                let view = MenuFixture(menu: menu); view.appearance = appearance
                filename = "\(prefix)-menu-model-\(label).png"
                try render(view, to: output.appendingPathComponent(filename)); files.append(filename)
            }
            for (mode, label) in [(SelectionMode.drag, "area"), (.mask, "fixed")] {
                let scene = OverlayFixture(frame: NSRect(x: 0, y: 0, width: 960, height: 600)); scene.appearance = appearance
                let selection = SelectionView(frame: scene.bounds); selection.mode = mode
                selection.rect = mode == .drag ? .zero : NSRect(x: 220, y: 190, width: 430, height: 250)
                selection.cancel = empty; selection.selection = { _ in }; scene.addSubview(selection)
                filename = "\(prefix)-overlay-\(label).png"
                try render(scene, to: output.appendingPathComponent(filename)); files.append(filename)
            }
            let record: [String: Any] = ["case": "ui-preview", "result": "PASS", "language": language.rawValue,
                "appearance": appearanceName, "files": files, "nativeMenuPopupTested": false,
                "captureTested": false, "clipboardTouched": false, "preferencesWritten": false, "overlayKeyboardInvariants": true]
            let data = try JSONSerialization.data(withJSONObject: record, options: .sortedKeys)
            print(String(data: data, encoding: .utf8)!); fflush(stdout); exit(0)
        } catch {
            fputs("UI fixture render failed\n", stderr); exit(1)
        }
    }
    @MainActor private static func verifyOverlayKeyboardInvariants() throws {
        let view = SelectionView(frame: NSRect(x: 0, y: 0, width: 960, height: 600))
        view.mode = .drag; view.rect = .zero
        var selections = 0; view.selection = { _ in selections += 1 }; view.cancel = {}
        func key(_ code: UInt16, modifiers: NSEvent.ModifierFlags = []) throws {
            guard let event = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: modifiers,
                timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "",
                isARepeat: false, keyCode: code) else { throw PreviewError.behavior }
            view.keyDown(with: event)
        }
        for code: UInt16 in [123, 124, 125, 126] {
            try key(code); try key(code, modifiers: .option)
            guard view.rect == .zero, view.rect.minX.isFinite, view.rect.minY.isFinite else { throw PreviewError.behavior }
        }
        try key(36) // An empty drag region must not confirm a capture.
        guard selections == 0 else { throw PreviewError.behavior }
        try key(46) // M enters a valid fixed region.
        guard view.mode == .mask, SelectionGeometry.valid(view.rect) else { throw PreviewError.behavior }
        let previous = view.rect
        try key(46); guard view.mode == .drag, view.rect == .zero else { throw PreviewError.behavior }
        try key(46); guard view.mode == .mask, view.rect == previous else { throw PreviewError.behavior }
        view.mode = .drag; guard view.rect == .zero else { throw PreviewError.behavior }
    }
    @MainActor private static func render(_ view: NSView, to output: URL) throws {
        var encoded: Data?
        view.effectiveAppearance.performAsCurrentDrawingAppearance {
            view.layoutSubtreeIfNeeded()
            guard let cached = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
            view.cacheDisplay(in: view.bounds, to: cached)
            // cacheDisplay captures only content, without the native window's
            // background. Flatten onto its semantic surface, never the desktop.
            guard let flattened = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cached.pixelsWide,
                pixelsHigh: cached.pixelsHigh, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
                let context = NSGraphicsContext(bitmapImageRep: flattened) else { return }
            NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = context
            defer { NSGraphicsContext.restoreGraphicsState() }
            context.cgContext.scaleBy(x: CGFloat(cached.pixelsWide) / view.bounds.width,
                                      y: CGFloat(cached.pixelsHigh) / view.bounds.height)
            NSColor.windowBackgroundColor.setFill(); NSBezierPath(rect: view.bounds).fill()
            let image = NSImage(size: view.bounds.size); image.addRepresentation(cached)
            image.draw(in: view.bounds)
            encoded = flattened.representation(using: .png, properties: [:])
        }
        guard let data = encoded else { throw PreviewError.render }
        try data.write(to: output)
    }
    private enum PreviewError: Error { case render, behavior }
}

// Public NSMenu has no direct bitmap view API. This clearly synthetic fixture
// draws its actual shared menu model; native popup interaction is separate QA.
private final class MenuFixture: NSView {
    private let menuModel: NSMenu
    init(menu: NSMenu) {
        self.menuModel = menu
        let count = menu.items.filter { !$0.isHidden }.count
        super.init(frame: NSRect(x: 0, y: 0, width: 310, height: CGFloat(count * 30 + 20)))
        var y = bounds.height - 36
        for item in menu.items where !item.isHidden {
            if let image = item.image {
                let icon = NSImageView(frame: NSRect(x: 13, y: y, width: 18, height: 18))
                icon.image = image; icon.contentTintColor = .labelColor; addSubview(icon)
            }
            y -= 30
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }
    override func draw(_ dirtyRect: NSRect) {
        NSColor.controlBackgroundColor.setFill(); NSBezierPath(roundedRect: bounds, xRadius: 10, yRadius: 10).fill()
        var y = bounds.height - 35
        for item in menuModel.items where !item.isHidden {
            if item.isSeparatorItem {
                NSColor.separatorColor.setStroke(); let line = NSBezierPath()
                line.move(to: NSPoint(x: 12, y: y + 8)); line.line(to: NSPoint(x: bounds.width - 12, y: y + 8)); line.stroke()
            } else {
                let plainTitle = item.attributedTitle?.string.components(separatedBy: "\t").first ?? item.title
                (plainTitle as NSString).draw(at: NSPoint(x: 41, y: y), withAttributes: [.font: NSFont.menuFont(ofSize: 13), .foregroundColor: NSColor.labelColor])
                let attributedParts = item.attributedTitle?.string.components(separatedBy: "\t") ?? []
                var hint = attributedParts.count == 2 ? attributedParts[1] : ""
                if !item.keyEquivalent.isEmpty {
                    let flags = item.keyEquivalentModifierMask
                    hint = (flags.contains(.control) ? "⌃" : "") + (flags.contains(.option) ? "⌥" : "")
                        + (flags.contains(.shift) ? "⇧" : "") + (flags.contains(.command) ? "⌘" : "")
                        + item.keyEquivalent.uppercased()
                }
                if !hint.isEmpty {
                    let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.menuFont(ofSize: 12), .foregroundColor: NSColor.secondaryLabelColor]
                    let width = (hint as NSString).size(withAttributes: attributes).width
                    (hint as NSString).draw(at: NSPoint(x: bounds.width - width - 18, y: y), withAttributes: attributes)
                }
            }
            y -= 30
        }
    }
}

private final class OverlayFixture: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.windowBackgroundColor.setFill(); NSBezierPath(rect: bounds).fill()
        let card = NSBezierPath(roundedRect: NSRect(x: 170, y: 150, width: 600, height: 360), xRadius: 18, yRadius: 18)
        NSColor.controlBackgroundColor.setFill(); card.fill()
        NSColor.controlAccentColor.withAlphaComponent(0.15).setFill()
        NSBezierPath(roundedRect: NSRect(x: 200, y: 410, width: 210, height: 56), xRadius: 12, yRadius: 12).fill()
        for i in 0..<4 {
            NSColor.separatorColor.withAlphaComponent(0.3).setFill()
            NSBezierPath(roundedRect: NSRect(x: 200, y: 210 + i * 40, width: 480 - i * 60, height: 12), xRadius: 6, yRadius: 6).fill()
        }
    }
}
