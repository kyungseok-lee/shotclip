import AppKit
import Darwin

#if SHOTCLIP_QA
// A QA build has no normal startup route, even if local software supplies argv.
// Only an explicitly selected fixture can reach its isolated development code.
if CommandLine.arguments.contains("--ui-preview") {
    MainActor.assumeIsolated { UIPreview.run() }
}
if CommandLine.arguments.contains("--localization-self-test") { L10n.runDiagnostic() }
guard CommandLine.arguments.contains("--self-test") else {
    fputs("Select an explicit Shot Clip QA route.\n", stderr)
    exit(64)
}
#else
// Reject retired flags before resources, preferences, AppDelegate, hotkeys,
// updater, AppKit initialization or permission APIs.
let retiredFlags: Set<String> = ["--self-test", "--ui-preview", "--localization-self-test",
    "--language", "--appearance", "--updater-only", "--capture-preview-only",
    "--native-save-panel", "--native-menu", "--settings-only",
    "--native-save-manual", "--native-save-error-ui", "--display-index"]
if CommandLine.arguments.dropFirst().contains(where: { retiredFlags.contains($0.components(separatedBy: "=")[0]) }) {
    fputs("Development QA arguments are unavailable in this app.\n", stderr)
    exit(64)
}
_ = L10n.bundle
L10n.preparePreferences()
#endif
MainActor.assumeIsolated {
    let application = NSApplication.shared
    let delegate = AppDelegate()
    application.delegate = delegate
    application.setActivationPolicy(.accessory)
    application.run()
}
