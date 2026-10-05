# Shot Clip

[한국어](README.ko.md)

![Shot Clip crop-and-copy icon with the message Capture. Copy. Continue.](docs/shotclip/assets/shotclip-hero.png)

A small macOS menu bar app that captures a selected region straight to the clipboard. Select with **Capture Area** or **Fixed Region**, then paste into another app with `⌘V`.

## 2026-10-06 latest release

**Shot Clip 0.8.1 (build 11)** is published and installed: [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.8.1/shotclip-0.8.1.zip) / [release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.1), published 2026-10-06 05:42:17 KST, reviewed source [`3140c27`](https://github.com/kyungseok-lee/shotclip/commit/3140c27629708eecca53ff820066356be7cf443d). **Apple Silicon (arm64) only; ad-hoc signed; NOT notarized.** The existing Sparkle library-validation exception remains a disclosed constraint.

Invalidly signed update feeds never become acceptable through elapsed time; later valid signed feeds remain eligible. Public packaging excludes development QA routes/capture test helper and private developer-home/absolute source/build paths. Isolated development QA remains available. English/Korean settings retain readable Roboto/Noto Sans KR, same-size/state window/forms/reading position and native controls; default content is 720×580 pt, minimum 620×480 pt. Actual state changes/resize may grow shared long-diagnostic height.

Independent candidate, signed public/feed and installed reviews pass. Actual **Sparkle 0.8.0(10)→0.8.1(11)**, exact public payload/security/resources, normal three-pane/latest signed-feed check and General ko→en→ko native root/restored tree pass. Complete per-view geometry is isolated synthetic evidence. Nine non-time preference digests are unchanged; check time changes, existing automatic checks ON is preserved and fresh default remains OFF. [Delivery QA](docs/shotclip/qa-results.md#2026-10-06-081-publication-installation-and-retirement) and [handoff](docs/shotclip/handoff.md#2026-10-06-081-delivery-handoff) record completed prior public retirement/exact generated cleanup and normal cold restart with unchanged payload, plus separate final documentation push.

Real 0.8.1 capture/paste/self-test/native-save/permission-grant/full accessibility and alternate macOS/CPU/account checks were not run; Screen Recording-needed state was observed. Notes fallback is not notes-rendering PASS. Earlier dated current/latest/pending statements below are historical baseline records, superseded by this section. Current canonical 0.8 installations can use Sparkle; historical folder/Sshot migration instructions apply only to those older installations.

Only v0.8.1/six current assets remain public; older download links are retired while source tags/history remain. Exact obsolete/generated outputs are removed, six synthetic representatives and compact QA/native proof kept. The latest canonical app restarts normally without build caches. [Independent delivery review](docs/shotclip/release-review-0.8.1.md) records final scope; documentation B/main push is separately verified after approval.

## 2026-10-06 current security work

**0.8.1 (build 11) is the active candidate; verified public/installed latest remains 0.8.0 (build 10).** The candidate hardens invalid-feed handling, removes production QA execution paths while retaining a separate development QA host, and rejects private developer-home and absolute source/build paths throughout the published app. A later valid signed feed remains eligible. Existing bilingual layout/fonts/native behavior, settings/identity/update keys and privacy limits stay required.

Frozen author core/security/isolated QA and separate sealed production package/native candidate checks pass. Independent approval, new publication and latest installation remain pending. Follow [security requirements](docs/shotclip/requirements.md#2026-10-06-081-security-requirements), [current QA](docs/shotclip/qa-results.md#2026-10-06-081-security-findings-and-candidate-status) and [handoff](docs/shotclip/handoff.md#2026-10-06-081-security-handoff). The 0.8 delivery details below are a historical baseline; they are not 0.8.1 results.

## 2026-10-06 0.8.0 delivered baseline

**Shot Clip 0.8.0 (build 10)** is the latest GitHub developer preview, published 2026-10-06 03:17:40 KST: [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.8.0/shotclip-0.8.0.zip) / [release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.0), from reviewed source [`215bf10`](https://github.com/kyungseok-lee/shotclip/commit/215bf102d87c049e00ec18264a9c1318265f39fe). **Apple Silicon (arm64) only; ad-hoc signed; NOT notarized.**

English/Korean settings keep the same window, navigation, rows, form controls and reading position at the same size/state. Roboto/Noto Sans KR, readable role sizes/line heights and a shared 160 pt form lane reserve full bilingual text without clipping. Default content is 720×580 pt; minimum is 620×480 pt. Long diagnostics may expand the shared layout after a state change or resize.

Candidate checks and independent reproduction passed; exact public assets/feed, a real **Sparkle 0.7.0(9)→0.8.0(10)** upgrade and installed payload/signature/resources were separately verified. Normal General Korean→English→Korean preserves the native root frame and restored accessibility tree; complete per-view geometry belongs to synthetic matrices. Prior public releases/local versions and generated build outputs are deleted, Git source/tags remain, and normal cold restart passes without build caches. See [delivery QA](docs/shotclip/qa-results.md#2026-10-06-080-publication-installation-and-retirement) and [independent delivery review](docs/shotclip/release-review-0.8.0.md).

When Screen Recording is unavailable, choose **Enable Screen Recording…**; ready capture actions appear once access is available. After successful copy, a lower-right thumbnail opens the original at Fit or 100%. **Save…** exports PNG only to a destination you choose. Dismissal, close or save cancellation preserves the clipboard; no automatic capture storage/history is added.

Actual 0.8 capture/paste and capture harness were not run; Screen Recording-needed UI was observed. Full accessibility, macOS 14/Intel and clean-account first launch remain unverified. The tested updater displayed a release-notes fallback; rendered notes are not claimed. Earlier download links are retired; historical source tags and records remain available.

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

Sparkle automatic checks are opt-in and **OFF by default**. The [public signed feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) and 0.8.0 archive were verified on 2026-10-06. This host’s existing automatic-checks ON preference was preserved; OFF is the fresh-install default. Updates retain the existing Ed25519 key and Keychain account `sshot`, with no rotation/export/regeneration. Stock Sparkle may replace an existing `ShotClip.app` in place; install Shot Clip manually once to adopt `Shot Clip.app`. Historical Sshot also needs manual installation and selected shortcut/mode migration; permission/login registration do not migrate. The manual-check-driven same-ID 0.7→0.8 Sparkle upgrade passed on this host; other versions/platforms remain separate coverage.

## Privacy and verification

Capture/encode happens in memory; Shot Clip adds no cloud, capture history, automatic storage, or OCR. Only accepting the **Save…** panel writes the original to your chosen location; closing or cancelling preserves the clipboard. It does not log captured images, screen content, app/window information, or clipboard contents. Cancellation, denial, and capture/encoding failure leave the clipboard unchanged. Clipboard write recovery has OS atomicity limits; failures are reported.

Fast checks and user-owned capture steps are in the [QA plan](docs/shotclip/qa-plan.md). Capture GUI/permission/paste checks have **not** been passed by this documentation work. The opt-in harness uses synthetic content and a unique named pasteboard; SKIP is not PASS.

Read the [product plan](docs/shotclip/product-plan.md), [development plan](docs/shotclip/development-plan.md), [design system](docs/shotclip/design-system.md), and [handoff](docs/shotclip/handoff.md), or browse the [documentation index](docs/shotclip/README.md).
