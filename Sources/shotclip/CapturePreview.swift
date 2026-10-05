import AppKit
import UniformTypeIdentifiers

// Successful captures remain in memory until the user dismisses their preview.
// This presentation layer never reads or writes a pasteboard and never saves
// unless the user accepts the native save panel.
@MainActor final class CapturePreviewController: NSObject, NSWindowDelegate {
    private(set) var thumbnail: NSPanel?
    private(set) var preview: CaptureImagePreviewWindow?
    private(set) var image: CGImage?
    private let presentWindows: Bool
    private let thumbnailLifetime: TimeInterval?
    private var dismissalTimer: Timer?
    private var anchorFrame = NSRect.zero
    private var thumbnailView: CaptureThumbnailView?

    init(presentWindows: Bool = true, thumbnailLifetime: TimeInterval? = 8) {
        self.presentWindows = presentWindows; self.thumbnailLifetime = thumbnailLifetime; super.init()
    }

    func show(_ image: CGImage, visibleFrame: NSRect) {
        dismiss()
        self.image = image; anchorFrame = visibleFrame
        let width = min(DesignTokens.thumbnailWidth, max(1, visibleFrame.width - DesignTokens.screenInset * 2))
        let height = min(DesignTokens.thumbnailHeight, max(1, visibleFrame.height - DesignTokens.screenInset * 2))
        let panel = CaptureThumbnailPanel(contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.level = .floating; panel.isOpaque = false; panel.backgroundColor = .clear
        panel.hasShadow = true; panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let view = CaptureThumbnailView(image: image, frame: NSRect(x: 0, y: 0, width: width, height: height))
        view.open = { [weak self] in self?.openPreview() }
        view.dismiss = { [weak self] in self?.dismissThumbnail() }
        view.hover = { [weak self] inside in
            self?.dismissalTimer?.invalidate(); self?.dismissalTimer = nil
            if !inside { self?.scheduleDismissal() }
        }
        panel.contentView = view; thumbnailView = view; thumbnail = panel
        panel.setFrameOrigin(NSPoint(x: visibleFrame.maxX - width - DesignTokens.screenInset,
            y: visibleFrame.minY + DesignTokens.screenInset))
        if presentWindows {
            panel.orderFrontRegardless()
            NSAccessibility.post(element: view.openButton, notification: .announcementRequested,
                userInfo: [.announcement: L10n.text("capture.preview.announcement"), .priority: NSAccessibilityPriorityLevel.medium.rawValue])
        }
        scheduleDismissal()
    }

    private func scheduleDismissal() {
        guard thumbnail != nil, let thumbnailLifetime else { return }
        dismissalTimer?.invalidate()
        dismissalTimer = Timer.scheduledTimer(withTimeInterval: thumbnailLifetime, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.dismissThumbnail() }
        }
    }

    func openPreview() {
        guard let image else { return }
        if let preview {
            if presentWindows { NSApp.activate(ignoringOtherApps: true); preview.makeKeyAndOrderFront(nil) }
            return
        }
        let window = CaptureImagePreviewWindow(image: image, availableFrame: anchorFrame)
        window.delegate = self; preview = window
        dismissalTimer?.invalidate(); dismissalTimer = nil
        thumbnail?.close(); thumbnail = nil; thumbnailView = nil
        if presentWindows { NSApp.activate(ignoringOtherApps: true); window.makeKeyAndOrderFront(nil) }
    }

    func dismissThumbnail() {
        dismissalTimer?.invalidate(); dismissalTimer = nil
        thumbnail?.close(); thumbnail = nil; thumbnailView = nil
        if preview == nil { image = nil }
    }

    func dismiss() {
        dismissalTimer?.invalidate(); dismissalTimer = nil
        // Closing a sheet is cancellation; it must not retain a hidden preview
        // or accept a filename when a new capture begins.
        preview?.cancelSave()
        preview?.close(); preview = nil
        thumbnail?.close(); thumbnail = nil; thumbnailView = nil; image = nil
    }

    func windowWillClose(_ notification: Notification) {
        guard let closing = notification.object as? NSWindow, closing === preview else { return }
        preview?.cancelSave(); preview = nil
        if thumbnail == nil { image = nil }
    }
    func windowDidChangeBackingProperties(_ notification: Notification) { preview?.updateImageLayout() }

    func refreshLanguage() { thumbnailView?.refreshLanguage(); preview?.refreshLanguage() }

