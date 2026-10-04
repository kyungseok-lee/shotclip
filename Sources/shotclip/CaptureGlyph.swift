import AppKit
import CaptureCore
import Carbon

// One original capture + copy-sheet mark for the menu bar and capture actions.
// Template rendering lets macOS provide contrast in both menu bar appearances.
enum CaptureGlyph {
    static func image(size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { _ in
            NSGraphicsContext.current?.cgContext.scaleBy(x: size / 24, y: size / 24)
            NSColor.black.setStroke()
            for (x, y, dx, dy) in [(3.0,21.0,5.0,-5.0), (20.0,21.0,-5.0,-5.0),
                                   (3.0,4.0,5.0,5.0), (20.0,4.0,-5.0,5.0)] {
                let path = NSBezierPath(); path.lineWidth = 1.9
                path.lineCapStyle = .round; path.lineJoinStyle = .round
                path.move(to: NSPoint(x: x + dx, y: y)); path.line(to: NSPoint(x: x, y: y))
                path.line(to: NSPoint(x: x, y: y + dy)); path.stroke()
            }
            let sheet = NSBezierPath(roundedRect: NSRect(x: 10, y: 1, width: 12, height: 14), xRadius: 2, yRadius: 2)
            NSGraphicsContext.current?.cgContext.saveGState()
            NSGraphicsContext.current?.cgContext.setBlendMode(.clear); sheet.fill()
            NSGraphicsContext.current?.cgContext.restoreGState()
            NSColor.black.setStroke(); sheet.lineWidth = 1.9; sheet.stroke()
            let copy = NSBezierPath(); copy.lineWidth = 1.7; copy.lineCapStyle = .round
            copy.move(to: NSPoint(x: 13, y: 11)); copy.line(to: NSPoint(x: 18, y: 11))
            copy.move(to: NSPoint(x: 13, y: 7)); copy.line(to: NSPoint(x: 17, y: 7)); copy.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }
}

enum CaptureMenu {
    static let permissionTag = 10
    static let updatesTag = 20
    struct Actions {
        let area: Selector, fixed: Selector, permission: Selector
        let settings: Selector, updates: Selector, quit: Selector
    }
    static func shortcutDisplay(_ shortcut: Shortcut) -> String {
        let prefix = (shortcut.modifiers & UInt32(controlKey) != 0 ? "⌃" : "")
            + (shortcut.modifiers & UInt32(optionKey) != 0 ? "⌥" : "")
            + (shortcut.modifiers & UInt32(shiftKey) != 0 ? "⇧" : "")
            + (shortcut.modifiers & UInt32(cmdKey) != 0 ? "⌘" : "")
        guard let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
              let property = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            return prefix + L10n.format("shortcut.key_number", String(shortcut.key))
        }
        let data = unsafeBitCast(property, to: CFData.self)
        guard let bytes = CFDataGetBytePtr(data) else { return prefix + L10n.format("shortcut.key_number", String(shortcut.key)) }
        let layout = UnsafeRawPointer(bytes).assumingMemoryBound(to: UCKeyboardLayout.self)
        var dead: UInt32 = 0
        var count: Int = 0
        var characters = [UniChar](repeating: 0, count: 8)
        let status = UCKeyTranslate(layout, UInt16(shortcut.key), UInt16(kUCKeyActionDisplay), 0,
            UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysMask), &dead, 8, &count, &characters)
        guard status == noErr, count > 0 else { return prefix + L10n.format("shortcut.key_number", String(shortcut.key)) }
        let key = String(utf16CodeUnits: characters, count: Int(count))
        return prefix + key.uppercased()
    }
    static func make(ready: Bool, mode: SelectionMode, shortcut: Shortcut, canCheck: Bool,
                     target: AnyObject?, actions: Actions) -> NSMenu {
        let menu = NSMenu(); menu.autoenablesItems = false
        func item(_ key: String, action: Selector, symbol: String? = nil) -> NSMenuItem {
            let item = NSMenuItem(title: L10n.text(key), action: action, keyEquivalent: "")
            item.target = target
            if let symbol { item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) }
            return item
        }
        let area = item("capture.area", action: actions.area); area.image = CaptureGlyph.image()
        let fixed = item("capture.fixed", action: actions.fixed, symbol: "rectangle.dashed")
        let current = mode == .drag ? area : fixed
        // The Carbon hotkey is a physical key. Do not invent a second menu
        // binding from a persisted label (which may be stale or multi-character).
        let hint = shortcutDisplay(shortcut)
        let paragraph = NSMutableParagraphStyle()
        paragraph.tabStops = [NSTextTab(textAlignment: .right, location: 230)]
        current.attributedTitle = NSAttributedString(string: "\(current.title)\t\(hint)", attributes: [
            .font: NSFont.menuFont(ofSize: 13), .paragraphStyle: paragraph
        ])
        current.toolTip = hint
        menu.addItem(area); menu.addItem(fixed); menu.addItem(.separator())
        let permission = item("menu.enable_access", action: actions.permission, symbol: "exclamationmark.circle")
        permission.tag = permissionTag; permission.isHidden = ready; menu.addItem(permission)
        let settings = item("menu.settings", action: actions.settings, symbol: "gearshape")
        settings.keyEquivalent = ","; settings.keyEquivalentModifierMask = .command; menu.addItem(settings)
        let updates = item("menu.updates", action: actions.updates, symbol: "arrow.down.circle")
        updates.tag = updatesTag; updates.isEnabled = canCheck; menu.addItem(updates)
        menu.addItem(.separator())
        let quit = item("menu.quit", action: actions.quit); quit.keyEquivalent = "q"; quit.keyEquivalentModifierMask = .command; menu.addItem(quit)
        return menu
    }
}
