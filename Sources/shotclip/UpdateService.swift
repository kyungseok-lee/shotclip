import AppKit
import Sparkle
import CaptureCore

@MainActor
final class UpdateService {
    private var controller: SPUStandardUpdaterController?
    private var observation: NSKeyValueObservation?
    var onChange: (() -> Void)?
    private var initializationError:Int?
    var statusText:String {
        if let initializationError {return L10n.format("updates.initialization_failed",String(initializationError))}
        guard isConfigured else {return L10n.text("updates.unconfigured")}
        return L10n.text(canCheckForUpdates ? "updates.ready":"updates.busy")
    }
    var isConfigured: Bool { controller != nil }
    var canCheckForUpdates: Bool { controller?.updater.canCheckForUpdates ?? false }
    var automaticallyChecksForUpdates: Bool {
        get { controller?.updater.automaticallyChecksForUpdates ?? false }
        set {
            guard let updater = controller?.updater else { return }
            updater.automaticallyChecksForUpdates = newValue
            onChange?()
        }
    }
    func start() {
        guard controller == nil,
              UpdateConfiguration(feed: Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
                                  publicKey: Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String) != nil else { return }
        let instance = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
        do { try instance.updater.start() }
        catch {
            initializationError=(error as NSError).code
            onChange?()
            return
        }
        controller = instance
        observation = instance.updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in self?.onChange?() }
        }
        initializationError=nil
        onChange?()
    }
    func checkForUpdates() {
        guard let controller else {
            let alert = NSAlert()
            alert.messageText = L10n.text("updates.server_unavailable")
            alert.informativeText = statusText
            alert.addButton(withTitle:L10n.text("action.ok"))
            alert.runModal()
            return
        }
        controller.checkForUpdates(nil)
    }
}
