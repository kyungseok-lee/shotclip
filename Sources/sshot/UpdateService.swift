import AppKit
import Sparkle
import CaptureCore

@MainActor
final class UpdateService {
    private var controller: SPUStandardUpdaterController?
    private var observation: NSKeyValueObservation?
    var onChange: (() -> Void)?
    private(set) var statusText = "업데이트 배포 주소와 서명 키가 아직 설정되지 않았습니다."
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
            statusText = "업데이트 초기화에 실패했습니다. 배포 설정을 확인하세요. (오류 \((error as NSError).code))"
            onChange?()
            return
        }
        controller = instance
        observation = instance.updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in self?.onChange?() }
        }
        statusText = "서명된 업데이트를 확인합니다. 설치 전 확인 창이 표시됩니다."
        onChange?()
    }
    func checkForUpdates() {
        guard let controller else {
            let alert = NSAlert()
            alert.messageText = "업데이트 서버가 준비되지 않았습니다"
            alert.informativeText = statusText
            alert.runModal()
            return
        }
        controller.checkForUpdates(nil)
    }
}
