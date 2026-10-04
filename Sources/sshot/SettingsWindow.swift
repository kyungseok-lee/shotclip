import AppKit

private final class SettingsColumn:NSStackView {
    override var isFlipped:Bool {true}
}

@MainActor final class SettingsWindow:NSWindow {
    enum Section:Int {case general,permission,updates}
    struct Actions {
        let mask:()->Void, drag:()->Void, shortcut:()->Void, login:()->Void
        let request:()->Void, settings:()->Void, recheck:()->Void, restart:()->Void, reveal:()->Void
        let update:()->Void, automatic:(Bool)->Void
    }
    private let actions:Actions
    private let root=NSStackView()
    private let pages=NSView()
    private var sections=[NSView]()
    private let permissionBadge=NSTextField(labelWithString:"")
    private let generalPermissionBadge=NSTextField(labelWithString:"")
    private let permissionSummary=NSTextField(wrappingLabelWithString:"")
    private let permissionDetails=NSTextField(wrappingLabelWithString:"")
    private let shortcutValue=NSTextField(labelWithString:"")
    private let versionValue=NSTextField(labelWithString:"")
    private let updateStatus=NSTextField(wrappingLabelWithString:"")
    private lazy var automatic=NSButton(checkboxWithTitle:"자동으로 업데이트 확인",target:self,action:#selector(toggleAutomatic))
    private lazy var navigation=NSSegmentedControl(labels:["일반","권한","업데이트"],trackingMode:.selectOne,target:self,action:#selector(changeSection))
    private var captureButtons=[NSButton]()
    private var callbacks=[ObjectIdentifier:()->Void]()
    private var detailsVisible=false
    init(actions:Actions) {
        self.actions=actions
        super.init(contentRect:NSRect(x:0,y:0,width:660,height:560),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
        title="Sshot 설정";isReleasedWhenClosed=false;minSize=NSSize(width:520,height:470)
        let content=NSView();contentView=content
        root.orientation = .vertical;root.alignment = .leading;root.spacing=20
        content.addSubview(root);root.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([root.leadingAnchor.constraint(equalTo:content.leadingAnchor,constant:28),root.trailingAnchor.constraint(equalTo:content.trailingAnchor,constant:-28),root.topAnchor.constraint(equalTo:content.topAnchor,constant:24),root.bottomAnchor.constraint(equalTo:content.bottomAnchor,constant:-24)])
        let icon=NSImageView();icon.image=NSApp.applicationIconImage;icon.imageScaling = .scaleProportionallyUpOrDown
        icon.widthAnchor.constraint(equalToConstant:56).isActive=true;icon.heightAnchor.constraint(equalToConstant:56).isActive=true
        icon.setAccessibilityLabel("Sshot 앱 아이콘")
        let name=text("Sshot",size:24,weight:.semibold)
        let subtitle=text("선택하고, 바로 붙여 넣으세요.",secondary:true)
        let heading=stack([name,subtitle],vertical:true,spacing:4)
        root.addArrangedSubview(stack([icon,heading],vertical:false,spacing:16))
        navigation.selectedSegment=0;navigation.setAccessibilityLabel("설정 섹션");root.addArrangedSubview(navigation)
        root.addArrangedSubview(pages);pages.translatesAutoresizingMaskIntoConstraints=false
        pages.widthAnchor.constraint(equalTo:root.widthAnchor).isActive=true
        pages.setContentHuggingPriority(.defaultLow,for:.vertical)
        let general=column()
        general.addArrangedSubview(text("화면 캡처",size:19,weight:.semibold))
        general.addArrangedSubview(text("고정 영역을 반복해서 캡처하거나, 드래그로 새로운 영역을 선택하세요.",secondary:true))
        generalPermissionBadge.font = .systemFont(ofSize:13,weight:.medium)
        general.addArrangedSubview(stack([generalPermissionBadge,button("권한 확인…",action:{[weak self] in self?.select(.permission)})],vertical:false,spacing:12))
        let mask=button("고정 영역 캡처",action:actions.mask);let drag=button("드래그 캡처",action:actions.drag);captureButtons=[mask,drag]
        general.addArrangedSubview(stack([mask,drag],vertical:false,spacing:12))
        general.addArrangedSubview(rule())
        shortcutValue.font = .monospacedSystemFont(ofSize:14,weight:.medium)
        general.addArrangedSubview(stack([text("캡처 단축키"),shortcutValue,button("변경…",action:actions.shortcut)],vertical:false,spacing:14))
        general.addArrangedSubview(button("로그인 자동 시작 설정…",action:actions.login))
        general.addArrangedSubview(text("Enter: 캡처  ·  Esc: 취소  ·  Tab: 선택 방식 전환\n캡처한 이미지는 클립보드에 복사됩니다. 다른 앱에서 ⌘V를 누르세요.",secondary:true))
        let permission=column()
        permissionBadge.font = .systemFont(ofSize:17,weight:.semibold)
        permission.addArrangedSubview(permissionBadge);permission.addArrangedSubview(permissionSummary)
        permission.addArrangedSubview(text("1. 화면 기록 설정에서 현재 Sshot을 허용하세요.\n2. 설정에서 돌아와 ‘다시 확인’을 누르세요.\n3. 권한이 적용되지 않았다면 Sshot을 재시작하세요.",secondary:true))
        permission.addArrangedSubview(stack([button("권한 요청",action:actions.request),button("화면 기록 설정…",action:actions.settings),button("다시 확인",action:actions.recheck)],vertical:false,spacing:10))
        permission.addArrangedSubview(stack([button("Sshot 재시작",action:actions.restart),button("현재 앱 위치 보기",action:actions.reveal)],vertical:false,spacing:10))
        permission.addArrangedSubview(text("접근성·전체 디스크 접근 권한은 필요하지 않습니다.",secondary:true))
        permission.addArrangedSubview(button("문제가 계속되나요? 세부 정보",action:{[weak self] in self?.toggleDetails()}))
        permissionDetails.textColor = .secondaryLabelColor;permission.addArrangedSubview(permissionDetails);permissionDetails.isHidden=true
        let updates=column()
        updates.addArrangedSubview(text("소프트웨어 업데이트",size:19,weight:.semibold))
        versionValue.textColor = .secondaryLabelColor;updates.addArrangedSubview(versionValue)
        updates.addArrangedSubview(automatic);updates.addArrangedSubview(updateStatus)
        updates.addArrangedSubview(button("업데이트 확인…",action:actions.update))
        updates.addArrangedSubview(text("업데이트는 서명을 확인한 뒤 설치 안내를 표시합니다.",secondary:true))
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
    func refresh(permission:PermissionStatus,shortcut:String,update:String,automaticEnabled:Bool,configured:Bool) {
        permissionBadge.stringValue=permission.title;permissionBadge.textColor=permission.isReady ? .systemGreen:.systemOrange
        generalPermissionBadge.stringValue=permission.title;generalPermissionBadge.textColor=permission.isReady ? .systemGreen:.systemOrange
        permissionSummary.stringValue=permission.explanation
        permissionDetails.stringValue=permission.identityAdvice+"\n\n실행 위치: "+permission.bundleURL.path+"\nmacOS 버전에 따라 ‘화면 및 시스템 오디오 기록’으로 표시됩니다."
        permissionDetails.isSelectable=true
        shortcutValue.stringValue=shortcut;captureButtons.forEach{$0.isEnabled=permission.isReady}
        versionValue.stringValue="현재 버전 "+permission.version
        updateStatus.stringValue=update;automatic.state=automaticEnabled ? .on:.off;automatic.isEnabled=configured
    }
    func select(_ section:Section) {navigation.selectedSegment=section.rawValue;for (i,view) in pages.subviews.enumerated(){view.isHidden=i != section.rawValue}}
    @objc private func changeSection(){select(Section(rawValue:navigation.selectedSegment) ?? .general)}
    @objc private func toggleAutomatic(){actions.automatic(automatic.state == .on)}
    @objc private func invoke(_ sender:NSButton){callbacks[ObjectIdentifier(sender)]?()}
    private func toggleDetails(){detailsVisible.toggle();permissionDetails.isHidden = !detailsVisible}
    private func button(_ title:String,action:@escaping ()->Void)->NSButton {
        let button=NSButton(title:title,target:self,action:#selector(invoke(_:)));button.bezelStyle = .rounded;button.setAccessibilityLabel(title);callbacks[ObjectIdentifier(button)]=action;return button
    }
    private func text(_ value:String,size:CGFloat=13,weight:NSFont.Weight = .regular,secondary:Bool=false)->NSTextField {
        let field=NSTextField(wrappingLabelWithString:value);field.font = .systemFont(ofSize:size,weight:weight);field.textColor=secondary ? .secondaryLabelColor:.labelColor;return field
    }
    private func stack(_ views:[NSView],vertical:Bool,spacing:CGFloat)->NSStackView {
        let stack=NSStackView(views:views);stack.orientation=vertical ? .vertical:.horizontal;stack.alignment=vertical ? .leading:.centerY;stack.spacing=spacing;return stack
    }
    private func column()->NSStackView {let view=SettingsColumn();view.orientation = .vertical;view.alignment = .leading;view.spacing=16;view.edgeInsets=NSEdgeInsets(top:4,left:0,bottom:16,right:12);return view}
    private func rule()->NSView {let rule=NSBox();rule.boxType = .separator;return rule}
}