    // Exercise the exact production button actions without desktop pixels.
    #if SHOTCLIP_QA
    func clickThumbnailForPreview() { thumbnailView?.openButton.performClick(nil) }
    func clickDismissForPreview() { thumbnailView?.closeButton.performClick(nil) }
    func expireThumbnailForPreview() { dismissThumbnail() }
    var thumbnailCaptionForPreview: NSTextField? { thumbnailView?.caption }
    var thumbnailImageFrameForPreview: NSRect? { thumbnailView?.imageFrame }
    func setThumbnailCaptionForPreview(_ text: String) { thumbnailView?.setCaptionForPreview(text) }
    #endif
}

private final class CaptureThumbnailPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

@MainActor private final class CaptureThumbnailView: NSVisualEffectView {
    let openButton = NSButton()
    let closeButton = NSButton()
    private let imageView = NSImageView()
    let caption = WrappingLabel(wrappingLabelWithString: "")
    var open: (() -> Void)?
    var dismiss: (() -> Void)?
    var hover: ((Bool) -> Void)?
    private var hoverTracking: NSTrackingArea?

    init(image: CGImage, frame: NSRect) {
        super.init(frame: frame)
        material = .popover; blendingMode = .withinWindow; state = .active
        wantsLayer = true; layer?.cornerRadius = DesignTokens.borderRadius; layer?.masksToBounds = true
        imageView.image = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.setAccessibilityElement(false)
        caption.font = DesignTokens.caption; caption.textColor = DesignTokens.primaryText
        caption.alignment = .center; caption.maximumNumberOfLines = 2
        caption.setAccessibilityElement(false)
        openButton.isBordered = false; openButton.title = ""; openButton.target = self; openButton.action = #selector(openImage)
        openButton.setAccessibilityRole(.button)
        closeButton.isBordered = false; closeButton.title = ""; closeButton.target = self; closeButton.action = #selector(closeImage)
        closeButton.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)
        closeButton.contentTintColor = DesignTokens.secondaryText
        for view in [imageView, caption, openButton, closeButton] { addSubview(view) }
        refreshLanguage()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func updateTrackingAreas() {
        if let hoverTracking { removeTrackingArea(hoverTracking) }
        let tracking = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self)
        hoverTracking = tracking; addTrackingArea(tracking); super.updateTrackingAreas()
    }
    override func mouseEntered(with event: NSEvent) { hover?(true) }
    override func mouseExited(with event: NSEvent) { hover?(false) }
    override func layout() {
        super.layout()
        let padding = DesignTokens.group
        let captionWidth = max(1, bounds.width - padding * 2)
        caption.preferredMaxLayoutWidth = captionWidth
        let captionHeight = caption.requiredHeight(forWidth: captionWidth)
        caption.frame = NSRect(x: padding, y: padding, width: captionWidth, height: captionHeight)
        imageView.frame = NSRect(x: padding, y: caption.frame.maxY + DesignTokens.inline,
            width: max(1, bounds.width - padding * 2), height: max(1, bounds.height - caption.frame.maxY - DesignTokens.inline - padding))
        openButton.frame = bounds
        closeButton.frame = NSRect(x: bounds.maxX - 26, y: bounds.maxY - 26, width: 22, height: 22)
    }
    func refreshLanguage() {
        caption.stringValue = L10n.text("capture.preview.thumbnail")
        openButton.setAccessibilityLabel(L10n.text("capture.preview.open"))
        openButton.toolTip = L10n.text("capture.preview.open")
        closeButton.setAccessibilityLabel(L10n.text("capture.preview.dismiss"))
        closeButton.toolTip = L10n.text("capture.preview.dismiss")
        needsLayout = true
    }
    var imageFrame: NSRect { imageView.frame }
    #if SHOTCLIP_QA
    func setCaptionForPreview(_ text: String) { caption.stringValue = text; needsLayout = true }
    #endif
    @objc private func openImage() { open?() }
    @objc private func closeImage() { dismiss?() }
}

@MainActor final class CaptureImagePreviewWindow: NSWindow {
    let originalImage: CGImage
    let saveButton = NSButton()
    let zoomControl = NSSegmentedControl(labels: ["", ""], trackingMode: .selectOne, target: nil, action: nil)
    let scrollView = NSScrollView()
    private let dimensions = NSTextField(labelWithString: "")
    private let surface = CaptureImageDocumentView()
    private var savePanel: NSSavePanel?
    #if SHOTCLIP_QA
    private(set) var saveRequests = 0
    private(set) var saveCompletions = 0
    private(set) var lastSaveResponse: NSApplication.ModalResponse?
    var configureSavePanelForPreview: ((NSSavePanel) -> Void)?
    var onSavePanelPresented: ((NSSavePanel) -> Void)?
    var beforePNGWriteForPreview: ((URL) -> Void)?
    var onSaveFailure: (() -> Void)?
    #endif
    private var languageObserver: Any?

