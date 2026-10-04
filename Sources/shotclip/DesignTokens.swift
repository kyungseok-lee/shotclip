import AppKit

// Project defaults from docs/shotclip/design-system.md; native semantic colors
// adapt to appearance. These tokens make no prediction about future Apple APIs.
enum DesignTokens {
    static let primaryText = NSColor.labelColor
    static let secondaryText = NSColor.secondaryLabelColor
    static let windowSurface = NSColor.windowBackgroundColor
    static let ready = NSColor.systemGreen
    static let attention = NSColor.systemOrange
    static let body = NSFont.systemFont(ofSize: 13)
    static let caption = NSFont.systemFont(ofSize: 12)
    static let section = NSFont.systemFont(ofSize: 17, weight: .semibold)
    static let title = NSFont.systemFont(ofSize: 24, weight: .semibold)
    static let shortcut = NSFont.monospacedSystemFont(ofSize: 14, weight: .medium)
    static let inline: CGFloat = 8
    static let group: CGFloat = 12
    static let sectionGap: CGFloat = 20
    static let inset: CGFloat = 24
}
