# Shot Clip architecture and decisions

[Requirements](requirements.md) · [Design](design-system.md) · [Verification](verification.md)

## Boundaries and source map

| Component | Responsibility / source |
| --- | --- |
| App entry/settings | Menu, shortcut, mode, language and recovery; [AppDelegate](../../Sources/shotclip/AppDelegate.swift), [SettingsWindow](../../Sources/shotclip/SettingsWindow.swift) |
| Coordinator/geometry | One session, cancellation, timeout/late-result rejection and display conversion; [CaptureCore](../../Sources/CaptureCore) |
| Selection overlay | One-display area/fixed region and keyboard/mouse controls; [Overlay](../../Sources/shotclip/Overlay.swift) |
| Capture/clipboard | SCK filter/capture, in-memory PNG/TIFF, guarded snapshot/commit/recovery; [Services](../../Sources/shotclip/Services.swift) |
| Permission presentation | Effective access and signing/path recovery; [PermissionStatus](../../Sources/shotclip/PermissionStatus.swift) |
| Localization/design | Explicit en/ko lookup, semantic metrics, process-local fonts; [Localization](../../Sources/shotclip/Localization.swift), [DesignTokens](../../Sources/shotclip/DesignTokens.swift), [resources](../../Sources/shotclip/Resources) |
| Preview/export | In-memory thumbnail/original window and accepted native PNG save; [CapturePreview](../../Sources/shotclip/CapturePreview.swift) |
| Updates | One Sparkle updater and retained localized public driver; [UpdateService](../../Sources/shotclip/UpdateService.swift), [LocalizedUpdateDriver](../../Sources/shotclip/LocalizedUpdateDriver.swift) |
| Isolated development QA | Explicit QA-only fixture/diagnostic code; [build recipe](qa-plan.md#production-and-isolated-qa-builds); excluded from the published product |

## State, capture, and clipboard

`idle → selecting → processing → idle`. Effective access is checked before selection. Reentry activates the same selection or ignores processing; a session token rejects late results after cancellation, timeout or replacement. A 12-second timeout, screen reconfiguration or sleep cancels the session, without promising immediate cancellation of the OS operation.

Choose the display under the pointer, keep selection within that display, normalize/clamp points, convert global AppKit coordinates with `x = rect.minX − screen.minX` and `y = screen.maxY − rect.maxY`, then apply display scale/outward pixel rounding. No cross-display composition is performed. `SCContentFilter` excludes the app and cursor capture is disabled; actual current-version pixel/UI exclusion remains a user-owned test.

Encode PNG/TIFF before touching the clipboard. Snapshot existing item/type data with bounds of 64 MiB total, 128 items and 64 types per item; unreadable/changed data aborts before clear. Commit/recovery checks `changeCount` and protects observed external changes. `NSPasteboard` has no atomic compare-and-swap/replacement, so final races and rollback failures remain possible and are reported distinctly.

## Identity, permission, and privacy

The product is `dev.shotclip.app` / executable `shotclip`, installed as `/Applications/Shot Clip.app`. Only missing validated shortcut/mode values migrate from the legacy domain; no wholesale defaults, Screen Recording, login or key migration occurs. Ad-hoc replacement may need reapproval; no TCC reset/edit/bypass is implemented. Manual canonical-folder migration is distinct from a Sparkle update of an existing host folder.

App-owned language refresh is synchronous and preserves pane/selection/state. One public `SPUUserDriver` retains callbacks, progress, focus and unchanged release-note selection/scroll through relabeling; macOS security prompts follow OS language. Bounded plain-text notes and credential-free HTTPS links are separate from active HTML. Update traffic distributes releases; capture data is not uploaded.

Captured images stay in memory until dismissal, close or replacement. The preview never reads or rewrites the clipboard. Only native Save PNG acceptance writes original pixels to the chosen file. Diagnostics exclude images, screen/clipboard content, observed app/window names and export paths; displaying the app's own location in Access does not authorize logging it.

## Settings and production boundaries

D17 reserves common bilingual full-text geometry at actual width with fallback-ink-safe line metrics. Same-state/size language changes preserve all structural frames, document extent, scroll and focus; resize/state changes may enlarge dynamic reservations. Minimum-size scrolling is supported.

D18 sets exact integer-zero signed-feed failure expiry, keeps archive/feed authentication, compiles QA entrypoints/hooks only under `SHOTCLIP_QA`, and rejects retired QA argv before normal startup. The separate QA bundle has no normal startup route. Native resources have no generated absolute build fallback. Packaging maps source metadata, uses concise file IDs/no debug data, removes only verified toolchain RPATHs before signing, and gates the complete artifact with negative-tested scanning.

## Decision register

| ID | Adopted decision | Evidence / limit |
| --- | --- | --- |
| D01 | macOS 14+, SwiftPM/AppKit | Current-host compile/runtime; other OS/Intel unverified |
| D02 | SCScreenshotManager | API/source/logic evidence; current-version real pixel/exclusion test unrun |
| D03 | Configurable exclusive global shortcut | Validation/conflict/mapping evidence; native Carbon/input-source scope separate |
| D04 | One-display selections | Geometry tests; real mixed-display/scaling coverage unrun |
| D05 | Pre-encode, snapshot, guarded rollback | Error-injection tests; platform atomicity limits remain |
| D06 | Session-only region, persisted mode/shortcut | No disk region/image history; explicit PNG export is separate |
| D07 | Single flight, timeout/session token | Coordinator cancellation/late-result regressions |
| D08 | Explicit GitHub ad-hoc preview | No Developer ID/notarization claim |
| D09 | Running menu bar process, opt-in login | First launch required; no quit-state launcher |
| D10 | Sparkle 2.10.0, canonical HTTPS and established Ed25519 archive/feed trust | Exact public bytes and actual update evidence; automatic checks fresh OFF |
| D11 | Native ready-only menu, Access recovery, shortcut column and compact controls | Source/synthetic/native bounded proof; full accessibility separate |
| D12 | Stable identity with verified folder migration | Signed temporary installer/rollback and current exact installed payload |
| D13 | English default, explicit mutable en/ko lookup/live refresh | 173 app/57 Updates keys per language; fallback and bounded normal transitions |
| D14 | Reviewed source/tag/artifact alignment and preview disclosure | Independent preparation/public/installed approval; no key export/rotation |
| D15 | Success-only thumbnail/original and explicit PNG export | Historical synthetic/native-save evidence; current actual capture/export unrun |
| D16 | Semantic tokens and process-local Roboto/Noto Sans KR | Font bytes/licenses/cascade/weight and synthetic shaping evidence |
| D17 | Language-invariant full settings geometry | All 139 app-owned structural views in paired fixtures; separate native root/tree evidence |
| D18 | Strict feed expiry, production QA exclusion and artifact path purity | Policy/negative fixtures, retired argv, whole artifact scanner and current delivery |

Primary references: [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager), [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter), [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard), [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen). Availability is checked against the SDK; documentation alone is not runtime proof.
