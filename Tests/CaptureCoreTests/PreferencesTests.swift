import XCTest
@testable import CaptureCore

final class PreferencesTests: XCTestCase {
    func testEnglishIsInitialDefaultEvenWithKoreanHostPreferences() {
        let initial = AppPreferences.startupValues(current: ["AppleLanguages": ["ko-KR"]], legacy: ["appLanguage": "ko", "AppleLanguages": ["ko"]])
        XCTAssertEqual(initial[AppPreferences.languageKey] as? String, "en")
        XCTAssertEqual(initial["AppleLanguages"] as? [String], ["en"])
        XCTAssertEqual(initial["SUEnableAutomaticChecks"] as? Bool, false)
        for invalid in [nil, "", "ko-KR", "fr", "Korean"] as [String?] { XCTAssertEqual(AppLanguage.resolve(invalid), .english) }
        XCTAssertEqual(AppLanguage.allCases.map(\.rawValue), ["en", "ko"])
    }
    func testSavedLanguageRoundTripAndRestartSnapshot() throws {
        let values = AppPreferences.languageValues(.korean)
        let data = try PropertyListSerialization.data(fromPropertyList: values, format: .binary, options: 0)
        let saved = try XCTUnwrap(try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
        let selected = AppLanguage.resolve(saved[AppPreferences.languageKey] as? String)
        XCTAssertEqual(selected, .korean)
        XCTAssertEqual(AppPreferences.startupValues(current: saved, legacy: [:])["AppleLanguages"] as? [String], ["ko"])
        var selection = LanguageSelection(active: .english, selected: selected)
        XCTAssertTrue(selection.requiresRestart)
        XCTAssertEqual(selection.active, .english)
        selection.selected = .english
        XCTAssertFalse(selection.requiresRestart)
        XCTAssertFalse(LanguageSelection(active: .korean, selected: .korean).requiresRestart)
    }
    func testMigrationCopiesOnlyValidShortcutAndMode() throws {
        let data = try JSONEncoder().encode(CaptureShortcut())
        let legacy: [String: Any] = ["shortcut": data, "mode": "drag", "appLanguage": "ko", "AppleLanguages": ["ko"], "SUEnableAutomaticChecks": true, "SUHasLaunchedBefore": true, "SUSendProfileInfo": true, "screenRecordingAllowed": true, "login": true, "rect": [1, 2, 3, 4]]
        let migrated = SafeDefaultsMigration.missingValues(legacy: legacy, current: [:])
        XCTAssertEqual(Set(migrated.keys), ["shortcut", "mode"])
        XCTAssertEqual(migrated["shortcut"] as? Data, data)
        XCTAssertEqual(migrated["mode"] as? String, "drag")
        let startup = AppPreferences.startupValues(current: [:], legacy: legacy)
        XCTAssertEqual(startup["SUEnableAutomaticChecks"] as? Bool, false)
        XCTAssertEqual(startup[AppPreferences.languageKey] as? String, "en")
        XCTAssertEqual(startup[SafeDefaultsMigration.marker] as? Bool, true)
    }
    func testMigrationNeverOverwritesNewValuesAndIsNotRepeated() throws {
        let old = try JSONEncoder().encode(CaptureShortcut())
        let new = try JSONEncoder().encode(CaptureShortcut(key: 20, label: "⌃⇧⌘3"))
        let current: [String: Any] = ["shortcut": new, "mode": "mask", "appLanguage": "ko", "SUEnableAutomaticChecks": true]
        XCTAssertTrue(SafeDefaultsMigration.missingValues(legacy: ["shortcut": old, "mode": "drag"], current: current).isEmpty)
        let initial = AppPreferences.startupValues(current: current, legacy: [:])
        XCTAssertNil(initial["shortcut"])
        XCTAssertNil(initial["mode"])
        XCTAssertNil(initial["SUEnableAutomaticChecks"])
        XCTAssertEqual(initial["appLanguage"] as? String, "ko")
        XCTAssertTrue(SafeDefaultsMigration.missingValues(legacy: ["shortcut": old, "mode": "drag"], current: [SafeDefaultsMigration.marker: true]).isEmpty)
        XCTAssertTrue(SafeDefaultsMigration.missingValues(legacy: ["shortcut": old, "mode": "drag"], current: ["shortcut": "malformed new value", "mode": "malformed new value"]).isEmpty)
    }
    func testInvalidLegacyValuesAreRejected() throws {
        for invalid in [Data(), Data("not JSON".utf8), try JSONEncoder().encode(CaptureShortcut(key: 128)), try JSONEncoder().encode(CaptureShortcut(modifiers: 0)), try JSONEncoder().encode(CaptureShortcut(label: "bad\nlabel")), try JSONEncoder().encode(CaptureShortcut(modifiers: UInt32.max))] {
            XCTAssertTrue(SafeDefaultsMigration.missingValues(legacy: ["shortcut": invalid, "mode": "unknown"], current: [:]).isEmpty)
        }
        XCTAssertTrue(SafeDefaultsMigration.missingValues(legacy: ["shortcut": "text", "mode": 42], current: [:]).isEmpty)
        XCTAssertTrue(CaptureShortcut().isValid)
    }
    func testOverlayModeKeyLeavesTabForNativeFocusAndPreservesSelectionKeys() {
        XCTAssertEqual(SelectionKeyCommand.command(keyCode: 46), .switchMode)
        XCTAssertEqual(SelectionKeyCommand.command(keyCode: 48), .focusNext)
        XCTAssertEqual(SelectionKeyCommand.command(keyCode: 48, shift: true), .focusPrevious)
        XCTAssertEqual(SelectionKeyCommand.command(keyCode: 36), .confirm)
        XCTAssertEqual(SelectionKeyCommand.command(keyCode: 76), .confirm)
        XCTAssertEqual(SelectionKeyCommand.command(keyCode: 53), .cancel)
        for key in UInt16(123)...UInt16(126) { XCTAssertEqual(SelectionKeyCommand.command(keyCode: key, shift: true, hasOption: true), .move) }
        XCTAssertNil(SelectionKeyCommand.command(keyCode: 46, hasCommandOrControl: true))
        XCTAssertNil(SelectionKeyCommand.command(keyCode: 46, hasOption: true))
    }
}
