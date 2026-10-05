#if SHOTCLIP_QA
import AppKit
import CaptureCore

// Synthetic pixels and an isolated named pasteboard exercise the production
// presentation and encoding paths. This never captures a screen, touches the
// general pasteboard, invokes TCC or starts AppDelegate.
enum CapturePreviewQA {
    private enum Failure: Error { case assertion(String), image, render, wrongMode }

    @MainActor static func run(output: URL, appearance: NSAppearance, nativeSavePanel: Bool = false) throws -> [String] {
        guard CommandLine.arguments.contains("--ui-preview") else { throw Failure.wrongMode }
        let initialLanguage = L10n.language
        let manualNativeSave = nativeSavePanel && CommandLine.arguments.contains("--native-save-manual")
        let errorUIRequested = CommandLine.arguments.contains("--native-save-error-ui")
        guard !errorUIRequested || nativeSavePanel else { throw Failure.wrongMode }
        let originalActivationPolicy = NSApp.activationPolicy()
        defer {
            if manualNativeSave { NSApp.setActivationPolicy(originalActivationPolicy) }
        }
        defer { L10n.select(initialLanguage) }
        var checks = 0; var files: [String] = []
        func require(_ condition: @autoclosure () -> Bool, _ description: String) throws {
            checks += 1
            guard condition() else { throw Failure.assertion(description) }
        }
        let prefix = "\(initialLanguage.rawValue)-\(appearance.name.rawValue)-capture-preview"
        let board = NSPasteboard(name: .init("dev.shotclip.qa.capture-preview.\(UUID().uuidString)"))
        defer { board.releaseGlobally() }
        let image = try makeImage(width: 2048, height: 1280)
        board.clearContents(); board.setString("Synthetic clipboard sentinel", forType: .string)
        try ClipboardService(board).store(image)
        let generation = board.changeCount
        guard let png = board.data(forType: .png), let tiff = board.data(forType: .tiff) else { throw Failure.image }
        func clipboardPreserved(_ description: String) throws {
            try require(board.changeCount == generation && board.data(forType: .png) == png && board.data(forType: .tiff) == tiff, description)
        }
        let visible = NSRect(x: -1728, y: 773, width: 1728, height: 1117)
        let controller = CapturePreviewController(presentWindows: false, thumbnailLifetime: nil)
        defer { controller.dismiss() }
        controller.show(image, visibleFrame: visible)
        guard let thumbnail = controller.thumbnail, let thumbnailView = thumbnail.contentView else { throw Failure.image }
        thumbnail.appearance = appearance
        try require(thumbnail.frame.minX == visible.maxX - thumbnail.frame.width - DesignTokens.screenInset &&
            thumbnail.frame.minY == visible.minY + DesignTokens.screenInset && visible.contains(thumbnail.frame), "capture-screen-bottom-right")
        try require(thumbnail.styleMask.contains(.nonactivatingPanel) && !thumbnail.canBecomeKey, "nonactivating-thumbnail")
        let thumbnailFile = prefix + "-thumbnail.png"
        try render(thumbnailView, to: output.appendingPathComponent(thumbnailFile)); files.append(thumbnailFile)
        var captionGeometry = [[String: Any]]()
        captionGeometry.append(try verifyThumbnailCaption(controller, expectedLines: 1))
        try require(controller.thumbnailCaptionForPreview is WrappingLabel, "thumbnail-uses-shared-fallback-font-height")
        for (captionLanguage, text) in [("en", "Copied to clipboard\nClick to preview or save"),
            ("ko", "클립보드에 복사했습니다\n열어서 확인하거나 저장하세요")] {
            controller.setThumbnailCaptionForPreview(text); thumbnailView.layoutSubtreeIfNeeded()
            var metrics = try verifyThumbnailCaption(controller, expectedLines: 2)
            metrics["syntheticLanguage"] = captionLanguage; captionGeometry.append(metrics)
            let filename = prefix + "-thumbnail-multiline-" + captionLanguage + ".png"
            try render(thumbnailView, to: output.appendingPathComponent(filename)); files.append(filename)
        }
        guard let caption = controller.thumbnailCaptionForPreview else { throw Failure.image }
        let captionFrame = caption.frame
        caption.setFrameSize(NSSize(width: captionFrame.width, height: 1))
        var captionClippingRejected = false
        do { _ = try verifyThumbnailCaption(controller, expectedLines: 2) }
        catch Failure.assertion(_) { captionClippingRejected = true }
        caption.frame = captionFrame
        try require(captionClippingRejected, "thumbnail-geometry-rejects-glyph-clipping")
        controller.refreshLanguage(); thumbnailView.layoutSubtreeIfNeeded()
        _ = try verifyThumbnailCaption(controller, expectedLines: 1)
        try clipboardPreserved("thumbnail-shown-keeps-image")
        controller.clickThumbnailForPreview()
        guard let preview = controller.preview else { throw Failure.image }
        preview.appearance = appearance; preview.contentView?.layoutSubtreeIfNeeded(); preview.updateImageLayout()
        try require(controller.thumbnail == nil && preview.originalImage.width == 2048 && preview.originalImage.height == 1280,
            "thumbnail-click-opens-original")
        try require(preview.originalImage === image, "preview-retains-original-cgimage")
        let fitted = preview.previewImageFrame
        let viewport = preview.scrollView.contentView.bounds.size
        try require(fitted.width > 0 && fitted.height > 0 && fitted.width <= viewport.width - DesignTokens.previewImagePadding * 2 + 1 &&
            fitted.height <= viewport.height - DesignTokens.previewImagePadding * 2 + 1 && abs(fitted.width / fitted.height - 1.6) < 0.001, "fit-keeps-whole-image-aspect")
        var filename = prefix + "-fit.png"
        try render(preview.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
        preview.zoomControl.selectedSegment = 1
        try require(preview.zoomControl.sendAction(preview.zoomControl.action, to: preview.zoomControl.target), "native-zoom-action")
        let fullSize = preview.previewImageFrame.size
        try require(abs(fullSize.width * preview.backingScaleFactor - 2048) < 1 && abs(fullSize.height * preview.backingScaleFactor - 1280) < 1,
            "100-percent-image-pixels")
        try require(preview.previewDocumentSize.width > viewport.width && preview.previewDocumentSize.height > viewport.height, "100-percent-scroll-document")
        preview.scrollView.contentView.scroll(to: NSPoint(x: 80, y: 60)); preview.scrollView.reflectScrolledClipView(preview.scrollView.contentView)
        try require(preview.scrollView.contentView.bounds.origin.x > 0 && preview.scrollView.contentView.bounds.origin.y > 0, "original-scrolls")
        filename = prefix + "-actual-size.png"
        try render(preview.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
        try clipboardPreserved("preview-open-and-zoom-keeps-image")

        let nativePanel = preview.makeSavePanel()
        try require(nativePanel.allowedContentTypes == [.png] && !nativePanel.allowsOtherFileTypes && !nativePanel.isExtensionHidden,
            "native-png-save-panel-policy")
        let savedURL = output.appendingPathComponent(prefix + "-synthetic-original.png")
        try preview.writePNG(to: savedURL)
        guard let saved = NSBitmapImageRep(data: try Data(contentsOf: savedURL))?.cgImage else { throw Failure.image }
        let originalPixels = try pixelBytes(image)
        let savedPixels = try pixelBytes(saved)
        try require(saved.width == image.width && saved.height == image.height && savedPixels == originalPixels, "png-keeps-original-pixels")
        try clipboardPreserved("save-original-keeps-image")
        let badURL = output.appendingPathComponent("missing-\(UUID().uuidString)", isDirectory: true).appendingPathComponent("synthetic.png")
        do { try preview.writePNG(to: badURL); throw Failure.assertion("save-error-not-reported") }
        catch let error as Failure { throw error }
        catch { try clipboardPreserved("save-error-keeps-image") }

        let windowID = ObjectIdentifier(preview)
        for language in [initialLanguage == .english ? AppLanguage.korean : .english, initialLanguage] {
            L10n.select(language); controller.refreshLanguage()
            try require(controller.preview.map(ObjectIdentifier.init) == windowID && preview.title == L10n.text("capture.preview.title") &&
                preview.saveButton.title == L10n.text("capture.preview.save") && preview.originalImage === image,
                "preview-live-language-keeps-window-and-image")
            try clipboardPreserved("language-change-keeps-image")
        }

        var nativeCanceled = false; var nativeAccepted = false
        var nativeCloseCanceled = false; var nativeReplacementCanceled = false
        var nativeSaveErrorUI = false; var nativeSaveErrorRecovery = false
        if nativeSavePanel {
            // Real native sheets receive synthetic user actions, confined to the
            // QA output directory. No normal application window is involved.
            if manualNativeSave {
                try require(NSApp.setActivationPolicy(.regular), "native-manual-regular-activation")
                // UIPreview deliberately never calls NSApplication.run. Finish
                // only the native AppKit startup here, with no AppDelegate, and
                // dispatch application events below so real mouse/AX actions
                // reach the save sheet instead of servicing timers alone.
                NSApp.finishLaunching()
                if let screen = NSScreen.main {
                    preview.setFrameOrigin(NSPoint(x: screen.visibleFrame.midX - preview.frame.width / 2,
                        y: screen.visibleFrame.midY - preview.frame.height / 2))
                }
                NSApp.activate(ignoringOtherApps: true); preview.makeKeyAndOrderFront(nil)
            } else { preview.orderFront(nil) }
            preview.onSavePanelPresented = { panel in
                DispatchQueue.main.async { panel.cancel(nil) }
            }
            preview.saveButton.performClick(nil); preview.saveButton.performClick(nil)
            try pumpUntil(dispatchNativeEvents: manualNativeSave) { preview.lastSaveResponse == .cancel }
            try require(preview.saveRequests == 1 && preview.saveCompletions == 1 && preview.saveButton.isEnabled, "native-save-cancel-once")
            try clipboardPreserved("native-save-cancel-keeps-image"); nativeCanceled = true

            let acceptedURL = output.appendingPathComponent(prefix + "-native-saved-\(UUID().uuidString).png")
            preview.configureSavePanelForPreview = { panel in
                panel.directoryURL = output; panel.nameFieldStringValue = acceptedURL.lastPathComponent
            }
            var defaultButtonUnavailable = false
            preview.onSavePanelPresented = { panel in
                if !manualNativeSave {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Invoke the real native default button's action. The
                        // inherited NSSavePanel.ok(_:) can raise on modern
                        // remote sheets and is not an acceptance harness.
                        guard let button = panel.defaultButtonCell else {
                            defaultButtonUnavailable = true; panel.cancel(nil); return
                        }
                        button.performClick(nil)
                    }
                }
            }
            let markerURL = output.appendingPathComponent(prefix + "-native-save-awaiting.json")
            var marker: [String: Any] = ["case": "capture-preview-native-save", "state": "awaiting-real-native-save",
                "processPID": ProcessInfo.processInfo.processIdentifier, "outputDirectory": output.path,
                "expectedFile": acceptedURL.path, "syntheticPixelsOnly": true, "generalClipboardTouched": false,
                "acceptanceRoute": manualNativeSave ? "external-native-GUI" : "public-default-button-cell",
                "nativeApplicationEventDispatch": manualNativeSave, "activationPolicy": manualNativeSave ? "regular" : "prohibited"]
            try JSONSerialization.data(withJSONObject: marker, options: [.prettyPrinted, .sortedKeys]).write(to: markerURL)
            preview.saveButton.performClick(nil)
            try pumpUntil(timeout: manualNativeSave ? 90 : 5, dispatchNativeEvents: manualNativeSave) { preview.lastSaveResponse == .OK || defaultButtonUnavailable }
            try require(!defaultButtonUnavailable, "native-default-button-unavailable-use-native-save-manual")
            try require(preview.saveRequests == 2 && preview.saveCompletions == 2 && preview.saveButton.isEnabled, "native-save-accept-once")
            guard let accepted = NSBitmapImageRep(data: try Data(contentsOf: acceptedURL))?.cgImage else { throw Failure.image }
            let acceptedPixels = try pixelBytes(accepted)
            try require(accepted.width == 2048 && accepted.height == 1280 && acceptedPixels == originalPixels, "native-panel-saves-original-pixels")
            try clipboardPreserved("native-save-accept-keeps-image"); nativeAccepted = true
            marker["state"] = "accepted-pixel-equality-verified"
            try JSONSerialization.data(withJSONObject: marker, options: [.prettyPrinted, .sortedKeys]).write(to: markerURL)

            if errorUIRequested {
                // The directory exists through real native acceptance. A QA
                // callback then removes only that exclusively owned empty
                // directory, immediately before the real PNG write. The
                // production PNG writer consequently encounters an actual
                // filesystem failure after .OK; no response/exporter is faked.
                let errorDirectory = output.appendingPathComponent(prefix + "-native-error-\(UUID().uuidString)", isDirectory: true)
                try FileManager.default.createDirectory(at: errorDirectory, withIntermediateDirectories: false)
                let errorURL = errorDirectory.appendingPathComponent("synthetic-save-error.png")
                var writePreparationCalls = 0; var removedErrorDirectory = false
                defer {
                    if FileManager.default.fileExists(atPath: errorDirectory.path),
                        (try? FileManager.default.contentsOfDirectory(at: errorDirectory, includingPropertiesForKeys: nil).isEmpty) == true {
                        try? FileManager.default.removeItem(at: errorDirectory)
                    }
                }
                preview.configureSavePanelForPreview = { panel in
                    panel.directoryURL = errorDirectory; panel.nameFieldStringValue = errorURL.lastPathComponent
                }
                preview.beforePNGWriteForPreview = { selectedURL in
                    writePreparationCalls += 1
                    guard selectedURL.standardizedFileURL.resolvingSymlinksInPath() == errorURL.standardizedFileURL.resolvingSymlinksInPath(),
                        errorDirectory.lastPathComponent.contains("-native-error-"),
                        (try? FileManager.default.contentsOfDirectory(at: errorDirectory, includingPropertiesForKeys: nil).isEmpty) == true else { return }
                    do {
                        try FileManager.default.removeItem(at: errorDirectory); removedErrorDirectory = true
                    } catch { /* The subsequent assertion reports an unusable fixture, not a fabricated write error. */ }
                }
                marker["state"] = "awaiting-real-native-save-error"; marker["expectedFile"] = errorURL.path
                try JSONSerialization.data(withJSONObject: marker, options: [.prettyPrinted, .sortedKeys]).write(to: markerURL)
                preview.saveButton.performClick(nil)
                try pumpUntil(timeout: manualNativeSave ? 90 : 5, dispatchNativeEvents: manualNativeSave) {
                    preview.saveCompletions == 3 || defaultButtonUnavailable
                }
                try require(!defaultButtonUnavailable && preview.lastSaveResponse == .OK && writePreparationCalls == 1 &&
                    removedErrorDirectory && !FileManager.default.fileExists(atPath: errorURL.path), "native-error-save-real-acceptance-and-filesystem-failure")
                try pumpUntil(dispatchNativeEvents: manualNativeSave) { preview.attachedSheet != nil }
                guard let errorSheet = preview.attachedSheet, let errorContent = errorSheet.contentView else { throw Failure.image }
                let alertCopy = textFields(in: errorContent).map(\.stringValue)
                try require(errorSheet.isVisible && alertCopy.contains(L10n.text("capture.preview.save_failed")) &&
                    alertCopy.contains(L10n.text("capture.preview.save_failed_help")), "production-save-error-alert-is-visible-and-localized")
                let errorFile = prefix + "-native-save-error-alert.png"
                try render(errorContent, to: output.appendingPathComponent(errorFile)); files.append(errorFile)
                try clipboardPreserved("native-save-error-alert-keeps-image")
                marker["state"] = "awaiting-error-alert-acknowledgment"
                try JSONSerialization.data(withJSONObject: marker, options: [.prettyPrinted, .sortedKeys]).write(to: markerURL)
                if !manualNativeSave {
                    guard let button = errorSheet.defaultButtonCell else { throw Failure.assertion("native-error-alert-default-button-unavailable") }
                    button.performClick(nil)
                }
                try pumpUntil(timeout: manualNativeSave ? 90 : 5, dispatchNativeEvents: manualNativeSave) { preview.attachedSheet == nil }
                try require(preview.saveButton.isEnabled && preview.originalImage === image && controller.preview === preview,
                    "native-save-error-acknowledgment-retains-open-original")
                try clipboardPreserved("native-save-error-acknowledgment-keeps-image"); nativeSaveErrorUI = true

                let recoveredURL = output.appendingPathComponent(prefix + "-native-recovered-\(UUID().uuidString).png")
                preview.beforePNGWriteForPreview = nil
                preview.configureSavePanelForPreview = { panel in
                    panel.directoryURL = output; panel.nameFieldStringValue = recoveredURL.lastPathComponent
                }
                marker["state"] = "awaiting-real-native-recovery-save"; marker["expectedFile"] = recoveredURL.path
                try JSONSerialization.data(withJSONObject: marker, options: [.prettyPrinted, .sortedKeys]).write(to: markerURL)
                preview.saveButton.performClick(nil)
                try pumpUntil(timeout: manualNativeSave ? 90 : 5, dispatchNativeEvents: manualNativeSave) {
                    preview.saveCompletions == 4 || defaultButtonUnavailable
                }
                try require(!defaultButtonUnavailable && preview.lastSaveResponse == .OK && preview.saveRequests == 4 && preview.saveButton.isEnabled,
                    "native-save-error-recovers-through-real-accepted-save")
                guard let recovered = NSBitmapImageRep(data: try Data(contentsOf: recoveredURL))?.cgImage else { throw Failure.image }
                let recoveredPixels = try pixelBytes(recovered)
                try require(recovered.width == 2048 && recovered.height == 1280 && recoveredPixels == originalPixels,
                    "native-save-error-recovery-keeps-original-pixels")
                try clipboardPreserved("native-save-error-recovery-keeps-image"); nativeSaveErrorRecovery = true
                marker["state"] = "recovery-accepted-pixel-equality-verified"
                try JSONSerialization.data(withJSONObject: marker, options: [.prettyPrinted, .sortedKeys]).write(to: markerURL)
            }
            preview.beforePNGWriteForPreview = nil; preview.configureSavePanelForPreview = nil; preview.onSavePanelPresented = nil; preview.orderOut(nil)
        }
        preview.close()
        try require(controller.preview == nil && controller.image == nil, "native-close-releases-memory")
        try clipboardPreserved("close-without-saving-keeps-image")

        if nativeSavePanel {
            controller.show(image, visibleFrame: visible); controller.clickThumbnailForPreview()
            guard let closing = controller.preview else { throw Failure.image }
            closing.appearance = appearance; closing.orderFront(nil)
            let closeURL = output.appendingPathComponent(prefix + "-must-not-save-on-close-\(UUID().uuidString).png")
            var closeSawPendingSheet = false
            closing.configureSavePanelForPreview = { panel in
                panel.directoryURL = output; panel.nameFieldStringValue = closeURL.lastPathComponent
            }
            closing.onSavePanelPresented = { [weak closing] panel in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak closing, weak panel] in
                    closeSawPendingSheet = closing?.attachedSheet === panel && closing?.saveCompletions == 0
                    closing?.close()
                }
            }
            closing.saveButton.performClick(nil)
            try pumpUntil(dispatchNativeEvents: manualNativeSave) { closing.lastSaveResponse == .cancel }
            closing.close(); controller.dismiss()
            try settleNativeCallbacks(dispatchNativeEvents: manualNativeSave)
            try require(closeSawPendingSheet && closing.saveRequests == 1 && closing.saveCompletions == 1 &&
                closing.lastSaveResponse == .cancel && closing.attachedSheet == nil && closing.saveButton.isEnabled,
                "native-close-pending-save-cancels-once")
            try require(controller.preview == nil && controller.thumbnail == nil && controller.image == nil,
                "native-close-pending-save-releases-controller-memory")
            try require(!FileManager.default.fileExists(atPath: closeURL.path), "native-close-pending-save-does-not-write")
            try clipboardPreserved("native-close-pending-save-keeps-image")
            closing.configureSavePanelForPreview = nil; closing.onSavePanelPresented = nil; nativeCloseCanceled = true

            controller.show(image, visibleFrame: visible); controller.clickThumbnailForPreview()
            guard let replaced = controller.preview else { throw Failure.image }
            replaced.appearance = appearance; replaced.orderFront(nil)
            let replacementImage = try makeImage(width: 320, height: 240)
            let replacementURL = output.appendingPathComponent(prefix + "-must-not-save-on-replacement-\(UUID().uuidString).png")
            var replacementSawPendingSheet = false
            replaced.configureSavePanelForPreview = { panel in
                panel.directoryURL = output; panel.nameFieldStringValue = replacementURL.lastPathComponent
            }
            replaced.onSavePanelPresented = { [weak replaced] panel in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak replaced, weak panel] in
                    replacementSawPendingSheet = replaced?.attachedSheet === panel && replaced?.saveCompletions == 0
                    controller.show(replacementImage, visibleFrame: visible)
                }
            }
            replaced.saveButton.performClick(nil)
            try pumpUntil(dispatchNativeEvents: manualNativeSave) { replaced.lastSaveResponse == .cancel }
            try settleNativeCallbacks(dispatchNativeEvents: manualNativeSave)
            try require(replacementSawPendingSheet && replaced.saveRequests == 1 && replaced.saveCompletions == 1 &&
                replaced.lastSaveResponse == .cancel && replaced.attachedSheet == nil && replaced.saveButton.isEnabled,
                "native-replacement-pending-save-cancels-once")
            try require(controller.preview == nil && controller.thumbnail != nil && controller.image === replacementImage &&
                controller.image !== image, "native-replacement-retains-only-new-controller-image")
            try require(!FileManager.default.fileExists(atPath: replacementURL.path), "native-replacement-pending-save-does-not-write")
            try clipboardPreserved("native-replacement-pending-save-keeps-image")
            controller.clickThumbnailForPreview()
            try require(controller.preview?.originalImage === replacementImage && controller.preview?.originalImage.width == 320 &&
                controller.preview?.originalImage.height == 240, "native-replacement-thumbnail-opens-new-image")
            controller.dismiss()
            try require(controller.preview == nil && controller.thumbnail == nil && controller.image == nil && replaced.saveCompletions == 1,
                "native-replacement-dismiss-releases-controller-memory")
            try clipboardPreserved("native-replacement-dismiss-keeps-image")
            replaced.configureSavePanelForPreview = nil; replaced.onSavePanelPresented = nil; nativeReplacementCanceled = true
        }

        controller.show(image, visibleFrame: visible); controller.clickDismissForPreview()
        try require(controller.thumbnail == nil && controller.image == nil, "dismiss-button-releases-memory")
        try clipboardPreserved("thumbnail-dismiss-keeps-image")
        controller.show(image, visibleFrame: visible); controller.expireThumbnailForPreview()
        try require(controller.thumbnail == nil && controller.image == nil, "thumbnail-expiry-releases-memory")
        try clipboardPreserved("thumbnail-expiry-keeps-image")

        for (width, height, label) in [(80, 1600, "portrait"), (4000, 80, "panorama"), (64, 64, "small")] {
            let synthetic = try makeImage(width: width, height: height)
            controller.show(synthetic, visibleFrame: visible); controller.clickThumbnailForPreview()
            guard let extreme = controller.preview else { throw Failure.image }
            extreme.appearance = appearance; extreme.contentView?.layoutSubtreeIfNeeded(); extreme.updateImageLayout()
            let rect = extreme.previewImageFrame; let bounds = extreme.scrollView.contentView.bounds
            try require(rect.width <= bounds.width && rect.height <= bounds.height && abs(rect.width / rect.height - CGFloat(width) / CGFloat(height)) < 0.001,
                "fit-extreme-" + label)
            extreme.setContentSize(NSSize(width: 440, height: 278)); extreme.contentView?.layoutSubtreeIfNeeded(); extreme.updateImageLayout()
            let minimum = extreme.previewImageFrame
            try require(minimum.width > 0 && minimum.height > 0 && minimum.width <= extreme.scrollView.contentView.bounds.width && minimum.height <= extreme.scrollView.contentView.bounds.height,
                "minimum-fit-" + label)
            filename = prefix + "-" + label + "-minimum.png"
            try render(extreme.contentView!, to: output.appendingPathComponent(filename)); files.append(filename)
            controller.dismiss()
        }
        try clipboardPreserved("all-aspect-and-dismiss-cases-keep-image")
        checks += try verifyMenus()
        let report: [String: Any] = ["case": "capture-preview-synthetic", "result": "PASS", "assertions": checks,
            "language": initialLanguage.rawValue, "appearance": appearance.name.rawValue, "files": files,
            "sourceDimensions": [2048, 1280], "pixelEquality": true, "lowerRightCaptureScreen": true,
            "fitAndActualSize": true, "extremeAspectRatios": true, "liveLanguageTransitions": true,
            "namedPasteboardPreserved": true, "generalClipboardTouched": false, "screenCaptureTested": false,
            "nativeSavePanelCanceled": nativeCanceled, "nativeSavePanelAccepted": nativeAccepted,
            "nativeSaveAcceptanceRoute": !nativeAccepted ? "not-run" : (manualNativeSave ? "external-native-GUI" : "public-default-button-cell"),
            "nativeApplicationEventDispatch": manualNativeSave,
            "nativeSavePanelCloseCanceled": nativeCloseCanceled, "nativeSavePanelReplacementCanceled": nativeReplacementCanceled,
            "pendingSaveNoOutput": nativeCloseCanceled && nativeReplacementCanceled,
            "explicitURLPNGWrite": true, "saveErrorTested": true, "saveErrorUIPathTested": nativeSaveErrorUI,
            "nativeSaveErrorRecovery": nativeSaveErrorRecovery,
            "nativeSaveErrorPostAcceptanceDirectoryRemoval": nativeSaveErrorUI,
            "thumbnailDismissAndExpiry": true, "menuReadiness": true,
            "thumbnailCaptionGeometry": captionGeometry, "thumbnailCaptionGeometryNegativeRejected": captionClippingRejected]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            .write(to: output.appendingPathComponent(prefix + ".json"))
        return files
    }

    @MainActor private static func verifyMenus() throws -> Int {
        var checks = 0
        func require(_ condition: @autoclosure () -> Bool, _ description: String) throws {
            checks += 1; guard condition() else { throw Failure.assertion(description) }
        }
        let actions = CaptureMenu.Actions(area: #selector(Receiver.capture(_:)), fixed: #selector(Receiver.capture(_:)),
            permission: #selector(Receiver.recovery(_:)), settings: #selector(Receiver.recovery(_:)),
            updates: #selector(Receiver.recovery(_:)), quit: #selector(Receiver.recovery(_:)))
        let receiver = Receiver()
        for mode in [SelectionMode.drag, .mask] {
            let menu = CaptureMenu.make(ready: false, mode: mode, shortcut: Shortcut(), canCheck: true, target: receiver, actions: actions)
            try require(menu.item(withTag: CaptureMenu.areaTag)?.isHidden == true && menu.item(withTag: CaptureMenu.fixedTag)?.isHidden == true &&
                menu.item(withTag: CaptureMenu.areaTag)?.keyEquivalent.isEmpty == true && menu.item(withTag: CaptureMenu.fixedTag)?.keyEquivalent.isEmpty == true &&
                menu.item(withTag: CaptureMenu.permissionTag)?.isHidden == false, "unready-menu-shows-only-recovery")
            let before = receiver.captures
            let key = CaptureMenu.presentation(Shortcut())
            if let equivalent = key.equivalent, let event = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: key.modifiers,
                timestamp: 0, windowNumber: 0, context: nil, characters: equivalent, charactersIgnoringModifiers: equivalent,
                isARepeat: false, keyCode: UInt16(Shortcut().key)) {
                try require(!menu.performKeyEquivalent(with: event) && receiver.captures == before, "hidden-capture-is-not-a-key-equivalent")
            }
            CaptureMenu.applyReadiness(to: menu, ready: true); CaptureMenu.applyShortcut(to: menu, mode: mode, presentation: key)
            try require(menu.item(withTag: CaptureMenu.areaTag)?.isHidden == false && menu.item(withTag: CaptureMenu.fixedTag)?.isHidden == false &&
                menu.item(withTag: CaptureMenu.permissionTag)?.isHidden == true && menu.item(withTag: mode == .drag ? CaptureMenu.areaTag : CaptureMenu.fixedTag)?.keyEquivalent == key.equivalent,
                "readiness-restores-native-capture-actions")
            menu.performActionForItem(at: menu.indexOfItem(withTag: mode == .drag ? CaptureMenu.areaTag : CaptureMenu.fixedTag))
            try require(receiver.captures == before + 1 && receiver.recoveries == 0, "ready-menu-dispatches-capture")
            CaptureMenu.applyReadiness(to: menu, ready: false); CaptureMenu.applyShortcut(to: menu, mode: mode, presentation: key)
            try require(menu.item(withTag: CaptureMenu.areaTag)?.isHidden == true && menu.item(withTag: CaptureMenu.permissionTag)?.isHidden == false,
                "revocation-restores-explicit-recovery")
        }
        return checks
    }

    @MainActor private static func textFields(in view: NSView) -> [NSTextField] {
        (view as? NSTextField).map { [$0] } ?? view.subviews.flatMap { textFields(in: $0) }
    }

    @MainActor private static func verifyThumbnailCaption(_ controller: CapturePreviewController, expectedLines: Int) throws -> [String: Any] {
        guard let caption = controller.thumbnailCaptionForPreview, let cell = caption.cell,
            let parent = caption.superview, let imageFrame = controller.thumbnailImageFrameForPreview else { throw Failure.image }
        let tolerance: CGFloat = 0.5
        let drawing = cell.drawingRect(forBounds: caption.bounds)
        let storage = NSTextStorage(attributedString: caption.attributedStringValue)
        let layout = NSLayoutManager()
        let container = NSTextContainer(containerSize: NSSize(width: drawing.width, height: 100_000))
        container.lineFragmentPadding = 0; container.lineBreakMode = cell.lineBreakMode
        storage.addLayoutManager(layout); layout.addTextContainer(container); layout.ensureLayout(for: container)
        let glyphs = layout.glyphRange(for: container)
        let used = layout.usedRect(for: container)
        let ink = layout.boundingRect(forGlyphRange: glyphs, in: container)
        var lines = 0
        layout.enumerateLineFragments(forGlyphRange: glyphs) { _, _, _, _, _ in lines += 1 }
        guard drawing.width > 0, glyphs.length == layout.numberOfGlyphs, lines == expectedLines, lines <= caption.maximumNumberOfLines,
            drawing.height + tolerance >= max(used.maxY, ink.maxY),
            parent.bounds.insetBy(dx: -tolerance, dy: -tolerance).contains(caption.frame),
            abs(caption.preferredMaxLayoutWidth - caption.bounds.width) <= tolerance,
            abs(caption.frame.minX - DesignTokens.group) <= tolerance,
            abs(parent.bounds.maxX - caption.frame.maxX - DesignTokens.group) <= tolerance,
            abs(caption.frame.minY - DesignTokens.group) <= tolerance,
            abs(imageFrame.minY - caption.frame.maxY - DesignTokens.inline) <= tolerance,
            abs(parent.bounds.maxY - imageFrame.maxY - DesignTokens.group) <= tolerance,
            parent.bounds.contains(imageFrame), imageFrame.height > 0 else {
                throw Failure.assertion("thumbnail-caption-glyphs-padding-and-containment")
        }
        return ["width": caption.frame.width, "height": caption.frame.height, "drawingHeight": drawing.height,
            "glyphHeight": used.maxY, "inkHeight": ink.maxY, "lines": lines, "outerPadding": DesignTokens.group,
            "imageCaptionGap": DesignTokens.inline, "fullGlyphs": true, "contained": true]
    }

    @MainActor private static func pumpUntil(timeout: TimeInterval = 5, dispatchNativeEvents: Bool = false, _ condition: () -> Bool) throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            if dispatchNativeEvents {
                if let event = NSApp.nextEvent(matching: .any, until: Date().addingTimeInterval(0.02), inMode: .default, dequeue: true) {
                    NSApp.sendEvent(event)
                }
                NSApp.updateWindows()
            } else {
                _ = RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.02))
            }
        }
        guard condition() else { throw Failure.assertion("native-sheet-completion-timeout") }
    }
    @MainActor private static func settleNativeCallbacks(dispatchNativeEvents: Bool = false) throws {
        // Give the dismissed native sheet another run-loop turn before checking
        // the completion count and output absence, including duplicate closes.
        var settled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { settled = true }
        try pumpUntil(dispatchNativeEvents: dispatchNativeEvents) { settled }
    }

    private static func makeImage(width: Int, height: Int) throws -> CGImage {
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw Failure.image }
        context.setFillColor(CGColor(red: 0.1, green: 0.2, blue: 0.32, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setFillColor(CGColor(red: 0.25, green: 0.65, blue: 0.9, alpha: 1)); context.fill(CGRect(x: width / 4, y: height / 4, width: width / 2, height: height / 2))
        context.setFillColor(CGColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: max(1, width / 8), height: max(1, height / 8)))
        guard let image = context.makeImage() else { throw Failure.image }; return image
    }
    private static func pixelBytes(_ image: CGImage) throws -> Data {
        guard let context = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
            bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
            let data = context.data else { throw Failure.image }
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return Data(bytes: data, count: image.width * image.height * 4)
    }
    @MainActor private static func render(_ view: NSView, to output: URL) throws {
        view.window?.layoutIfNeeded(); view.layoutSubtreeIfNeeded()
        var data: Data?
        view.effectiveAppearance.performAsCurrentDrawingAppearance {
            guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
            view.cacheDisplay(in: view.bounds, to: bitmap); data = bitmap.representation(using: .png, properties: [:])
        }
        guard let data else { throw Failure.render }; try data.write(to: output)
    }
    @MainActor private final class Receiver: NSObject {
        var captures = 0; var recoveries = 0
        @objc func capture(_ sender: Any?) { captures += 1 }
        @objc func recovery(_ sender: Any?) { recoveries += 1 }
    }
}
#endif
