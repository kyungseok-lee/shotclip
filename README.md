# Shot Clip

[한국어](README.ko.md)

![Shot Clip crop-and-copy icon with the message Capture. Copy. Continue.](docs/shotclip/assets/shotclip-hero.png)

A small macOS menu bar app that captures a selected region straight to the clipboard. Select with **Capture Area** or **Fixed Region**, then paste into another app with `⌘V`.

**Shot Clip 0.5.0 (build 7)** is the latest GitHub developer preview, published 2026-10-05 04:30:38 KST: [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/shotclip-0.5.0.zip) / [release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.5.0), from reviewed source [`3d803a9`](https://github.com/kyungseok-lee/shotclip/commit/3d803a9c45f72c1eb3c7328ca68321e1fdb1d2b4). **Apple Silicon (arm64) only; ad-hoc signed; NOT notarized.**

The published 0.5.0 redesign puts Capture Area first, groups settings into General / Access / Updates, and uses an original crop-and-copy icon. Project artwork is synthetic and contains no captured screens. The superseded 0.4.1 release/assets were removed after new publication and installation checks; source/tag history is retained.

For 0.5.0, six public assets, the signed feed and the exact installed app were verified. English dark-mode settings received limited native inspection; 76 inert English/Korean light/dark previews checked synthetic layouts. Actual capture, permission grants, paste, VoiceOver/native focus and automatic upgrades remain untested; see [QA results](docs/shotclip/qa-results.md#2026-10-05-050-publication-installation-and-cleanup).

**Current development target: 0.6.0 (build 8).** The development update uses a narrow General / Access / Updates icon rail, grouped native preference rows, and the standard menu shortcut column. English / 한국어 changes immediately; app-owned update dialogs are being integrated into the same live language flow. Source, layout and callback checks are recorded separately from release/installation in [current QA](docs/shotclip/qa-results.md#2026-10-05-060-documentation-and-development-checkpoint). A new release has not yet been recorded here. The downloadable 0.5.0 still uses its earlier settings layout and applies language after restart.

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

1. Open Shot Clip, then choose **Capture Area** or **Fixed Region**, or use `⌃⇧⌘5` (configurable) to open the last selection mode. New users default to Capture Area; valid saved modes/shortcuts are retained.
2. Grant **Screen Recording** when you choose to capture. Return to Shot Clip and check again; restart if needed.
3. Move/resize Fixed Region and press Return or Capture. In Drag Region, release a valid drag to capture.
4. Paste with `⌘V` in an image-capable app; Preview can open the clipboard image with `⌘N`.

Escape cancels. Arrows move the region; Shift increases the step; Option+Arrows resizes its upper-right corner. `M` switches modes and Tab/Shift-Tab moves control focus. English is the default; the 0.6 development UI applies **English / 한국어** immediately from General settings and remembers the choice. Menu, settings, selection controls, app messages and app-owned update dialogs follow it. macOS-owned permission and security prompts follow the OS language. Screen Recording changes may still require a restart; that is separate from changing language.

Each selection stays within one display. Fixed Region is remembered only during the current session; mode and shortcut preferences persist. Shot Clip must be running for the global shortcut to work. Login start is opt-in. No Accessibility or Full Disk Access permission is required.

The 0.5.0 display/path change retains `dev.shotclip.app` and existing settings. A historical Sshot installation had another ID and needs a fresh grant; ad-hoc replacements may also need reapproval. Use `/Applications/Shot Clip.app` consistently after the manual folder migration. Recovery shows the current app location and does not reset TCC. See [Apple’s permission guide](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac).

## Developer preview and updates

An ad-hoc preview may be blocked at first launch. After checking its source, follow Apple’s per-app **Privacy & Security → Open Anyway** flow when available; do not disable Gatekeeper globally. Ed25519 update signatures verify feed/archive integrity and do not replace Apple notarization or grant Screen Recording. See [Apple’s first-launch guidance](https://support.apple.com/en-us/102445) and [update operations](docs/shotclip/update-operations.md).

Sparkle automatic checks are opt-in and **OFF by default**. The [public signed feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) and 0.5.0 archive were verified on 2026-10-05. Updates retain the existing Ed25519 key and Keychain account `sshot`, with no rotation/export/regeneration. Stock Sparkle may replace an existing `ShotClip.app` in place; install 0.5.0 manually once to adopt `Shot Clip.app`. Historical Sshot also needs manual installation and selected shortcut/mode migration; permission/login registration do not migrate. A real same-ID automatic upgrade remains untested.

## Privacy and verification

Capture/encode happens in memory; Shot Clip adds no cloud, capture history, storage, or OCR. It does not log captured images, screen content, app/window information, or clipboard contents. Cancellation, denial, and capture/encoding failure leave the clipboard unchanged. Clipboard write recovery has OS atomicity limits; failures are reported.

Fast checks and user-owned capture steps are in the [QA plan](docs/shotclip/qa-plan.md). Capture GUI/permission/paste checks have **not** been passed by this documentation work. The opt-in harness uses synthetic content and a unique named pasteboard; SKIP is not PASS.

Read the [product plan](docs/shotclip/product-plan.md), [development plan](docs/shotclip/development-plan.md), [design system](docs/shotclip/design-system.md), and [handoff](docs/shotclip/handoff.md), or browse the [documentation index](docs/shotclip/README.md).
