import AppKit
import CaptureCore

private final class SettingsColumn: NSStackView {
    override var isFlipped: Bool { true }
}

// The control retains native keyboard, focus and accessibility behavior. Only
// the selected icon tile is drawn to match the reference's navigation hierarchy.
private final class SettingsRailButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        if state == .on {
            NSColor.controlAccentColor.setFill()
            NSBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), xRadius: 10, yRadius: 10).fill()
        }
        super.draw(dirtyRect)
    }
    override func viewDidChangeEffectiveAppearance() { super.viewDidChangeEffectiveAppearance(); needsDisplay = true }
}

private final class OpaqueRailSurface: NSView {
    override func draw(_ dirtyRect: NSRect) { NSColor.windowBackgroundColor.setFill(); NSBezierPath(rect: bounds).fill() }
}

@MainActor final class SettingsWindow: NSWindow {
    enum Section: Int, CaseIterable {
        case general, permission, updates
        var key: String {
            switch self { case .general: return "settings.general"; case .permission: return "settings.permissions"; case .updates: return "settings.updates" }
        }
        var symbol: String {
            switch self { case .general: return "slider.horizontal.3"; case .permission: return "lock.shield"; case .updates: return "arrow.down.circle" }
        }
    }
    struct Actions {
        let mask: () -> Void, drag: () -> Void, shortcut: () -> Void, login: () -> Void
        let request: () -> Void, settings: () -> Void, recheck: () -> Void, restart: () -> Void, reveal: () -> Void
        let update: () -> Void, automatic: (Bool) -> Void, language: (AppLanguage) -> Void
    }
    private struct State {
        let permission: PermissionStatus, shortcut: String, spokenShortcut: String?, login: String
        let loginEnabled: Bool, loginNeedsApproval: Bool, update: String, updateText: (() -> String)?, automaticEnabled: Bool, configured: Bool, canCheck: Bool
    }
    private let actions: Actions
    private var state: State?
    private let pages = NSView()
    private let pageTitle = NSTextField(labelWithString: "")
    private let rail = NSVisualEffectView()
    private let opaqueRail = OpaqueRailSurface()
    private var railButtons = [SettingsRailButton]()
    private var scrollViews = [NSScrollView]()
    private var localizationBindings = [() -> Void]()
    private var callbacks = [ObjectIdentifier: () -> Void]()
    private let language = NSPopUpButton(frame: .zero, pullsDown: false)
    private let login = NSSwitch()
    private let automatic = NSSwitch()
    private var loginLabel: NSTextField!
    private var automaticLabel: NSTextField!
    private let loginStatus = NSTextField(wrappingLabelWithString: "")
    private let permissionTitle = NSTextField(wrappingLabelWithString: "")
    private let permissionSummary = NSTextField(wrappingLabelWithString: "")
    private let permissionIcon = NSImageView()
    private let permissionDetails = NSTextField(wrappingLabelWithString: "")
    private let versionValue = NSTextField(labelWithString: "")
    private let updateStatus = NSTextField(wrappingLabelWithString: "")
    private let captureHint = NSTextField(wrappingLabelWithString: "")
    private var shortcutButton: NSButton!
    private var loginApprovalButton: NSButton!
    private var requestButton: NSButton!
    private var requestRow: NSView!
    private var requestRule: NSView!
    private var checkUpdatesButton: NSButton!
    private var detailsButton: NSButton!
    private var detailsCard: NSView!
    private var detailsVisible = false
    private(set) var selectedSection: Section = .general
    var troubleshootingVisible: Bool { detailsVisible }
    var previewScrollView: NSScrollView { scrollViews[selectedSection.rawValue] }

