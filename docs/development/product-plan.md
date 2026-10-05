# Shot Clip product plan

[Usage](../../README.md) · [Requirements](requirements.md#requirements) · [Design](design-system.md)

## Product and audience

Shot Clip is a small menu bar app for people who repeatedly copy a selected part of the screen into a document, chat or editor. Its main path is **select → copy → paste**. An optional in-memory preview and deliberate PNG save support people who also need a file.

The current public app is **0.8.1 (build 11)**. It requires macOS 14 or later; the published binary is arm64 and ad-hoc signed without Apple notarization. Current-host verification and remaining coverage are recorded in [QA results](qa-results.md#current-evidence). The documentation reorganization introduces no capture feature; the requested new release is tracked separately in the handoff.

## Essential journey

1. Open Shot Clip once. It stays in the menu bar; later launches are quiet and opening it again in Finder shows settings.
2. Press `⌃⇧⌘5` to use the last-used mode, or choose **Capture Area** or **Fixed Region** from the menu. New users start with Capture Area. The app must be running for the global shortcut to work.
3. If Screen Recording access is unavailable, the menu and shortcut open **Access** setup. Request access there, allow Shot Clip in macOS settings, then **Check Again**; restart the app if needed. The app does not request system permission automatically at launch.
4. Drag and release a valid Capture Area, or adjust a Fixed Region and press **Capture** or Return. Escape cancels; `M` switches modes.
5. A successful capture copies PNG/TIFF image data and returns focus to the previous app. Press `⌘V` in a destination that accepts images; Preview can create an image from the clipboard with `⌘N`.
6. A lower-right thumbnail briefly offers the original image. Click it for Fit/100% and **Save…** to export PNG; a file is written only after native save-panel acceptance. Closing, cancelling or starting another capture does not rewrite the clipboard.

The last region is session-only, with a centered 400×300 pt fallback clamped to the selected display. Mode, shortcut and language preferences persist. There is no saved capture history or way to reopen a dismissed image from history.

## Scope and success

| Product behavior | Requirement |
| --- | --- |
| Two region modes, running-process shortcut, one display per selection | R01–R03, R07, R10 |
| Immediate image copy; user-controlled paste; safe cancellation before commit | R04–R05, R08–R09 |
| Progressive Access recovery and native keyboard controls | R06, R12 |
| In-memory original preview and explicit PNG export | R11, R18 |
| Readable native settings with immediate English/Korean refresh | R14–R15 |
| Stable identity and verified signed update distribution | R13, R16–R17 |

Cancellation, denial, capture failure and encoding failure leave the clipboard untouched. Clipboard write failure uses guarded recovery; platform races and rollback failures prevent an unconditional preservation guarantee. No capture upload, automatic file storage, OCR, annotation, image editing, scrolling/video capture, cross-display stitching, automatic paste or quit-state shortcut launcher is included.

## Native settings and language

**General** contains shortcut/mode actions, optional login start and English/Korean selection. **Access** contains effective permission status and recovery, with detailed location/signing advice behind Troubleshooting. **Updates** contains version, manual checks and the automatic-check switch. Fresh automatic checks default OFF; an existing choice is preserved, and automatic download/install is disabled.

Changing language immediately relabels app-owned menus, settings, selection controls and update dialogs while preserving state. macOS permission/security prompts follow the OS language. Settings use the same structural frames at the same state/window size in both languages; long content can scroll at smaller sizes. Bundled fonts register only within the process.

## Identity and delivery

| Item | Current value |
| --- | --- |
| Name / bundle ID / executable | Shot Clip / `dev.shotclip.app` / `shotclip` |
| Canonical app | `/Applications/Shot Clip.app` |
| Public distribution | [0.8.1](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.1), arm64 ad-hoc preview, not notarized |
| Release source | `3140c27629708eecca53ff820066356be7cf443d` |
| Update trust | Canonical HTTPS feed, existing Ed25519 archive/feed key, no invalid-feed timeout fallback |

Legacy identity/folder migration is an installation compatibility boundary, not a product feature or automatic-folder-rename promise. See [update operations](update-operations.md#trust-and-migration-limits). Current support comes from executed evidence, not the requirement list.
