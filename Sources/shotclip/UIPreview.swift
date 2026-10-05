import AppKit
import CoreText
import CaptureCore
import Darwin

// Inert view fixtures, not desktop screenshots. This path runs before preference
// preparation and AppDelegate, and never starts a hotkey, updater, capture or TCC.
enum UIPreview {
    private static var settingsLayoutEvidence = [[String: Any]]()
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
        // persistentDomain reads the explicitly named domain directly; no suite
        // initialization or persistence is needed in this read-only fixture.
        let defaults = UserDefaults.standard
        let preferencesBefore = defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain) ?? [:]
        let application = NSApplication.shared; application.setActivationPolicy(.prohibited)
        application.appearance = appearance
        let empty: () -> Void = {}
        var previewWindow: SettingsWindow!
        appearance.performAsCurrentDrawingAppearance {
            previewWindow = SettingsWindow(actions: .init(mask: empty, drag: empty, shortcut: empty, login: empty,
                request: empty, settings: empty, recheck: empty, restart: empty, reveal: empty,
                update: empty, automatic: { _ in }, language: { L10n.select($0) }))
            previewWindow.appearance = appearance
        }
        let window = previewWindow!
        let permission = { (ready: Bool) in PermissionStatus(isReady: ready, isAdHoc: true,
            bundleURL: URL(fileURLWithPath: "/Applications/Shot Clip.app"), version: "0.7.0 (9)") }
        let prefix = "\(language.rawValue)-\(appearanceName)"
        let shortcutDisplay = CaptureMenu.shortcutDisplay(Shortcut())
        var files: [String] = []
        var phase = "overlay-keyboard"
        func renderMinimum(_ label: String) throws {
            let originalFrame = window.frame
            window.setFrame(NSRect(origin: .zero, size: window.minSize), display: false)
            let filename = "\(prefix)-\(label)-minimum.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            window.setFrame(originalFrame, display: false)
        }
        do {
            if arguments.contains("--updater-only") {
                phase = "updater-fixture-only"
                try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
                let updateFiles = try UpdatePreview.run(output: output, appearance: appearance)
                guard NSDictionary(dictionary: preferencesBefore).isEqual(to: defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain) ?? [:]) else { throw PreviewError.behavior }
                let record: [String: Any] = ["case": "ui-preview-updater-only", "result": "PASS", "files": updateFiles, "preferencesWritten": false, "captureTested": false, "clipboardTouched": false]
                print(String(data: try JSONSerialization.data(withJSONObject: record, options: .sortedKeys), encoding: .utf8)!); fflush(stdout); exit(0)
            }
            let typography = AppTypography.auditEvidence
            guard typography["result"] as? String == "PASS" else { throw PreviewError.behavior }
            try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
            try JSONSerialization.data(withJSONObject: typography, options: [.sortedKeys, .prettyPrinted])
                .write(to: output.appendingPathComponent("\(prefix)-typography.json"))
            try verifyOverlayKeyboardInvariants()
            phase = "shortcut-menu-dispatch"
            try verifyShortcutAndMenuDispatch()
            phase = "settings-render"
            try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
            for (ready, state) in [(true, "ready"), (false, "access-needed")] {
                window.refresh(permission: permission(ready), shortcut: shortcutDisplay, login: L10n.text("login.off"),
                    update: L10n.text("updates.ready"), updateText: { L10n.text("updates.ready") }, automaticEnabled: false, configured: true, canCheck: true)
                guard window.previewControls.updateStatus.isHidden,
                      (window.previewControls.checkUpdates.accessibilityHelp() ?? "").isEmpty,
                      (window.previewControls.automatic.accessibilityHelp() ?? "").isEmpty else { throw PreviewError.behavior }
                for (section, label) in [(SettingsWindow.Section.general, "general"), (.permission, "access"), (.updates, "updates")] {
                    window.select(section)
                    for (minimum, size) in [(false, "default"), (true, "minimum")] {
                        if minimum { window.setFrame(NSRect(origin: .zero, size: window.minSize), display: false) }
                        else { window.setContentSize(NSSize(width: 720, height: 560)) }
                        let filename = "\(prefix)-\(label)-\(size)-\(state).png"
                        try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
                    }
                }
            }
            window.setContentSize(NSSize(width: 720, height: 560)); window.select(.permission)
            window.showTroubleshootingForPreview()
            var filename = "\(prefix)-access-troubleshooting.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            try renderMinimum("access-troubleshooting")
            window.select(.general)
            window.refresh(permission: permission(true), shortcut: shortcutDisplay, login: L10n.text("login.approval"), loginNeedsApproval: true,
                update: L10n.text("updates.busy"), updateText: { L10n.text("updates.busy") }, automaticEnabled: false, configured: true, canCheck: false)
            filename = "\(prefix)-general-approval.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            try renderMinimum("general-approval")
            window.select(.updates)
            filename = "\(prefix)-updates-busy.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            try renderMinimum("updates-busy")
            window.refresh(permission: permission(true), shortcut: shortcutDisplay, login: L10n.text("login.off"),
                update: L10n.text("updates.unconfigured"), updateText: { L10n.text("updates.unconfigured") }, automaticEnabled: false, configured: false, canCheck: false)
            filename = "\(prefix)-updates-unconfigured.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            try renderMinimum("updates-unconfigured")
            window.refresh(permission: permission(true), shortcut: shortcutDisplay, login: L10n.text("login.off"),
                update: L10n.format("updates.initialization_failed", "1001"), updateText: { L10n.format("updates.initialization_failed", "1001") }, automaticEnabled: false, configured: false, canCheck: false)
            filename = "\(prefix)-updates-error.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            try renderMinimum("updates-error")
            // A bounded synthetic status guarantees 3+ lines in the nested
            // manual-check label at both widths, independently of current copy.
            let longStatus = language == .english
                ? "The update check could not finish. Try again when your connection is available.\nIf this continues, check your connection and retry later.\nYour current version can still be used."
                : "업데이트 확인을 완료하지 못했습니다. 연결을 확인한 뒤 다시 시도해 주세요.\n문제가 계속되면 연결 상태를 확인하고 나중에 다시 시도해 주세요.\n현재 버전은 계속 사용할 수 있습니다."
            window.refresh(permission: permission(true), shortcut: shortcutDisplay, login: L10n.text("login.off"),
                update: longStatus, automaticEnabled: false, configured: true, canCheck: true)
            filename = "\(prefix)-updates-long-status.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            try renderMinimum("updates-long-status")
            try verifyGeometryRejectsClipping(window)
            let fakeActions = CaptureMenu.Actions(area: #selector(InertMenuReceiver.area(_:)), fixed: #selector(InertMenuReceiver.fixed(_:)),
                permission: #selector(InertMenuReceiver.noop(_:)), settings: #selector(InertMenuReceiver.noop(_:)), updates: #selector(InertMenuReceiver.noop(_:)), quit: #selector(InertMenuReceiver.noop(_:)))
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
                selection.layoutSubtreeIfNeeded()
                let toolbar = selection.previewToolbar
                guard toolbar.bounds.height == DesignTokens.toolbarHeight, toolbar.bounds.width <= 340,
                      abs(toolbar.frame.midX - scene.bounds.midX) < 1,
                      selection.previewToolbarControls.allSatisfy({ control in
                          let rect = control.convert(control.bounds, to: toolbar)
                          return toolbar.bounds.insetBy(dx: -1, dy: -1).contains(rect)
                      }) else { throw PreviewError.behavior }
                selection.cancel = empty; selection.selection = { _ in }; scene.addSubview(selection)
                filename = "\(prefix)-overlay-\(label).png"
                try render(scene, to: output.appendingPathComponent(filename)); files.append(filename)
            }
            phase = "live-language-transitions"
            try verifyLanguageTransitions(window: window, permission: permission(true),
                initial: language, appearance: appearance, output: output, files: &files)
            phase = "updater-fixture"
            files += try UpdatePreview.run(output: output, appearance: appearance)
            phase = "capture-preview-fixture"
            files += try CapturePreviewQA.run(output: output, appearance: appearance, nativeSavePanel: arguments.contains("--native-save-panel"))
            phase = "preference-preservation"
            guard NSDictionary(dictionary: preferencesBefore).isEqual(to: defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain) ?? [:]) else { throw PreviewError.behavior }
            let geometryFile = "\(prefix)-settings-geometry.json"
            try JSONSerialization.data(withJSONObject: settingsLayoutEvidence, options: [.sortedKeys, .prettyPrinted])
                .write(to: output.appendingPathComponent(geometryFile))
            let record: [String: Any] = ["case": "ui-preview", "result": "PASS", "language": language.rawValue,
                "appearance": appearanceName, "files": files, "nativeMenuPopupTested": false,
                "captureTested": false, "generalClipboardTouched": false, "namedClipboardTested": true, "preferencesWritten": false, "overlayKeyboardInvariants": true, "sameProcessLanguageTransitions": ["en-to-ko", "ko-to-en"],
                "settingsWindowPreserved": true, "settingsControlStatePreserved": true, "selectedSectionPreserved": true, "scrollOriginPreserved": true, "focusedControlPreserved": true,
                "settingsGeometryVerified": true, "settingsRootSizes": [[720, 560], [620, 480]], "settingsMinimumViewportHeight": 424,
                "settingsFullTextGeometryVerified": true, "googleFontsBundledAndShapingVerified": true, "squareNavigationTiles": true, "compactCaptureToolbarGeometry": true, "settingsMinimumContentPadding": 12, "settingsGeometryReport": geometryFile,
                "settingsGeometryNegativeCases": ["truncatedNestedStatus", "staleNestedWrappingWidth", "missingRowPadding"],
                "nativeMenuKeyEquivalents": true, "appMenuCaptions": true, "overlayLanguageRefresh": true, "sparkleDialogsTested": false, "localizedUpdateDriverFixture": true, "sparkleLiveUpgradeTested": false, "inertNativeMenuDispatch": true, "captureSingleFlight": true, "carbonRoutingTested": false, "currentKeyboardLayoutOnly": true, "alternateKeyboardLayoutsTested": false, "inputSourceSwitchTested": false]
            let data = try JSONSerialization.data(withJSONObject: record, options: .sortedKeys)
            print(String(data: data, encoding: .utf8)!); fflush(stdout)
            if arguments.contains("--native-menu") { showNativePreview(window: window, appearance: appearance) }
            exit(0)
        } catch {
            fputs("UI fixture failed: \(phase) / \(error)\n", stderr); exit(1)
        }
    }
    @MainActor private static func showNativePreview(window: SettingsWindow, appearance: NSAppearance) {
        // Explicit reviewer-only route. It retains the inert SettingsWindow and
        // a real native menu with dummy targets, never launching AppDelegate.
        let receiver = InertMenuReceiver()
        let actions = CaptureMenu.Actions(area: #selector(InertMenuReceiver.area(_:)), fixed: #selector(InertMenuReceiver.fixed(_:)),
            permission: #selector(InertMenuReceiver.noop(_:)), settings: #selector(InertMenuReceiver.noop(_:)),
            updates: #selector(InertMenuReceiver.noop(_:)), quit: #selector(InertMenuReceiver.finishPreview(_:)))
        let menu = CaptureMenu.make(ready: false, mode: .drag, shortcut: Shortcut(), canCheck: false, target: receiver, actions: actions)
        NSApp.setActivationPolicy(.regular)
        NSApp.mainMenu = CaptureMenu.applicationMenu(ready: false, mode: .drag, shortcut: Shortcut(), canCheck: false, target: receiver, actions: actions)
        window.select(.general); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            let chosen = menu.popUp(positioning: nil, at: NSPoint(x: window.contentView!.bounds.maxX - 300, y: window.contentView!.bounds.maxY - 72), in: window.contentView)
            print("{\"case\":\"ui-preview-native-menu\",\"result\":\"DISMISSED\",\"actionSelected\":\(chosen),\"dummyCaptureDispatches\":\(receiver.dispatches),\"captureTested\":false}")
            fflush(stdout); NSApp.stop(nil)
        }
        withExtendedLifetime(receiver) { NSApp.run() }
        window.close()
    }
    @MainActor private static func verifyShortcutAndMenuDispatch() throws {
        let stale = Shortcut(key: 23, label: "stale label is not a shortcut")
        let number = CaptureMenu.presentation(stale)
        let letter = CaptureMenu.presentation(Shortcut(key: 0, label: "wrong"))
        let punctuation = CaptureMenu.presentation(Shortcut(key: 27, label: "wrong"))
        let backspace = CaptureMenu.presentation(Shortcut(key: 51))
        let delete = CaptureMenu.presentation(Shortcut(key: 117))
        let enter = CaptureMenu.presentation(Shortcut(key: 76))
        let returnKey = CaptureMenu.presentation(Shortcut(key: 36))
        let left = CaptureMenu.presentation(Shortcut(key: 123))
        let function = CaptureMenu.presentation(Shortcut(key: 122))
        let unresolved = CaptureMenu.presentation(Shortcut(key: UInt32.max, label: "5"))
        guard let numberKey = number.equivalent, numberKey.utf16.count == 1, number.visual == "⌃⇧⌘" + numberKey.uppercased(), number.modifiers == [.control, .shift, .command] else { throw PreviewError.numberMapping }
        // Printable physical keys follow the active keyboard layout, which can
        // differ from US ANSI (including dead-key and input-method layouts).
        // A stale persisted label must never become a native equivalent.
        guard let letterKey = letter.equivalent, let punctuationKey = punctuation.equivalent,
              letterKey.utf16.count == 1, punctuationKey.utf16.count == 1,
              letter.visual == "⌃⇧⌘" + letterKey.uppercased(), punctuation.visual == "⌃⇧⌘" + punctuationKey.uppercased(),
              letterKey != "wrong", punctuationKey != "wrong" else { throw PreviewError.printableMapping }
        guard backspace.equivalent == "\u{8}", delete.equivalent == "\u{7f}", returnKey.equivalent == "\r", enter.equivalent == "\u{3}", left.equivalent == "\u{f702}" else { throw PreviewError.specialMapping }
        guard function.equivalent == "\u{f704}", function.visual == "⌃⇧⌘F1" else { throw PreviewError.functionMapping(code: function.equivalent?.unicodeScalars.first?.value ?? 0, visual: function.visual) }
        guard unresolved.equivalent == nil, unresolved.visual.contains(String(UInt32.max)), unresolved.visual != "⌃⇧⌘5", !number.spoken.isEmpty else { throw PreviewError.fallbackMapping }
        let receiver = InertMenuReceiver()
        let actions = CaptureMenu.Actions(area: #selector(InertMenuReceiver.area(_:)), fixed: #selector(InertMenuReceiver.fixed(_:)),
            permission: #selector(InertMenuReceiver.noop(_:)), settings: #selector(InertMenuReceiver.noop(_:)),
            updates: #selector(InertMenuReceiver.noop(_:)), quit: #selector(InertMenuReceiver.noop(_:)))
        for printable in [Shortcut(key: 0, label: "wrong"), Shortcut(key: 27, label: "wrong")] {
            let actual = CaptureMenu.presentation(printable)
            let menu = CaptureMenu.make(ready: true, mode: .drag, shortcut: printable, canCheck: true, target: receiver, actions: actions)
            guard menu.item(withTag: CaptureMenu.areaTag)?.keyEquivalent == actual.equivalent,
                  menu.item(withTag: CaptureMenu.areaTag)?.attributedTitle == nil,
                  menu.item(withTag: CaptureMenu.fixedTag)?.keyEquivalent.isEmpty == true else { throw PreviewError.printableMapping }
        }
        for mode in [SelectionMode.drag, .mask] {
            receiver.reset()
            let menu = CaptureMenu.make(ready: true, mode: mode, shortcut: stale, canCheck: true, target: receiver, actions: actions)
            guard let event = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: number.modifiers,
                timestamp: 0, windowNumber: 0, context: nil, characters: numberKey, charactersIgnoringModifiers: numberKey, isARepeat: false, keyCode: 23),
                menu.performKeyEquivalent(with: event), receiver.dispatches == 1, receiver.opened == 1, receiver.mode == mode else { throw PreviewError.menuDispatch }
            receiver.simulateGlobal(mode)
            guard receiver.dispatches == 2, receiver.opened == 1, receiver.broughtForward == 1 else { throw PreviewError.captureSingleFlight }
        }
    }
    @MainActor private static func verifyLanguageTransitions(window: SettingsWindow, permission: PermissionStatus,
        initial: AppLanguage, appearance: NSAppearance, output: URL, files: inout [String]) throws {
        let controls = window.previewControls
        let shortcutDisplay = CaptureMenu.shortcutDisplay(Shortcut())
        let windowIdentity = ObjectIdentifier(window)
        let languageIdentity = ObjectIdentifier(controls.language)
        let loginIdentity = ObjectIdentifier(controls.login)
        let automaticIdentity = ObjectIdentifier(controls.automatic)
        window.select(.general); window.makeFirstResponder(controls.language)
        window.refresh(permission: permission, shortcut: shortcutDisplay, login: L10n.text("login.on"), loginEnabled: true,
            update: L10n.text("updates.busy"), updateText: { L10n.text("updates.busy") }, automaticEnabled: true, configured: true, canCheck: false)
        let frame = window.frame
        let overlay = SelectionView(frame: NSRect(x: 0, y: 0, width: 960, height: 600))
        overlay.mode = .mask; overlay.rect = NSRect(x: 140, y: 150, width: 420, height: 230)
        let rect = overlay.rect
        let actions = CaptureMenu.Actions(area: #selector(InertMenuReceiver.area(_:)), fixed: #selector(InertMenuReceiver.fixed(_:)),
            permission: #selector(InertMenuReceiver.noop(_:)), settings: #selector(InertMenuReceiver.noop(_:)), updates: #selector(InertMenuReceiver.noop(_:)), quit: #selector(InertMenuReceiver.noop(_:)))
        var baselineEquivalent: String?
        for destination in [initial == .english ? AppLanguage.korean : .english, initial] {
            let sourceLanguage = L10n.language
            controls.language.selectItem(at: AppLanguage.allCases.firstIndex(of: destination)!)
            guard let action = controls.language.action,
                  controls.language.sendAction(action, to: controls.language.target) else { throw PreviewError.behavior }
            guard L10n.language == destination, ObjectIdentifier(window) == windowIdentity, window.frame == frame,
                  window.selectedSection == .general, window.firstResponder === controls.language,
                  ObjectIdentifier(window.previewControls.language) == languageIdentity,
                  ObjectIdentifier(window.previewControls.login) == loginIdentity,
                  ObjectIdentifier(window.previewControls.automatic) == automaticIdentity,
                  controls.login.state == .on, controls.login.isEnabled, controls.automatic.state == .on,
                  controls.automatic.isEnabled, !controls.checkUpdates.isEnabled, controls.shortcut.title == shortcutDisplay,
                  controls.language.indexOfSelectedItem == AppLanguage.allCases.firstIndex(of: destination),
                  overlay.mode == .mask, overlay.rect == rect,
                  overlay.accessibilityLabel() == (destination == .english ? "Capture selection" : "캡처 영역 선택") else { throw PreviewError.behavior }
            let expectedTitle = destination == .english ? "Shot Clip Settings" : "Shot Clip 설정"
            let expectedSettings = destination == .english ? "Settings…" : "설정…"
            let expectedArea = destination == .english ? "Capture Area" : "영역 캡처"
            guard window.title == expectedTitle,
                  controls.updateStatus.stringValue == (destination == .english ? "Update checking is temporarily unavailable while the updater is busy." : "업데이트 처리 중에는 잠시 새 업데이트를 확인할 수 없습니다."),
                  controls.permissionTitle.stringValue == (destination == .english ? "Screen Recording is ready" : "화면 기록 준비 완료"),
                  controls.pageTitle.stringValue == (destination == .english ? "General" : "일반"),
                  controls.loginLabel.stringValue == (destination == .english ? "Launch at login" : "로그인 시 시작"),
                  controls.automaticLabel.stringValue == (destination == .english ? "Automatically check for updates" : "자동으로 업데이트 확인") else { throw PreviewError.behavior }
            for mode in [SelectionMode.drag, .mask] {
                let menu = CaptureMenu.make(ready: true, mode: mode, shortcut: Shortcut(), canCheck: false, target: nil, actions: actions)
                let app = CaptureMenu.applicationMenu(ready: true, mode: mode, shortcut: Shortcut(), canCheck: false, target: nil, actions: actions)
                guard let capture = app.items[1].submenu,
                      let current = menu.item(withTag: mode == .drag ? CaptureMenu.areaTag : CaptureMenu.fixedTag),
                      let other = menu.item(withTag: mode == .drag ? CaptureMenu.fixedTag : CaptureMenu.areaTag),
                      current.attributedTitle == nil, current.view == nil, !current.keyEquivalent.isEmpty,
                      current.keyEquivalentModifierMask == [.control, .shift, .command], other.keyEquivalent.isEmpty,
                      menu.item(withTag: CaptureMenu.areaTag)?.title == expectedArea,
                      menu.item(withTag: CaptureMenu.settingsTag)?.title == expectedSettings,
                      menu.item(withTag: CaptureMenu.settingsTag)?.keyEquivalent == ",",
                      menu.item(withTag: CaptureMenu.settingsTag)?.keyEquivalentModifierMask == .command,
                      menu.item(withTag: CaptureMenu.quitTag)?.keyEquivalent == "q",
                      menu.item(withTag: CaptureMenu.quitTag)?.keyEquivalentModifierMask == .command,
                      menu.item(withTag: CaptureMenu.updatesTag)?.isEnabled == false,
                      capture.items.map(\.title) == menu.items.map(\.title),
                      capture.items.map(\.keyEquivalent) == menu.items.map(\.keyEquivalent),
                      app.items[0].submenu?.items.first?.title == expectedSettings,
                      app.items[2].title == (destination == .english ? "Edit" : "편집"),
                      app.items[3].title == (destination == .english ? "Window" : "윈도우") else { throw PreviewError.behavior }
                if let baselineEquivalent { guard current.keyEquivalent == baselineEquivalent else { throw PreviewError.behavior } }
                else { baselineEquivalent = current.keyEquivalent }
            }
            let label = "live-\(sourceLanguage.rawValue)-to-\(destination.rawValue)"
            let filename = "\(label)-\(appearance.name.rawValue)-general.png"
            try render(window.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            window.select(.permission); window.showTroubleshootingForPreview()
            window.contentView?.layoutSubtreeIfNeeded()
            let scroll = window.previewScrollView
            scroll.contentView.scroll(to: NSPoint(x: 0, y: 30)); scroll.reflectScrolledClipView(scroll.contentView)
            let origin = scroll.contentView.bounds.origin
            let focused = window.firstResponder
            guard origin.y > 0 else { throw PreviewError.behavior }
            L10n.select(destination == .english ? .korean : .english)
            guard scroll.contentView.bounds.origin == origin, window.firstResponder === focused, window.selectedSection == .permission, window.troubleshootingVisible, window.frame == frame else { throw PreviewError.behavior }
            L10n.select(destination)
            guard window.selectedSection == .permission, window.troubleshootingVisible, window.frame == frame, scroll.contentView.bounds.origin == origin, window.firstResponder === focused else { throw PreviewError.behavior }
            let accessFile = "\(label)-\(appearance.name.rawValue)-access-troubleshooting.png"
            try render(window.contentView!, to: output.appendingPathComponent(accessFile)); files.append(accessFile)
            window.select(.general); window.makeFirstResponder(controls.language)
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
        // NSWindow owns its root frame and guide. Examine the complete native
        // layout rather than trusting a content subtree's fitting size.
        view.window?.layoutIfNeeded()
        view.layoutSubtreeIfNeeded()
        if let window = view.window as? SettingsWindow {
            let size = view.bounds.size
            guard window.previewRailButtons.allSatisfy({ abs($0.bounds.width - DesignTokens.controlSize) <= 1 && abs($0.bounds.height - DesignTokens.controlSize) <= 1 }) else {
                throw PreviewError.textGeometry(output.lastPathComponent, "rail sizes \(window.previewRailButtons.map { $0.bounds.size })")
            }
            let heading = window.previewControls.pageTitle
            let availableTitleWidth = size.width - DesignTokens.railWidth - DesignTokens.controlSize - DesignTokens.settingsInset
            guard abs(heading.alignmentRect(forFrame: heading.frame).width - availableTitleWidth) <= 0.5 else {
                throw PreviewError.textGeometry(output.lastPathComponent, "header width \(heading.bounds.width) / available \(availableTitleWidth)")
            }
            for field in [heading, window.previewVersionValue] where !field.isHiddenOrHasHiddenAncestor {
                let drawing = field.cell!.drawingRect(forBounds: field.bounds)
                let line = CTLineCreateWithAttributedString(field.attributedStringValue)
                let fullWidth = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
                let storage = NSTextStorage(attributedString: field.attributedStringValue)
                let layout = NSLayoutManager(); let container = NSTextContainer(containerSize: NSSize(width: drawing.width, height: 100_000))
                container.lineFragmentPadding = 0; container.lineBreakMode = field.cell!.lineBreakMode
                storage.addLayoutManager(layout); layout.addTextContainer(container); layout.ensureLayout(for: container)
                var lines = 0; layout.enumerateLineFragments(forGlyphRange: layout.glyphRange(for: container)) { _, _, _, _, _ in lines += 1 }
                guard lines == 1, drawing.width + 0.5 >= fullWidth, drawing.height + 0.5 >= layout.usedRect(for: container).height else {
                    throw PreviewError.textGeometry(output.lastPathComponent, "single-line header/version height \(drawing.height), width \(drawing.width), neededWidth \(fullWidth), lines \(lines)")
                }
            }
            let geometry = window.previewGeometry
            guard [NSSize(width: 720, height: 560), NSSize(width: 620, height: 480)].contains(size),
                  window.contentLayoutRect.size == size,
                  window.contentRect(forFrameRect: window.frame).size == size,
                  geometry.pages.width == size.width - 72, geometry.pages.height == size.height - 56,
                  geometry.viewport.height >= size.height - 57,
                  geometry.viewport.width >= size.width - 90,
                  geometry.document.height >= 200, geometry.document.width >= size.width - 90,
                  !window.previewScrollView.isHidden,
                  geometry.controls.allSatisfy({ $0.bounds.width > 0 && $0.bounds.height > 0 && !$0.isHiddenOrHasHiddenAncestor })
            else { throw PreviewError.settingsGeometry(root: size, pages: geometry.pages.size, viewport: geometry.viewport.size) }
            try verifySettingsTextGeometry(window, filename: output.lastPathComponent)
        }
        view.effectiveAppearance.performAsCurrentDrawingAppearance {
            view.layoutSubtreeIfNeeded()
            guard let cached = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
            if view.window is SettingsWindow {
                let backing = view.convertToBacking(view.bounds).size
                guard cached.pixelsWide == Int(backing.width.rounded()), cached.pixelsHigh == Int(backing.height.rounded()) else { return }
            }
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
    @MainActor private static func verifyGeometryRejectsClipping(_ window: SettingsWindow) throws {
        window.layoutIfNeeded(); window.contentView?.layoutSubtreeIfNeeded()
        let field = window.previewControls.updateStatus
        guard let row = window.previewLayout.rows.first(where: { field.isDescendant(of: $0.view) }) else { throw PreviewError.behavior }
        func expectRejection(_ reason: String, mutate: () -> Void, restore: () -> Void) throws {
            mutate()
            defer { restore() }
            do { try verifySettingsTextGeometry(window, filename: "geometry-negative", recordEvidence: false) }
            catch PreviewError.textGeometry(_, let actual) where actual.hasPrefix(reason) { return }
            throw PreviewError.behavior
        }
        let frame = field.frame
        try expectRejection("full-text", mutate: { field.setFrameSize(NSSize(width: frame.width, height: 1)) }, restore: { field.frame = frame })
        let width = field.preferredMaxLayoutWidth
        try expectRejection("stale-wrapping-width", mutate: { field.preferredMaxLayoutWidth = width + 20 }, restore: { field.preferredMaxLayoutWidth = width })
        let label = row.content[0]; let labelFrame = label.frame
        try expectRejection("row-padding", mutate: { label.setFrameOrigin(NSPoint(x: labelFrame.minX, y: 0)) }, restore: { label.frame = labelFrame })
        try verifySettingsTextGeometry(window, filename: "geometry-restored", recordEvidence: false)
    }
    @MainActor private static func verifySettingsTextGeometry(_ window: SettingsWindow, filename: String, recordEvidence: Bool = true) throws {
        let tolerance: CGFloat = 0.5
        var textMetrics = [[String: Any]]()
        func descendants(_ view: NSView) -> [NSView] { [view] + view.subviews.flatMap(descendants) }
        func rowContent(_ view: NSView) -> [NSView] {
            // Native control internals can draw shadows beyond the public
            // alignment rectangle; they are not app-owned label containers.
            [view] + (view is NSControl ? [] : view.subviews.flatMap(rowContent))
        }
        func contains(_ outer: NSRect, _ inner: NSRect) -> Bool {
            outer.insetBy(dx: -tolerance, dy: -tolerance).contains(inner)
        }
        let document = window.previewScrollView.documentView!
        for stack in rowContent(document).compactMap({ $0 as? NSStackView }) where stack.orientation == .horizontal && !stack.isHiddenOrHasHiddenAncestor {
            let children = stack.arrangedSubviews.filter { !$0.isHiddenOrHasHiddenAncestor }
            let rects = children.map { stack.convert($0.alignmentRect(forFrame: $0.frame), from: $0.superview!) }
            guard let first = rects.first, let last = rects.last,
                  abs(first.minX - stack.edgeInsets.left) <= tolerance,
                  abs(last.maxX - (stack.bounds.maxX - stack.edgeInsets.right)) <= tolerance else { throw PreviewError.textGeometry(filename, "unused-nested-label-width") }
            for (left, right) in zip(rects, rects.dropFirst()) {
                guard abs(right.minX - left.maxX - stack.spacing) <= tolerance else { throw PreviewError.textGeometry(filename, "excess-nested-label-gap") }
            }
        }
        // Sections, cards, nested label columns and footer neighbors all obey
        // arranged order. This catches overlaps outside the selected controls.
        for stack in descendants(document).compactMap({ $0 as? NSStackView }) where stack.orientation == .vertical && !stack.isHiddenOrHasHiddenAncestor {
            var previousBottom: CGFloat?
            for child in stack.arrangedSubviews where !child.isHiddenOrHasHiddenAncestor {
                let rect = stack.convert(child.alignmentRect(forFrame: child.frame), from: child.superview!)
                let top = stack.isFlipped ? rect.minY : stack.bounds.maxY - rect.maxY
                let bottom = top + rect.height
                guard contains(stack.bounds, rect), previousBottom == nil || top + tolerance >= previousBottom! else { throw PreviewError.textGeometry(filename, "section-or-nested-stack-overlap") }
                previousBottom = bottom
            }
        }
        for field in rowContent(document).compactMap({ $0 as? NSTextField }) where !field.isHiddenOrHasHiddenAncestor && !field.stringValue.isEmpty {
            guard let cell = field.cell else { throw PreviewError.textGeometry(filename, "missing-cell") }
            let drawing = cell.drawingRect(forBounds: field.bounds)
            let storage = NSTextStorage(attributedString: field.attributedStringValue)
            let layout = NSLayoutManager(); let container = NSTextContainer(containerSize: NSSize(width: drawing.width, height: CGFloat.greatestFiniteMagnitude))
            container.lineFragmentPadding = 0; container.lineBreakMode = cell.lineBreakMode
            storage.addLayoutManager(layout); layout.addTextContainer(container); layout.ensureLayout(for: container)
            let glyphs = layout.glyphRange(for: container)
            let used = layout.usedRect(for: container)
            let needed = cell.cellSize(forBounds: NSRect(x: 0, y: 0, width: field.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            var lines = 0
            layout.enumerateLineFragments(forGlyphRange: glyphs) { _, _, _, _, _ in lines += 1 }
            guard drawing.width > 0, glyphs.length == layout.numberOfGlyphs,
                  field.bounds.height + tolerance >= needed.height, drawing.height + tolerance >= used.height,
                  contains(field.superview!.bounds, field.alignmentRect(forFrame: field.frame)) else {
                throw PreviewError.textGeometry(filename, "full-text height \(field.bounds.height) / cell \(needed.height) / text \(used.height) / drawing \(drawing.height), width \(field.bounds.width), lines \(lines), field \(field.frame), parent \(field.superview!.bounds)")
            }
            if cell.wraps {
                guard abs(field.preferredMaxLayoutWidth - field.bounds.width) <= tolerance else { throw PreviewError.textGeometry(filename, "stale-wrapping-width") }
            }
            if window.previewLayout.headings.contains(where: { $0 === field }) {
                guard lines == 1, abs(field.alignmentRect(forFrame: field.frame).width - (field.superview!.bounds.width - 24)) <= tolerance else { throw PreviewError.textGeometry(filename, "heading-width-or-wrapping") }
            }
            textMetrics.append(["width": field.bounds.width, "height": field.bounds.height, "fullTextHeight": needed.height,
                "drawingHeight": drawing.height, "glyphHeight": used.height, "lines": lines, "characters": field.stringValue.count])
        }
        var rowMetrics = [[String: Any]]()
        for row in window.previewLayout.rows where !row.view.isHiddenOrHasHiddenAncestor {
            guard contains(document.bounds, row.view.convert(row.view.bounds, to: document)) else { throw PreviewError.textGeometry(filename, "row-outside-document") }
            var minimumPadding = CGFloat.greatestFiniteMagnitude
            for content in row.content where !content.isHiddenOrHasHiddenAncestor {
                for child in rowContent(content) where !child.isHiddenOrHasHiddenAncestor {
                    // Native buttons/switches include ornamentation outside
                    // their alignment bounds. Full text-field bounds remain
                    // strict, including every nested multiline label.
                    let rect = child is NSControl && !(child is NSTextField)
                        ? child.superview!.convert(child.alignmentRect(forFrame: child.frame), to: row.view)
                        : child.convert(child.bounds, to: row.view)
                    let padding = min(rect.minY - row.view.bounds.minY, row.view.bounds.maxY - rect.maxY)
                    guard padding + tolerance >= 12, contains(row.view.bounds, rect) else { throw PreviewError.textGeometry(filename, "row-padding \(padding), \(type(of: child)), rect \(rect), row \(row.view.bounds)") }
                    minimumPadding = min(minimumPadding, padding)
                }
            }
            rowMetrics.append(["height": row.view.bounds.height, "minimumPadding": minimumPadding])
        }
        for card in window.previewLayout.cards where !card.view.isHiddenOrHasHiddenAncestor {
            var previous: NSRect?
            for child in card.content where !child.isHiddenOrHasHiddenAncestor {
                // Use a flipped comparison space even though the native card
                // is unflipped, so arranged order has monotonically increasing y.
                let rect = child.superview!.convert(child.alignmentRect(forFrame: child.frame), to: card.view)
                let top = card.view.bounds.maxY - rect.maxY
                let bottom = card.view.bounds.maxY - rect.minY
                guard contains(card.view.bounds, rect), previous == nil || top + tolerance >= previous!.maxY else { throw PreviewError.textGeometry(filename, "card-or-separator-overlap: card \(card.view.bounds), child \(rect), previous \(String(describing: previous))") }
                previous = NSRect(x: rect.minX, y: top, width: rect.width, height: bottom - top)
            }
        }
        for footer in window.previewLayout.footers where !footer.view.isHiddenOrHasHiddenAncestor {
            let rect = footer.content.convert(footer.content.bounds, to: footer.view)
            guard rect.minY - footer.view.bounds.minY + tolerance >= 12,
                  footer.view.bounds.maxY - rect.maxY + tolerance >= 12,
                  contains(document.bounds, footer.view.convert(footer.view.bounds, to: document)) else { throw PreviewError.textGeometry(filename, "footer-padding-or-document") }
        }
        if filename.contains("long-status") {
            guard textMetrics.contains(where: { ($0["lines"] as? Int ?? 0) >= 3 }), !window.previewControls.updateStatus.isHidden else { throw PreviewError.textGeometry(filename, "missing-long-status") }
        }
        if recordEvidence {
            settingsLayoutEvidence.append(["file": filename, "section": window.selectedSection.rawValue, "rows": rowMetrics, "labels": textMetrics,
                "root": [window.contentView!.bounds.width, window.contentView!.bounds.height], "documentHeight": document.bounds.height, "minimumRequiredPadding": 12])
        }
    }
    private enum PreviewError: Error {
        case render, behavior, numberMapping, printableMapping, specialMapping, fallbackMapping, menuDispatch, captureSingleFlight
        case settingsGeometry(root: NSSize, pages: NSSize, viewport: NSSize)
        case functionMapping(code: UInt32, visual: String)
        case textGeometry(String, String)
    }
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
                let plainTitle = item.title
                (plainTitle as NSString).draw(at: NSPoint(x: 41, y: y), withAttributes: [.font: menuModel.font ?? DesignTokens.body, .foregroundColor: NSColor.labelColor])
                var hint = ""
                if !item.keyEquivalent.isEmpty {
                    let flags = item.keyEquivalentModifierMask
                    hint = (flags.contains(.control) ? "⌃" : "") + (flags.contains(.option) ? "⌥" : "")
                        + (flags.contains(.shift) ? "⇧" : "") + (flags.contains(.command) ? "⌘" : "")
                        + item.keyEquivalent.uppercased()
                }
                if !hint.isEmpty {
                    let attributes: [NSAttributedString.Key: Any] = [.font: DesignTokens.caption, .foregroundColor: NSColor.secondaryLabelColor]
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

// Exercises native NSMenu action dispatch and existing CaptureCoordinator's
// single-flight semantics without a Carbon registration, overlay, or capture.
@MainActor private final class InertMenuReceiver: NSObject {
    private var coordinator = CaptureCoordinator<Bool>()
    private(set) var dispatches = 0
    private(set) var opened = 0
    private(set) var broughtForward = 0
    private(set) var mode: SelectionMode?
    func reset() { coordinator.cancel(); dispatches = 0; opened = 0; broughtForward = 0; mode = nil }
    @objc func area(_ sender: Any?) { begin(.drag) }
    @objc func fixed(_ sender: Any?) { begin(.mask) }
    @objc func noop(_ sender: Any?) {}
    @objc func finishPreview(_ sender: Any?) { NSApp.stop(nil) }
    func simulateGlobal(_ mode: SelectionMode) { begin(mode) }
    private func begin(_ mode: SelectionMode) {
        dispatches += 1; self.mode = mode
        switch coordinator.begin(permission: true) {
        case .opened: opened += 1
        case .bringForward: broughtForward += 1
        default: break
        }
    }
}