    init(actions: Actions) {
        self.actions = actions
        super.init(contentRect: NSRect(x: 0, y: 0, width: 720, height: 560), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        isReleasedWhenClosed = false; titleVisibility = .hidden; titlebarAppearsTransparent = true
        minSize = frameRect(forContentRect: NSRect(x: 0, y: 0, width: 620, height: 480)).size
        backgroundColor = DesignTokens.windowSurface
        // Keep native titlebar geometry separate from the settings content.
        // This also avoids coupling the scroll views' fitting size to a
        // full-size contentLayoutGuide while the window is still hidden.
        let content = NSView(); contentView = content
        let safeTop = content.topAnchor
        rail.material = .sidebar; rail.blendingMode = .behindWindow; rail.state = .followsWindowActiveState
        content.addSubview(rail); rail.translatesAutoresizingMaskIntoConstraints = false
        rail.addSubview(opaqueRail); opaqueRail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rail.leadingAnchor.constraint(equalTo: content.leadingAnchor), rail.topAnchor.constraint(equalTo: content.topAnchor),
            rail.bottomAnchor.constraint(equalTo: content.bottomAnchor), rail.widthAnchor.constraint(equalToConstant: 72),
            opaqueRail.leadingAnchor.constraint(equalTo: rail.leadingAnchor), opaqueRail.trailingAnchor.constraint(equalTo: rail.trailingAnchor),
            opaqueRail.topAnchor.constraint(equalTo: rail.topAnchor), opaqueRail.bottomAnchor.constraint(equalTo: rail.bottomAnchor)
        ])
        let navigation = stack([], vertical: true, spacing: 12)
        navigation.setAccessibilityLabel(L10n.text("settings.navigation"))
        rail.addSubview(navigation); navigation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([navigation.topAnchor.constraint(equalTo: safeTop, constant: 16), navigation.centerXAnchor.constraint(equalTo: rail.centerXAnchor)])
        for section in Section.allCases {
            let button = SettingsRailButton(title: "", target: self, action: #selector(changeSection(_:)))
            button.tag = section.rawValue; button.setButtonType(.pushOnPushOff); button.isBordered = false
            button.imagePosition = .imageOnly; button.focusRingType = .exterior
            button.image = NSImage(systemSymbolName: section.symbol, accessibilityDescription: nil)?.withSymbolConfiguration(.init(pointSize: 22, weight: .regular))
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true; button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            navigation.addArrangedSubview(button); railButtons.append(button)
        }
        let railRule = rule(); content.addSubview(railRule); railRule.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([railRule.leadingAnchor.constraint(equalTo: rail.trailingAnchor), railRule.topAnchor.constraint(equalTo: content.topAnchor), railRule.bottomAnchor.constraint(equalTo: content.bottomAnchor), railRule.widthAnchor.constraint(equalToConstant: 1)])
        pageTitle.font = DesignTokens.title
        let header = stack([pageTitle, spacer()], vertical: false, spacing: 0)
        header.edgeInsets = NSEdgeInsets(top: 0, left: 44, bottom: 0, right: 28)
        content.addSubview(header); header.translatesAutoresizingMaskIntoConstraints = false
        let headerRule = rule(); content.addSubview(headerRule); headerRule.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(pages); pages.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: rail.trailingAnchor), header.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            header.topAnchor.constraint(equalTo: safeTop), header.heightAnchor.constraint(equalToConstant: 56),
            headerRule.leadingAnchor.constraint(equalTo: header.leadingAnchor), headerRule.trailingAnchor.constraint(equalTo: header.trailingAnchor), headerRule.topAnchor.constraint(equalTo: header.bottomAnchor),
            pages.leadingAnchor.constraint(equalTo: header.leadingAnchor), pages.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            pages.topAnchor.constraint(equalTo: header.bottomAnchor), pages.bottomAnchor.constraint(equalTo: content.bottomAnchor)
        ])
        let general = column()
        shortcutButton = button(nil, action: actions.shortcut); shortcutButton.font = DesignTokens.shortcut
        shortcutButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 104).isActive = true
        let area = button("capture.start", accessibility: "capture.area", action: actions.drag)
        let fixed = button("capture.start", accessibility: "capture.fixed", action: actions.mask)
        localizationBindings.append { [weak area, weak fixed] in
            area?.setAccessibilityHelp(L10n.text("capture.area_help")); fixed?.setAccessibilityHelp(L10n.text("capture.fixed_help"))
        }
        captureHint.font = DesignTokens.caption; captureHint.textColor = DesignTokens.secondaryText
        general.addArrangedSubview(section("settings.capture_section", rows: [
            row(label("settings.shortcut", help: "settings.shortcut_help"), shortcutButton),
            row(label("capture.area", help: "capture.area_help"), area),
            row(label("capture.fixed", help: "capture.fixed_help"), fixed)
        ], footer: captureHint))
        login.target = self; login.action = #selector(toggleLogin)
        loginLabel = text("settings.login")
        loginStatus.font = DesignTokens.caption; loginStatus.textColor = DesignTokens.secondaryText
        loginApprovalButton = button("login.approval_action", action: actions.login)
        let loginLabels = stack([loginLabel, loginStatus], vertical: true, spacing: 3)
        let loginControls = stack([loginApprovalButton, login], vertical: false, spacing: 10)
        language.addItems(withTitles: AppLanguage.allCases.map(\.nativeName)); language.target = self; language.action = #selector(changeLanguage)
        language.widthAnchor.constraint(greaterThanOrEqualToConstant: 132).isActive = true
        language.setContentCompressionResistancePriority(.required, for: .horizontal)
        general.addArrangedSubview(section("settings.app_section", rows: [row(loginLabels, loginControls), row(label("settings.language"), language)], footer: text("settings.language_help", font: DesignTokens.caption, secondary: true)))
        let access = column()
        permissionIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true; permissionIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        permissionTitle.font = DesignTokens.body; permissionSummary.font = DesignTokens.caption; permissionSummary.textColor = DesignTokens.secondaryText
        let statusLabels = stack([permissionTitle, permissionSummary], vertical: true, spacing: 3)
        let statusRow = row(stack([permissionIcon, statusLabels], vertical: false, spacing: 10), nil)
        requestButton = button("permission.request", action: actions.request)
        requestRow = row(text("permission.reason", font: DesignTokens.caption, secondary: true), requestButton)
        requestRule = rule()
        access.addArrangedSubview(section("settings.screen_recording_section", content: group([statusRow, requestRule, requestRow])))
        access.addArrangedSubview(section("settings.recovery_section", rows: [
            row(label("permission.settings", help: "permission.steps_short"), button("permission.open_action", accessibility: "permission.settings", action: actions.settings)),
            row(label("permission.status_label"), button("permission.recheck", action: actions.recheck))
        ], footer: text("permission.minimum", font: DesignTokens.caption, secondary: true)))
        detailsButton = button("permission.details_show", action: { [weak self] in self?.toggleDetails() })
        detailsButton.bezelStyle = .inline; detailsButton.isBordered = false; detailsButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        detailsButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 28).isActive = true
        permissionDetails.font = DesignTokens.caption; permissionDetails.textColor = DesignTokens.secondaryText; permissionDetails.isSelectable = true
        detailsCard = group([
            row(permissionDetails, nil), rule(),
            row(label("permission.restart_label"), button("action.restart", action: actions.restart)), rule(),
            row(label("permission.location_label"), button("permission.reveal_short", accessibility: "permission.reveal", action: actions.reveal))
        ])
        let troubleshooting = stack([stack([detailsButton, spacer()], vertical: false, spacing: 0), detailsCard], vertical: true, spacing: 8)
        for view in troubleshooting.arrangedSubviews { view.widthAnchor.constraint(equalTo: troubleshooting.widthAnchor).isActive = true }
        access.addArrangedSubview(troubleshooting); detailsCard.isHidden = true
        let updates = column()
        versionValue.font = DesignTokens.body; versionValue.textColor = DesignTokens.secondaryText; versionValue.alignment = .right
        automaticLabel = text("updates.automatic"); automatic.target = self; automatic.action = #selector(toggleAutomatic)
        checkUpdatesButton = button("menu.updates", action: actions.update)
        updateStatus.font = DesignTokens.caption; updateStatus.textColor = DesignTokens.secondaryText
        updates.addArrangedSubview(section("updates.title", rows: [
            row(label("version.label"), versionValue), row(automaticLabel, automatic),
            row(stack([text("updates.check_label"), updateStatus], vertical: true, spacing: 3), checkUpdatesButton)
        ], footer: text("updates.explanation", font: DesignTokens.caption, secondary: true)))
        updates.addArrangedSubview(footer(text("updates.preview", font: DesignTokens.caption, secondary: true)))
        for page in [general, access, updates] {
            for view in page.arrangedSubviews { view.widthAnchor.constraint(equalTo: page.widthAnchor, constant: -56).isActive = true }
            let scroll = NSScrollView(); scroll.hasVerticalScroller = true; scroll.autohidesScrollers = true; scroll.drawsBackground = false
            scroll.documentView = page; pages.addSubview(scroll); scroll.translatesAutoresizingMaskIntoConstraints = false
            page.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scroll.leadingAnchor.constraint(equalTo: pages.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: pages.trailingAnchor),
                scroll.topAnchor.constraint(equalTo: pages.topAnchor), scroll.bottomAnchor.constraint(equalTo: pages.bottomAnchor),
                page.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor), page.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
                page.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor)
            ])
            scrollViews.append(scroll)
        }
        localizationBindings.append { [weak language, weak login, weak automatic, weak shortcutButton, weak navigation] in
            language?.setAccessibilityLabel(L10n.text("settings.language")); login?.setAccessibilityLabel(L10n.text("settings.login"))
            automatic?.setAccessibilityLabel(L10n.text("updates.automatic")); shortcutButton?.setAccessibilityLabel(L10n.text("settings.shortcut_change_accessibility"))
            shortcutButton?.setAccessibilityHelp(L10n.text("settings.shortcut_help")); navigation?.setAccessibilityLabel(L10n.text("settings.navigation"))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalization), name: L10n.languageDidChange, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refreshAccessibilityDisplay), name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil)
        refreshLocalization(); refreshAccessibilityDisplay(); center()
    }
    func refresh(permission: PermissionStatus, shortcut: String, spokenShortcut: String? = nil, login: String, loginEnabled: Bool = false, loginNeedsApproval: Bool = false,
                 update: String, updateText: (() -> String)? = nil, automaticEnabled: Bool, configured: Bool, canCheck: Bool) {
        state = State(permission: permission, shortcut: shortcut, spokenShortcut: spokenShortcut, login: login, loginEnabled: loginEnabled, loginNeedsApproval: loginNeedsApproval,
                      update: update, updateText: updateText, automaticEnabled: automaticEnabled, configured: configured, canCheck: canCheck)
        applyState()
    }
    private func applyState() {
        guard let state else { return }
        let permission = state.permission
        permissionTitle.stringValue = L10n.text(permission.isReady ? "permission.ready.short" : "permission.review.short")
        permissionIcon.image = NSImage(systemSymbolName: permission.isReady ? "checkmark.circle.fill" : "record.circle", accessibilityDescription: nil)
        permissionIcon.contentTintColor = permission.isReady ? DesignTokens.ready : DesignTokens.attention
        permissionSummary.stringValue = permission.explanation
        permissionDetails.stringValue = L10n.format("permission.details_format", permission.identityAdvice, permission.bundleURL.path)
        requestRow.isHidden = permission.isReady; requestRule.isHidden = permission.isReady
        captureHint.stringValue = L10n.text(permission.isReady ? "settings.capture_description" : "settings.capture_access_hint")
        shortcutButton.title = state.shortcut; shortcutButton.setAccessibilityValue(state.spokenShortcut ?? state.shortcut)
        login.state = state.loginEnabled ? .on : .off; login.isEnabled = !state.loginNeedsApproval
        loginStatus.stringValue = state.loginNeedsApproval ? L10n.text("login.approval") : ""; loginStatus.isHidden = !state.loginNeedsApproval
        loginApprovalButton.isHidden = !state.loginNeedsApproval
        versionValue.stringValue = permission.version
        updateStatus.stringValue = state.updateText?() ?? state.update; automatic.state = state.automaticEnabled ? .on : .off; automatic.isEnabled = state.configured
        automatic.setAccessibilityHelp(L10n.text(state.configured ? "updates.explanation" : "updates.unconfigured"))
        checkUpdatesButton.isEnabled = state.configured && state.canCheck; checkUpdatesButton.setAccessibilityHelp(updateStatus.stringValue)
        language.selectItem(at: AppLanguage.allCases.firstIndex(of: L10n.language) ?? 0)
        if requestRow.isHidden, let responder = firstResponder as? NSView, responder.isDescendant(of: requestRow) { makeFirstResponder(railButtons[Section.permission.rawValue]) }
    }
    @objc func refreshLocalization() {
        let origins = scrollViews.map { $0.contentView.bounds.origin }
        title = L10n.text("settings.title")
        localizationBindings.forEach { $0() }
        for (index, button) in railButtons.enumerated() {
            let section = Section(rawValue: index)!
            button.toolTip = L10n.text(section.key); button.setAccessibilityLabel(L10n.text(section.key))
            button.setAccessibilityHelp(L10n.format("settings.section_help", L10n.text(section.key)))
        }
        select(selectedSection); updateDetailsPresentation(); applyState()
        contentView?.layoutSubtreeIfNeeded()
        for (scroll, origin) in zip(scrollViews, origins) { scroll.contentView.scroll(to: origin); scroll.reflectScrolledClipView(scroll.contentView) }
    }
    @objc private func refreshAccessibilityDisplay() {
        opaqueRail.isHidden = !NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        railButtons.forEach { $0.needsDisplay = true }; contentView?.needsDisplay = true
    }
    func select(_ section: Section) {
        selectedSection = section; pageTitle.stringValue = L10n.text(section.key)
        for (index, button) in railButtons.enumerated() {
            let selected = index == section.rawValue
            button.state = selected ? .on : .off; button.contentTintColor = selected ? .selectedControlTextColor : .secondaryLabelColor
            button.setAccessibilityValue(L10n.text(selected ? "settings.selected" : "settings.not_selected")); button.needsDisplay = true
            scrollViews[index].isHidden = !selected
        }
        if let responder = firstResponder as? NSView, responder.isHiddenOrHasHiddenAncestor { makeFirstResponder(railButtons[section.rawValue]) }
    }
    func showTroubleshootingForPreview() { if !detailsVisible { toggleDetails() } }
    // Fixture reads and exercises actual controls/actions; it does not recreate
    // a view model or write preferences, nor replace the normal app startup path.
    var previewControls: (language: NSPopUpButton, login: NSSwitch, automatic: NSSwitch, checkUpdates: NSButton, shortcut: NSButton, loginLabel: NSTextField, automaticLabel: NSTextField, pageTitle: NSTextField, permissionTitle: NSTextField, updateStatus: NSTextField) {
        (language, login, automatic, checkUpdatesButton, shortcutButton, loginLabel, automaticLabel, pageTitle, permissionTitle, updateStatus)
    }
    var previewGeometry: (pages: NSRect, viewport: NSRect, document: NSRect, controls: [NSView]) {
        let scroll = previewScrollView
        let controls: [NSView]
        switch selectedSection {
        case .general: controls = [shortcutButton, login, language]
        case .permission: controls = [permissionTitle, detailsButton] + (requestRow.isHidden ? [] : [requestButton])
        case .updates: controls = [versionValue, automatic, checkUpdatesButton]
        }
        return (pages.bounds, scroll.contentView.bounds, scroll.documentView!.bounds, controls)
    }
    @objc private func changeSection(_ sender: NSButton) { select(Section(rawValue: sender.tag) ?? .general) }
    @objc private func toggleAutomatic() { actions.automatic(automatic.state == .on) }
    @objc private func toggleLogin() { actions.login() }
    @objc private func changeLanguage() {
        guard AppLanguage.allCases.indices.contains(language.indexOfSelectedItem) else { return }
        actions.language(AppLanguage.allCases[language.indexOfSelectedItem])
    }
    @objc private func invoke(_ sender: NSButton) { callbacks[ObjectIdentifier(sender)]?() }
    private func toggleDetails() {
        detailsVisible.toggle(); detailsCard.isHidden = !detailsVisible
        if !detailsVisible, let responder = firstResponder as? NSView, responder.isDescendant(of: detailsCard) { makeFirstResponder(detailsButton) }
        updateDetailsPresentation()
    }
    private func updateDetailsPresentation() {
        detailsButton.title = L10n.text(detailsVisible ? "permission.details_hide" : "permission.details_show")
        detailsButton.image = NSImage(systemSymbolName: detailsVisible ? "chevron.down" : "chevron.right", accessibilityDescription: nil)
        detailsButton.imagePosition = .imageLeading; detailsButton.setAccessibilityLabel(detailsButton.title)
        detailsButton.setAccessibilityValue(L10n.text(detailsVisible ? "settings.expanded" : "settings.collapsed"))
    }
    private func button(_ key: String?, accessibility: String? = nil, action: @escaping () -> Void) -> NSButton {
        let button = NSButton(title: "", target: self, action: #selector(invoke(_:))); button.bezelStyle = .rounded
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 108).isActive = true
        button.setContentHuggingPriority(.required, for: .horizontal); button.setContentCompressionResistancePriority(.required, for: .horizontal)
        if let key { localizationBindings.append { [weak button] in button?.title = L10n.text(key); button?.setAccessibilityLabel(L10n.text(accessibility ?? key)) } }
        callbacks[ObjectIdentifier(button)] = action; return button
    }
    private func text(_ key: String, font: NSFont = DesignTokens.body, secondary: Bool = false) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: ""); field.font = font
        field.textColor = secondary ? DesignTokens.secondaryText : DesignTokens.primaryText
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        localizationBindings.append { [weak field] in field?.stringValue = L10n.text(key) }; return field
    }
    private func label(_ key: String, help: String? = nil) -> NSView {
        guard let help else { return text(key) }
        return stack([text(key), text(help, font: DesignTokens.caption, secondary: true)], vertical: true, spacing: 3)
    }
    private func stack(_ views: [NSView], vertical: Bool, spacing: CGFloat) -> NSStackView {
        let stack = NSStackView(views: views); stack.orientation = vertical ? .vertical : .horizontal
        stack.alignment = vertical ? .leading : .centerY; stack.spacing = spacing; return stack
    }
    private func column() -> NSStackView {
        let column = SettingsColumn(); column.orientation = .vertical; column.alignment = .leading; column.spacing = 24
        column.edgeInsets = NSEdgeInsets(top: 22, left: 28, bottom: 24, right: 28)
        return column
    }
    private func row(_ label: NSView, _ control: NSView?) -> NSView {
        let row = stack(control.map { [label, spacer(), $0] } ?? [label], vertical: false, spacing: 12)
        row.edgeInsets = NSEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        if let control { control.setContentCompressionResistancePriority(.required, for: .horizontal) }
        label.setContentHuggingPriority(.defaultLow, for: .horizontal); label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return row
    }
    private func section(_ key: String, rows: [NSView], footer: NSView? = nil) -> NSView {
        var content = [NSView]()
        for (index, row) in rows.enumerated() { if index > 0 { content.append(rule()) }; content.append(row) }
        return section(key, content: group(content), footer: footer)
    }
    private func section(_ key: String, content: NSView, footer: NSView? = nil) -> NSView {
        let heading = stack([text(key, font: DesignTokens.section), spacer()], vertical: false, spacing: 0)
        heading.edgeInsets = NSEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        let section = stack([heading, content], vertical: true, spacing: 10)
        if let footer { section.addArrangedSubview(self.footer(footer)) }
        for view in section.arrangedSubviews { view.widthAnchor.constraint(equalTo: section.widthAnchor).isActive = true }
        return section
    }
    private func footer(_ view: NSView) -> NSView {
        let footer = stack([view], vertical: true, spacing: 0); footer.edgeInsets = NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.widthAnchor.constraint(equalTo: footer.widthAnchor, constant: -32).isActive = true; return footer
    }
    private func group(_ views: [NSView]) -> NSView {
        let card = SettingsCard(); let content = stack(views, vertical: true, spacing: 0)
        content.alignment = .centerX
        card.addSubview(content); content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([content.leadingAnchor.constraint(equalTo: card.leadingAnchor), content.trailingAnchor.constraint(equalTo: card.trailingAnchor), content.topAnchor.constraint(equalTo: card.topAnchor), content.bottomAnchor.constraint(equalTo: card.bottomAnchor)])
        for view in views {
            let inset: CGFloat = view is NSBox ? 16 : 0
            view.widthAnchor.constraint(equalTo: content.widthAnchor, constant: -2 * inset).isActive = true

        }
        return card
    }
    private func spacer() -> NSView {
        let spacer = NSView(); spacer.setContentHuggingPriority(.init(1), for: .horizontal); spacer.setContentCompressionResistancePriority(.init(1), for: .horizontal); return spacer
    }
    private func rule() -> NSView { let rule = NSBox(); rule.boxType = .separator; return rule }
}
