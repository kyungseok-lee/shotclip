#if SHOTCLIP_QA
import AppKit
import Sparkle
import CaptureCore

// Runs only under the existing inert --ui-preview path, before UpdateService /
// AppDelegate. No updater, network, preferences, installation, TCC or Keychain.
enum UpdatePreview {
    private enum FixtureError: Error { case wrongMode, assertion(String), render }
    @MainActor static func run(output: URL, appearance: NSAppearance) throws -> [String] {
        guard CommandLine.arguments.contains("--ui-preview") else { throw FixtureError.wrongMode }
        let initial = L10n.language
        defer { L10n.select(initial) }
        let keyCount = try LocalizationAudit.validate(bundle: L10n.bundle, table: "Updates")
        var opened: [URL] = []
        let driver = LocalizedUpdateDriver(presentWindows: false, openLink: { opened.append($0) })
        driver.window.appearance = appearance
        var checks = 0; var files: [String] = []
        func require(_ condition: @autoclosure () -> Bool, _ name: String) throws {
            checks += 1; guard condition() else {
                fputs("Updater fixture assertion failed: \(name)\n", stderr)
                throw FixtureError.assertion(name)
            }
        }
        func transitions(_ phase: String, capture: Bool = false, noteState: Bool = false) throws {
            driver.window.orderFront(nil) // A real, already open synthetic NSWindow.
            let identity = ObjectIdentifier(driver.window!)
            let actions = driver.visibleActions; let controls = driver.previewButtonIdentities
            let state = driver.screen; let received = driver.received; let expected = driver.expected
            let extraction = driver.extraction; let progress = driver.previewProgress
            let frame = driver.window.frame
            if noteState { driver.focusAndScrollPreviewNotes() } else { driver.focusPreviewAction() }
            let focus = driver.window.firstResponder
            let noteSelection = driver.previewNotesSelection; let noteOrigin = driver.previewNotesOrigin
            if noteState { try require(noteSelection.length > 0 && noteOrigin.y > 0, phase + "-note-fixture") }
            L10n.select(.english); let english = driver.previewCaptions
            for language in [AppLanguage.korean, .english, .korean, .english] {
                L10n.select(language)
                try require(ObjectIdentifier(driver.window!) == identity && driver.window.isVisible && abs(driver.window.frame.minX - frame.minX) <= 1 && abs(driver.window.frame.maxY - frame.maxY) <= 1, phase + "-window")
                try require(driver.screen == state && driver.visibleActions == actions && driver.previewButtonIdentities == controls, phase + "-state")
                try require(driver.window.firstResponder === focus, phase + "-focus")
                if noteState { try require(driver.previewNotesSelection == noteSelection && driver.previewNotesOrigin == noteOrigin, phase + "-notes-selection-scroll") }
                try require(driver.received == received && driver.expected == expected && driver.extraction == extraction && driver.previewProgress == progress, phase + "-progress")
                try require(driver.window.title == (language == .english ? "Shot Clip Updates" : "Shot Clip 업데이트"), phase + "-title")
                try require(language == .english ? driver.previewCaptions == english : driver.previewCaptions != english, phase + "-captions")
                if capture && (language == .korean || language == .english) {
                    for (size, contentSize) in [("default", driver.previewContentSize), ("minimum", driver.previewMinimumContentSize)] {
                        driver.layoutForPreview(width: contentSize.width)
                        driver.window.contentView?.layoutSubtreeIfNeeded()
                        if !driver.previewLayoutFits, let data = try? JSONSerialization.data(withJSONObject: driver.previewLayoutDiagnostics, options: [.sortedKeys]), let diagnostic = String(data: data, encoding: .utf8) {
                            fputs("Updater geometry: " + diagnostic + "\n", stderr)
                        }
                        try require(driver.previewLayoutFits, phase + "-" + size + "-layout")
                        let filename = "\(language.rawValue)-\(appearance.name.rawValue)-updater-\(phase)-\(size).png"
                        try render(driver.window.contentView!, to: output.appendingPathComponent(filename))
                        if !files.contains(filename) { files.append(filename) }
                    }
                    driver.layoutForPreview(width: driver.previewContentSize.width)
                }
            }
        }
        let permissionRequest = SPUUpdatePermissionRequest(systemProfile: [])
        for allow in [false, true] {
            var replies: [SUUpdatePermissionResponse] = []
            driver.show(permissionRequest, reply: { replies.append($0) })
            try transitions("permission", capture: true)
            driver.clickPreviewAction(allow ? .allow : .deny); driver.clickPreviewAction(allow ? .allow : .deny)
            try require(replies.count == 1 && replies[0].automaticUpdateChecks == allow && !replies[0].sendSystemProfile && replies[0].automaticUpdateDownloading == nil, "permission-once")
        }
        var permissionClose = 0
        driver.show(permissionRequest, reply: { if !$0.automaticUpdateChecks { permissionClose += 1 } })
        _ = driver.windowShouldClose(driver.window); _ = driver.windowShouldClose(driver.window)
        try require(permissionClose == 1, "permission-close-denies-once")
        var canceled = 0
        driver.showUserInitiatedUpdateCheck(cancellation: { canceled += 1 })
        try transitions("checking", capture: true)
        _ = driver.windowShouldClose(driver.window); driver.clickPreviewAction(.cancel)
        try require(canceled == 1 && driver.screen == nil && !driver.window.isVisible, "check-close-cancels-once")
        driver.showUserInitiatedUpdateCheck(cancellation: { canceled += 1 })
        driver.clickPreviewAction(.cancel); driver.clickPreviewAction(.cancel)
        try require(canceled == 2, "check-button-cancels-once")

        let baseline = LocalizedUpdateDriver.Item(version: "0.7.0", notesURL: URL(string: "https://example.invalid/notes"), plainNotes: "Synthetic release notes.\nCapture and update improvements.")
        // Sparkle has no public value constructor for full appcast/state objects.
        // Exercise its public callback with the public empty-item sentinel, then
        // the same production presentation adapter with synthetic metadata.
        var emptyReplies: [SPUUserUpdateChoice] = []
        driver.showUpdateFound(with: SUAppcastItem.empty(), state: SPUUserUpdateState(coder: FixtureStateCoder())!, reply: { emptyReplies.append($0) })
        try require(emptyReplies == [.dismiss], "empty-public-appcast-dismissed")
        for stage in [SPUUserUpdateStage.notDownloaded, .downloaded, .installing] {
            for (action, expected) in [(LocalizedUpdateDriver.Action.install, SPUUserUpdateChoice.install), (.dismiss, .dismiss), (.skip, .skip)] {
                var replies: [SPUUserUpdateChoice] = []
                var item = baseline; item.stage = stage
                driver.showFound(item, reply: { replies.append($0) })
                try transitions("found-\(stage.rawValue)", capture: action == .install)
                driver.clickPreviewAction(action); driver.clickPreviewAction(action)
                try require(replies == [expected], "found-choice-once")
            }
        }
        var foundClose: [SPUUserUpdateChoice] = []
        driver.showFound(baseline, reply: { foundClose.append($0) })
        driver.showUpdateInFocus(); _ = driver.windowShouldClose(driver.window); _ = driver.windowShouldClose(driver.window)
        try require(foundClose == [.dismiss], "found-close-dismisses")

        var longItem = baseline
        longItem.version = "0.7.0 " + String(repeating: "Synthetic version ", count: 8)
        driver.showFound(longItem, reply: { _ in })
        try transitions("available-long", capture: true)
        try require((driver.item?.version.count ?? 0) <= 80, "bounded-version-caption")
        driver.dismissUpdateInstallation()
        var noteStateItem = baseline
        noteStateItem.plainNotes = (1...80).map { "Synthetic release note paragraph \($0). This text exists only in the inert updater fixture." }.joined(separator: "\n\n")
        driver.showFound(noteStateItem, reply: { _ in })
        try transitions("notes-state", noteState: true); driver.dismissUpdateInstallation()
        var noteChoices = 0
        driver.showFound(baseline, reply: { _ in noteChoices += 1 })
        let notesOpenedBefore = opened.count
        driver.clickPreviewAction(.notes)
        try require(opened.count == notesOpenedBefore + 1 && noteChoices == 0 && driver.screen == .found, "notes-link-keeps-choice-pending")
        driver.clickPreviewAction(.dismiss); try require(noteChoices == 1, "notes-link-followed-by-one-reply")

        var info = baseline; info.informational = true; info.infoURL = URL(string: "https://example.invalid/info")
        var infoReplies: [SPUUserUpdateChoice] = []
        driver.showFound(info, reply: { infoReplies.append($0) })
        try transitions("informational", capture: true)
        driver.clickPreviewAction(.install); try require(infoReplies.isEmpty && !driver.visibleActions.contains(.install), "info-never-installs")
        driver.clickPreviewAction(.learnMore); driver.clickPreviewAction(.learnMore)
        try require(infoReplies == [.dismiss] && opened.last == info.infoURL, "info-link-dismisses-once")
        driver.showFound(info, reply: { infoReplies.append($0) })
        driver.clickPreviewAction(.skip)
        try require(infoReplies == [.dismiss, .skip], "informational-skip-supported")
        var criticalInfo = info; criticalInfo.critical = true
        driver.showFound(criticalInfo, reply: { infoReplies.append($0) })
        try require(!driver.visibleActions.contains(.install) && !driver.visibleActions.contains(.skip) && !driver.visibleActions.contains(.dismiss), "critical-informational-choice-rules")
        driver.clickPreviewAction(.learnMore)
        criticalInfo.major = true
        driver.showFound(criticalInfo, reply: { infoReplies.append($0) })
        try require(driver.visibleActions.contains(.skip) && driver.visibleActions.contains(.dismiss) && !driver.visibleActions.contains(.install), "major-informational-choice-rules")
        driver.clickPreviewAction(.skip)
        info.infoURL = URL(string: "javascript:alert(1)")
        driver.showFound(info, reply: { infoReplies.append($0) })
        try require(!driver.visibleActions.contains(.learnMore), "unsafe-link-hidden")
        driver.clickPreviewAction(.dismiss)

        var critical = baseline; critical.critical = true
        var criticalReplies: [SPUUserUpdateChoice] = []
        driver.showFound(critical, reply: { criticalReplies.append($0) })
        try transitions("critical", capture: true)
        driver.clickPreviewAction(.skip); try require(!driver.visibleActions.contains(.skip) && !driver.visibleActions.contains(.dismiss) && criticalReplies.isEmpty, "critical-no-skip-later")
        _ = driver.windowShouldClose(driver.window)
        try require(criticalReplies == [.dismiss], "critical-close-is-dismiss")
        critical.major = true
        driver.showFound(critical, reply: { criticalReplies.append($0) })
        try transitions("major", capture: true)
        try require(driver.visibleActions.contains(.skip) && driver.visibleActions.contains(.dismiss), "major-choice-rules")
        driver.clickPreviewAction(.skip); try require(criticalReplies == [.dismiss, .skip], "major-skip")

        var installingVariants = baseline
        installingVariants.stage = .installing; installingVariants.critical = true
        driver.showFound(installingVariants, reply: { _ in })
        try transitions("critical-installing", capture: true); driver.dismissUpdateInstallation()
        installingVariants.critical = false; installingVariants.major = true
        driver.showFound(installingVariants, reply: { _ in })
        try transitions("major-installing", capture: true); driver.dismissUpdateInstallation()
        installingVariants.critical = true
        driver.showFound(installingVariants, reply: { _ in })
        try transitions("critical-major-installing", capture: true); driver.dismissUpdateInstallation()

        var failed = info; failed.critical = true; failed.signingFailed = true; failed.plainNotes = "Synthetic unverified note"
        driver.showFound(failed, reply: { _ in })
        try require(driver.item?.critical == false && driver.item?.informational == false && driver.item?.plainNotes == nil && !driver.visibleActions.contains(.notes) && !driver.visibleActions.contains(.learnMore), "failed-signing-safe-mode")
        try transitions("signing-failed", capture: true); driver.dismissUpdateInstallation()

        driver.showFound(baseline, reply: { _ in })
        let linksBefore = opened.count
        driver.showUpdateReleaseNotes(with: FixtureDownloadData("Synthetic downloaded plain notes", mime: "text/plain"))
        try require(driver.previewCaptions.contains("Synthetic downloaded plain notes"), "plain-notes")
        driver.showUpdateReleaseNotes(with: FixtureDownloadData("<script>synthetic()</script><img src='https://example.invalid/image'>", mime: "text/html"))
        try require(!driver.previewCaptions.joined().contains("<script>") && opened.count == linksBefore, "html-never-rendered-or-loaded")
        driver.showUpdateReleaseNotesFailedToDownloadWithError(NSError(domain: "Fixture", code: 1, userInfo: [NSLocalizedDescriptionKey: "Synthetic private diagnostic"]))
        try transitions("notes-error")
        try require(!driver.previewCaptions.joined().contains("private diagnostic"), "notes-error-redacted")
        driver.dismissUpdateInstallation()

        var downloadsCanceled = 0
        driver.showDownloadInitiated(cancellation: { downloadsCanceled += 1 })
        driver.showDownloadDidReceiveExpectedContentLength(100); driver.showDownloadDidReceiveData(ofLength: 30)
        try transitions("downloading", capture: true)
        driver.showDownloadDidReceiveExpectedContentLength(.max)
        driver.showDownloadDidReceiveData(ofLength: UInt64.max / 2)
        try transitions("progress-long", capture: true)
        driver.showDownloadDidReceiveExpectedContentLength(20)
        try require(driver.previewProgress == 1, "small-expected-clamped")
        driver.showDownloadDidReceiveExpectedContentLength(0); driver.showDownloadDidReceiveData(ofLength: .max)
        try require(driver.received == .max, "overflow-saturated")
        _ = driver.windowShouldClose(driver.window); driver.clickPreviewAction(.cancel)
        try require(downloadsCanceled == 1, "download-close-cancels-once")
        driver.showDownloadInitiated(cancellation: { downloadsCanceled += 1 }); driver.clickPreviewAction(.cancel); driver.clickPreviewAction(.cancel)
        try require(downloadsCanceled == 2, "download-button-cancels-once")
        driver.showDownloadInitiated(cancellation: { downloadsCanceled += 1 }); driver.showDownloadDidStartExtractingUpdate()
        driver.clickPreviewAction(.cancel); _ = driver.windowShouldClose(driver.window)
        try require(downloadsCanceled == 2 && driver.screen == .extracting, "extract-no-stale-cancel")
        driver.showExtractionReceivedProgress(0.42); try transitions("extracting")
        driver.showExtractionReceivedProgress(.infinity); try require(driver.extraction == 0, "extract-nonfinite")
        driver.showExtractionReceivedProgress(-1); try require(driver.extraction == 0, "extract-negative")
        driver.showExtractionReceivedProgress(2); try require(driver.extraction == 1, "extract-clamped")

        for (action, expected) in [(LocalizedUpdateDriver.Action.install, SPUUserUpdateChoice.install), (.dismiss, .dismiss), (.skip, .skip)] {
            var replies: [SPUUserUpdateChoice] = []
            driver.showReady(toInstallAndRelaunch: { replies.append($0) })
            try transitions("ready", capture: action == .install)
            driver.clickPreviewAction(action); driver.clickPreviewAction(action)
            try require(replies == [expected], "ready-choice-once")
        }
        var readyClose: [SPUUserUpdateChoice] = []
        driver.showReady(toInstallAndRelaunch: { readyClose.append($0) })
        _ = driver.windowShouldClose(driver.window)
        try require(readyClose == [.dismiss], "ready-close-installs-on-quit-not-cancel")
        var retries = 0
        driver.showInstallingUpdate(withApplicationTerminated: false, retryTerminatingApplication: { retries += 1 })
        try transitions("installing-waiting"); driver.clickPreviewAction(.retry); driver.clickPreviewAction(.retry)
        try require(retries == 2, "retry-may-repeat")
        driver.showInstallingUpdate(withApplicationTerminated: true, retryTerminatingApplication: { retries += 1 })
        try transitions("installing"); driver.clickPreviewAction(.retry); _ = driver.windowShouldClose(driver.window)
        try require(retries == 2 && driver.screen == .installing(true), "terminated-no-retry")
        for relaunched in [false, true] {
            var acknowledged = 0
            driver.showUpdateInstalledAndRelaunched(relaunched, acknowledgement: { acknowledged += 1 })
            try transitions("installed-\(relaunched)")
            _ = driver.windowShouldClose(driver.window); driver.clickPreviewAction(.acknowledge)
            try require(acknowledged == 1, "installed-ack-once")
        }
        for reason in [SPUNoUpdateFoundReason.unknown, .onLatestVersion, .onNewerThanLatestVersion, .systemIsTooOld, .systemIsTooNew, .hardwareDoesNotSupportARM64] {
            var acknowledged = 0
            driver.showUpdateNotFoundWithError(NSError(domain: "Fixture", code: 0, userInfo: [SPUNoUpdateFoundReasonKey: NSNumber(value: reason.rawValue), NSLocalizedDescriptionKey: "Synthetic private diagnostic"]), acknowledgement: { acknowledged += 1 })
            try transitions("no-update-\(reason.rawValue)", capture: true)
            try require(driver.previewContentSize.width == DesignTokens.noticeWidth && driver.previewContentSize.height <= 240, "compact-no-update-result")
            try require(!driver.previewCaptions.joined().contains("private diagnostic"), "no-update-error-redacted")
            driver.clickPreviewAction(.acknowledge); driver.clickPreviewAction(.acknowledge)
            try require(acknowledged == 1, "no-update-ack-once")
        }
        var errorAcks = 0
        driver.showUpdaterError(NSError(domain: "Fixture", code: 2001, userInfo: [NSLocalizedDescriptionKey: "Synthetic private diagnostic"]), acknowledgement: { errorAcks += 1 })
        try transitions("error", capture: true)
        try require(driver.previewCaptions.joined().contains("2001") && !driver.previewCaptions.joined().contains("private diagnostic"), "error-code-only")
        _ = driver.windowShouldClose(driver.window); driver.clickPreviewAction(.acknowledge)
        try require(errorAcks == 1, "error-ack-once")
        driver.showUpdaterError(NSError(domain: "Fixture", code: Int.min), acknowledgement: {})
        try transitions("error-long", capture: true); driver.clickPreviewAction(.acknowledge)
        var stale = 0
        driver.showUserInitiatedUpdateCheck(cancellation: { stale += 1 }); driver.dismissUpdateInstallation(); driver.clickPreviewAction(.cancel)
        driver.showFound(baseline, reply: { _ in stale += 1 }); driver.dismissUpdateInstallation(); driver.clickPreviewAction(.install)
        driver.showUpdaterError(NSError(domain: "Fixture", code: 0), acknowledgement: { stale += 1 }); driver.dismissUpdateInstallation(); driver.clickPreviewAction(.acknowledge)
        try require(stale == 0 && driver.screen == nil && !driver.window.isVisible, "sparkle-teardown-invalidates-stale-callbacks")
        var reentrant: [SPUUserUpdateChoice] = []
        driver.showFound(baseline, reply: { choice in
            reentrant.append(choice)
            driver.showDownloadInitiated(cancellation: { stale += 1 })
        })
        driver.clickPreviewAction(.install); driver.clickPreviewAction(.install)
        try require(reentrant == [.install] && driver.screen == .downloading, "reentrant-stage-preserved")
        driver.dismissUpdateInstallation()
        let record: [String: Any] = ["case": "localized-updater-inert", "result": "PASS", "assertions": checks,
            "updatesKeyCount": keyCount, "requiredCallbacks": 16, "optionalCallbacks": 1, "publicSparkleCallbackFixtures": true, "fullAppcastMetadataViaPresentationAdapter": true, "realAppcastMappingTested": false,
            "alreadyOpenWindowTransitions": ["en-ko-en-ko-en"], "progressRetained": true, "focusedControlRetained": true, "noteSelectionAndScrollRetained": true, "defaultAndMinimumLayoutsFit": true, "contentMeasuredLayout": true, "noticeWidth": DesignTokens.noticeWidth, "releaseNotesHeight": DesignTokens.releaseNotesHeight,
            "oneShotReplies": true, "nativeButtonTargetActionDispatch": true, "informationalNeverInstalls": true, "htmlRendered": false,
            "updaterStarted": false, "networkUsed": false, "preferencesWritten": false,
            "keychainUsed": false, "clipboardTouched": false, "tccUsed": false,
            "macOSAuthorizationDialogsTested": false, "appearance": appearance.name.rawValue, "files": files]
        let report = "updater-fixture-\(initial.rawValue)-\(appearance.name.rawValue).json"
        try JSONSerialization.data(withJSONObject: record, options: [.prettyPrinted, .sortedKeys]).write(to: output.appendingPathComponent(report))
        return files
    }
    @MainActor private static func render(_ view: NSView, to output: URL) throws {
        var encoded: Data?
        view.effectiveAppearance.performAsCurrentDrawingAppearance {
            view.layoutSubtreeIfNeeded()
            guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
            view.cacheDisplay(in: view.bounds, to: bitmap)
            guard let flattened = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: bitmap.pixelsWide, pixelsHigh: bitmap.pixelsHigh,
                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
                let context = NSGraphicsContext(bitmapImageRep: flattened) else { return }
            NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = context
            defer { NSGraphicsContext.restoreGraphicsState() }
            context.cgContext.scaleBy(x: CGFloat(bitmap.pixelsWide) / view.bounds.width, y: CGFloat(bitmap.pixelsHigh) / view.bounds.height)
            DesignTokens.windowSurface.setFill(); NSBezierPath(rect: view.bounds).fill()
            let image = NSImage(size: view.bounds.size); image.addRepresentation(bitmap); image.draw(in: view.bounds)
            encoded = flattened.representation(using: .png, properties: [:])
        }
        guard let encoded else { throw FixtureError.render }; try encoded.write(to: output)
    }
}

// Public NSCoder test double for the public NSSecureCoding state initializer.
// Keys are ignored; no private archive schema or private initializer is used.
private final class FixtureStateCoder: NSCoder {
    override var allowsKeyedCoding: Bool { true }
    override func decodeInteger(forKey key: String) -> Int { SPUUserUpdateStage.notDownloaded.rawValue }
    override func decodeBool(forKey key: String) -> Bool { true }
}
private final class FixtureDownloadData: SPUDownloadData, @unchecked Sendable {
    private let fixtureData: Data
    private let fixtureMIME: String
    override var data: Data { fixtureData }
    override var mimeType: String? { fixtureMIME }
    override var textEncodingName: String? { "utf-8" }
    override var url: URL { URL(string: "https://example.invalid/notes")! }
    init(_ text: String, mime: String) { fixtureData = Data(text.utf8); fixtureMIME = mime; super.init() }
    required init?(coder: NSCoder) { fatalError("Inert fixture only") }
}
#endif
