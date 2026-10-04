# ShotClip architecture and decisions

[Design system](design-system.md) · [Development plan](development-plan.md) · [Technical evidence](technical-validation.md) · [한국어](#한국어)

SwiftPM/AppKit menu bar app with ScreenCaptureKit still-image capture on macOS 14+. Actual support and runtime evidence are recorded separately in [QA results](qa-results.md).

## Boundaries and source map

| Component | Responsibility / current source |
| --- | --- |
| App and settings | Menu, shortcut, selection entry, native settings, language and recovery; `Sources/shotclip/AppDelegate.swift`, `SettingsWindow.swift` |
| Capture coordinator | Single session, cancellation, timeout, late-result rejection; `Sources/CaptureCore/Coordinator.swift` |
| Selection overlay | One-display mask/drag, mouse/keyboard controls; `Sources/shotclip/Overlay.swift` |
| Geometry | Global AppKit points → display-local capture rect → output pixels; `Sources/CaptureCore/Geometry.swift` |
| Capture and clipboard | SCK filter/capture, PNG/TIFF encode, snapshot/commit/recovery; `Sources/shotclip/Services.swift` |
| Permissions | Effective access and signing recovery presentation; `Sources/shotclip/PermissionStatus.swift`, `Sources/CaptureCore/PermissionPresentation.swift` |
| Updates | Sparkle and fail-closed feed/key configuration; `Sources/shotclip/UpdateService.swift`, `Sources/CaptureCore/UpdateConfiguration.swift` |
| QA fixture | Opt-in synthetic screen and metadata-only test; `Sources/shotclip/SelfTest.swift`, `Sources/shotclip-fixture/main.swift` |

Localization and allowlisted migration have testable seams in `Sources/CaptureCore/Localization.swift` and `Preferences.swift`; bilingual tables belong under `Sources/shotclip/Resources`.

## State, capture, and clipboard

`idle → selecting → processing → idle`. Check access before selecting. Reentry activates the same selection or ignores processing. A session token rejects late results after cancellation/timeout/new sessions. A 12-second timeout, display reconfiguration, or sleep cancels the session; immediate cancellation of the OS capture operation is not guaranteed.

Normalize/clamp to the starting display. Convert global AppKit coordinates using `x = rect.minX - screen.minX`, `y = screen.maxY - rect.maxY`; output uses the relevant display scale and outward pixel rounding. Do not assume array order identifies the active display. No cross-display image composition.

Exclude the app with `SCContentFilter` and set `showsCursor = false`. Hide the normal overlay before capture; the synthetic harness can test exclusion with a visible colored overlay. Real pixel/exclusion checks remain user-owned.

Encode before touching the clipboard. Snapshot all existing item/type data (limits: 64 MiB total, 128 items, 64 types per item); unreadable data or a changed generation aborts before clear. Guard commit/recovery with `changeCount` and never overwrite an observed external change. `NSPasteboard` has no atomic replace/compare-and-swap: final races, system writes, and rollback failures prevent an unconditional preservation guarantee. Report write/rollback errors distinctly.

## Identity, permission, and privacy

Target bundle `dev.shotclip.app`, executable `shotclip`, installation `/Applications/ShotClip.app`. Migrate only selected validated legacy defaults while preserving new values. Do not migrate Screen Recording consent, entire domains, login registration, or update trust. The new identity expects fresh TCC permission; ad-hoc replacements may need regrant. No TCC reset/DB editing or permission bypass.

English defaults; a saved `en` / `ko` choice applies after restart to app-owned surfaces. Use native semantic tokens and labeled status/recovery, with M for mode and native Tab focus. System Settings/Sparkle-owned language behavior is separate.

Images remain in memory, with no storage/upload. Do not log capture/screen/clipboard content, observed app names, or window titles. Diagnostics/harness may report safe case IDs, state, error codes, dimensions, or sample-match booleans. Exposing ShotClip’s own path in a recovery view does not authorize logging it.

## Decision register

| ID | Adopted decision | Evidence / limit |
| --- | --- | --- |
| D01 | macOS 14+, SwiftPM/AppKit | SDK/current-host compile; macOS 14/Intel runtime unverified |
| D02 | SCScreenshotManager | API probe and implementation; real pixel/exclusion QA pending |
| D03 | Configurable exclusive ⌃⇧⌘5 | Historical registration/conflict/event evidence; current overlay QA pending |
| D04 | Independent one-display selections | Geometry tests; mixed-scale hardware capture pending |
| D05 | Pre-encode, snapshot, guarded rollback | Error-injection tests; platform atomicity limits remain |
| D06 | Session region; persisted mode/shortcut | No image/region storage |
| D07 | Single flight, timeout/session token | Historical coordinator regression evidence |
| D08 | GitHub ad-hoc developer preview | Supersedes Developer ID prerequisite; no notarization claim |
| D09 | Running menu bar process; opt-in login | First launch needed; no quit-state launcher |
| D10 | Sparkle, canonical HTTPS, existing Ed25519 archive/feed signing | Historical local cryptographic QA; new public assets/upgrades unverified |
| D11 | Native settings/icon/semantic tokens | Historical 0.3.0 UI evidence; ShotClip GUI/accessibility checks separate |
| D12 | New ShotClip identity and allowlisted defaults migration | Approved 2026-10-05; fresh TCC regrant and actual migration checks required |
| D13 | English default, explicit Korean, restart applies | Approved 2026-10-05; resource/text/persistence checks required |
| D14 | Source/tag/artifact alignment and explicit preview disclosure | Approved preview route; no key export/rotation, no fabricated release QA |

Apple primary references: [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager), [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter), [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard), [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen), and native guidance in the [design system](design-system.md). API availability is checked against the installed SDK; a link alone is not runtime evidence.

## 한국어

SwiftPM/AppKit 메뉴 막대 앱이며 ScreenCaptureKit으로 한 화면의 영역만 캡처합니다. 상태는 idle → selecting → processing → idle이고 세션 토큰·timeout으로 늦은 결과와 중복 쓰기를 막습니다. PNG/TIFF 인코딩과 전체 클립보드 snapshot 이후에만 교체하며 외부 변경을 보호합니다. OS 원자성·복원 실패 한계는 공개합니다.

새 식별자 `dev.shotclip.app`와 `/Applications/ShotClip.app`을 사용하고 유효한 단축키/모드만 이전합니다. 권한은 새로 허용하며 TCC를 조작하지 않습니다. 영어 기본/한국어 선택은 재시작하여 적용합니다. D08은 승인된 ad-hoc 프리뷰로 변경되었고 Developer ID/공증은 이번 배포 조건이 아닙니다. 캡처·클립보드·앱/창 정보는 저장하거나 로그/원격으로 보내지 않습니다.
