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
    var mode: SelectionMode = .mask {
        didSet {
            modeControl.selectedSegment=mode == .mask ? 0:1
            captureButton.isHidden=mode == .drag
            if mode == .drag,window?.firstResponder === captureButton {window?.makeFirstResponder(self)}
            updateAccessibility();needsDisplay=true
        }
    }
    var rect=CGRect.zero {didSet {updateAccessibility()}}
    var selection: ((CGRect) -> Void)?
    var cancel: (() -> Void)?
    private var origin=CGPoint.zero
    private var original=CGRect.zero
    private var handle: Int?
    private var movable=false
    private lazy var captureButton=NSButton(title:L10n.text("capture.start"),target:self,action:#selector(confirm))
    private lazy var cancelButton=NSButton(title:L10n.text("action.cancel"),target:self,action:#selector(cancelSelection))
    private lazy var modeControl=NSSegmentedControl(labels:[L10n.text("capture.fixed"),L10n.text("capture.drag")],trackingMode:.selectOne,target:self,action:#selector(selectCaptureMode))
    override init(frame frameRect:NSRect) {
        super.init(frame:frameRect)
        captureButton.frame=CGRect(x:30,y:95,width:100,height:32);cancelButton.frame=CGRect(x:145,y:95,width:100,height:32)
        modeControl.frame=CGRect(x:260,y:95,width:260,height:32);modeControl.selectedSegment=0
        addSubview(captureButton);addSubview(cancelButton);addSubview(modeControl)
        captureButton.setAccessibilityLabel(L10n.text("capture.start"));cancelButton.setAccessibilityLabel(L10n.text("action.cancel"))
        modeControl.setAccessibilityLabel(L10n.text("overlay.mode_label"));modeControl.setAccessibilityHelp(L10n.text("overlay.mode_help"))
        setAccessibilityElement(true);setAccessibilityRole(.group);setAccessibilityLabel(L10n.text("overlay.title"))
        nextKeyView=captureButton;captureButton.nextKeyView=cancelButton;cancelButton.nextKeyView=modeControl;modeControl.nextKeyView=self
        updateAccessibility()
    }
    required init?(coder:NSCoder) { fatalError("init(coder:) is unavailable") }
    @objc private func confirm() { if SelectionGeometry.valid(rect) { selection?(rect) } }
    @objc private func cancelSelection() { cancel?() }
    @objc private func selectCaptureMode() {mode=modeControl.selectedSegment == 0 ? .mask:.drag}
    private func updateAccessibility() {
        setAccessibilityHelp(L10n.text(mode == .mask ? "overlay.mask_help":"overlay.drag_help"))
        setAccessibilityValue(L10n.format("overlay.selection_value",Double(rect.width),Double(rect.height),Double(rect.minX),Double(rect.minY)))
    }
    override func performKeyEquivalent(with event:NSEvent)->Bool {
        if SelectionKeyCommand.command(keyCode:event.keyCode,hasCommandOrControl:!event.modifierFlags.intersection([.command,.control]).isEmpty,hasOption:event.modifierFlags.contains(.option)) == .switchMode {
            mode = mode == .mask ? .drag:.mask;return true
        }
        return super.performKeyEquivalent(with:event)
    }
    override func cancelOperation(_ sender:Any?) {cancel?()}
    override var acceptsFirstResponder: Bool { true }
    private var handles: [CGPoint] { [CGPoint(x:rect.minX,y:rect.minY),CGPoint(x:rect.midX,y:rect.minY),CGPoint(x:rect.maxX,y:rect.minY),CGPoint(x:rect.maxX,y:rect.midY),CGPoint(x:rect.maxX,y:rect.maxY),CGPoint(x:rect.midX,y:rect.maxY),CGPoint(x:rect.minX,y:rect.maxY),CGPoint(x:rect.minX,y:rect.midY)] }
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.35).setFill(); let shade=NSBezierPath(rect:bounds);shade.append(NSBezierPath(rect:rect));shade.windingRule = .evenOdd;shade.fill()
        captureButton.isHidden=mode == .drag
        let path=NSBezierPath(rect:rect);NSColor.black.setStroke();path.lineWidth=4;path.stroke()
        NSColor.white.setStroke();path.lineWidth=2;path.stroke()
        if window?.firstResponder === self {NSColor.keyboardFocusIndicatorColor.setStroke();let focus=NSBezierPath(rect:rect.insetBy(dx:-4,dy:-4));focus.lineWidth=2;focus.stroke()}
        if mode == .mask {
            NSColor.white.setFill(); for p in handles { NSBezierPath(rect:CGRect(x:p.x-4,y:p.y-4,width:8,height:8)).fill() }
        }
        let reduceTransparency=NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        NSColor.black.withAlphaComponent(reduceTransparency ? 1:0.88).setFill()
        NSBezierPath(roundedRect:CGRect(x:16,y:16,width:min(bounds.width-32,940),height:128),xRadius:8,yRadius:8).fill()
        let text=L10n.text(mode == .mask ? "overlay.mask_help":"overlay.drag_help")
        (text as NSString).draw(in:CGRect(x:30,y:30,width:min(bounds.width-60,900),height:27),withAttributes:[.foregroundColor:NSColor.white,.font:NSFont.systemFont(ofSize:14,weight:.semibold)])
        (L10n.text("overlay.display_help") as NSString).draw(in:CGRect(x:30,y:60,width:min(bounds.width-60,900),height:28),withAttributes:[.foregroundColor:NSColor.white,.font:NSFont.systemFont(ofSize:12)])
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
        switch SelectionKeyCommand.command(keyCode:event.keyCode,shift:event.modifierFlags.contains(.shift),hasCommandOrControl:!event.modifierFlags.intersection([.command,.control]).isEmpty,hasOption:event.modifierFlags.contains(.option)) {
        case .cancel: cancel?()
        case .confirm: if SelectionGeometry.valid(rect) { selection?(rect) }
        case .switchMode: mode = mode == .mask ? .drag : .mask
        case .focusNext:window?.selectNextKeyView(self)
        case .focusPrevious:window?.selectPreviousKeyView(self)
        case .move:
            let d:CGFloat=event.modifierFlags.contains(.shift) ? 10 : 1
            let delta=CGSize(width:event.keyCode == 123 ? -d : event.keyCode == 124 ? d : 0,height:event.keyCode == 125 ? -d : event.keyCode == 126 ? d : 0)
            if event.modifierFlags.contains(.option) { rect=SelectionGeometry.resized(rect,corner:.topRight,by:delta,within:bounds) }
            else { rect=SelectionGeometry.translated(rect,by:delta,within:bounds) };needsDisplay=true
        case nil: super.keyDown(with:event)
        }
    }
}
