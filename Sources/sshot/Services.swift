import AppKit
import Carbon
import ScreenCaptureKit
import CaptureCore

struct Shortcut: Codable {
    var key: UInt32 = 23
    var modifiers: UInt32 = UInt32(controlKey | shiftKey | cmdKey)
    var label: String = "⌃⇧⌘5"
}
final class HotkeyService {
    private var reference: EventHotKeyRef?
    private var handler: EventHandlerRef?
    private var handlerStatus: OSStatus = noErr
    private var activeShortcut: Shortcut?
    var action: (() -> Void)?
    init() {
        var event = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        handlerStatus=InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context else { return noErr }; Unmanaged<HotkeyService>.fromOpaque(context).takeUnretainedValue().action?(); return noErr
        }, 1, &event, Unmanaged.passUnretained(self).toOpaque(), &handler)
    }
    func register(_ shortcut: Shortcut) -> OSStatus {
        guard handlerStatus == noErr else { return handlerStatus }
        guard shortcut.key < 128,shortcut.modifiers & UInt32(cmdKey | controlKey) != 0,shortcut.modifiers & UInt32(shiftKey | optionKey) != 0 else { return OSStatus(paramErr) }
        if let activeShortcut,activeShortcut.key == shortcut.key,activeShortcut.modifiers == shortcut.modifiers { return noErr }
        let id=EventHotKeyID(signature:0x53534854,id:1)
        var candidate:EventHotKeyRef?
        let result=RegisterEventHotKey(shortcut.key, shortcut.modifiers, id, GetApplicationEventTarget(), OptionBits(kEventHotKeyExclusive), &candidate)
        guard result == noErr else {return result}
        if let reference {
            let unregistered=UnregisterEventHotKey(reference)
            if unregistered != noErr {if let candidate {UnregisterEventHotKey(candidate)};return unregistered}
        }
        reference=candidate;activeShortcut=shortcut;return noErr
    }
    deinit { if let reference { UnregisterEventHotKey(reference) }; if let handler { RemoveEventHandler(handler) } }
}

enum CaptureFailure: LocalizedError {
    case unavailable, invalidImage, clipboardChanged, clipboardUnreadable, clipboardWrite, clipboardRollback
    var errorDescription: String? {
        switch self {
        case .unavailable: return "화면을 찾을 수 없습니다. 다시 선택하세요."
        case .invalidImage: return "이미지를 만들지 못했습니다. 기존 클립보드는 유지됩니다."
        case .clipboardChanged: return "다른 앱이 클립보드를 변경했습니다. 다시 캡처하세요."
        case .clipboardUnreadable: return "기존 클립보드를 안전하게 보존할 수 없습니다. 다른 내용을 복사한 뒤 다시 시도하세요."
        case .clipboardWrite: return "클립보드 복사에 실패했습니다. 다시 시도하세요."
        case .clipboardRollback: return "클립보드 쓰기와 복원에 실패했습니다. 기존 데이터 보존을 확인할 수 없습니다."
        }
    }
}
final class CaptureService {
    func capture(rect: CGRect, screen: NSScreen) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly:true)
        try Task.checkCancellation()
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        guard let display=content.displays.first(where:{$0.displayID == number?.uint32Value}) else { throw CaptureFailure.unavailable }
        let own=content.applications.filter{$0.processID == ProcessInfo.processInfo.processIdentifier}
        let filter=SCContentFilter(display:display,excludingApplications:own,exceptingWindows:[])
        let config=SCStreamConfiguration()
        let scale=CGFloat(filter.pointPixelScale)
        guard let local=SelectionGeometry.snappedCaptureRect(rect,screen:screen.frame,scale:scale) else {throw CaptureFailure.invalidImage}
        config.sourceRect=local
        config.width=Int((local.width*scale).rounded()); config.height=Int((local.height*scale).rounded()); config.showsCursor=false
        let image=try await SCScreenshotManager.captureImage(contentFilter:filter,configuration:config)
        try Task.checkCancellation()
        return image
    }
}
final class ClipboardService {
    let pasteboard: NSPasteboard
    init(_ pasteboard: NSPasteboard = .general) { self.pasteboard=pasteboard }
    func store(_ image: CGImage) throws {
        let bitmap=NSBitmapImageRep(cgImage:image)
        guard let png=bitmap.representation(using:.png,properties:[:]), let tiff=bitmap.tiffRepresentation else { throw CaptureFailure.invalidImage }
        let generation=pasteboard.changeCount
        let items=pasteboard.pasteboardItems
        guard items != nil || (pasteboard.types ?? []).isEmpty else {throw CaptureFailure.clipboardUnreadable}
        guard (items?.count ?? 0) <= 128 else {throw CaptureFailure.clipboardUnreadable}
        var backupBytes=0
        var snapshot=[[String:Data]]()
        for item in items ?? [] {
            guard item.types.count <= 64 else {throw CaptureFailure.clipboardUnreadable}
            var types=[String:Data]()
            for type in item.types {
                guard let data=item.data(forType:type) else { throw CaptureFailure.clipboardUnreadable }
                guard data.count <= 64*1024*1024-backupBytes else {throw CaptureFailure.clipboardUnreadable}
                backupBytes+=data.count
                types[type.rawValue]=data
            }
            snapshot.append(types)
        }
        guard generation == pasteboard.changeCount else { throw CaptureFailure.clipboardChanged }
        let result=ClipboardTransaction.commitResult(snapshot:snapshot,expectedGeneration:generation,clear:{ self.pasteboard.clearContents() },write:{ values in
            if values.isEmpty { return true }
            let items=values.map { types -> NSPasteboardItem in let item=NSPasteboardItem(); for (type,data) in types { item.setData(data,forType:NSPasteboard.PasteboardType(type)) }; return item }
            return self.pasteboard.writeObjects(items)
        },count:{self.pasteboard.changeCount},image:[[NSPasteboard.PasteboardType.png.rawValue:png,NSPasteboard.PasteboardType.tiff.rawValue:tiff]])
        switch result {
        case .success:break
        case .externalChange:throw CaptureFailure.clipboardChanged
        case .writeFailedRestored:throw CaptureFailure.clipboardWrite
        case .rollbackFailed:throw CaptureFailure.clipboardRollback
        }
    }
}
