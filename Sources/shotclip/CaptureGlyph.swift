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
    static let areaTag = 30
    static let fixedTag = 31
    static let settingsTag = 40
    static let quitTag = 50
    struct Actions {
        let area: Selector, fixed: Selector, permission: Selector
        let settings: Selector, updates: Selector, quit: Selector
    }
    struct ShortcutPresentation {
        let equivalent: String?
        let modifiers: NSEvent.ModifierFlags
        let visual: String
        let spoken: String
    }
    static func shortcutDisplay(_ shortcut: Shortcut) -> String { presentation(shortcut).visual }
    static func presentation(_ shortcut: Shortcut) -> ShortcutPresentation {
        let modifiers = shortcutModifiers(shortcut)
        let prefix = (modifiers.contains(.control) ? "⌃" : "") + (modifiers.contains(.option) ? "⌥" : "")
            + (modifiers.contains(.shift) ? "⇧" : "") + (modifiers.contains(.command) ? "⌘" : "")
        var spoken = [String]()
        for (flag, key) in [(NSEvent.ModifierFlags.control, "shortcut.modifier.control"), (.option, "shortcut.modifier.option"),
                            (.shift, "shortcut.modifier.shift"), (.command, "shortcut.modifier.command")] where modifiers.contains(flag) {
            spoken.append(L10n.text(key))
        }
        let key = resolvedKey(shortcut.key)
        let visual = key?.visual ?? L10n.format("shortcut.key_number", String(shortcut.key))
        spoken.append(key?.spoken ?? visual)
        return ShortcutPresentation(equivalent: key?.equivalent, modifiers: modifiers, visual: prefix + visual, spoken: spoken.joined(separator: ", "))
    }
    static func shortcutModifiers(_ shortcut: Shortcut) -> NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if shortcut.modifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        if shortcut.modifiers & UInt32(optionKey) != 0 { flags.insert(.option) }
        if shortcut.modifiers & UInt32(shiftKey) != 0 { flags.insert(.shift) }
        if shortcut.modifiers & UInt32(cmdKey) != 0 { flags.insert(.command) }
        return flags
    }
    private static func resolvedKey(_ physical: UInt32) -> (equivalent: String, visual: String, spoken: String)? {
        let special: [UInt32: (Int, String, String)] = [
            36: (NSCarriageReturnCharacter, "↩", "shortcut.key.return"), 76: (NSEnterCharacter, "⌤", "shortcut.key.enter"),
            48: (NSTabCharacter, "⇥", "shortcut.key.tab"), 53: (0x1B, "⎋", "shortcut.key.escape"),
            51: (NSBackspaceCharacter, "⌫", "shortcut.key.backspace"), 117: (NSDeleteCharacter, "⌦", "shortcut.key.forward_delete"),
            123: (NSLeftArrowFunctionKey, "←", "shortcut.key.left"), 124: (NSRightArrowFunctionKey, "→", "shortcut.key.right"),
            125: (NSDownArrowFunctionKey, "↓", "shortcut.key.down"), 126: (NSUpArrowFunctionKey, "↑", "shortcut.key.up"),
            115: (NSHomeFunctionKey, "↖", "shortcut.key.home"), 119: (NSEndFunctionKey, "↘", "shortcut.key.end"),
            116: (NSPageUpFunctionKey, "⇞", "shortcut.key.page_up"), 121: (NSPageDownFunctionKey, "⇟", "shortcut.key.page_down")
        ]
        if let (code, visual, key) = special[physical], let scalar = UnicodeScalar(code) {
            return (String(scalar), visual, L10n.text(key))
        }
        let functionKeys: [UInt32] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 105, 107, 113, 106, 64, 79, 80, 90]
        if let number = functionKeys.firstIndex(of: physical), let scalar = UnicodeScalar(NSF1FunctionKey + number) {
            let name = "F\(number + 1)"; return (String(scalar), name, name)
        }
        guard physical < 128 else { return nil }
        // IMEs may lack Unicode layout data. Try the current keyboard-layout
        // source and its ASCII-capable fallback without changing input sources.
        let sources = [TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
                       TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
                       TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue()]
        for source in sources.compactMap({ $0 }) {
            guard let property = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { continue }
            let data = unsafeBitCast(property, to: CFData.self)
            guard let bytes = CFDataGetBytePtr(data) else { continue }
            let layout = UnsafeRawPointer(bytes).assumingMemoryBound(to: UCKeyboardLayout.self)
            var dead: UInt32 = 0; var count: Int = 0; var characters = [UniChar](repeating: 0, count: 8)
            let result = UCKeyTranslate(layout, UInt16(physical), UInt16(kUCKeyActionDisplay), 0,
                UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysMask), &dead, 8, &count, &characters)
            guard result == noErr, count == 1 else { continue }
            let key = String(utf16CodeUnits: characters, count: count)
            guard key.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value < 0xF700 }), key.lowercased().utf16.count == 1 else { continue }
            return (key.lowercased(), key.uppercased(), key.uppercased())
        }
        return nil
    }
    static func applyShortcut(to menu: NSMenu, mode: SelectionMode, presentation: ShortcutPresentation) {
        for tag in [areaTag, fixedTag] {
            guard let item = menu.item(withTag: tag) else { continue }
            item.attributedTitle = nil; item.keyEquivalent = ""; item.keyEquivalentModifierMask = []
            item.allowsAutomaticKeyEquivalentLocalization = false
            if !item.isHidden, tag == (mode == .drag ? areaTag : fixedTag) {
                item.keyEquivalent = presentation.equivalent ?? ""; item.keyEquivalentModifierMask = presentation.modifiers
                item.toolTip = presentation.spoken
            } else { item.toolTip = nil }
        }
    }
    static func make(ready: Bool, mode: SelectionMode, shortcut: Shortcut, presentation: ShortcutPresentation? = nil, canCheck: Bool,
                     target: AnyObject?, actions: Actions) -> NSMenu {
        let menu = NSMenu(); menu.font = DesignTokens.body; menu.autoenablesItems = false; menu.minimumWidth = 288
        func item(_ key: String, action: Selector, symbol: String? = nil) -> NSMenuItem {
            let item = NSMenuItem(title: L10n.text(key), action: action, keyEquivalent: "")
            item.target = target
            if let symbol {
                item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?.withSymbolConfiguration(.init(pointSize: 16, weight: .regular))
                item.image?.size = NSSize(width: 18, height: 18); item.image?.isTemplate = true
            }
            return item
        }
        let area = item("capture.area", action: actions.area); area.image = CaptureGlyph.image()
        let fixed = item("capture.fixed", action: actions.fixed, symbol: "rectangle.dashed")
        area.tag = areaTag; fixed.tag = fixedTag
        menu.addItem(area); menu.addItem(fixed); menu.addItem(.separator())
        let permission = item("menu.enable_access", action: actions.permission, symbol: "exclamationmark.circle")
        permission.tag = permissionTag; permission.isHidden = ready; menu.addItem(permission)
        let settings = item("menu.settings", action: actions.settings, symbol: "gearshape")
        settings.tag = settingsTag; settings.keyEquivalent = ","; settings.keyEquivalentModifierMask = .command; menu.addItem(settings)
        let updates = item("menu.updates", action: actions.updates, symbol: "arrow.down.circle")
        updates.tag = updatesTag; updates.isEnabled = canCheck; menu.addItem(updates)
        menu.addItem(.separator())
        let quit = item("menu.quit", action: actions.quit, symbol: "power"); quit.tag = quitTag; quit.keyEquivalent = "q"; quit.keyEquivalentModifierMask = .command; menu.addItem(quit)
        applyReadiness(to: menu, ready: ready)
        applyShortcut(to: menu, mode: mode, presentation: presentation ?? self.presentation(shortcut))
        return menu
    }
    // Menus can remain open while macOS changes permission. Hide their existing
    // capture rows before dispatch; recovery remains an explicitly named action.
    static func applyReadiness(to menu: NSMenu, ready: Bool) {
        let area = menu.item(withTag: areaTag)
        area?.isHidden = !ready; menu.item(withTag: fixedTag)?.isHidden = !ready
        if let area, let index = menu.items.firstIndex(of: area), menu.items.indices.contains(index + 2), menu.items[index + 2].isSeparatorItem {
            menu.items[index + 2].isHidden = !ready
        }
        menu.item(withTag: permissionTag)?.isHidden = ready
    }
    static func applicationMenu(ready: Bool, mode: SelectionMode, shortcut: Shortcut, presentation: ShortcutPresentation? = nil, canCheck: Bool,
                                target: AnyObject?, actions: Actions) -> NSMenu {
        let main = NSMenu(); main.font = DesignTokens.body
        let appItem = NSMenuItem(title: L10n.text("app.name"), action: nil, keyEquivalent: ""); main.addItem(appItem)
        let app = NSMenu(title: appItem.title); app.font = DesignTokens.body; appItem.submenu = app; app.autoenablesItems = false
        for (key, action, equivalent) in [("menu.settings", actions.settings, ","), ("menu.updates", actions.updates, "")] {
            let item = NSMenuItem(title: L10n.text(key), action: action, keyEquivalent: equivalent)
            item.target = target; item.keyEquivalentModifierMask = .command
            if key == "menu.updates" { item.tag = updatesTag; item.isEnabled = canCheck }
            app.addItem(item)
        }
        app.addItem(.separator())
        let hide = NSMenuItem(title: L10n.text("menu.hide"), action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"); hide.target = NSApp; app.addItem(hide)
        let others = NSMenuItem(title: L10n.text("menu.hide_others"), action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h"); others.keyEquivalentModifierMask = [.command, .option]; others.target = NSApp; app.addItem(others)
        let all = NSMenuItem(title: L10n.text("menu.show_all"), action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""); all.target = NSApp; app.addItem(all)
        app.addItem(.separator())
        let quit = NSMenuItem(title: L10n.text("menu.quit"), action: actions.quit, keyEquivalent: "q"); quit.target = target; app.addItem(quit)
        let captureItem = NSMenuItem(title: L10n.text("menu.capture"), action: nil, keyEquivalent: ""); main.addItem(captureItem)
        captureItem.submenu = make(ready: ready, mode: mode, shortcut: shortcut, presentation: presentation, canCheck: canCheck, target: target, actions: actions)
        let editItem = NSMenuItem(title: L10n.text("menu.edit"), action: nil, keyEquivalent: ""); main.addItem(editItem)
        let edit = NSMenu(title: editItem.title); edit.font = DesignTokens.body; editItem.submenu = edit
        for (key, action, equivalent) in [("menu.undo", "undo:", "z"), ("menu.redo", "redo:", "z"), ("menu.cut", "cut:", "x"), ("menu.copy", "copy:", "c"), ("menu.paste", "paste:", "v"), ("menu.select_all", "selectAll:", "a")] {
            let item = NSMenuItem(title: L10n.text(key), action: Selector(action), keyEquivalent: equivalent)
            item.keyEquivalentModifierMask = key == "menu.redo" ? [.command, .shift] : .command; edit.addItem(item)
        }
        let windowItem = NSMenuItem(title: L10n.text("menu.window"), action: nil, keyEquivalent: ""); main.addItem(windowItem)
        let windows = NSMenu(title: windowItem.title); windows.font = DesignTokens.body; windowItem.submenu = windows
        windows.addItem(NSMenuItem(title: L10n.text("menu.minimize"), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"))
        windows.addItem(NSMenuItem(title: L10n.text("menu.close"), action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        return main
    }
}
