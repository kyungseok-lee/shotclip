import Foundation

public enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    case korean = "ko"

    // Deliberately independent of the host's preferred languages.
    public static func resolve(_ storedValue: String?) -> AppLanguage {
        storedValue.flatMap(AppLanguage.init(rawValue:)) ?? .english
    }
    public var nativeName: String { self == .english ? "English" : "한국어" }
    public var locale: Locale { Locale(identifier: rawValue) }
}

public struct LanguageSelection: Equatable {
    public let active: AppLanguage
    public var selected: AppLanguage
    public init(active: AppLanguage, selected: AppLanguage) {
        self.active = active
        self.selected = selected
    }
    public var requiresRestart: Bool { active != selected }
}

public struct StringLocalization {
    public let language: AppLanguage
    private let selectedBundle: Bundle?
    private let englishBundle: Bundle?
    public init(bundle: Bundle, language: AppLanguage) {
        self.language = language
        englishBundle = bundle.resourceURL.flatMap { Bundle(url: $0.appendingPathComponent("en.lproj")) }
        selectedBundle = bundle.resourceURL.flatMap { Bundle(url: $0.appendingPathComponent(language.rawValue + ".lproj")) }
    }
    // Foundation provides table lookup; an explicit English sub-bundle makes
    // fallback deterministic even when the host's preferred language is Korean.
    public func text(_ key: String, defaultValue: String? = nil) -> String {
        let fallback = englishBundle?.localizedString(forKey: key, value: defaultValue, table: "Localizable") ?? defaultValue ?? key
        return selectedBundle?.localizedString(forKey: key, value: fallback, table: "Localizable") ?? fallback
    }
    public func format(_ key: String, arguments: [CVarArg]) -> String {
        String(format: text(key), locale: language.locale, arguments: arguments)
    }
}

public enum LocalizationAuditError: Error { case missingTable, invalidTable, mismatchedKeys, emptyValue, fallbackFailed }

public enum LocalizationAudit {
    public static func table(bundle: Bundle, language: AppLanguage) throws -> [String: String] {
        guard let url = bundle.resourceURL?.appendingPathComponent(language.rawValue + ".lproj/Localizable.strings"),
              FileManager.default.fileExists(atPath: url.path) else { throw LocalizationAuditError.missingTable }
        let data = try Data(contentsOf: url)
        guard let table = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String], !table.isEmpty else { throw LocalizationAuditError.invalidTable }
        return table
    }
    @discardableResult public static func validate(bundle: Bundle) throws -> Int {
        let english = try table(bundle: bundle, language: .english)
        let korean = try table(bundle: bundle, language: .korean)
        guard Set(english.keys) == Set(korean.keys) else { throw LocalizationAuditError.mismatchedKeys }
        guard (Array(english.values) + Array(korean.values)).allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { throw LocalizationAuditError.emptyValue }
        for language in AppLanguage.allCases {
            let localization = StringLocalization(bundle: bundle, language: language)
            let table = language == .english ? english : korean
            guard table.allSatisfy({ localization.text($0.key) == $0.value }),
                  localization.text("diagnostic.missing.key", defaultValue: "English fallback") == "English fallback" else { throw LocalizationAuditError.fallbackFailed }
        }
        return english.count
    }
}
