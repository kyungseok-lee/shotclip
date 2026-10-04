import AppKit
import Sparkle
import CaptureCore

@MainActor
final class UpdateService {
    private var updater: SPUUpdater?
    private let userDriver = LocalizedUpdateDriver()
    private var attemptedStartup = false
    private var observation: NSKeyValueObservation?
    var onChange: (() -> Void)?
    private var initializationError: Int?
    var statusText: String {
        if let initializationError { return L10n.format("updates.initialization_failed", String(initializationError)) }
        guard isConfigured else { return L10n.text("updates.unconfigured") }
        return L10n.text(canCheckForUpdates ? "updates.ready" : "updates.busy")
    }
    var isConfigured: Bool { updater != nil }
    var canCheckForUpdates: Bool { updater?.canCheckForUpdates ?? false }
    var automaticallyChecksForUpdates: Bool {
        get { updater?.automaticallyChecksForUpdates ?? false }
        set {
            guard let updater else { return }
            updater.automaticallyChecksForUpdates = newValue
            onChange?()
        }
    }
    func start() {
        guard !attemptedStartup else { return }
        attemptedStartup = true
        guard UpdateConfiguration(feed: Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
                                  publicKey: Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String) != nil else { return }
        // One updater and one supported driver for the service's lifetime.
        // Initial automatic-check/signing/feed defaults remain in Info.plist.
        let instance = SPUUpdater(hostBundle: .main, applicationBundle: .main, userDriver: userDriver, delegate: nil)
        do { try instance.start() }
        catch {
            initializationError = (error as NSError).code
            onChange?()
            return
        }
        updater = instance
        observation = instance.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in self?.onChange?() }
        }
        initializationError = nil
        onChange?()
    }
    func checkForUpdates() {
        guard let updater else {
            userDriver.showUpdaterError(NSError(domain: "ShotClipUpdateConfiguration", code: initializationError ?? 0), acknowledgement: {})
            return
        }
        updater.checkForUpdates()
    }
}
