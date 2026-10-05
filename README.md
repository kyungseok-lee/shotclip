# Shot Clip

[한국어](README.ko.md)

![Shot Clip crop-and-copy icon with the message Capture. Copy. Continue.](docs/shotclip/assets/shotclip-hero.png)

A small macOS menu bar app that captures a selected region straight to the clipboard. Select with **Capture Area** or **Fixed Region**, then paste into another app with `⌘V`.

**Shot Clip 0.6.0 (build 8)** is the latest GitHub developer preview, published 2026-10-05 06:32:14 KST: [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.6.0/shotclip-0.6.0.zip) / [release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.6.0), from reviewed source [`e87e40e`](https://github.com/kyungseok-lee/shotclip/commit/e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d). **Apple Silicon (arm64) only; ad-hoc signed; NOT notarized.**

The published 0.6 presentation uses General / Access / Updates with a 72 pt icon rail and grouped native preference rows. Capture Area stays first; only the remembered mode shows the configured shortcut in the standard right-aligned menu column. English / 한국어 changes immediately, including new and already-visible app-owned update dialogs. The original crop-and-copy icon and synthetic brand illustrations are unchanged; they contain no captured screens.

Independent [source APPROVE](docs/shotclip/qa-review-0.6.0.md), 36 core tests, 159 app + 57 update strings per language and four inert English/Korean light/dark runs (368 synthetic exports) support this release. Six public assets, the signed feed and all 171 installed payload entries were verified. Normal local runtime confirmed immediate Korean→English→Korean labels and a real manual update check; the existing result dialog also changed language live. Superseded 0.5 public assets were removed and 60 local items moved recoverably to Trash after verification. Actual capture, permission grants, paste, VoiceOver, macOS 14/Intel and automatic upgrades remain untested; see [QA results](docs/shotclip/qa-results.md#2026-10-05-060-publication-installation-and-cleanup).

## 0.7.0 release candidate

Current source targets **0.7.0 (build 9)**. The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Publication, the new source commit/tag and installation are still pending; the public ZIP above remains 0.6.0(8), source `e87e40e`. The earlier UI-development [independent approval](docs/shotclip/qa-review-ui-refresh.md) covers 36 core tests,544 synthetic rendered views and a 62-assertion actual native PNG Save gate on its frozen 0.6-development candidate. It is baseline evidence; the 0.7 candidate/version/release assets need separate review and proof. See [current release QA](docs/shotclip/qa-results.md#2026-10-05-070-release-candidate).

The executor finished `.gitignore` hygiene checks:37 intended paths ignored,29 required paths visible and all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Specific transient OMC paths are ignored while shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Related source/release/build/installer inspection reported no additional blocker; the final candidate verdict is recorded separately in `qa-review-0.7.0.md`.

When Screen Recording is unavailable, the menu offers **Enable Screen Recording…** and hides capture actions that would only open setup. The refresh uses bundled **Roboto + Noto Sans KR**, consistent multiline padding, truly square settings navigation buttons, content-sized update notices and an Apple-reference capture toolbar. Existing square crop-and-copy app artwork is preserved.

After successful copy, a thumbnail appears at the capture screen’s lower-right. Click it to view the original at Fit or 100% and choose **Save…** to export PNG. Dismissing the thumbnail, closing the preview, or cancelling save keeps the image in the clipboard. Files are saved only when you choose a destination; no automatic storage or capture history is added. The capture instructions below describe the current source workflow.

## Build and run

Requires macOS 14+, Xcode with the macOS SDK, and Swift 5.9+. Build, installation and normal local startup were verified on macOS 27.0.1 / Xcode 27.0 / Apple Silicon. macOS 14 runtime is untested; the published archive contains no Intel binary.

```sh
git clone https://github.com/kyungseok-lee/shotclip.git
cd shotclip
swift test
bash scripts/build-app.sh
bash scripts/install-app.sh
open '/Applications/Shot Clip.app'
```

The ZIP contains `Shot Clip.app`; install it at `/Applications/Shot Clip.app`. The source installer stages and verifies the new app, installs and verifies that canonical path, then recoverably backs up verified prior `ShotClip.app`/`sshot.app` copies. Quit all copies before installation. This manual folder migration was verified locally; stock Sparkle may retain an existing unspaced host path. Development output is `dist/Shot Clip.app`; `.build/` and `dist/` are ignored.

## Capture and language

1. Open Shot Clip. If access is unavailable, choose **Enable Screen Recording…**; when ready, choose **Capture Area** or **Fixed Region**, or use `⌃⇧⌘5` (configurable) to open the last selection mode. New users default to Capture Area; valid saved modes/shortcuts are retained.
2. Grant **Screen Recording** when you choose to capture. Return to Shot Clip and check again; restart if needed.
3. Move/resize Fixed Region and press Return or Capture. In Drag Region, release a valid drag to capture.
4. Paste with `⌘V` in an image-capable app; Preview can open the clipboard image with `⌘N`.

Escape cancels. Arrows move the region; Shift increases the step; Option+Arrows resizes its upper-right corner. `M` switches modes and Tab/Shift-Tab moves control focus. English is the default; General settings apply **English / 한국어** immediately and remember the choice. Menu, settings, selection controls, app messages and app-owned update dialogs follow it. macOS-owned permission and security prompts follow the OS language. Screen Recording changes may still require a restart; that is separate from changing language.

Each selection stays within one display. Fixed Region is remembered only during the current session; mode and shortcut preferences persist. Shot Clip must be running for the global shortcut to work. Login start is opt-in. No Accessibility or Full Disk Access permission is required.

The 0.5.0 display/path change retains `dev.shotclip.app` and existing settings. A historical Sshot installation had another ID and needs a fresh grant; ad-hoc replacements may also need reapproval. Use `/Applications/Shot Clip.app` consistently after the manual folder migration. Recovery shows the current app location and does not reset TCC. See [Apple’s permission guide](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac).

## Developer preview and updates

An ad-hoc preview may be blocked at first launch. After checking its source, follow Apple’s per-app **Privacy & Security → Open Anyway** flow when available; do not disable Gatekeeper globally. Ed25519 update signatures verify feed/archive integrity and do not replace Apple notarization or grant Screen Recording. See [Apple’s first-launch guidance](https://support.apple.com/en-us/102445) and [update operations](docs/shotclip/update-operations.md).

Sparkle automatic checks are opt-in and **OFF by default**. The [public signed feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) and 0.6.0 archive were verified on 2026-10-05. Updates retain the existing Ed25519 key and Keychain account `sshot`, with no rotation/export/regeneration. Stock Sparkle may replace an existing `ShotClip.app` in place; install Shot Clip manually once to adopt `Shot Clip.app`. Historical Sshot also needs manual installation and selected shortcut/mode migration; permission/login registration do not migrate. A real same-ID automatic upgrade remains untested.

## Privacy and verification

Capture/encode happens in memory; Shot Clip adds no cloud, capture history, automatic storage, or OCR. In the0.7 release candidate, only accepting the **Save…** panel writes the original to your chosen location; closing or cancelling preserves the clipboard. It does not log captured images, screen content, app/window information, or clipboard contents. Cancellation, denial, and capture/encoding failure leave the clipboard unchanged. Clipboard write recovery has OS atomicity limits; failures are reported.

Fast checks and user-owned capture steps are in the [QA plan](docs/shotclip/qa-plan.md). Capture GUI/permission/paste checks have **not** been passed by this documentation work. The opt-in harness uses synthetic content and a unique named pasteboard; SKIP is not PASS.

Read the [product plan](docs/shotclip/product-plan.md), [development plan](docs/shotclip/development-plan.md), [design system](docs/shotclip/design-system.md), and [handoff](docs/shotclip/handoff.md), or browse the [documentation index](docs/shotclip/README.md).
