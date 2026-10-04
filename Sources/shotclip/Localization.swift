import Foundation
import CaptureCore
import Darwin

enum L10n {
    static let languageKey = AppPreferences.languageKey
    private static let defaults: UserDefaults = {
        // Foundation rejects an app's own bundle identifier as a suite name.
        // CLI development still targets the same explicit application domain.
        if Bundle.main.bundleIdentifier == SafeDefaultsMigration.currentDomain { return .standard }
        return UserDefaults(suiteName: SafeDefaultsMigration.currentDomain) ?? .standard
    }()
    // Preview language is selected before any preference lookup. It never writes
    // the user's persistent language or invokes the normal app startup path.
    private static var previewLanguage: AppLanguage? {
        guard CommandLine.arguments.contains("--ui-preview"),
              let index = CommandLine.arguments.firstIndex(of: "--language"),
              CommandLine.arguments.indices.contains(index + 1) else { return nil }
        return AppLanguage(rawValue: CommandLine.arguments[index + 1])
    }
    static let languageDidChange = Notification.Name("ShotClipAppLanguageDidChange")
    static var language: AppLanguage { localization.language }
    static let bundle: Bundle = {
        // Installed apps must be independent of SwiftPM's generated absolute
        // build-directory fallback. The release script owns copying this bundle.
        if let url = Bundle.main.resourceURL?.appendingPathComponent("shotclip_shotclip.bundle"),
           let installed = Bundle(url: url) { return installed }
        if Bundle.main.bundleURL.pathExtension == "app" { return .main }
        return Bundle.module
    }()
    private static let localization = AppLocalization(bundle: bundle, language: previewLanguage ?? AppLanguage.resolve(defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain)?[languageKey] as? String))
    static func text(_ key: String, defaultValue: String? = nil) -> String {
        localization.text(key, defaultValue: defaultValue)
    }
    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        localization.format(key, arguments: arguments)
    }
    static func preparePreferences() {
        let current = defaults.persistentDomain(forName: SafeDefaultsMigration.currentDomain) ?? [:]
        let legacy = defaults.persistentDomain(forName: SafeDefaultsMigration.legacyDomain) ?? [:]
        // Application domain only. AppleLanguages provides the initial preference
        // to framework-owned UI; app-owned copy uses explicit sub-bundle lookup.
        for (key, value) in AppPreferences.startupValues(current: current, legacy: legacy) { defaults.set(value, forKey: key) }
    }
    @MainActor static func select(_ language: AppLanguage) {
        // The synthetic runtime exercises the production transition without any
        // persistent writes, including AppleLanguages or migration markers.
        if !CommandLine.arguments.contains("--ui-preview") {
            for (key, value) in AppPreferences.languageValues(language) { defaults.set(value, forKey: key) }
        }
        if localization.select(language) { NotificationCenter.default.post(name: languageDidChange, object: nil) }
    }
    static func runDiagnostic() -> Never {
        let record: [String: Any]
        let result: Int32
        do {
            let count = try LocalizationAudit.validate(bundle: bundle)
            let updateCount = try LocalizationAudit.validate(bundle: bundle, table: "Updates")
            let live = AppLocalization(bundle: bundle, language: .english)
            guard live.text("action.cancel") == "Cancel", live.select(.korean), live.text("action.cancel") == "취소",
                  live.select(.english), live.text("action.cancel") == "Cancel" else { throw LocalizationAuditError.fallbackFailed }
            let installed = Bundle.main.bundleURL.pathExtension == "app"
            // Foundation can represent resourceURL relative to the app bundle.
            let bundleParent = bundle.bundleURL.deletingLastPathComponent().absoluteURL.standardizedFileURL
            let appResources = Bundle.main.resourceURL?.absoluteURL.standardizedFileURL
            guard !installed || bundleParent == appResources else { throw LocalizationAuditError.missingTable }
            record = ["case": "localization", "result": "PASS", "languages": ["en", "ko"], "keyCount": count, "fallback": true, "installedBundle": installed, "liveLanguageTransitions": true, "updateKeyCount": updateCount, "updatesFallback": true]
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
