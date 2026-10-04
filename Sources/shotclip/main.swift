import AppKit
if CommandLine.arguments.contains("--localization-self-test") { L10n.runDiagnostic() }
if !CommandLine.arguments.contains("--self-test") { L10n.preparePreferences() }
MainActor.assumeIsolated {
    let application = NSApplication.shared
    let delegate = AppDelegate()
    application.delegate = delegate
    application.setActivationPolicy(.accessory)
    application.run()
}
