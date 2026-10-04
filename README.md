# ShotClip

[한국어](README.ko.md)

A small macOS menu bar app that captures a selected region straight to the clipboard. Select with **Fixed Region** or **Drag Region**, then paste into another app with `⌘V`.

The repository is transitioning from Sshot to ShotClip. The next release target is **0.4.0 (build 5)**, a GitHub **ad-hoc developer preview**, without Developer ID signing or notarization. Publication, capture GUI tests, and real updates are separate checks; see [QA results](docs/shotclip/qa-results.md).

## Build and run

Requires macOS 14+, Xcode with the macOS SDK, and Swift 5.9+. The existing recorded build environment is macOS 27.0.1 / Xcode 27.0 / Apple Silicon; macOS 14 and Intel runtime support remain unverified.

```sh
git clone https://github.com/kyungseok-lee/shotclip.git
cd shotclip
swift test
bash scripts/build-app.sh
bash scripts/install-app.sh
open /Applications/ShotClip.app
```

Quit ShotClip before replacing its bundle. The installer verifies the new bundle and preserves an existing installation in a backup directory that it prints. Development output is `dist/ShotClip.app`; `.build/` and `dist/` are ignored.

## Capture and language

1. Open ShotClip, then use the menu bar or `⌃⇧⌘5` (configurable) to open the last selection mode.
2. Grant **Screen Recording** when you choose to capture. Return to ShotClip and check again; restart if needed.
3. Move/resize Fixed Region and press Return or Capture. In Drag Region, release a valid drag to capture.
4. Paste with `⌘V` in an image-capable app; Preview can open the clipboard image with `⌘N`.

Escape cancels. Arrows move the region; Shift increases the step; Option+Arrows resizes its upper-right corner. `M` switches modes and Tab/Shift-Tab moves control focus. English is the default; choose **English / 한국어** in General settings and restart to apply.

Each selection stays within one display. Fixed Region is remembered only during the current session; mode and shortcut preferences persist. ShotClip must be running for the global shortcut to work. Login start is opt-in. No Accessibility or Full Disk Access permission is required.

The new `dev.shotclip.app` identity needs a fresh Screen Recording grant, even if historical Sshot was allowed. Use `/Applications/ShotClip.app` consistently. Ad-hoc replacements may need reapproval; the app shows its current location in permission recovery. It does not reset TCC. See [Apple’s permission guide](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac).

## Developer preview and updates

An ad-hoc preview may be blocked at first launch. After checking its source, follow Apple’s per-app **Privacy & Security → Open Anyway** flow when available; do not disable Gatekeeper globally. Ed25519 update signatures verify feed/archive integrity and do not replace Apple notarization or grant Screen Recording. See [Apple’s first-launch guidance](https://support.apple.com/en-us/102445) and [update operations](docs/shotclip/update-operations.md).

Sparkle automatic checks are OFF by default. Updates use the renamed GitHub repository and the existing Ed25519 key; Keychain account `sshot` is deliberately retained for compatibility. Moving from historical Sshot requires a one-time manual ShotClip install; selected shortcut/mode settings migrate, permission and login registration do not. Actual ShotClip upgrades remain unverified. A feed URL does not prove public assets or an upgrade exist.

## Privacy and verification

Capture/encode happens in memory; ShotClip adds no cloud, capture history, storage, or OCR. It does not log captured images, screen content, app/window information, or clipboard contents. Cancellation, denial, and capture/encoding failure leave the clipboard unchanged. Clipboard write recovery has OS atomicity limits; failures are reported.

Fast checks and user-owned capture steps are in the [QA plan](docs/shotclip/qa-plan.md). Capture GUI/permission/paste checks have **not** been passed by this documentation work. The opt-in harness uses synthetic content and a unique named pasteboard; SKIP is not PASS.

Read the [product plan](docs/shotclip/product-plan.md), [development plan](docs/shotclip/development-plan.md), [design system](docs/shotclip/design-system.md), and [handoff](docs/shotclip/handoff.md), or browse the [documentation index](docs/shotclip/README.md).
