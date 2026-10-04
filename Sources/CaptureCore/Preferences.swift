import Foundation

public struct CaptureShortcut: Codable, Equatable {
    public var key: UInt32
    public var modifiers: UInt32
    public var label: String
    public init(key: UInt32 = 23, modifiers: UInt32 = 0x1100 | 0x0200, label: String = "⌃⇧⌘5") {
        self.key = key
        self.modifiers = modifiers
        self.label = label
    }
    // Carbon Events.h modifier bits: Command 8, Shift 9, Option 11, Control 12.
    public var isValid: Bool {
        let allowed: UInt32 = 0x0100 | 0x0200 | 0x0800 | 0x1000
        return key < 128 && modifiers & (0x0100 | 0x1000) != 0 && modifiers & (0x0200 | 0x0800) != 0 && modifiers & ~allowed == 0 && !label.isEmpty && label.count <= 32 && label.unicodeScalars.allSatisfy { !CharacterSet.controlCharacters.contains($0) }
    }
}

public enum SafeDefaultsMigration {
    public static let marker = "shotclipLegacyPreferencesMigrated"
    public static let legacyDomain = "dev.sshot.app"
    public static let currentDomain = "dev.shotclip.app"
    // Return only missing, validated, nonsensitive preferences. No updater
    // internals, consent, login registration, language, or region are copied.
    public static func missingValues(legacy: [String: Any], current: [String: Any]) -> [String: Any] {
        guard current[marker] as? Bool != true else { return [:] }
        var result = [String: Any]()
        if current["shortcut"] == nil, let data = legacy["shortcut"] as? Data,
           let shortcut = try? JSONDecoder().decode(CaptureShortcut.self, from: data), shortcut.isValid {
            result["shortcut"] = data
        }
        if current["mode"] == nil, let mode = legacy["mode"] as? String, ["mask", "drag"].contains(mode) {
            result["mode"] = mode
        }
        return result
    }
}

public enum AppPreferences {
    public static let languageKey = "appLanguage"
    public static func languageValues(_ language: AppLanguage) -> [String: Any] {
        [languageKey: language.rawValue, "AppleLanguages": [language.rawValue]]
    }
    public static func startupValues(current: [String: Any], legacy: [String: Any]) -> [String: Any] {
        var values = SafeDefaultsMigration.missingValues(legacy: legacy, current: current)
        values[SafeDefaultsMigration.marker] = true
        for (key, value) in languageValues(AppLanguage.resolve(current[languageKey] as? String)) { values[key] = value }
        if current["SUEnableAutomaticChecks"] == nil { values["SUEnableAutomaticChecks"] = false }
        return values
    }
}

public enum SelectionKeyCommand: Equatable {
    case confirm, cancel, switchMode, focusNext, focusPrevious, move
    public static func command(keyCode: UInt16, shift: Bool = false, hasCommandOrControl: Bool = false, hasOption: Bool = false) -> SelectionKeyCommand? {
        guard !hasCommandOrControl else { return nil }
        switch keyCode {
        case 53: return .cancel
        case 36, 76: return .confirm
        case 46 where !hasOption: return .switchMode // ANSI M; Tab belongs to focus.
        case 48: return shift ? .focusPrevious : .focusNext
        case 123...126: return .move
        default: return nil
        }
    }
}
