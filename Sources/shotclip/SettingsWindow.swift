import AppKit
import CaptureCore

private final class SettingsColumn:NSStackView {
    override var isFlipped:Bool {true}
}

@MainActor final class SettingsWindow:NSWindow {
    enum Section:Int {case general,permission,updates}
    struct Actions {
        let mask:()->Void, drag:()->Void, shortcut:()->Void, login:()->Void
        let request:()->Void, settings:()->Void, recheck:()->Void, restart:()->Void, reveal:()->Void
        let update:()->Void, automatic:(Bool)->Void, language:(AppLanguage)->Void
    }
    private let actions:Actions
    private let root=NSStackView()
    private let pages=NSView()
    private var sections=[NSView]()
    private let permissionBadge=NSTextField(wrappingLabelWithString:"")
    private let generalPermissionBadge=NSTextField(wrappingLabelWithString:"")
    private let permissionSummary=NSTextField(wrappingLabelWithString:"")
    private let permissionDetails=NSTextField(wrappingLabelWithString:"")
    private let shortcutValue=NSTextField(labelWithString:"")
    private let versionValue=NSTextField(labelWithString:"")
    private let updateStatus=NSTextField(wrappingLabelWithString:"")
    private lazy var automatic=NSButton(checkboxWithTitle:L10n.text("updates.automatic"),target:self,action:#selector(toggleAutomatic))
    private lazy var navigation=NSSegmentedControl(labels:[L10n.text("settings.general"),L10n.text("settings.permissions"),L10n.text("settings.updates")],trackingMode:.selectOne,target:self,action:#selector(changeSection))
    private let loginValue=NSTextField(wrappingLabelWithString:"")
    private let languageStatus=NSTextField(wrappingLabelWithString:"")
    private let language=NSPopUpButton(frame:.zero,pullsDown:false)
    private var recoveryButton:NSButton!
    private var restartLanguageButton:NSButton!
    private var detailsButton:NSButton!
    private var checkUpdatesButton:NSButton!
    private var captureButtons=[NSButton]()
    private var callbacks=[ObjectIdentifier:()->Void]()
    private var detailsVisible=false
    init(actions:Actions) {
        self.actions=actions
        super.init(contentRect:NSRect(x:0,y:0,width:660,height:560),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
        title=L10n.text("settings.title");isReleasedWhenClosed=false;minSize=NSSize(width:520,height:470);backgroundColor=DesignTokens.windowSurface
        let content=NSView();contentView=content
        root.orientation = .vertical;root.alignment = .leading;root.spacing=DesignTokens.sectionGap
        content.addSubview(root);root.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([root.leadingAnchor.constraint(equalTo:content.leadingAnchor,constant:DesignTokens.inset),root.trailingAnchor.constraint(equalTo:content.trailingAnchor,constant:-DesignTokens.inset),root.topAnchor.constraint(equalTo:content.topAnchor,constant:DesignTokens.inset),root.bottomAnchor.constraint(equalTo:content.bottomAnchor,constant:-DesignTokens.inset)])
        let icon=NSImageView();icon.image=NSApp.applicationIconImage;icon.imageScaling = .scaleProportionallyUpOrDown
        icon.widthAnchor.constraint(equalToConstant:56).isActive=true;icon.heightAnchor.constraint(equalToConstant:56).isActive=true
        icon.setAccessibilityLabel(L10n.text("settings.icon"))
        let name=text(L10n.text("app.name"),font:DesignTokens.title)
        let subtitle=text(L10n.text("settings.subtitle"),secondary:true)
        let heading=stack([name,subtitle],vertical:true,spacing:4)
        root.addArrangedSubview(stack([icon,heading],vertical:false,spacing:16))
        navigation.selectedSegment=0;navigation.setAccessibilityLabel(L10n.text("settings.navigation"));root.addArrangedSubview(navigation)
        root.addArrangedSubview(pages);pages.translatesAutoresizingMaskIntoConstraints=false
        pages.widthAnchor.constraint(equalTo:root.widthAnchor).isActive=true
        pages.setContentHuggingPriority(.defaultLow,for:.vertical)
        let general=column()
        general.addArrangedSubview(text(L10n.text("settings.capture_title"),font:DesignTokens.section))
        general.addArrangedSubview(text(L10n.text("settings.capture_description"),secondary:true))
        generalPermissionBadge.font = .systemFont(ofSize:13,weight:.medium)
        general.addArrangedSubview(generalPermissionBadge)
        recoveryButton=button(L10n.text("permission.settings"),action:actions.settings)
        general.addArrangedSubview(recoveryButton)
        general.addArrangedSubview(button(L10n.text("settings.permission_review"),action:{[weak self] in self?.select(.permission)}))
        let mask=button(L10n.text("capture.fixed"),action:actions.mask);let drag=button(L10n.text("capture.drag"),action:actions.drag);captureButtons=[mask,drag]
        general.addArrangedSubview(stack([mask,drag],vertical:false,spacing:12))
        general.addArrangedSubview(rule())
        shortcutValue.font = DesignTokens.shortcut
        general.addArrangedSubview(stack([text(L10n.text("settings.shortcut")),shortcutValue,button(L10n.text("settings.shortcut_change"),action:actions.shortcut)],vertical:false,spacing:14))
        loginValue.textColor=DesignTokens.secondaryText;loginValue.setAccessibilityLabel(L10n.text("settings.login"))
        general.addArrangedSubview(stack([text(L10n.text("settings.login")),loginValue],vertical:false,spacing:DesignTokens.group))
        general.addArrangedSubview(button(L10n.text("settings.login_change"),action:actions.login))
        general.addArrangedSubview(rule())
        language.addItems(withTitles:AppLanguage.allCases.map(\.nativeName));language.target=self;language.action=#selector(changeLanguage)
        language.setAccessibilityLabel(L10n.text("settings.language"));language.setAccessibilityHelp(L10n.text("settings.language_help"))
        general.addArrangedSubview(stack([text(L10n.text("settings.language")),language],vertical:false,spacing:DesignTokens.group))
        languageStatus.font=DesignTokens.caption;languageStatus.textColor=DesignTokens.secondaryText
        general.addArrangedSubview(languageStatus)
        restartLanguageButton=button(L10n.text("action.restart"),action:actions.restart);general.addArrangedSubview(restartLanguageButton)
        general.addArrangedSubview(text(L10n.text("settings.usage"),secondary:true))
        let permission=column()
        permissionBadge.font = DesignTokens.section
        permission.addArrangedSubview(permissionBadge);permission.addArrangedSubview(permissionSummary)
        permission.addArrangedSubview(text(L10n.text("permission.reason"),secondary:true))
        permission.addArrangedSubview(button(L10n.text("permission.request"),action:actions.request))
        permission.addArrangedSubview(text(L10n.text("permission.steps"),secondary:true))
        permission.addArrangedSubview(button(L10n.text("permission.settings"),action:actions.settings))
        permission.addArrangedSubview(button(L10n.text("permission.recheck"),action:actions.recheck))
        permission.addArrangedSubview(button(L10n.text("action.restart"),action:actions.restart))
        permission.addArrangedSubview(button(L10n.text("permission.reveal"),action:actions.reveal))
        permission.addArrangedSubview(text(L10n.text("permission.minimum"),secondary:true))
        detailsButton=button(L10n.text("permission.details_show"),action:{[weak self] in self?.toggleDetails()})
        permission.addArrangedSubview(detailsButton)
        permissionDetails.textColor = DesignTokens.secondaryText;permission.addArrangedSubview(permissionDetails);permissionDetails.isHidden=true
        let updates=column()
        updates.addArrangedSubview(text(L10n.text("updates.title"),font:DesignTokens.section))
        versionValue.textColor = DesignTokens.secondaryText;updates.addArrangedSubview(versionValue)
        updates.addArrangedSubview(automatic);updates.addArrangedSubview(updateStatus)
        checkUpdatesButton=button(L10n.text("menu.updates"),action:actions.update);updates.addArrangedSubview(checkUpdatesButton)
        updates.addArrangedSubview(text(L10n.text("updates.explanation"),secondary:true))
        updates.addArrangedSubview(text(L10n.text("updates.preview"),secondary:true))
        sections=[general,permission,updates]
        for section in sections {
            if let column=section as? NSStackView {
                for view in column.arrangedSubviews where view is NSTextField || view is NSBox {
                    view.translatesAutoresizingMaskIntoConstraints=false
                    view.widthAnchor.constraint(equalTo:column.widthAnchor,constant:-12).isActive=true
                }
            }
            let scroll=NSScrollView();scroll.hasVerticalScroller=true;scroll.drawsBackground=false
            scroll.documentView=section;pages.addSubview(scroll);scroll.translatesAutoresizingMaskIntoConstraints=false
            section.translatesAutoresizingMaskIntoConstraints=false
            NSLayoutConstraint.activate([scroll.leadingAnchor.constraint(equalTo:pages.leadingAnchor),scroll.trailingAnchor.constraint(equalTo:pages.trailingAnchor),scroll.topAnchor.constraint(equalTo:pages.topAnchor),scroll.bottomAnchor.constraint(equalTo:pages.bottomAnchor),section.leadingAnchor.constraint(equalTo:scroll.contentView.leadingAnchor),section.trailingAnchor.constraint(equalTo:scroll.contentView.trailingAnchor),section.topAnchor.constraint(equalTo:scroll.contentView.topAnchor),section.widthAnchor.constraint(equalTo:scroll.contentView.widthAnchor)])
            section.isHidden=false
        }
        select(.general);center()
    }
    func refresh(permission:PermissionStatus,shortcut:String,login:String,update:String,automaticEnabled:Bool,configured:Bool,canCheck:Bool) {
        permissionBadge.stringValue=permission.title;permissionBadge.textColor=permission.isReady ? DesignTokens.ready:DesignTokens.attention
        generalPermissionBadge.stringValue=permission.title;generalPermissionBadge.textColor=permission.isReady ? DesignTokens.ready:DesignTokens.attention
        permissionSummary.stringValue=permission.explanation
        permissionDetails.stringValue=L10n.format("permission.details_format",permission.identityAdvice,permission.bundleURL.path)
        permissionDetails.isSelectable=true
        shortcutValue.stringValue=shortcut;shortcutValue.setAccessibilityLabel(L10n.text("settings.shortcut"));shortcutValue.setAccessibilityValue(shortcut)
        loginValue.stringValue=login;loginValue.setAccessibilityValue(login)
        captureButtons.forEach{$0.isEnabled=permission.isReady;$0.setAccessibilityHelp(L10n.text(permission.isReady ? "settings.usage":"permission.reason"))}
        recoveryButton.isHidden=permission.isReady
        versionValue.stringValue=L10n.format("version.current",permission.version)
        updateStatus.stringValue=update;automatic.state=automaticEnabled ? .on:.off;automatic.isEnabled=configured
        automatic.setAccessibilityLabel(L10n.text("updates.automatic"));automatic.setAccessibilityHelp(L10n.text(configured ? "updates.explanation":"updates.unconfigured"))
        checkUpdatesButton.isEnabled=configured && canCheck;checkUpdatesButton.setAccessibilityHelp(update)
        let selection=L10n.selection
        language.selectItem(at:AppLanguage.allCases.firstIndex(of:selection.selected) ?? 0)
        languageStatus.stringValue=L10n.text(selection.requiresRestart ? "settings.language_pending":"settings.language_help")
        restartLanguageButton.isHidden = !selection.requiresRestart
    }
    func select(_ section:Section) {navigation.selectedSegment=section.rawValue;for (i,view) in pages.subviews.enumerated(){view.isHidden=i != section.rawValue}}
    @objc private func changeSection(){select(Section(rawValue:navigation.selectedSegment) ?? .general)}
    @objc private func toggleAutomatic(){actions.automatic(automatic.state == .on)}
    @objc private func changeLanguage(){guard AppLanguage.allCases.indices.contains(language.indexOfSelectedItem) else {return};actions.language(AppLanguage.allCases[language.indexOfSelectedItem])}
    @objc private func invoke(_ sender:NSButton){callbacks[ObjectIdentifier(sender)]?()}
    private func toggleDetails(){detailsVisible.toggle();permissionDetails.isHidden = !detailsVisible;detailsButton.title=L10n.text(detailsVisible ? "permission.details_hide":"permission.details_show");detailsButton.setAccessibilityLabel(detailsButton.title)}
    private func button(_ title:String,action:@escaping ()->Void)->NSButton {
        let button=NSButton(title:title,target:self,action:#selector(invoke(_:)));button.bezelStyle = .rounded;button.setAccessibilityLabel(title);callbacks[ObjectIdentifier(button)]=action;return button
    }
    private func text(_ value:String,font:NSFont=DesignTokens.body,secondary:Bool=false)->NSTextField {
        let field=NSTextField(wrappingLabelWithString:value);field.font = font;field.textColor=secondary ? DesignTokens.secondaryText:DesignTokens.primaryText;field.setContentCompressionResistancePriority(.defaultLow,for:.horizontal);return field
    }
    private func stack(_ views:[NSView],vertical:Bool,spacing:CGFloat)->NSStackView {
        let stack=NSStackView(views:views);stack.orientation=vertical ? .vertical:.horizontal;stack.alignment=vertical ? .leading:.centerY;stack.spacing=spacing;return stack
    }
    private func column()->NSStackView {let view=SettingsColumn();view.orientation = .vertical;view.alignment = .leading;view.spacing=DesignTokens.group;view.edgeInsets=NSEdgeInsets(top:4,left:0,bottom:16,right:12);return view}
    private func rule()->NSView {let rule=NSBox();rule.boxType = .separator;return rule}
}