    init(image: CGImage, availableFrame: NSRect) {
        originalImage = image
        let size = NSSize(width: min(DesignTokens.previewDefaultSize.width,
            max(DesignTokens.previewMinimumSize.width, availableFrame.width - DesignTokens.screenInset * 4)),
            height: min(DesignTokens.previewDefaultSize.height,
            max(DesignTokens.previewMinimumSize.height, availableFrame.height - DesignTokens.screenInset * 4)))
        super.init(contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        isReleasedWhenClosed = false; minSize = DesignTokens.previewMinimumSize
        backgroundColor = DesignTokens.windowSurface
        setFrameOrigin(NSPoint(x: availableFrame.midX - frame.width / 2, y: availableFrame.midY - frame.height / 2))
        let root = CapturePreviewRootView(frame: NSRect(origin: .zero, size: size))
        contentView = root
        let toolbar = NSView(); toolbar.translatesAutoresizingMaskIntoConstraints = false
        dimensions.font = DesignTokens.caption; dimensions.textColor = DesignTokens.secondaryText
        dimensions.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        zoomControl.target = self; zoomControl.action = #selector(changeZoom); zoomControl.selectedSegment = 0
        saveButton.bezelStyle = .rounded; saveButton.target = self; saveButton.action = #selector(saveImage)
        saveButton.keyEquivalent = "s"; saveButton.keyEquivalentModifierMask = .command
        zoomControl.font = DesignTokens.body; saveButton.font = DesignTokens.body
        for view in [dimensions, zoomControl, saveButton] { view.translatesAutoresizingMaskIntoConstraints = false; toolbar.addSubview(view) }
        let separator = NSBox(); separator.boxType = .separator; separator.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasHorizontalScroller = true; scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true; scrollView.drawsBackground = true
        scrollView.backgroundColor = DesignTokens.windowSurface
        surface.imageView.image = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        surface.imageView.imageScaling = .scaleAxesIndependently
        scrollView.documentView = surface
        root.addSubview(toolbar); root.addSubview(separator); root.addSubview(scrollView)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: root.leadingAnchor), toolbar.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: root.topAnchor), toolbar.heightAnchor.constraint(equalToConstant: DesignTokens.previewToolbarHeight),
            dimensions.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: DesignTokens.inset),
            dimensions.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            zoomControl.leadingAnchor.constraint(greaterThanOrEqualTo: dimensions.trailingAnchor, constant: DesignTokens.group),
            zoomControl.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            saveButton.leadingAnchor.constraint(equalTo: zoomControl.trailingAnchor, constant: DesignTokens.group),
            saveButton.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -DesignTokens.inset),
            saveButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: root.leadingAnchor), separator.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            separator.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor), scrollView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: separator.bottomAnchor), scrollView.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
        root.didLayout = { [weak self] in self?.updateImageLayout() }
        refreshLanguage(); root.layoutSubtreeIfNeeded(); updateImageLayout()
        languageObserver = NotificationCenter.default.addObserver(forName: L10n.languageDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshLanguage() }
        }
    }
    deinit { if let languageObserver { NotificationCenter.default.removeObserver(languageObserver) } }

    func refreshLanguage() {
        title = L10n.text("capture.preview.title")
        saveButton.title = L10n.text("capture.preview.save")
        zoomControl.setLabel(L10n.text("capture.preview.fit"), forSegment: 0)
        zoomControl.setLabel("100%", forSegment: 1)
        zoomControl.setAccessibilityLabel(L10n.text("capture.preview.zoom"))
        scrollView.setAccessibilityLabel(L10n.text("capture.preview.image"))
        dimensions.stringValue = "\(originalImage.width) × \(originalImage.height)"
        dimensions.setAccessibilityLabel(L10n.format("capture.preview.dimensions", String(originalImage.width), String(originalImage.height)))
        contentView?.needsLayout = true
    }

    func updateImageLayout() {
        let viewport = scrollView.contentView.bounds.size
        guard viewport.width > 0, viewport.height > 0 else { return }
        let padding = DesignTokens.previewImagePadding
        let backingScale = max(1, backingScaleFactor)
        let actual = NSSize(width: CGFloat(originalImage.width) / backingScale, height: CGFloat(originalImage.height) / backingScale)
        let ratio = zoomControl.selectedSegment == 1 ? 1 : min(1,
            min(max(1, viewport.width - padding * 2) / actual.width, max(1, viewport.height - padding * 2) / actual.height))
        let imageSize = NSSize(width: actual.width * ratio, height: actual.height * ratio)
        surface.frame = NSRect(origin: .zero, size: NSSize(width: max(viewport.width, imageSize.width + padding * 2),
            height: max(viewport.height, imageSize.height + padding * 2)))
        surface.imageView.frame = NSRect(x: (surface.bounds.width - imageSize.width) / 2,
            y: (surface.bounds.height - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        surface.imageView.needsDisplay = true
    }
    @objc private func changeZoom() { updateImageLayout() }

    func makeSavePanel() -> NSSavePanel {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]; panel.allowsOtherFileTypes = false
        panel.canCreateDirectories = true; panel.isExtensionHidden = false
        panel.title = L10n.text("capture.preview.save_title")
        panel.prompt = L10n.text("capture.preview.save_action")
        panel.nameFieldStringValue = "Shot Clip.png"
        return panel
    }

    @objc private func saveImage() {
        guard savePanel == nil else { return }
        let panel = makeSavePanel()
        #if SHOTCLIP_QA
        // Native directory/name properties are configuration-phase-only. The
        // inert fixture configures a synthetic destination before presentation,
        // then exercises the same native sheet and completion as the app.
        configureSavePanelForPreview?(panel)
        saveRequests += 1
        #endif
        savePanel = panel
        saveButton.isEnabled = false
        panel.beginSheetModal(for: self) { [weak self, weak panel] response in
            guard let self else { return }
            let selectedURL = panel?.url
            panel?.orderOut(nil)
            #if SHOTCLIP_QA
            self.lastSaveResponse = response; self.saveCompletions += 1
            #endif
            self.savePanel = nil; self.saveButton.isEnabled = true
            guard response == .OK, let url = selectedURL else { return }
            #if SHOTCLIP_QA
            // Inert QA can remove its own empty destination after real native
            // acceptance to exercise an actual write failure. Normal launches
            // never invoke this nil-by-default callback or replace the writer.
            if CommandLine.arguments.contains("--ui-preview") { self.beforePNGWriteForPreview?(url) }
            #endif
            do { try self.writePNG(to: url) }
            catch {
                #if SHOTCLIP_QA
                if let onSaveFailure = self.onSaveFailure { onSaveFailure(); return }
                #endif
                let alert = NSAlert(); alert.messageText = L10n.text("capture.preview.save_failed")
                alert.informativeText = L10n.text("capture.preview.save_failed_help")
                alert.addButton(withTitle: L10n.text("action.ok")); alert.beginSheetModal(for: self)
            }
        }
        #if SHOTCLIP_QA
        onSavePanelPresented?(panel)
        #endif
    }

    func cancelSave() { savePanel?.cancel(nil) }

    // The same original CGImage is used here and in the 100% view; fit scaling
    // affects presentation only. An atomic write preserves an existing file if
    // encoding fails before the user's explicitly selected destination is used.
    func writePNG(to url: URL) throws {
        let bitmap = NSBitmapImageRep(cgImage: originalImage)
        guard let data = bitmap.representation(using: .png, properties: [:]) else { throw CaptureFailure.invalidImage }
        try data.write(to: url, options: .atomic)
    }

    #if SHOTCLIP_QA
    var previewImageFrame: NSRect { surface.imageView.frame }
    var previewDocumentSize: NSSize { surface.frame.size }
    #endif
}

@MainActor private final class CapturePreviewRootView: NSView {
    var didLayout: (() -> Void)?
    override func layout() { super.layout(); didLayout?() }
    override func draw(_ dirtyRect: NSRect) { DesignTokens.windowSurface.setFill(); NSBezierPath(rect: bounds).fill() }
    override func viewDidChangeEffectiveAppearance() { super.viewDidChangeEffectiveAppearance(); needsDisplay = true }
}
@MainActor private final class CaptureImageDocumentView: NSView {
    let imageView = NSImageView()
    override init(frame frameRect: NSRect) { super.init(frame: frameRect); addSubview(imageView) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
