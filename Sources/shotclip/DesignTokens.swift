import AppKit

// Semantic system colors keep the compact native UI readable in both appearances.
enum DesignTokens {
    static let primaryText = NSColor.labelColor
    static let secondaryText = NSColor.secondaryLabelColor
    static let windowSurface = NSColor.windowBackgroundColor
    static let cardSurface = NSColor.controlBackgroundColor
    static let ready = NSColor.systemGreen
    static let attention = NSColor.systemOrange
    static let body = NSFont.systemFont(ofSize: 13)
    static let caption = NSFont.systemFont(ofSize: 11)
    static let section = NSFont.systemFont(ofSize: 15, weight: .semibold)
    static let title = NSFont.systemFont(ofSize: 23, weight: .semibold)
    static let shortcut = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
    static let inline: CGFloat = 8
    static let group: CGFloat = 12
    static let sectionGap: CGFloat = 16
    static let inset: CGFloat = 20
}

final class SettingsCard: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 12, yRadius: 12)
        DesignTokens.cardSurface.setFill(); path.fill()
        NSColor.separatorColor.withAlphaComponent(0.45).setStroke(); path.lineWidth = 1; path.stroke()
    }
    override func viewDidChangeEffectiveAppearance() { super.viewDidChangeEffectiveAppearance(); needsDisplay = true }
}
