import AppKit
import CaptureCore

private final class SettingsColumn: NSStackView {
    override var isFlipped: Bool { true }
}

@MainActor final class SettingsWindow: NSWindow {
    enum Section: Int { case general, permission, updates }
    struct Actions {
        let mask: () -> Void, drag: () -> Void, shortcut: () -> Void, login: () -> Void
        let request: () -> Void, settings: () -> Void, recheck: () -> Void, restart: () -> Void, reveal: () -> Void
        let update: () -> Void, automatic: (Bool) -> Void, language: (AppLanguage) -> Void
    }
    private let actions: Actions
    private let pages = NSView()
    private let permissionTitle = NSTextField(wrappingLabelWithString: "")
    private let permissionSummary = NSTextField(wrappingLabelWithString: "")
    private let permissionIcon = NSImageView()
    private let permissionDetails = NSTextField(wrappingLabelWithString: "")
    private let details = NSStackView()
    private let languageStatus = NSTextField(wrappingLabelWithString: "")
    private let loginStatus = NSTextField(wrappingLabelWithString: "")
    private let versionValue = NSTextField(labelWithString: "")
    private let updateStatus = NSTextField(wrappingLabelWithString: "")
    private let language = NSPopUpButton(frame: .zero, pullsDown: false)
    private lazy var login = NSButton(checkboxWithTitle: L10n.text("settings.login"), target: self, action: #selector(toggleLogin))
    private lazy var automatic = NSButton(checkboxWithTitle: L10n.text("updates.automatic"), target: self, action: #selector(toggleAutomatic))
    private lazy var navigation = NSSegmentedControl(labels: [L10n.text("settings.general"), L10n.text("settings.permissions"), L10n.text("settings.updates")], trackingMode: .selectOne, target: self, action: #selector(changeSection))
    private var shortcutButton: NSButton!
    private var loginApprovalButton: NSButton!
    private var restartLanguageButton: NSButton!
    private var detailsButton: NSButton!
    private var detailsCard: NSView!
    private var checkUpdatesButton: NSButton!
    private var requestButton: NSButton!
    private var callbacks = [ObjectIdentifier: () -> Void]()
    private var detailsVisible = false
    private let captureHint = NSTextField(wrappingLabelWithString: "")
    init(actions: Actions) {
        self.actions = actions
        super.init(contentRect: NSRect(x: 0, y: 0, width: 620, height: 510), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        title = L10n.text("settings.title"); isReleasedWhenClosed = false
        minSize = NSSize(width: 540, height: 450); backgroundColor = DesignTokens.windowSurface
        let content = NSView(); contentView = content
        let root = stack([], vertical: true, spacing: 16); root.alignment = .centerX
        content.addSubview(root); root.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            root.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            root.topAnchor.constraint(equalTo: content.topAnchor, constant: 18),
            root.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16)
        ])
        let icon = NSImageView(); icon.image = NSApp.applicationIconImage; icon.imageScaling = .scaleProportionallyUpOrDown
        icon.widthAnchor.constraint(equalToConstant: 44).isActive = true; icon.heightAnchor.constraint(equalToConstant: 44).isActive = true
        icon.setAccessibilityLabel(L10n.text("settings.icon"))
        let heading = stack([text(L10n.text("app.name"), font: DesignTokens.title), text(L10n.text("settings.subtitle"), secondary: true)], vertical: true, spacing: 2)
        let header = stack([icon, heading, spacer()], vertical: false, spacing: 12)
        root.addArrangedSubview(header); header.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        navigation.selectedSegment = 0; navigation.setAccessibilityLabel(L10n.text("settings.navigation"))
        root.addArrangedSubview(navigation)
        root.addArrangedSubview(pages); pages.widthAnchor.constraint(equalTo: root.widthAnchor).isActive = true
        pages.setContentHuggingPriority(.defaultLow, for: .vertical)
        let general = column()
        let captureTitle = text(L10n.text("settings.capture_title"), font: DesignTokens.section)
        let glyph = NSImageView(); glyph.image = CaptureGlyph.image(size: 22); glyph.contentTintColor = .controlAccentColor
        glyph.widthAnchor.constraint(equalToConstant: 24).isActive = true; glyph.heightAnchor.constraint(equalToConstant: 24).isActive = true
        let area = button(L10n.text("capture.area"), action: actions.drag); area.bezelColor = .controlAccentColor
        area.setAccessibilityHelp(L10n.text("capture.area_help"))
        let fixed = button(L10n.text("capture.fixed"), action: actions.mask); fixed.setAccessibilityHelp(L10n.text("capture.fixed_help"))
        captureHint.font = DesignTokens.caption; captureHint.textColor = DesignTokens.secondaryText
        general.addArrangedSubview(card([
            stack([glyph, captureTitle, spacer()], vertical: false, spacing: 8),
            text(L10n.text("settings.capture_description"), secondary: true),
            stack([area, fixed, spacer()], vertical: false, spacing: 8), captureHint
        ], spacing: 8))
        shortcutButton = button("", action: actions.shortcut); shortcutButton.font = DesignTokens.shortcut
        shortcutButton.setAccessibilityLabel(L10n.text("settings.shortcut"))
        let shortcutLabel = stack([text(L10n.text("settings.shortcut")), text(L10n.text("settings.shortcut_help"), font: DesignTokens.caption, secondary: true)], vertical: true, spacing: 2)
        language.addItems(withTitles: AppLanguage.allCases.map(\.nativeName)); language.target = self; language.action = #selector(changeLanguage)
        language.setAccessibilityLabel(L10n.text("settings.language"))
        loginStatus.font = DesignTokens.caption; loginStatus.textColor = DesignTokens.secondaryText
        loginApprovalButton = button(L10n.text("login.approval_action"), action: actions.login)
        general.addArrangedSubview(card([
            row(shortcutLabel, shortcutButton), rule(),
            stack([login, spacer(), loginStatus, loginApprovalButton], vertical: false, spacing: 8), rule(),
            row(text(L10n.text("settings.language")), language)
        ], spacing: 10))
        languageStatus.font = DesignTokens.caption; languageStatus.textColor = DesignTokens.secondaryText
        restartLanguageButton = button(L10n.text("action.restart"), action: actions.restart)
        general.addArrangedSubview(stack([languageStatus, spacer(), restartLanguageButton], vertical: false, spacing: 8))
        let access = column()
        permissionIcon.widthAnchor.constraint(equalToConstant: 27).isActive = true; permissionIcon.heightAnchor.constraint(equalToConstant: 27).isActive = true
        permissionTitle.font = DesignTokens.section
        permissionSummary.font = DesignTokens.body; permissionSummary.textColor = DesignTokens.secondaryText
        requestButton = button(L10n.text("permission.request"), action: actions.request); requestButton.bezelColor = .controlAccentColor
        access.addArrangedSubview(card([
            stack([permissionIcon, permissionTitle, spacer()], vertical: false, spacing: 9),
            permissionSummary,
            text(L10n.text("permission.reason"), secondary: true),
            stack([requestButton, button(L10n.text("permission.settings_short"), action: actions.settings), button(L10n.text("permission.recheck"), action: actions.recheck), spacer()], vertical: false, spacing: 8)
        ], spacing: 12))
        access.addArrangedSubview(text(L10n.text("permission.steps_short"), font: DesignTokens.caption, secondary: true))
        detailsButton = button(L10n.text("permission.details_show"), action: { [weak self] in self?.toggleDetails() })
        detailsButton.bezelStyle = .inline
        access.addArrangedSubview(detailsButton)
        details.orientation = .vertical; details.alignment = .leading; details.spacing = 10
        permissionDetails.font = DesignTokens.caption; permissionDetails.textColor = DesignTokens.secondaryText; permissionDetails.isSelectable = true
        details.addArrangedSubview(permissionDetails)
        details.addArrangedSubview(text(L10n.text("permission.minimum"), font: DesignTokens.caption, secondary: true))
        details.addArrangedSubview(stack([button(L10n.text("action.restart"), action: actions.restart), button(L10n.text("permission.reveal"), action: actions.reveal), spacer()], vertical: false, spacing: 8))
        detailsCard = card([details], spacing: 8); access.addArrangedSubview(detailsCard); detailsCard.isHidden = true
        let updates = column()
        versionValue.font = DesignTokens.caption; versionValue.textColor = DesignTokens.secondaryText
        checkUpdatesButton = button(L10n.text("menu.updates"), action: actions.update)
        updateStatus.font = DesignTokens.body; updateStatus.textColor = DesignTokens.secondaryText
        updates.addArrangedSubview(card([
            stack([text(L10n.text("updates.title"), font: DesignTokens.section), spacer(), versionValue], vertical: false, spacing: 8),
            automatic, updateStatus, stack([checkUpdatesButton, spacer()], vertical: false, spacing: 8)
        ], spacing: 12))
        updates.addArrangedSubview(text(L10n.text("updates.explanation"), font: DesignTokens.caption, secondary: true))
        updates.addArrangedSubview(text(L10n.text("updates.preview"), font: DesignTokens.caption, secondary: true))
        for page in [general, access, updates] {
            for view in page.arrangedSubviews { view.widthAnchor.constraint(equalTo: page.widthAnchor).isActive = true }
            let scroll = NSScrollView(); scroll.hasVerticalScroller = true; scroll.autohidesScrollers = true; scroll.drawsBackground = false
            scroll.documentView = page; pages.addSubview(scroll); scroll.translatesAutoresizingMaskIntoConstraints = false
            page.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scroll.leadingAnchor.constraint(equalTo: pages.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: pages.trailingAnchor),
                scroll.topAnchor.constraint(equalTo: pages.topAnchor), scroll.bottomAnchor.constraint(equalTo: pages.bottomAnchor),
                page.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor), page.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
                page.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor)
            ])
        }
        select(.general); center()
    }
    func refresh(permission: PermissionStatus, shortcut: String, login: String, loginEnabled: Bool = false, loginNeedsApproval: Bool = false,
                 update: String, automaticEnabled: Bool, configured: Bool, canCheck: Bool, languageSelection: LanguageSelection? = nil) {
        permissionTitle.stringValue = L10n.text(permission.isReady ? "permission.ready.short" : "permission.review.short")
        permissionIcon.image = NSImage(systemSymbolName: permission.isReady ? "checkmark.circle.fill" : "record.circle", accessibilityDescription: nil)
        permissionIcon.contentTintColor = permission.isReady ? DesignTokens.ready : DesignTokens.attention
        permissionSummary.stringValue = L10n.text(permission.isReady ? "permission.ready.summary" : "permission.review.summary")
        permissionDetails.stringValue = L10n.format("permission.details_format", permission.identityAdvice, permission.bundleURL.path)
        requestButton.isHidden = permission.isReady
        captureHint.stringValue = L10n.text(permission.isReady ? "settings.capture_hint" : "settings.capture_access_hint")
        shortcutButton.title = shortcut; shortcutButton.setAccessibilityValue(shortcut)
        self.login.state = loginEnabled ? .on : .off; self.login.isEnabled = !loginNeedsApproval
        loginStatus.stringValue = loginNeedsApproval ? login : ""; loginStatus.isHidden = !loginNeedsApproval
        loginApprovalButton.isHidden = !loginNeedsApproval
        versionValue.stringValue = L10n.format("version.current", permission.version)
        updateStatus.stringValue = update; automatic.state = automaticEnabled ? .on : .off; automatic.isEnabled = configured
        automatic.setAccessibilityHelp(L10n.text(configured ? "updates.explanation" : "updates.unconfigured"))
        checkUpdatesButton.isEnabled = configured && canCheck; checkUpdatesButton.setAccessibilityHelp(update)
        let selection = languageSelection ?? L10n.selection
        language.selectItem(at: AppLanguage.allCases.firstIndex(of: selection.selected) ?? 0)
        languageStatus.stringValue = L10n.text(selection.requiresRestart ? "settings.language_pending" : "settings.language_help")
        restartLanguageButton.isHidden = !selection.requiresRestart
        if requestButton.isHidden, firstResponder === requestButton { makeFirstResponder(navigation) }
        if restartLanguageButton.isHidden, firstResponder === restartLanguageButton { makeFirstResponder(language) }
    }
    func select(_ section: Section) {
        navigation.selectedSegment = section.rawValue
        for (index, view) in pages.subviews.enumerated() { view.isHidden = index != section.rawValue }
        if let responder = firstResponder as? NSView, responder.isHiddenOrHasHiddenAncestor { makeFirstResponder(navigation) }
    }
    func showTroubleshootingForPreview() { if !detailsVisible { toggleDetails() } }
    @objc private func changeSection() { select(Section(rawValue: navigation.selectedSegment) ?? .general) }
    @objc private func toggleAutomatic() { actions.automatic(automatic.state == .on) }
    @objc private func toggleLogin() { actions.login() }
    @objc private func changeLanguage() {
        guard AppLanguage.allCases.indices.contains(language.indexOfSelectedItem) else { return }
        actions.language(AppLanguage.allCases[language.indexOfSelectedItem])
    }
    @objc private func invoke(_ sender: NSButton) { callbacks[ObjectIdentifier(sender)]?() }
    private func toggleDetails() {
        detailsVisible.toggle(); detailsCard.isHidden = !detailsVisible
        if !detailsVisible, let responder = firstResponder as? NSView, responder.isDescendant(of: details) { makeFirstResponder(detailsButton) }
        detailsButton.title = L10n.text(detailsVisible ? "permission.details_hide" : "permission.details_show")
        detailsButton.setAccessibilityLabel(detailsButton.title)
    }
    private func button(_ title: String, action: @escaping () -> Void) -> NSButton {
        let button = NSButton(title: title, target: self, action: #selector(invoke(_:))); button.bezelStyle = .rounded
        button.setAccessibilityLabel(title); callbacks[ObjectIdentifier(button)] = action; return button
    }
    private func text(_ value: String, font: NSFont = DesignTokens.body, secondary: Bool = false) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: value); field.font = font
        field.textColor = secondary ? DesignTokens.secondaryText : DesignTokens.primaryText
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal); return field
    }
    private func stack(_ views: [NSView], vertical: Bool, spacing: CGFloat) -> NSStackView {
        let stack = NSStackView(views: views); stack.orientation = vertical ? .vertical : .horizontal
        stack.alignment = vertical ? .leading : .centerY; stack.spacing = spacing; return stack
    }
    private func column() -> NSStackView {
        let column = SettingsColumn(); column.orientation = .vertical; column.alignment = .leading; column.spacing = 12
        return column
    }
    private func row(_ label: NSView, _ control: NSView) -> NSStackView { stack([label, spacer(), control], vertical: false, spacing: 12) }
    private func spacer() -> NSView {
        let spacer = NSView(); spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        spacer.setContentCompressionResistancePriority(.init(1), for: .horizontal); return spacer
    }
    private func card(_ views: [NSView], spacing: CGFloat) -> NSView {
        let card = SettingsCard(); let content = stack(views, vertical: true, spacing: spacing)
        card.addSubview(content); content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15), content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 14), content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        for view in views { view.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true }
        return card
    }
    private func rule() -> NSView { let rule = NSBox(); rule.boxType = .separator; return rule }
}
