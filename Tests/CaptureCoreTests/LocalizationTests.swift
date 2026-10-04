import XCTest
@testable import CaptureCore

final class LocalizationTests: XCTestCase {
    private var repository: URL { URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent() }
    private func resources() throws -> Bundle {
        try XCTUnwrap(Bundle(url: repository.appendingPathComponent("Sources/shotclip/Resources")))
    }
    func testEveryStringResourceHasKeyAndFormatParityAndNativeLookup() throws {
        let bundle = try resources()
        let english = try LocalizationAudit.table(bundle: bundle, language: .english)
        let korean = try LocalizationAudit.table(bundle: bundle, language: .korean)
        XCTAssertEqual(try LocalizationAudit.validate(bundle: bundle), english.count)
        XCTAssertGreaterThan(english.count, 90)
        let placeholder = try NSRegularExpression(pattern: "%([0-9]+\\$)?[0-9]*(\\.[0-9]+)?[a-zA-Z@]")
        func formats(_ text: String) -> [String] {
            placeholder.matches(in: text, range: NSRange(text.startIndex..., in: text)).map { String(text[Range($0.range, in: text)!]) }
        }
        for key in english.keys {
            let translated = try XCTUnwrap(korean[key], key)
            XCTAssertEqual(formats(english[key]!), formats(translated), key)
        }
        XCTAssertEqual(StringLocalization(bundle: bundle, language: .english).text("action.cancel"), "Cancel")
        XCTAssertEqual(StringLocalization(bundle: bundle, language: .korean).text("action.cancel"), "취소")
        XCTAssertEqual(StringLocalization(bundle: bundle, language: .korean).format("menu.fixed_shortcut", arguments: ["⌃⇧⌘5"]), "고정 영역 (⌃⇧⌘5)")
    }
    func testAppOwnedLiteralKeysAndPurePermissionKeysExistInBothLanguages() throws {
        let bundle = try resources()
        let english = try LocalizationAudit.table(bundle: bundle, language: .english)
        let korean = try LocalizationAudit.table(bundle: bundle, language: .korean)
        let pattern = try NSRegularExpression(pattern: "\"((?:action|app|menu|capture|overlay|settings|permission|version|updates|restart|login|shortcut)\\.[a-z0-9_.]+)\"")
        let files = try FileManager.default.contentsOfDirectory(at: repository.appendingPathComponent("Sources/shotclip"), includingPropertiesForKeys: nil).filter { $0.pathExtension == "swift" }
        for file in files {
            let source = try String(contentsOf: file, encoding: .utf8)
            for match in pattern.matches(in: source, range: NSRange(source.startIndex..., in: source)) {
                let key = String(source[Range(match.range(at: 1), in: source)!])
                XCTAssertNotNil(english[key], "Missing English key \(key)")
                XCTAssertNotNil(korean[key], "Missing Korean key \(key)")
            }
        }
        for ready in [true, false] {
            for signing in [true, false, nil] as [Bool?] {
                let state = PermissionPresentation(accessEffective: ready, adHoc: signing)
                for key in [state.titleKey, state.explanationKey, state.identityAdviceKey] {
                    XCTAssertNotNil(english[key]); XCTAssertNotNil(korean[key])
                }
                XCTAssertEqual(state.canCapture, ready)
            }
        }
        XCTAssertNotNil(english[CoordinatorError.timeout.localizationKey])
        XCTAssertNotNil(korean[CoordinatorError.timeout.localizationKey])
    }
    func testMissingKoreanTranslationAndUnsupportedLanguageFallBackToEnglish() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("shotclip-localization-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        for language in AppLanguage.allCases {
            let folder = directory.appendingPathComponent(language.rawValue + ".lproj")
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let table = language == .english ? ["fallback.test": "English fallback", "translated.test": "English"] : ["translated.test": "한국어"]
            let data = try PropertyListSerialization.data(fromPropertyList: table, format: .xml, options: 0)
            try data.write(to: folder.appendingPathComponent("Localizable.strings"))
        }
        let bundle = try XCTUnwrap(Bundle(url: directory))
        XCTAssertEqual(StringLocalization(bundle: bundle, language: .korean).text("fallback.test"), "English fallback")
        XCTAssertEqual(StringLocalization(bundle: bundle, language: .korean).text("translated.test"), "한국어")
        XCTAssertEqual(StringLocalization(bundle: bundle, language: AppLanguage.resolve("fr")).text("translated.test"), "English")
        XCTAssertEqual(StringLocalization(bundle: bundle, language: .korean).text("missing", defaultValue: "Explicit fallback"), "Explicit fallback")
    }
}
