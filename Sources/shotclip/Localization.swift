import Foundation
import CaptureCore
import Darwin

enum L10n {
    static let languageKey = AppPreferences.languageKey
    private static let defaults = UserDefaults(suiteName: SafeDefaultsMigration.currentDomain) ?? .standard
    static let language = AppLanguage.resolve(defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain)?[languageKey] as? String)
    static var selectedLanguage: AppLanguage {
        AppLanguage.resolve(defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain)?[languageKey] as? String)
    }
    static var selection: LanguageSelection { LanguageSelection(active: language, selected: selectedLanguage) }
    static let bundle: Bundle = {
        // Installed apps must be independent of SwiftPM's generated absolute
        // build-directory fallback. The release script owns copying this bundle.
        if let url = Bundle.main.resourceURL?.appendingPathComponent("shotclip_shotclip.bundle"),
           let installed = Bundle(url: url) { return installed }
        if Bundle.main.bundleURL.pathExtension == "app" { return .main }
        return Bundle.module
    }()
    private static let localization = StringLocalization(bundle: bundle, language: language)
    static func text(_ key: String, defaultValue: String? = nil) -> String {
        localization.text(key, defaultValue: defaultValue)
    }
    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        localization.format(key, arguments: arguments)
    }
    static func preparePreferences() {
        let current = defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain) ?? [:]
        let legacy = defaults.persistentDomain(forName: SafeDefaultsMigration.legacyDomain) ?? [:]
        // Application domain only, before NSApplication/Sparkle start. A saved
        // selection changes the next launch; app-owned copy uses a launch snapshot.
        for (key, value) in AppPreferences.startupValues(current: current, legacy: legacy) { defaults.set(value, forKey: key) }
    }
    static func save(_ language: AppLanguage) {
        for (key, value) in AppPreferences.languageValues(language) { defaults.set(value, forKey: key) }
    }
    static func runDiagnostic() -> Never {
        let record: [String: Any]
        let result: Int32
        do {
            let count = try LocalizationAudit.validate(bundle: bundle)
            let installed = Bundle.main.bundleURL.pathExtension == "app"
            // Foundation can represent resourceURL relative to the app bundle.
            let bundleParent = bundle.bundleURL.deletingLastPathComponent().absoluteURL.standardizedFileURL
            let appResources = Bundle.main.resourceURL?.absoluteURL.standardizedFileURL
            guard !installed || bundleParent == appResources else { throw LocalizationAuditError.missingTable }
            record = ["case": "localization", "result": "PASS", "languages": ["en", "ko"], "keyCount": count, "fallback": true, "installedBundle": installed]
            result = 0
        } catch {
            record = ["case": "localization", "result": "FAIL"]
            result = 1
        }
        if let data = try? JSONSerialization.data(withJSONObject: record, options: .sortedKeys), let output = String(data: data, encoding: .utf8) { print(output) }
        fflush(stdout)
        exit(result)
    }
}
