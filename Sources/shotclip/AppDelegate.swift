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
    private var guide: SettingsWindow?
    private var recorder: Any?
    private var mode:SelectionMode = .drag
    private let capturePreview=CapturePreviewController()
    private var restarting=false
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if SHOTCLIP_QA
        if CommandLine.arguments.contains("--self-test") { Task { await SelfTest.run() };return }
        #endif
        if let data=UserDefaults.standard.data(forKey:"shortcut"),let saved=try? JSONDecoder().decode(Shortcut.self,from:data),saved.isValid { shortcut=saved }
        mode=SelectionMode(rawValue:UserDefaults.standard.string(forKey:"mode") ?? "drag") ?? .drag
        configureHotkeyAction()
        coordinator.onFinish={ [weak self] in self?.finishUI() }
        coordinator.onError={ [weak self] error in
            let detail:String
            if let failure=error as? CaptureFailure {detail=failure.errorDescription ?? L10n.text("capture.invalid_image")}
            else if let failure=error as? CoordinatorError {detail=L10n.text(failure.localizationKey,defaultValue:failure.errorDescription)}
            else {detail=L10n.format("capture.system_error",String((error as NSError).code))}
            self?.message(L10n.format("capture.failed",detail))
        }
        let result=hotkey?.register(shortcut) ?? OSStatus(paramErr)
        status=NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength);status.button?.image=CaptureGlyph.image();status.button?.toolTip=L10n.text("app.name");status.button?.setAccessibilityLabel(L10n.text("capture.accessibility"))
        updater.onChange={ [weak self] in self?.refreshStatus() }
        updater.start()
        configureMainMenu();updateMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: L10n.languageDidChange, object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(refreshStatus), name: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String), object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(screenChanged),name:NSApplication.didChangeScreenParametersNotification,object:nil)
        NSWorkspace.shared.notificationCenter.addObserver(self,selector:#selector(screenChanged),name:NSWorkspace.willSleepNotification,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(refreshStatus),name:NSApplication.didBecomeActiveNotification,object:nil)
        if !UserDefaults.standard.bool(forKey:"welcome0.5Shown") {
            UserDefaults.standard.set(true,forKey:"welcome0.5Shown");showGuide()
            if !CGPreflightScreenCaptureAccess() {guide?.select(.permission)}
        }
        if result != noErr { message(L10n.format("shortcut.registration_failed",String(result))) }
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showGuide(); return true }
    private func updateMenu(presentation: CaptureMenu.ShortcutPresentation? = nil) {
        let menu=CaptureMenu.make(ready:CGPreflightScreenCaptureAccess(),mode:mode,shortcut:shortcut,presentation:presentation,
            canCheck:updater.canCheckForUpdates,target:self,actions:.init(area:#selector(drag),fixed:#selector(mask),
                permission:#selector(openAccess),settings:#selector(openGuide),updates:#selector(checkUpdates),quit:#selector(quit)))
        menu.delegate=self;status.menu=menu
    }
    private var menuActions: CaptureMenu.Actions {
        .init(area: #selector(drag), fixed: #selector(mask), permission: #selector(openAccess),
              settings: #selector(openGuide), updates: #selector(checkUpdates), quit: #selector(quit))
    }
    private func configureMainMenu(presentation: CaptureMenu.ShortcutPresentation? = nil) {
        let main = CaptureMenu.applicationMenu(ready: CGPreflightScreenCaptureAccess(), mode: mode,
            shortcut: shortcut, presentation: presentation, canCheck: updater.canCheckForUpdates, target: self, actions: menuActions)
        main.items[0].submenu?.delegate = self; main.items[1].submenu?.delegate = self
        NSApp.mainMenu = main; NSApp.windowsMenu = main.items.last?.submenu
    }
    @objc private func languageChanged() {
        status?.button?.toolTip = L10n.text("app.name")
        status?.button?.setAccessibilityLabel(L10n.text("capture.accessibility"))
        capturePreview.refreshLanguage()
        refreshStatus()
    }
    func menuWillOpen(_ menu:NSMenu) {
        CaptureMenu.applyReadiness(to: menu, ready: CGPreflightScreenCaptureAccess())
        CaptureMenu.applyShortcut(to: menu, mode: mode, presentation: CaptureMenu.presentation(shortcut))
        menu.item(withTag:CaptureMenu.updatesTag)?.isEnabled=updater.canCheckForUpdates
    }
    private func configureHotkeyAction() { hotkey?.action={ [weak self] in guard let self else {return};self.begin(self.mode) } }
    @objc private func mask() { begin(.mask) }
    @objc private func drag() { begin(.drag) }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func openGuide() { showGuide() }
    @objc private func openAccess() { showGuide();guide?.select(.permission) }
    @objc private func screenChanged() { if coordinator.state != .idle { finish(); message(L10n.text("capture.screen_changed")) } }
    func begin(_ mode: SelectionMode) {
        guard !restarting else {return}
        switch coordinator.begin(permission:CGPreflightScreenCaptureAccess()) {
        case .bringForward: overlay?.makeKeyAndOrderFront(nil);return
        case .ignored: return
        case .permissionDenied:showGuide();guide?.select(.permission);return
        case .opened:break
        }
        capturePreview.dismiss()
        guard let screen=NSScreen.screens.first(where:{$0.frame.contains(NSEvent.mouseLocation)}) ?? NSScreen.main else { finish();return }
        previous=NSWorkspace.shared.frontmostApplication
        self.mode=mode;UserDefaults.standard.set(mode.rawValue,forKey:"mode");updateMenu();configureMainMenu()
        let window=OverlayWindow(contentRect:screen.frame,styleMask:.borderless,backing:.buffered,defer:false)
        window.level = .screenSaver;window.isOpaque=false;window.backgroundColor = .clear;window.collectionBehavior=[.canJoinAllSpaces,.fullScreenAuxiliary];window.isReleasedWhenClosed=false
        let view=SelectionView(frame:CGRect(origin:.zero,size:screen.frame.size));view.mode=mode
        let fallback=CGRect(x:screen.frame.midX-200,y:screen.frame.midY-150,width:400,height:300)
        let global=SelectionGeometry.clamped(lastRect ?? fallback,within:screen.frame)
        view.rect=mode == .drag ? .zero : (SelectionGeometry.valid(global) ? global.offsetBy(dx:-screen.frame.minX,dy:-screen.frame.minY) : fallback.offsetBy(dx:-screen.frame.minX,dy:-screen.frame.minY))
        view.cancel={ [weak self] in self?.finish() }
        view.selection={ [weak self] local in self?.perform(local.offsetBy(dx:screen.frame.minX,dy:screen.frame.minY),screen:screen) }
        window.contentView=view;overlay=window;guide?.orderOut(nil);NSApp.activate(ignoringOtherApps:true);window.makeKeyAndOrderFront(nil);window.makeFirstResponder(view)
    }
    private func perform(_ rect: CGRect, screen: NSScreen) {
        guard coordinator.state == .selecting else { return }; lastRect=rect
        if let view=overlay?.contentView as? SelectionView { mode=view.mode;UserDefaults.standard.set(mode.rawValue,forKey:"mode");updateMenu();configureMainMenu() }
        overlay?.orderOut(nil)
        coordinator.confirm(capture:{ [capture] in try await capture.capture(rect:rect,screen:screen) },commit:{[weak self] image in
            try ClipboardService().store(image)
            self?.capturePreview.show(image, visibleFrame: screen.visibleFrame)
        },schedule:{ fire in
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
    private func message(_ text: String) {
        NSApp.activate(ignoringOtherApps:true)
        let alert=NSAlert();alert.messageText=L10n.text("app.name");alert.informativeText=text;alert.addButton(withTitle:L10n.text("action.ok"));alert.runModal()
    }
    private func showGuide() {
        if guide == nil {
            guide=SettingsWindow(actions:.init(mask:{[weak self] in self?.mask()},drag:{[weak self] in self?.drag()},shortcut:{[weak self] in self?.recordShortcut()},login:{[weak self] in self?.loginSetting()},request:{[weak self] in self?.requestPermission()},settings:{[weak self] in self?.openPermission()},recheck:{[weak self] in self?.recheckPermission()},restart:{[weak self] in self?.restartApp()},reveal:{[weak self] in self?.revealApp()},update:{[weak self] in self?.checkUpdates()},automatic:{[weak self] enabled in self?.updater.automaticallyChecksForUpdates=enabled;self?.refreshStatus()},language:{[weak self] selected in L10n.select(selected);self?.refreshStatus()}))
        }
        refreshStatus();NSApp.activate(ignoringOtherApps:true);guide?.makeKeyAndOrderFront(nil)
    }
    @objc private func refreshStatus() {
        let presentation = CaptureMenu.presentation(shortcut)
        guide?.refresh(permission:PermissionStatus(),shortcut:presentation.visual,spokenShortcut:presentation.spoken,login:loginStatusText,loginEnabled:SMAppService.mainApp.status == .enabled,loginNeedsApproval:SMAppService.mainApp.status == .requiresApproval,update:updater.statusText,updateText:{ [weak self] in self?.updater.statusText ?? L10n.text("updates.unconfigured") },automaticEnabled:updater.automaticallyChecksForUpdates,configured:updater.isConfigured,canCheck:updater.canCheckForUpdates)
        if status != nil {updateMenu(presentation: presentation);configureMainMenu(presentation: presentation)}
    }
    @objc private func requestPermission() { _=CGRequestScreenCaptureAccess();refreshStatus() }
    @objc private func recheckPermission() {refreshStatus()}
    @objc private func openPermission() { if let url=URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") { NSWorkspace.shared.open(url) } }
    @objc private func revealApp() {NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])}
    @objc private func checkUpdates() {updater.checkForUpdates();refreshStatus()}
    @objc private func restartApp() {
        guard !restarting else {return}
        guard coordinator.state != .processing else {message(L10n.text("restart.capture_busy"));return}
        let bundle=Bundle.main.bundleURL
        guard bundle.pathExtension == "app",FileManager.default.fileExists(atPath:bundle.path) else {message(L10n.text("restart.bundle_required"));return}
        finish();restarting=true;hotkey=nil
        let configuration=NSWorkspace.OpenConfiguration();configuration.createsNewApplicationInstance=true;configuration.arguments=[]
        NSWorkspace.shared.openApplication(at:bundle,configuration:configuration) { [weak self] application,error in
            Task { @MainActor in
                guard let self else {return}
                if error == nil,let application,application.processIdentifier != ProcessInfo.processInfo.processIdentifier {NSApp.terminate(nil)}
                else {self.restarting=false;self.hotkey=HotkeyService();self.configureHotkeyAction();let result=self.hotkey?.register(self.shortcut) ?? OSStatus(paramErr);self.message(result == noErr ? L10n.text("restart.failed") : L10n.text("restart.hotkey_failed"))}
            }
        }
    }
    private var loginStatusText:String {
        switch SMAppService.mainApp.status {
        case .enabled:return L10n.text("login.on")
        case .notRegistered:return L10n.text("login.off")
        case .requiresApproval:return L10n.text("login.approval")
        case .notFound:return L10n.text("login.not_found")
        @unknown default:return L10n.text("login.unknown")
        }
    }
    @objc private func loginSetting() {
        do {
            if SMAppService.mainApp.status == .enabled {try SMAppService.mainApp.unregister();message(L10n.text("login.disabled_notice"))}
            else if SMAppService.mainApp.status == .requiresApproval {SMAppService.openSystemSettingsLoginItems()}
            else {try SMAppService.mainApp.register();message(L10n.format("login.status_notice",loginStatusText))}
        } catch {message(L10n.text("login.failed"))}
        refreshStatus()
    }
    @objc private func recordShortcut() {
        let alert=NSAlert();alert.messageText=L10n.text("shortcut.record_title");alert.informativeText=L10n.text("shortcut.record_help");alert.addButton(withTitle:L10n.text("action.cancel"))
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
            else { let restore=self.hotkey?.register(self.shortcut) ?? OSStatus(paramErr);alert.informativeText=restore == noErr ? L10n.format("shortcut.conflict",String(result)) : L10n.format("shortcut.restore_failed",String(restore)) }
            return nil
        }
        alert.runModal();if let recorder { NSEvent.removeMonitor(recorder);self.recorder=nil }
    }
}
