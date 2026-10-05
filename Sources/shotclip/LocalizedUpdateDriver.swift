import AppKit
import Sparkle
import CaptureCore

// A public SPUUserDriver supplied once to SPUUpdater. Sparkle owns validation,
// scheduling, download and installation; this object owns only presentation.
@MainActor final class LocalizedUpdateDriver: NSObject, SPUUserDriver, NSWindowDelegate {
    enum Action: String { case cancel, install, dismiss, skip, allow, deny, learnMore, retry, acknowledge, notes }
    enum Screen: Equatable {
        case permission, checking, found, downloading, extracting, ready, installing(Bool), installed(Bool), noUpdate(Int), error(Int)
    }
    struct Item {
        var version: String
        var stage: SPUUserUpdateStage = .notDownloaded
        var informational = false
        var critical = false
        var major = false
        var signingFailed = false
        var infoURL: URL?
        var notesURL: URL?
        var plainNotes: String?
    }
    private enum Pending {
        case permission((SUUpdatePermissionResponse) -> Void)
        case choice((SPUUserUpdateChoice) -> Void)
        case cancellation(() -> Void)
        case acknowledgement(() -> Void)
    }
    private var pending: Pending?
    private var retry: (() -> Void)?
    private var languageObserver: NSObjectProtocol?
    // Keep copy in memory before an installation can replace the old bundle.
    // The installed callback and later refresh never read the replaced bundle.
    private let tables: [AppLanguage: [String: String]]
    private let presentWindows: Bool
    private let openLink: (URL) -> Void
    private(set) var screen: Screen?
    private(set) var item: Item?
    private(set) var received: UInt64 = 0
    private(set) var expected: UInt64 = 0
    private(set) var extraction: Double = 0
    private var notesFailed = false
    private var downloadedNotes: String?
    private(set) var visibleActions: [Action] = []
    private(set) var window: NSWindow!
    private let heading = WrappingLabel(wrappingLabelWithString: "")
    private let summary = WrappingLabel(wrappingLabelWithString: "")
    private let detail = WrappingLabel(wrappingLabelWithString: "")
    private let progress = NSProgressIndicator()
    private let notes = NSTextView()
    private let notesScroll = NSScrollView()
    private let buttons = NSStackView()
    private var actionButtons: [Action: NSButton] = [:]
    private let icon = NSImageView()
    private let notesLink = NSButton(title: "", target: nil, action: nil)
    private let root = NSStackView()
    private let headerLabels = NSStackView()
    private var headingHeight: NSLayoutConstraint!
    private var summaryHeight: NSLayoutConstraint!
    private var detailHeight: NSLayoutConstraint!
    private var preferredSize = NSSize(width: DesignTokens.noticeWidth, height: 180)

