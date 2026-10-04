import AppKit
import CaptureCore
enum SelectionMode: String { case mask, drag }
final class OverlayWindow: NSWindow {
    override init(contentRect: NSRect, styleMask: NSWindow.StyleMask, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect:contentRect,styleMask:styleMask,backing:backing,defer:flag)
        // Swift retains every overlay, including QA windows, until cleanup completes.
        isReleasedWhenClosed=false
    }
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
final class SelectionView: NSView {
    var mode: SelectionMode = .mask
    var rect=CGRect.zero
    var selection: ((CGRect) -> Void)?
    var cancel: (() -> Void)?
    private var origin=CGPoint.zero
    private var original=CGRect.zero
    private var handle: Int?
    private var movable=false
    private lazy var captureButton=NSButton(title:"캡처",target:self,action:#selector(confirm))
    private lazy var cancelButton=NSButton(title:"취소",target:self,action:#selector(cancelSelection))
    override init(frame frameRect:NSRect) {
        super.init(frame:frameRect)
        captureButton.frame=CGRect(x:30,y:95,width:100,height:32);cancelButton.frame=CGRect(x:145,y:95,width:100,height:32)
        addSubview(captureButton);addSubview(cancelButton)
    }
    required init?(coder:NSCoder) { fatalError("init(coder:) is unavailable") }
    @objc private func confirm() { if SelectionGeometry.valid(rect) { selection?(rect) } }
    @objc private func cancelSelection() { cancel?() }
    override var acceptsFirstResponder: Bool { true }
    private var handles: [CGPoint] { [CGPoint(x:rect.minX,y:rect.minY),CGPoint(x:rect.midX,y:rect.minY),CGPoint(x:rect.maxX,y:rect.minY),CGPoint(x:rect.maxX,y:rect.midY),CGPoint(x:rect.maxX,y:rect.maxY),CGPoint(x:rect.midX,y:rect.maxY),CGPoint(x:rect.minX,y:rect.maxY),CGPoint(x:rect.minX,y:rect.midY)] }
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.35).setFill(); let shade=NSBezierPath(rect:bounds);shade.append(NSBezierPath(rect:rect));shade.windingRule = .evenOdd;shade.fill()
        captureButton.isHidden=mode == .drag
        NSColor.white.setStroke(); let path=NSBezierPath(rect:rect); path.lineWidth=2; path.stroke()
        if mode == .mask {
            NSColor.white.setFill(); for p in handles { NSBezierPath(rect:CGRect(x:p.x-4,y:p.y-4,width:8,height:8)).fill() }
        }
        let text = mode == .mask ? "영역 이동·조절  •  Enter: 캡처  •  Esc: 취소  •  Tab: 드래그 모드" : "드래그 후 놓으면 캡처  •  Esc: 취소  •  Tab: 고정 영역 모드"
        (text as NSString).draw(at:CGPoint(x:30,y:30),withAttributes:[.foregroundColor:NSColor.white,.font:NSFont.systemFont(ofSize:18,weight:.semibold)])
        ("한 화면 안에서 선택하세요" as NSString).draw(at:CGPoint(x:30,y:60),withAttributes:[.foregroundColor:NSColor.white,.font:NSFont.systemFont(ofSize:14)])
    }
    override func mouseDown(with event: NSEvent) {
        origin=convert(event.locationInWindow,from:nil); original=rect
        if mode == .drag { rect=CGRect(origin:origin,size:.zero) }
        else { handle=handles.firstIndex(where:{abs($0.x-origin.x)<12 && abs($0.y-origin.y)<12});movable=rect.contains(origin) }
        needsDisplay=true
    }
    override func mouseDragged(with event: NSEvent) {
        let p=convert(event.locationInWindow,from:nil)
        if mode == .drag { rect=SelectionGeometry.rect(from:origin,to:p,within:bounds) }
        else if let h=handle {
            var lo=CGPoint(x:original.minX,y:original.minY), hi=CGPoint(x:original.maxX,y:original.maxY)
            if [0,6,7].contains(h) { lo.x=p.x }; if [2,3,4].contains(h) { hi.x=p.x }
            if [0,1,2].contains(h) { lo.y=p.y }; if [4,5,6].contains(h) { hi.y=p.y }
            rect=SelectionGeometry.rect(from:lo,to:hi,within:bounds)
        } else if movable {
            rect=SelectionGeometry.translated(original,by:CGSize(width:p.x-origin.x,height:p.y-origin.y),within:bounds)
        }
        needsDisplay=true
    }
    override func mouseUp(with event: NSEvent) { if mode == .drag && SelectionGeometry.valid(rect) { selection?(rect) }; handle=nil }
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53: cancel?()
        case 36,76: if SelectionGeometry.valid(rect) { selection?(rect) }
        case 48: mode = mode == .mask ? .drag : .mask; needsDisplay=true
        case 123,124,125,126:
            let d:CGFloat=event.modifierFlags.contains(.shift) ? 10 : 1
            let delta=CGSize(width:event.keyCode == 123 ? -d : event.keyCode == 124 ? d : 0,height:event.keyCode == 125 ? -d : event.keyCode == 126 ? d : 0)
            if event.modifierFlags.contains(.option) { rect=SelectionGeometry.resized(rect,corner:.topRight,by:delta,within:bounds) }
            else { rect=SelectionGeometry.translated(rect,by:delta,within:bounds) };needsDisplay=true
        default: super.keyDown(with:event)
        }
    }
}
