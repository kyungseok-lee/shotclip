import AppKit

// Semantic system colors keep the compact native UI readable in both appearances.
enum DesignTokens {
    static let primaryText = NSColor.labelColor
    static let secondaryText = NSColor.secondaryLabelColor
    static let windowSurface = NSColor.windowBackgroundColor
    static let cardSurface = NSColor.windowBackgroundColor
    static let ready = NSColor.systemGreen
    static let attention = NSColor.systemOrange
    static let body = NSFont.systemFont(ofSize: 13)
    static let caption = NSFont.systemFont(ofSize: 12)
    static let section = NSFont.systemFont(ofSize: 14, weight: .semibold)
    static let title = NSFont.systemFont(ofSize: 18, weight: .semibold)
    static let shortcut = NSFont.systemFont(ofSize: 13, weight: .medium)
    static let inline: CGFloat = 8
    static let group: CGFloat = 12
    static let sectionGap: CGFloat = 16
    static let inset: CGFloat = 20
}

final class SettingsCard: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 8, yRadius: 8)
        DesignTokens.cardSurface.setFill(); path.fill()
        NSColor.separatorColor.setStroke(); path.lineWidth = 1; path.stroke()
    }
    override func viewDidChangeEffectiveAppearance() { super.viewDidChangeEffectiveAppearance(); needsDisplay = true }
}