    init(presentWindows: Bool = true, openLink: @escaping (URL) -> Void = { NSWorkspace.shared.open($0) }) {
        self.presentWindows = presentWindows
        self.openLink = openLink
        tables = Dictionary(uniqueKeysWithValues: AppLanguage.allCases.map {
            ($0, (try? LocalizationAudit.table(bundle: L10n.bundle, language: $0, table: "Updates")) ?? [:])
        })
        super.init()
        buildWindow()
        languageObserver = NotificationCenter.default.addObserver(forName: L10n.languageDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }
    deinit { if let languageObserver { NotificationCenter.default.removeObserver(languageObserver) } }
    private func text(_ key: String) -> String { tables[L10n.language]?[key] ?? tables[.english]?[key] ?? key }
    private func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: L10n.language.locale, arguments: arguments)
    }
    private func buildWindow() {
        window = NSWindow(contentRect: NSRect(origin: .zero, size: preferredSize),
            styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false; window.delegate = self
        window.backgroundColor = DesignTokens.windowSurface
        let content = NSView(); window.contentView = content
        root.orientation = .vertical; root.alignment = .leading; root.spacing = DesignTokens.group
        root.translatesAutoresizingMaskIntoConstraints = false; content.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: DesignTokens.panelInset),
            root.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -DesignTokens.panelInset),
            root.topAnchor.constraint(equalTo: content.topAnchor, constant: DesignTokens.panelInset),
            root.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -DesignTokens.panelInset)
        ])
        icon.image = NSImage(systemSymbolName: "arrow.down.app", accessibilityDescription: nil)
        icon.contentTintColor = .controlAccentColor; icon.imageScaling = .scaleProportionallyUpOrDown
        icon.widthAnchor.constraint(equalToConstant: 38).isActive = true; icon.heightAnchor.constraint(equalToConstant: 38).isActive = true
        heading.font = DesignTokens.section; summary.font = DesignTokens.body; summary.textColor = DesignTokens.secondaryText
        headerLabels.orientation = .vertical; headerLabels.alignment = .leading; headerLabels.spacing = DesignTokens.tight
        for label in [heading, summary] {
            headerLabels.addArrangedSubview(label)
            label.widthAnchor.constraint(equalTo: headerLabels.widthAnchor).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        headingHeight = heading.heightAnchor.constraint(equalToConstant: 18); headingHeight.isActive = true
        summaryHeight = summary.heightAnchor.constraint(equalToConstant: 20); summaryHeight.isActive = true
        let header = NSStackView(views: [icon, headerLabels]); header.spacing = DesignTokens.group; header.alignment = .top; header.distribution = .fill
        headerLabels.widthAnchor.constraint(equalTo: header.widthAnchor, constant: -38 - DesignTokens.group).isActive = true
        headerLabels.setHuggingPriority(.defaultLow, for: .horizontal)
        root.addArrangedSubview(header); header.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        progress.style = .bar; progress.minValue = 0; progress.maxValue = 1
        root.addArrangedSubview(progress); progress.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 12).isActive = true
        detail.font = DesignTokens.caption; detail.textColor = DesignTokens.secondaryText
        root.addArrangedSubview(detail); detail.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        detailHeight = detail.heightAnchor.constraint(equalToConstant: 16); detailHeight.isActive = true
        notes.isEditable = false; notes.isSelectable = true; notes.isRichText = false
        notes.font = DesignTokens.body; notes.textColor = DesignTokens.primaryText; notes.backgroundColor = DesignTokens.cardSurface
        notes.textContainerInset = NSSize(width: DesignTokens.group, height: DesignTokens.group)
        notes.isVerticallyResizable = true; notes.isHorizontallyResizable = false
        notes.autoresizingMask = [.width]; notes.textContainer?.widthTracksTextView = true
        notesScroll.documentView = notes; notesScroll.hasVerticalScroller = true
        notesScroll.borderType = .bezelBorder
        root.addArrangedSubview(notesScroll); notesScroll.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        notesScroll.heightAnchor.constraint(equalToConstant: DesignTokens.releaseNotesHeight).isActive = true
        notesLink.bezelStyle = .rounded; notesLink.font = DesignTokens.body
        notesLink.target = self; notesLink.action = #selector(pressed(_:)); notesLink.identifier = NSUserInterfaceItemIdentifier(Action.notes.rawValue)
        root.addArrangedSubview(notesLink)
        buttons.orientation = .horizontal; buttons.alignment = .centerY; buttons.spacing = DesignTokens.inline
        let footer = NSView(); root.addArrangedSubview(footer)
        footer.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        footer.heightAnchor.constraint(equalToConstant: 32).isActive = true
        footer.addSubview(buttons); buttons.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttons.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
            buttons.leadingAnchor.constraint(greaterThanOrEqualTo: footer.leadingAnchor),
            buttons.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
        ])
        for action in [Action.cancel, .install, .dismiss, .skip, .allow, .deny, .learnMore, .retry, .acknowledge, .notes] {
            let button = NSButton(title: "", target: self, action: #selector(pressed(_:)))
            button.bezelStyle = .rounded; button.font = DesignTokens.body
            button.identifier = NSUserInterfaceItemIdentifier(action.rawValue)
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            actionButtons[action] = button
        }
    }
    private func labelHeight(_ field: WrappingLabel, width: CGFloat) -> CGFloat {
        let physicalWidth = width + field.alignmentRectInsets.left + field.alignmentRectInsets.right
        field.preferredMaxLayoutWidth = physicalWidth
        return field.requiredHeight(forWidth: physicalWidth)
    }
    private func layoutContent(width: CGFloat) -> NSSize {
        let innerWidth = width - 2 * DesignTokens.panelInset
        let labelWidth = innerWidth - 38 - DesignTokens.group
        headingHeight.constant = labelHeight(heading, width: labelWidth)
        summaryHeight.constant = labelHeight(summary, width: labelWidth)
        detailHeight.constant = labelHeight(detail, width: innerWidth)
        var heights = [max(38, headingHeight.constant + DesignTokens.tight + summaryHeight.constant)]
        if !progress.isHidden { heights.append(12) }
        if !detail.isHidden { heights.append(detailHeight.constant) }
        if !notesScroll.isHidden { heights.append(DesignTokens.releaseNotesHeight) }
        if !notesLink.isHidden { heights.append(notesLink.intrinsicContentSize.height) }
        if buttons.superview?.isHidden != true { heights.append(32) }
        return NSSize(width: width, height: ceil(2 * DesignTokens.panelInset + heights.reduce(0, +) + CGFloat(heights.count - 1) * DesignTokens.group))
    }
    private var buttonRowWidth: CGFloat {
        ceil(buttons.arrangedSubviews.reduce(CGFloat(0)) { $0 + $1.intrinsicContentSize.width }
            + CGFloat(max(0, buttons.arrangedSubviews.count - 1)) * DesignTokens.inline + 2 * DesignTokens.panelInset)
    }
    private func fitWindowToContent() {
        let width = max(notesScroll.isHidden ? DesignTokens.noticeWidth : DesignTokens.updateWidth, buttonRowWidth)
        preferredSize = layoutContent(width: width)
        window.setContentSize(preferredSize)
        window.contentView?.layoutSubtreeIfNeeded()
    }
    private func begin(_ screen: Screen, pending: Pending? = nil) {
        // A new Sparkle callback supersedes the previous stage's cancellation.
        self.pending = pending; retry = nil; self.screen = screen
        refresh()
        if presentWindows { window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
    }
    private func refresh() {
        guard let screen else { return }
        let previousNoteText = notes.string
        let noteSelection = notes.selectedRanges
        let noteOrigin = notesScroll.contentView.bounds.origin
        window.title = text("updater.window.title"); icon.setAccessibilityLabel(text("updater.icon"))
        var title = ""; var body = ""; var info = ""; var actions: [Action] = []
        var showProgress = false; var indeterminate = false; var amount = 0.0
        switch screen {
        case .permission:
            title = text("updater.permission.title"); body = text("updater.permission.body"); actions = [.deny, .allow]
        case .checking:
            title = text("updater.checking.title"); body = text("updater.checking.body"); actions = [.cancel]; showProgress = true; indeterminate = true
        case .found:
            guard let item else { return }
            title = text(item.critical ? "updater.found.critical" : item.stage == .notDownloaded ? "updater.found.title" : "updater.found.downloaded")
            body = format("updater.found.version", item.version)
            if item.informational {
                info = text("updater.found.informational")
                if !item.critical || item.major { actions = [.skip, .dismiss] }
                if Self.safeURL(item.infoURL) != nil { actions.append(.learnMore) }
            }
            else {
                actions = [.install]
                if !item.critical || item.major { actions.insert(.skip, at: 0); actions.insert(.dismiss, at: 1) }
                if item.stage == .installing {
                    info = text(actions.contains(.dismiss) ? "updater.found.installing" : "updater.found.installing_critical")
                    if actions.contains(.skip) { info += "\n" + text("updater.found.skip_installing") }
                }
            }
            if item.major { info += (info.isEmpty ? "" : "\n") + text("updater.found.major") }
            if item.signingFailed { info += (info.isEmpty ? "" : "\n") + text("updater.signature.warning") }
        case .downloading:
            title = text("updater.downloading.title"); body = text("updater.downloading.body"); actions = [.cancel]; showProgress = true
            indeterminate = expected == 0
            amount = expected == 0 ? 0 : min(1, Double(received) / Double(expected))
            info = expected == 0 ? format("updater.progress.received", bytes(received)) : format("updater.progress.total", bytes(received), bytes(expected))
        case .extracting:
            title = text("updater.extracting.title"); body = text("updater.extracting.body"); showProgress = true
            indeterminate = extraction == 0; amount = extraction
        case .ready:
            title = text("updater.ready.title"); body = text("updater.ready.body"); actions = [.skip, .dismiss, .install]
        case .installing(let terminated):
            title = text("updater.installing.title"); body = text(terminated ? "updater.installing.body" : "updater.installing.waiting")
            showProgress = true; indeterminate = true; if !terminated { actions = [.retry] }
        case .installed(let relaunched):
            title = text("updater.installed.title"); body = text(relaunched ? "updater.installed.relaunched" : "updater.installed.body"); actions = [.acknowledge]
        case .noUpdate(let reason):
            title = text("updater.no_update.title")
            switch reason {
            case Int(SPUNoUpdateFoundReason.onLatestVersion.rawValue): body = text("updater.no_update.latest")
            case Int(SPUNoUpdateFoundReason.onNewerThanLatestVersion.rawValue): body = text("updater.no_update.newer")
            case Int(SPUNoUpdateFoundReason.systemIsTooOld.rawValue): body = text("updater.no_update.system_old")
            case Int(SPUNoUpdateFoundReason.systemIsTooNew.rawValue): body = text("updater.no_update.system_new")
            case Int(SPUNoUpdateFoundReason.hardwareDoesNotSupportARM64.rawValue): body = text("updater.no_update.hardware")
            default: body = text("updater.no_update.unavailable")
            }
            actions = [.acknowledge]
        case .error(let code):
            title = text("updater.error.title"); body = format("updater.error.body", String(code)); actions = [.acknowledge]
        }
        heading.stringValue = title; summary.stringValue = body; detail.stringValue = info; detail.isHidden = info.isEmpty
        progress.isHidden = !showProgress; progress.isIndeterminate = indeterminate; progress.doubleValue = amount
        if showProgress && indeterminate { progress.startAnimation(nil) } else { progress.stopAnimation(nil) }
        progress.setAccessibilityLabel(title)
        let plain = downloadedNotes ?? item?.plainNotes
        let showNotes = screen == .found && item?.signingFailed != true
        notesScroll.isHidden = !showNotes
        if showNotes {
            let content = notesFailed ? text("updater.notes.failed") : (plain ?? text(Self.safeURL(item?.notesURL) != nil ? "updater.notes.browser" : "updater.notes.safe"))
            if notes.string != content { notes.string = content }
            notes.setAccessibilityLabel(text("updater.notes.title"))
            if !notesFailed, Self.safeURL(item?.notesURL) != nil, item?.signingFailed != true { actions.insert(.notes, at: 0) }
        }
        let previousActions = visibleActions
        visibleActions = actions
        notesLink.title = text("updater.action.notes"); notesLink.isHidden = !actions.contains(.notes)
        // Preserve existing button/control identity across language changes.
        if previousActions != actions {
            for button in buttons.arrangedSubviews { buttons.removeArrangedSubview(button); button.removeFromSuperview() }
        }
        for action in actions where action != .notes {
            guard let button = actionButtons[action] else { continue }
            var key = "updater.action." + action.rawValue
            if action == .install && (screen == .ready || item?.stage == .installing) { key = "updater.action.relaunch" }
            if action == .dismiss && (screen == .ready || (screen == .found && item?.stage == .installing)) { key = "updater.action.on_quit" }
            if action == .skip && screen == .ready { key = "updater.action.cancel_install" }
            button.title = text(key); button.keyEquivalent = (action == .install || action == .allow || action == .acknowledge || action == .learnMore) ? "\r" : ""
            if action == .cancel || action == .dismiss || action == .deny { button.keyEquivalent = "\u{1b}" }
            if previousActions != actions { buttons.addArrangedSubview(button) }
        }
        buttons.superview?.isHidden = actions.allSatisfy { $0 == .notes }
        fitWindowToContent()
        if screen == .found && notes.string == previousNoteText {
            notes.selectedRanges = noteSelection
            notesScroll.contentView.scroll(to: noteOrigin); notesScroll.reflectScrolledClipView(notesScroll.contentView)
        }
    }
    private func bytes(_ value: UInt64) -> String {
        let formatter = NumberFormatter(); formatter.locale = L10n.language.locale; formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return format("updater.bytes", formatter.string(from: NSNumber(value: Double(value) / 1_000_000)) ?? "0")
    }
    @objc private func pressed(_ sender: NSButton) {
        guard let value = sender.identifier?.rawValue, let action = Action(rawValue: value) else { return }
        perform(action)
    }
    func perform(_ action: Action) {
        guard visibleActions.contains(action) else { return }
        if action == .notes { if let url = Self.safeURL(item?.notesURL) { openLink(url) }; return }
        if action == .retry { retry?(); return } // Sparkle expressly permits multiple retries.
        let callback = pending
        guard callback != nil else { return }
        // Clear and hide before invoking the callback: callbacks may synchronously
        // re-enter the driver and double-clicks must never reply twice.
        pending = nil; hide()
        switch callback {
        case .permission(let reply): reply(SUUpdatePermissionResponse(automaticUpdateChecks: action == .allow, sendSystemProfile: false))
        case .choice(let reply):
            if action == .learnMore { if let url = Self.safeURL(item?.infoURL) { openLink(url) }; reply(.dismiss) }
            else { reply(action == .install ? .install : action == .skip ? .skip : .dismiss) }
        case .cancellation(let cancel): cancel()
        case .acknowledgement(let acknowledge): acknowledge()
        case nil: break
        }
    }
    private func hide() { window.orderOut(nil); progress.stopAnimation(nil); visibleActions = []; screen = nil; retry = nil }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let screen else { return true }
        switch screen {
        case .extracting, .installing: return false
        case .permission: perform(.deny)
        case .checking, .downloading: perform(.cancel)
        case .found, .ready:
            // Closing even a critical notice is dismissal, never skipping.
            if !visibleActions.contains(.dismiss) { visibleActions.append(.dismiss) }; perform(.dismiss)
        case .installed, .noUpdate, .error: perform(.acknowledge)
        }
        // hide() already handles this. Do not close a re-entrant callback's new UI.
        return false
    }
    static func safeURL(_ url: URL?) -> URL? {
        guard let url, url.scheme?.lowercased() == "https", let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil else { return nil }
        return url
    }
    static func safePlainText(_ value: String?) -> String? {
        guard let value else { return nil }
        let bounded = String(value.prefix(20_000))
        let scalars = bounded.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) || $0 == "\n" || $0 == "\t" }
        let result = String(String.UnicodeScalarView(scalars)).trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? nil : result
    }
    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        begin(.permission, pending: .permission(reply))
    }
    func showUserInitiatedUpdateCheck(cancellation: @escaping () -> Void) {
        item = nil; downloadedNotes = nil; notesFailed = false
        begin(.checking, pending: .cancellation(cancellation))
    }
    func showUpdateFound(with appcastItem: SUAppcastItem, state: SPUUserUpdateState, reply: @escaping (SPUUserUpdateChoice) -> Void) {
        guard appcastItem !== SUAppcastItem.empty() else { reply(.dismiss); return }
        // Sparkle has no public constructor for update state/appcast items.
        // The inert fixture calls this same presentation adapter with value data.
        let failed = appcastItem.signingValidationStatus == .failed
        showFound(Item(version: Self.safePlainText(appcastItem.displayVersionString) ?? "—", stage: state.stage,
            informational: appcastItem.isInformationOnlyUpdate && !failed, critical: appcastItem.isCriticalUpdate && !failed,
            major: appcastItem.isMajorUpgrade, signingFailed: failed,
            infoURL: failed ? nil : Self.safeURL(appcastItem.infoURL), notesURL: failed ? nil : Self.safeURL(appcastItem.releaseNotesURL),
            plainNotes: !failed && appcastItem.itemDescriptionFormat == "plain-text" ? Self.safePlainText(appcastItem.itemDescription) : nil), reply: reply)
    }
    func showFound(_ item: Item, reply: @escaping (SPUUserUpdateChoice) -> Void) {
        var safe = item
        safe.version = String((Self.safePlainText(item.version) ?? "—").prefix(80))
        safe.infoURL = Self.safeURL(item.infoURL); safe.notesURL = Self.safeURL(item.notesURL)
        safe.plainNotes = Self.safePlainText(item.plainNotes)
        if safe.signingFailed { safe.critical = false; safe.informational = false; safe.infoURL = nil; safe.notesURL = nil; safe.plainNotes = nil }
        self.item = safe; downloadedNotes = nil; notesFailed = false
        begin(.found, pending: .choice(reply))
    }
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        receiveNotes(data: downloadData.data, mime: downloadData.mimeType, encoding: downloadData.textEncodingName)
    }
    func receiveNotes(data: Data, mime: String?, encoding: String?) {
        guard screen == .found, item?.signingFailed != true else { return }
        if data.count <= 200_000, mime?.lowercased() == "text/plain", encoding == nil || encoding?.lowercased() == "utf-8" {
            downloadedNotes = Self.safePlainText(String(data: data, encoding: .utf8))
        } else { downloadedNotes = nil }
        refresh() // No HTML parser, WebView, scripts, images or automatic link loading.
    }
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        guard screen == .found else { return }; notesFailed = true; refresh()
    }
    func showUpdateNotFoundWithError(_ error: Error, acknowledgement: @escaping () -> Void) {
        item = nil; downloadedNotes = nil
        let reason = ((error as NSError).userInfo[SPUNoUpdateFoundReasonKey] as? NSNumber)?.intValue ?? -1
        begin(.noUpdate(reason), pending: .acknowledgement(acknowledgement))
    }
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        item = nil; downloadedNotes = nil
        begin(.error((error as NSError).code), pending: .acknowledgement(acknowledgement))
    }
    func showDownloadInitiated(cancellation: @escaping () -> Void) {
        received = 0; expected = 0; begin(.downloading, pending: .cancellation(cancellation))
    }
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        guard screen == .downloading else { return }; expected = expectedContentLength; refresh()
    }
    func showDownloadDidReceiveData(ofLength length: UInt64) {
        guard screen == .downloading else { return }
        let addition = received.addingReportingOverflow(length); received = addition.overflow ? .max : addition.partialValue; refresh()
    }
    func showDownloadDidStartExtractingUpdate() { extraction = 0; begin(.extracting) }
    func showExtractionReceivedProgress(_ progress: Double) {
        guard screen == .extracting else { return }; extraction = progress.isFinite ? min(1, max(0, progress)) : 0; refresh()
    }
    func showReady(toInstallAndRelaunch reply: @escaping (SPUUserUpdateChoice) -> Void) { begin(.ready, pending: .choice(reply)) }
    func showInstallingUpdate(withApplicationTerminated applicationTerminated: Bool, retryTerminatingApplication: @escaping () -> Void) {
        begin(.installing(applicationTerminated)); retry = applicationTerminated ? nil : retryTerminatingApplication
    }
    func showUpdateInstalledAndRelaunched(_ relaunched: Bool, acknowledgement: @escaping () -> Void) {
        item = nil; downloadedNotes = nil; begin(.installed(relaunched), pending: .acknowledgement(acknowledgement))
    }
    func dismissUpdateInstallation() {
        pending = nil; retry = nil; item = nil; downloadedNotes = nil; notesFailed = false; received = 0; expected = 0; extraction = 0; hide()
    }
    func showUpdateInFocus() { if presentWindows && screen != nil { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) } }
    #if SHOTCLIP_QA
    // Inert fixture snapshots contain only synthetic app-owned captions/state.
    var previewCaptions: [String] { [window.title, heading.stringValue, summary.stringValue, detail.stringValue, notes.string] + visibleActions.compactMap { $0 == .notes ? notesLink.title : actionButtons[$0]?.title } }
    var previewContentSize: NSSize { preferredSize }
    var previewMinimumContentSize: NSSize { layoutContent(width: max(notesScroll.isHidden ? 380 : 480, buttonRowWidth)) }
    func layoutForPreview(width: CGFloat) {
        let size = layoutContent(width: width)
        window.setContentSize(size); window.contentView?.layoutSubtreeIfNeeded()
    }
    var previewProgress: Double { progress.doubleValue }
    var previewButtonIdentities: [ObjectIdentifier] { visibleActions.compactMap { $0 == .notes ? ObjectIdentifier(notesLink) : actionButtons[$0].map(ObjectIdentifier.init) } }
    var previewNotesSelection: NSRange { notes.selectedRange() }
    var previewNotesOrigin: NSPoint { notesScroll.contentView.bounds.origin }
    func focusAndScrollPreviewNotes() {
        notes.layoutManager?.ensureLayout(for: notes.textContainer!)
        notes.setSelectedRange(NSRange(location: 8, length: 12))
        notesScroll.contentView.scroll(to: NSPoint(x: 0, y: 80)); notesScroll.reflectScrolledClipView(notesScroll.contentView)
        window.makeFirstResponder(notes)
    }
    var previewLayoutDiagnostics: [String: Any] {
        guard let content = window.contentView else { return ["missingContent": true] }
        let controls: [(String, NSView)] = [("heading", heading), ("summary", summary), ("detail", detail), ("notesLink", notesLink)]
            + visibleActions.filter { $0 != .notes }.compactMap { action in actionButtons[action].map { (action.rawValue, $0 as NSView) } }
        let metrics = controls.filter { !$0.1.isHiddenOrHasHiddenAncestor }.map { name, control -> [String: Any] in
            let rect = control.convert(control.bounds, to: content)
            var record: [String: Any] = ["control": name, "bounds": [control.bounds.width, control.bounds.height], "contentRect": [rect.minX, rect.minY, rect.width, rect.height]]
            if let button = control as? NSButton { record["cellWidth"] = button.cell?.cellSize.width ?? 0 }
            if let field = control as? NSTextField {
                record["preferredWidth"] = field.preferredMaxLayoutWidth
                record["cellHeight"] = field.cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: field.bounds.width, height: 100_000)).height ?? 0
                record["textHeight"] = (field as? WrappingLabel)?.requiredHeight(forWidth: field.bounds.width) ?? 0
            }
            return record
        }
        return ["contentSize": [content.bounds.width, content.bounds.height], "controls": metrics]
    }
    var previewLayoutFits: Bool {
        guard let content = window.contentView else { return false }
        let controls: [NSView] = [heading, summary, detail, notesLink] + visibleActions.filter { $0 != .notes }.compactMap { actionButtons[$0] }
        return controls.filter { !$0.isHiddenOrHasHiddenAncestor }.allSatisfy { control in
            let rect = control.convert(control.bounds, to: content)
            guard content.bounds.insetBy(dx: -1, dy: -1).contains(rect) else { return false }
            if let button = control as? NSButton, let cell = button.cell {
                return cell.cellSize.width <= button.bounds.width + 1
            }
            guard let field = control as? NSTextField, let cell = field.cell else { return true }
            let required = cell.cellSize(forBounds: NSRect(x: 0, y: 0, width: field.bounds.width, height: 100_000))
            let glyph = (field.stringValue as NSString).boundingRect(with: NSSize(width: max(1, field.bounds.width - 4), height: 100_000),
                options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: field.font ?? DesignTokens.body]).height
            return field.bounds.height + 1 >= max(required.height, glyph + 2)
                && abs(field.preferredMaxLayoutWidth - field.bounds.width) <= 1
        }
    }
    func clickPreviewAction(_ action: Action) {
        let button = action == .notes ? notesLink : actionButtons[action]
        if let button, let selector = button.action { _ = button.sendAction(selector, to: button.target) }
    }
    func focusPreviewAction() {
        if let first = visibleActions.first { window.makeFirstResponder(first == .notes ? notesLink : actionButtons[first]) }
    }
    #endif
}
