import AppKit
import CaptureCore
import ServiceManagement
import Carbon

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    private var status: NSStatusItem!
    private let hotkey=HotkeyService()
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
    func applicationDidFinishLaunching(_ notification: Notification) {
        if CommandLine.arguments.contains("--self-test") { Task { await SelfTest.run() };return }
        if let data=UserDefaults.standard.data(forKey:"shortcut"),let saved=try? JSONDecoder().decode(Shortcut.self,from:data) { shortcut=saved }
        mode=SelectionMode(rawValue:UserDefaults.standard.string(forKey:"mode") ?? "mask") ?? .mask
        hotkey.action={ [weak self] in guard let self else { return };self.begin(self.mode) }
        coordinator.onFinish={ [weak self] in self?.finishUI() }
        coordinator.onError={ [weak self] error in self?.message("캡처 실패: \(error.localizedDescription)") }
        let result=hotkey.register(shortcut)
        status=NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength);status.button?.image=NSImage(systemSymbolName:"viewfinder",accessibilityDescription:"sshot 캡처")
        updateMenu()
        NotificationCenter.default.addObserver(self,selector:#selector(screenChanged),name:NSApplication.didChangeScreenParametersNotification,object:nil)
        NSWorkspace.shared.notificationCenter.addObserver(self,selector:#selector(screenChanged),name:NSWorkspace.willSleepNotification,object:nil)
        showGuide()
        if result != noErr { message("단축키 등록 실패 (\(result)). 설정에서 변경하세요.") }
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showGuide(); return true }
    private func updateMenu() {
        let menu=NSMenu()
        for (title,action) in [("고정 영역 캡처 (\(shortcut.label))",#selector(mask)),("드래그 캡처",#selector(drag)),("사용 안내 및 설정",#selector(openGuide)),("종료",#selector(quit))] {
            let item=NSMenuItem(title:title,action:action,keyEquivalent:"");item.target=self;menu.addItem(item)
        }
        status.menu=menu
    }
    @objc private func mask() { begin(.mask) }
    @objc private func drag() { begin(.drag) }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func openGuide() { showGuide() }
    @objc private func screenChanged() { if coordinator.state != .idle { finish(); message("화면 구성이 바뀌어 캡처를 취소했습니다.") } }
    func begin(_ mode: SelectionMode) {
        switch coordinator.begin(permission:CGPreflightScreenCaptureAccess()) {
        case .bringForward: overlay?.makeKeyAndOrderFront(nil);return
        case .ignored: return
        case .permissionDenied:showGuide();message("화면 기록 권한이 필요합니다. 안내 창의 ‘권한 요청’ 후 다시 시도하세요.");return
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
        if let guide { NSApp.activate(ignoringOtherApps:true);guide.makeKeyAndOrderFront(nil);return }
        let window=NSWindow(contentRect:CGRect(x:0,y:0,width:510,height:390),styleMask:[.titled,.closable],backing:.buffered,defer:false)
        window.title="sshot — 캡처 및 설정";window.isReleasedWhenClosed=false;window.center()
        let content=NSView(frame:CGRect(x:0,y:0,width:510,height:390))
        let label=NSTextField(wrappingLabelWithString:"원하는 영역을 캡처하면 즉시 클립보드에 복사됩니다.\n다른 앱에서 ⌘V를 누르세요.\n\n앱이 실행 중일 때 단축키 \(shortcut.label)을 사용할 수 있습니다.\n화면 기록 권한을 허용한 뒤 다시 캡처하세요.")
        label.frame=CGRect(x:25,y:215,width:460,height:150);content.addSubview(label);shortcutLabel=label
        let entries:[(String,Selector,CGRect)]=[("고정 영역 캡처",#selector(mask),CGRect(x:25,y:175,width:210,height:32)),("드래그 캡처",#selector(drag),CGRect(x:265,y:175,width:210,height:32)),("권한 요청",#selector(requestPermission),CGRect(x:25,y:130,width:210,height:32)),("화면 기록 설정 열기",#selector(openPermission),CGRect(x:265,y:130,width:210,height:32)),("단축키 변경",#selector(recordShortcut),CGRect(x:25,y:85,width:210,height:32)),("로그인 자동 시작 설정",#selector(loginSetting),CGRect(x:265,y:85,width:210,height:32))]
        for (title,selector,frame) in entries { let b=NSButton(title:title,target:self,action:selector);b.frame=frame;content.addSubview(b) }
        let note=NSTextField(wrappingLabelWithString:"고정 영역: 이동·모서리 조절 후 Enter. 드래그: 놓으면 캡처.\nEsc: 취소 · Tab: 모드 전환 · 한 화면 안에서 선택.");note.frame=CGRect(x:25,y:20,width:460,height:55);content.addSubview(note)
        window.contentView=content;guide=window;NSApp.activate(ignoringOtherApps:true);window.makeKeyAndOrderFront(nil)
    }
    @objc private func requestPermission() { _=CGRequestScreenCaptureAccess(); if CGPreflightScreenCaptureAccess() { message("권한이 허용되었습니다. 캡처를 시작하세요.") } else { message("시스템 설정에서 sshot의 화면 기록을 허용하세요. 시스템에서 요청하면 앱을 다시 실행하세요.") } }
    @objc private func openPermission() { if let url=URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") { NSWorkspace.shared.open(url) } }
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
            let result=self.hotkey.register(candidate)
            if result == noErr { self.shortcut=candidate;UserDefaults.standard.set(try? JSONEncoder().encode(candidate),forKey:"shortcut");self.updateMenu();self.shortcutLabel?.stringValue="원하는 영역을 캡처하면 즉시 클립보드에 복사됩니다.\n다른 앱에서 ⌘V를 누르세요.\n\n앱 실행 중 단축키: \(candidate.label)\n화면 기록 권한을 허용한 뒤 다시 캡처하세요.";NSApp.abortModal() }
            else { let restore=self.hotkey.register(self.shortcut);alert.informativeText=restore == noErr ? "이미 사용 중이거나 등록할 수 없는 단축키입니다 (\(result)). 다른 조합을 누르세요." : "기존 단축키도 복구하지 못했습니다 (\(restore)). 다른 조합을 누르거나 앱을 재실행하세요." }
            return nil
        }
        alert.runModal();if let recorder { NSEvent.removeMonitor(recorder);self.recorder=nil }
    }
}
