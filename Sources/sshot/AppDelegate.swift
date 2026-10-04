import AppKit
import CaptureCore
import ServiceManagement
import Carbon

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var status: NSStatusItem!
    private var hotkey:HotkeyService?=HotkeyService()
    private let updater=UpdateService()
    private let capture=CaptureService()
    private let coordinator=CaptureCoordinator<CGImage>()
    private var overlay: OverlayWindow?
    private var previous: NSRunningApplication?
    private var lastRect: CGRect?
    private var shortcut=Shortcut()
    private var guide: NSWindow?
    private var recorder: Any?
    private var mode:SelectionMode = .mask
    private var toast:NSPanel?
    private var shortcutLabel:NSTextField?
    private var permissionLabel:NSTextField?
    private var permissionDetails:NSTextField?
    private var updateLabel:NSTextField?
    private var updateToggle:NSButton?
    private var captureButtons=[NSButton]()
    private var restarting=false
    func applicationDidFinishLaunching(_ notification: Notification) {
        if CommandLine.arguments.contains("--self-test") { Task { await SelfTest.run() };return }
        if let data=UserDefaults.standard.data(forKey:"shortcut"),let saved=try? JSONDecoder().decode(Shortcut.self,from:data) { shortcut=saved }
        mode=SelectionMode(rawValue:UserDefaults.standard.string(forKey:"mode") ?? "mask") ?? .mask
        configureHotkeyAction()
        coordinator.onFinish={ [weak self] in self?.finishUI() }
        coordinator.onError={ [weak self] error in self?.message("캡처 실패: \(error.localizedDescription)") }
        let result=hotkey?.register(shortcut) ?? OSStatus(paramErr)
        status=NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength);status.button?.image=NSImage(systemSymbolName:"viewfinder",accessibilityDescription:"sshot 캡처")
        updater.onChange={ [weak self] in self?.refreshStatus() }
        updater.start()
        updateMenu()
        NotificationCenter.default.addObserver(self,selector:#selector(screenChanged),name:NSApplication.didChangeScreenParametersNotification,object:nil)
        NSWorkspace.shared.notificationCenter.addObserver(self,selector:#selector(screenChanged),name:NSWorkspace.willSleepNotification,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(refreshStatus),name:NSApplication.didBecomeActiveNotification,object:nil)
        showGuide()
        if result != noErr { message("단축키 등록 실패 (\(result)). 설정에서 변경하세요.") }
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showGuide(); return true }
    private func updateMenu() {
        let menu=NSMenu()
        menu.delegate=self
        let permission=NSMenuItem(title:CGPreflightScreenCaptureAccess() ? "화면 기록: 캡처 준비 완료" : "화면 기록: 권한 확인 필요",action:nil,keyEquivalent:"");permission.isEnabled=false;menu.addItem(permission)
        for (title,action) in [("고정 영역 캡처 (\(shortcut.label))",#selector(mask)),("드래그 캡처",#selector(drag)),("권한 안내 및 설정",#selector(openGuide)),("업데이트 확인…",#selector(checkUpdates)),("종료",#selector(quit))] {
            let item=NSMenuItem(title:title,action:action,keyEquivalent:"");item.target=self;menu.addItem(item)
        }
        status.menu=menu
    }
    func menuWillOpen(_ menu:NSMenu) {
        menu.items.first?.title=CGPreflightScreenCaptureAccess() ? "화면 기록: 캡처 준비 완료" : "화면 기록: 권한 확인 필요"
    }
    private func configureHotkeyAction() { hotkey?.action={ [weak self] in guard let self else {return};self.begin(self.mode) } }
    @objc private func mask() { begin(.mask) }
    @objc private func drag() { begin(.drag) }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func openGuide() { showGuide() }
    @objc private func screenChanged() { if coordinator.state != .idle { finish(); message("화면 구성이 바뀌어 캡처를 취소했습니다.") } }
    func begin(_ mode: SelectionMode) {
        guard !restarting else {return}
        switch coordinator.begin(permission:CGPreflightScreenCaptureAccess()) {
        case .bringForward: overlay?.makeKeyAndOrderFront(nil);return
        case .ignored: return
        case .permissionDenied:showGuide();return
        case .opened:break
        }
        guard let screen=NSScreen.screens.first(where:{$0.frame.contains(NSEvent.mouseLocation)}) ?? NSScreen.main else { finish();return }
        previous=NSWorkspace.shared.frontmostApplication
        self.mode=mode;UserDefaults.standard.set(mode.rawValue,forKey:"mode")
        let window=OverlayWindow(contentRect:screen.frame,styleMask:.borderless,backing:.buffered,defer:false)
        window.level = .screenSaver;window.isOpaque=false;window.backgroundColor = .clear;window.collectionBehavior=[.canJoinAllSpaces,.fullScreenAuxiliary];window.isReleasedWhenClosed=false
        let view=SelectionView(frame:CGRect(origin:.zero,size:screen.frame.size));view.mode=mode
        let fallback=CGRect(x:screen.frame.midX-200,y:screen.frame.midY-150,width:400,height:300)
        let global=SelectionGeometry.clamped(lastRect ?? fallback,within:screen.frame)
        view.rect=SelectionGeometry.valid(global) ? global.offsetBy(dx:-screen.frame.minX,dy:-screen.frame.minY) : fallback.offsetBy(dx:-screen.frame.minX,dy:-screen.frame.minY)
        view.cancel={ [weak self] in self?.finish() }
        view.selection={ [weak self] local in self?.perform(local.offsetBy(dx:screen.frame.minX,dy:screen.frame.minY),screen:screen) }
        window.contentView=view;overlay=window;guide?.orderOut(nil);NSApp.activate(ignoringOtherApps:true);window.makeKeyAndOrderFront(nil);window.makeFirstResponder(view)
    }
    private func perform(_ rect: CGRect, screen: NSScreen) {
        guard coordinator.state == .selecting else { return }; lastRect=rect
        if let view=overlay?.contentView as? SelectionView { mode=view.mode;UserDefaults.standard.set(mode.rawValue,forKey:"mode") }
        overlay?.orderOut(nil)
        coordinator.confirm(capture:{ [capture] in try await capture.capture(rect:rect,screen:screen) },commit:{[weak self] image in try ClipboardService().store(image);self?.showCopied()},schedule:{ fire in
            let timer=Timer.scheduledTimer(withTimeInterval:12,repeats:false){_ in fire()};return {timer.invalidate()}
        })
    }
    private func finish() {
        coordinator.cancel()
    }
    private func finishUI() {
        overlay?.close();overlay=nil
        previous?.activate(options:[]);previous=nil
    }
    private func showCopied() {
        let panel=NSPanel(contentRect:CGRect(x:0,y:0,width:280,height:60),styleMask:.nonactivatingPanel,backing:.buffered,defer:false)
        panel.level = .floating;panel.isReleasedWhenClosed=false
        let text=NSTextField(labelWithString:"복사 완료 — ⌘V로 붙여 넣으세요");text.frame=CGRect(x:15,y:20,width:250,height:25);panel.contentView?.addSubview(text)
        if let screen=NSScreen.main { panel.setFrameOrigin(CGPoint(x:screen.visibleFrame.maxX-300,y:screen.visibleFrame.maxY-90)) }
        toast?.close();toast=panel;panel.orderFrontRegardless();DispatchQueue.main.asyncAfter(deadline:.now()+2){[weak self,weak panel] in panel?.close();if self?.toast === panel { self?.toast=nil }}
    }
    private func message(_ text: String) {
        NSApp.activate(ignoringOtherApps:true)
        let alert=NSAlert();alert.messageText="sshot";alert.informativeText=text;alert.addButton(withTitle:"확인");alert.runModal()
    }
    private func showGuide() {
        if let guide { refreshStatus();NSApp.activate(ignoringOtherApps:true);guide.makeKeyAndOrderFront(nil);return }
        let window=NSWindow(contentRect:CGRect(x:0,y:0,width:680,height:735),styleMask:[.titled,.closable],backing:.buffered,defer:false)
        window.title="sshot — 캡처 및 설정";window.isReleasedWhenClosed=false;window.center()
        let content=NSView(frame:CGRect(x:0,y:0,width:680,height:735))
        func label(_ text:String,_ rect:CGRect,_ size:CGFloat=13) -> NSTextField {
            let field=NSTextField(wrappingLabelWithString:text);field.frame=rect;field.font=NSFont.systemFont(ofSize:size);content.addSubview(field);return field
        }
        permissionLabel=label("",CGRect(x:24,y:685,width:632,height:28),20)
        permissionDetails=label("",CGRect(x:24,y:627,width:632,height:52))
        shortcutLabel=label("",CGRect(x:24,y:589,width:632,height:30))
        _=label("권한이 적용되지 않을 때",CGRect(x:24,y:483,width:632,height:24),16)
        _=label("1. ‘권한 요청’ 또는 ‘화면 기록 설정’을 누릅니다.\n2. 개인정보 보호 및 보안 → 화면 기록에서 현재 sshot을 허용합니다.\n   macOS 버전에 따라 ‘화면 및 시스템 오디오 기록’으로 표시됩니다.\n3. 돌아와 ‘다시 확인’을 누르세요. 계속 주황색이면 sshot을 재시작하세요.\n   접근성·전체 디스크 접근 권한은 필요하지 않습니다.",CGRect(x:24,y:390,width:632,height:85))
        let identity=PermissionStatus()
        _=label(identity.identityAdvice,CGRect(x:24,y:276,width:632,height:68))
        let location=label("실행 위치: \(identity.bundleURL.path)\n버전: \(identity.version)",CGRect(x:24,y:217,width:632,height:52));location.isSelectable=true
        _=label("업데이트",CGRect(x:24,y:183,width:632,height:24),16)
        updateLabel=label("",CGRect(x:24,y:130,width:632,height:48))
        let toggle=NSButton(checkboxWithTitle:"자동으로 업데이트 확인",target:self,action:#selector(toggleUpdates));toggle.frame=CGRect(x:24,y:91,width:320,height:28);content.addSubview(toggle);updateToggle=toggle
        let entries:[(String,Selector,CGRect)]=[("고정 영역 캡처",#selector(mask),CGRect(x:24,y:548,width:300,height:32)),("드래그 캡처",#selector(drag),CGRect(x:350,y:548,width:300,height:32)),("단축키 변경",#selector(recordShortcut),CGRect(x:24,y:509,width:300,height:32)),("로그인 자동 시작 설정",#selector(loginSetting),CGRect(x:350,y:509,width:300,height:32)),("권한 요청",#selector(requestPermission),CGRect(x:24,y:351,width:145,height:32)),("화면 기록 설정",#selector(openPermission),CGRect(x:183,y:351,width:145,height:32)),("다시 확인",#selector(recheckPermission),CGRect(x:342,y:351,width:145,height:32)),("sshot 재시작",#selector(restartApp),CGRect(x:501,y:351,width:145,height:32)),("현재 앱 위치 보기",#selector(revealApp),CGRect(x:350,y:87,width:300,height:32)),("업데이트 확인…",#selector(checkUpdates),CGRect(x:350,y:48,width:300,height:32))]
        for (title,selector,frame) in entries { let b=NSButton(title:title,target:self,action:selector);b.frame=frame;content.addSubview(b);if selector == #selector(mask) || selector == #selector(drag) {captureButtons.append(b)} }
        _=label("Enter: 캡처 · Esc: 취소 · Tab: 모드 전환\n이미지는 바로 복사됩니다. 다른 앱에서 ⌘V로 붙여 넣으세요.",CGRect(x:24,y:22,width:310,height:59),12)
        window.contentView=content;guide=window;refreshStatus();NSApp.activate(ignoringOtherApps:true);window.makeKeyAndOrderFront(nil)
    }
    @objc private func refreshStatus() {
        let permission=PermissionStatus()
        permissionLabel?.stringValue=permission.title
        permissionLabel?.textColor=permission.isReady ? .systemGreen : .systemOrange
        permissionDetails?.stringValue=permission.explanation
        shortcutLabel?.stringValue="앱 실행 중 단축키: \(shortcut.label) · 캡처 이미지는 바로 클립보드로 복사됩니다."
        captureButtons.forEach{$0.isEnabled=permission.isReady}
        updateLabel?.stringValue=updater.statusText
        updateToggle?.state=updater.automaticallyChecksForUpdates ? .on : .off
        updateToggle?.isEnabled=updater.isConfigured
        if status != nil {updateMenu()}
    }
    @objc private func requestPermission() { _=CGRequestScreenCaptureAccess();refreshStatus() }
    @objc private func recheckPermission() {refreshStatus()}
    @objc private func openPermission() { if let url=URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") { NSWorkspace.shared.open(url) } }
    @objc private func revealApp() {NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])}
    @objc private func checkUpdates() {updater.checkForUpdates();refreshStatus()}
    @objc private func toggleUpdates() {updater.automaticallyChecksForUpdates=updateToggle?.state == .on;refreshStatus()}
    @objc private func restartApp() {
        guard !restarting else {return}
        guard coordinator.state != .processing else {message("캡처가 끝난 뒤 다시 시작하세요.");return}
        let bundle=Bundle.main.bundleURL
        guard bundle.pathExtension == "app",FileManager.default.fileExists(atPath:bundle.path) else {message("앱 번들로 실행해야 재시작할 수 있습니다. 현재 앱 위치를 확인하세요.");return}
        finish();restarting=true;hotkey=nil
        let configuration=NSWorkspace.OpenConfiguration();configuration.createsNewApplicationInstance=true;configuration.arguments=[]
        NSWorkspace.shared.openApplication(at:bundle,configuration:configuration) { [weak self] application,error in
            Task { @MainActor in
                guard let self else {return}
                if error == nil,let application,application.processIdentifier != ProcessInfo.processInfo.processIdentifier {NSApp.terminate(nil)}
                else {self.restarting=false;self.hotkey=HotkeyService();self.configureHotkeyAction();let result=self.hotkey?.register(self.shortcut) ?? OSStatus(paramErr);self.message(result == noErr ? "재시작하지 못했습니다. 앱을 직접 종료한 뒤 현재 위치의 앱을 다시 여세요." : "재시작과 단축키 복구에 실패했습니다. 앱을 직접 종료한 뒤 다시 여세요.")}
            }
        }
    }
    @objc private func loginSetting() {
        do { if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister();message("로그인 자동 시작을 껐습니다.") } else { try SMAppService.mainApp.register();message("로그인 자동 시작 상태: \(SMAppService.mainApp.status == .enabled ? "켜짐" : "시스템 설정에서 승인 필요")") } } catch { message("로그인 설정을 변경하지 못했습니다. 서명된 앱 설치가 필요할 수 있습니다.") }
    }
    @objc private func recordShortcut() {
        let alert=NSAlert();alert.messageText="새 단축키를 누르세요";alert.informativeText="Command 또는 Control과 다른 modifier를 함께 사용하세요. Escape는 취소입니다.";alert.addButton(withTitle:"취소")
        recorder=NSEvent.addLocalMonitorForEvents(matching:.keyDown) { [weak self] event in
            guard let self else { return event };if event.keyCode == 53 { NSApp.abortModal();return nil }
            let flags=event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard (flags.contains(.command) || flags.contains(.control)),flags.intersection([.shift,.option]).rawValue != 0 else { return nil }
            var modifiers:UInt32=0; if flags.contains(.command) { modifiers |= UInt32(cmdKey) };if flags.contains(.control) { modifiers |= UInt32(controlKey) };if flags.contains(.shift) { modifiers |= UInt32(shiftKey) };if flags.contains(.option) { modifiers |= UInt32(optionKey) }
            guard let key=event.characters(byApplyingModifiers:[])?.uppercased(), !key.isEmpty,
                  key.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value < 0xF700 }) else { return nil }
            let label=(flags.contains(.control) ? "⌃":"")+(flags.contains(.option) ? "⌥":"")+(flags.contains(.shift) ? "⇧":"")+(flags.contains(.command) ? "⌘":"")+key
            let candidate=Shortcut(key:UInt32(event.keyCode),modifiers:modifiers,label:label)
            let result=self.hotkey?.register(candidate) ?? OSStatus(paramErr)
            if result == noErr { self.shortcut=candidate;UserDefaults.standard.set(try? JSONEncoder().encode(candidate),forKey:"shortcut");self.refreshStatus();NSApp.abortModal() }
            else { let restore=self.hotkey?.register(self.shortcut) ?? OSStatus(paramErr);alert.informativeText=restore == noErr ? "이미 사용 중이거나 등록할 수 없는 단축키입니다 (\(result)). 다른 조합을 누르세요." : "기존 단축키도 복구하지 못했습니다 (\(restore)). 다른 조합을 누르거나 앱을 재실행하세요." }
            return nil
        }
        alert.runModal();if let recorder { NSEvent.removeMonitor(recorder);self.recorder=nil }
    }
}
