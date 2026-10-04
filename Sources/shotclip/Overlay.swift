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
    var mode: SelectionMode = .drag {
        didSet {
            if mode == .drag {
                if SelectionGeometry.valid(rect) {rememberedRect=rect}
                rect = .zero
            }
            else if !SelectionGeometry.valid(rect) {
                rect=SelectionGeometry.clamped(rememberedRect ?? CGRect(x:bounds.midX-200,y:bounds.midY-150,width:400,height:300),within:bounds)
            }
            window?.invalidateCursorRects(for:self)
            modeControl.selectedSegment=mode == .drag ? 0:1
            captureButton.isHidden=mode == .drag
            if mode == .drag,window?.firstResponder === captureButton {window?.makeFirstResponder(self)}
            updateAccessibility();needsDisplay=true
        }
    }
    var rect=CGRect.zero {didSet {updateAccessibility()}}
    var selection: ((CGRect) -> Void)?
    var cancel: (() -> Void)?
    private var rememberedRect:CGRect?
    private var origin=CGPoint.zero
    private var original=CGRect.zero
    private var handle: Int?
    private var movable=false
    private lazy var captureButton=NSButton(title:L10n.text("capture.start"),target:self,action:#selector(confirm))
    private lazy var cancelButton=NSButton(title:L10n.text("action.cancel"),target:self,action:#selector(cancelSelection))
    private lazy var modeControl=NSSegmentedControl(labels:[L10n.text("capture.area"),L10n.text("capture.fixed")],trackingMode:.selectOne,target:self,action:#selector(selectCaptureMode))
    private let toolbar = SelectionToolbar()
    private let hint = NSTextField(labelWithString: "")
    private let dimensions = NSTextField(labelWithString: "")
    override init(frame frameRect:NSRect) {
        super.init(frame:frameRect)
        toolbar.appearance=NSAppearance(named:.vibrantDark)
        addSubview(toolbar)
        hint.font = .systemFont(ofSize:12,weight:.medium);hint.textColor = .white
        hint.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        dimensions.font = .monospacedSystemFont(ofSize:11,weight:.medium);dimensions.textColor = .white
        let top=NSStackView(views:[hint,NSView(),dimensions]);top.orientation = .horizontal;top.spacing=12;top.alignment = .centerY
        let controls=NSStackView(views:[modeControl,NSView(),cancelButton,captureButton]);controls.orientation = .horizontal;controls.spacing=8;controls.alignment = .centerY
        let content=NSStackView(views:[top,controls]);content.orientation = .vertical;content.spacing=10;content.alignment = .leading
        toolbar.addSubview(content);content.translatesAutoresizingMaskIntoConstraints=false
        top.translatesAutoresizingMaskIntoConstraints=false;controls.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([content.leadingAnchor.constraint(equalTo:toolbar.leadingAnchor,constant:16),content.trailingAnchor.constraint(equalTo:toolbar.trailingAnchor,constant:-16),content.topAnchor.constraint(equalTo:toolbar.topAnchor,constant:14),content.bottomAnchor.constraint(equalTo:toolbar.bottomAnchor,constant:-14),top.widthAnchor.constraint(equalTo:content.widthAnchor),controls.widthAnchor.constraint(equalTo:content.widthAnchor)])
        captureButton.bezelStyle = .rounded;captureButton.bezelColor = .controlAccentColor;cancelButton.bezelStyle = .rounded
        modeControl.selectedSegment=0
        captureButton.setAccessibilityLabel(L10n.text("capture.start"));cancelButton.setAccessibilityLabel(L10n.text("action.cancel"))
        modeControl.setAccessibilityLabel(L10n.text("overlay.mode_label"));modeControl.setAccessibilityHelp(L10n.text("overlay.mode_help"))
        setAccessibilityElement(true);setAccessibilityRole(.group);setAccessibilityLabel(L10n.text("overlay.title"))
        nextKeyView=captureButton;captureButton.nextKeyView=cancelButton;cancelButton.nextKeyView=modeControl;modeControl.nextKeyView=self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalization), name: L10n.languageDidChange, object: nil)
        refreshLocalization()
    }
    required init?(coder:NSCoder) { fatalError("init(coder:) is unavailable") }
    @objc func refreshLocalization() {
        captureButton.title = L10n.text("capture.start"); cancelButton.title = L10n.text("action.cancel")
        captureButton.setAccessibilityLabel(captureButton.title); cancelButton.setAccessibilityLabel(cancelButton.title)
        modeControl.setLabel(L10n.text("capture.area"), forSegment: 0)
        modeControl.setLabel(L10n.text("capture.fixed"), forSegment: 1)
        modeControl.setAccessibilityLabel(L10n.text("overlay.mode_label")); modeControl.setAccessibilityHelp(L10n.text("overlay.mode_help"))
        setAccessibilityLabel(L10n.text("overlay.title")); updateAccessibility(); needsDisplay = true
    }
    @objc private func confirm() { if SelectionGeometry.valid(rect) { selection?(rect) } }
    @objc private func cancelSelection() { cancel?() }
    @objc private func selectCaptureMode() {mode=modeControl.selectedSegment == 0 ? .drag:.mask}
    override func layout() {
        super.layout()
        let width=min(620,max(0,bounds.width-32));toolbar.frame=CGRect(x:max(16,(bounds.width-width)/2),y:24,width:width,height:91)
    }
    override func resetCursorRects() {addCursorRect(bounds,cursor:mode == .drag ? .crosshair:.arrow)}
    private func updateAccessibility() {
        hint.stringValue=L10n.text(mode == .mask ? "overlay.mask_help":"overlay.drag_help")
        dimensions.stringValue=SelectionGeometry.valid(rect) ? L10n.format("overlay.dimensions",Double(rect.width),Double(rect.height)):""
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
        guard SelectionGeometry.valid(rect) else {return}
        let path=NSBezierPath(rect:rect);NSColor.black.withAlphaComponent(0.6).setStroke();path.lineWidth=3;path.stroke()
        NSColor.white.setStroke();path.lineWidth=1.5;path.stroke()
        if window?.firstResponder === self {NSColor.keyboardFocusIndicatorColor.setStroke();let focus=NSBezierPath(rect:rect.insetBy(dx:-4,dy:-4));focus.lineWidth=2;focus.stroke()}
        if mode == .mask {
            for point in handles {
                let handle=NSBezierPath(roundedRect:CGRect(x:point.x-4,y:point.y-4,width:8,height:8),xRadius:2,yRadius:2)
                NSColor.white.setFill();handle.fill();NSColor.controlAccentColor.setStroke();handle.lineWidth=1.5;handle.stroke()
            }
        }
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
            guard SelectionGeometry.valid(rect) else {return}
            let d:CGFloat=event.modifierFlags.contains(.shift) ? 10 : 1
            let delta=CGSize(width:event.keyCode == 123 ? -d : event.keyCode == 124 ? d : 0,height:event.keyCode == 125 ? -d : event.keyCode == 126 ? d : 0)
            if event.modifierFlags.contains(.option) { rect=SelectionGeometry.resized(rect,corner:.topRight,by:delta,within:bounds) }
            else { rect=SelectionGeometry.translated(rect,by:delta,within:bounds) };needsDisplay=true
        case nil: super.keyDown(with:event)
        }
    }
}

private final class SelectionToolbar:NSView {
    override func draw(_ dirtyRect:NSRect) {
        let opacity:CGFloat=NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency ? 1:0.9
        let path=NSBezierPath(roundedRect:bounds.insetBy(dx:0.5,dy:0.5),xRadius:14,yRadius:14)
        NSColor(calibratedWhite:0.09,alpha:opacity).setFill();path.fill()
        NSColor.white.withAlphaComponent(0.15).setStroke();path.lineWidth=1;path.stroke()
    }
}
