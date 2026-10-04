# Shot Clip architecture and decisions

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
| Update dialog presentation (0.6) | One retained public `SPUUserDriver`; live labels, state and one-shot callbacks; `Sources/shotclip/LocalizedUpdateDriver.swift`, en/ko `Updates.strings`; inert fixtures in `Sources/shotclip/UpdatePreview.swift` |
| QA fixture | Opt-in synthetic screen and metadata-only test; `Sources/shotclip/SelfTest.swift`, `Sources/shotclip-fixture/main.swift` |

Localization and allowlisted migration have testable seams in `Sources/CaptureCore/Localization.swift` and `Preferences.swift`; bilingual tables belong under `Sources/shotclip/Resources`.

## State, capture, and clipboard

`idle → selecting → processing → idle`. Check access before selecting. Reentry activates the same selection or ignores processing. A session token rejects late results after cancellation/timeout/new sessions. A 12-second timeout, display reconfiguration, or sleep cancels the session; immediate cancellation of the OS capture operation is not guaranteed.

Normalize/clamp to the starting display. Convert global AppKit coordinates using `x = rect.minX - screen.minX`, `y = screen.maxY - rect.maxY`; output uses the relevant display scale and outward pixel rounding. Do not assume array order identifies the active display. No cross-display image composition.

Exclude the app with `SCContentFilter` and set `showsCursor = false`. Hide the normal overlay before capture; the synthetic harness can test exclusion with a visible colored overlay. Real pixel/exclusion checks remain user-owned.

Encode before touching the clipboard. Snapshot all existing item/type data (limits: 64 MiB total, 128 items, 64 types per item); unreadable data or a changed generation aborts before clear. Guard commit/recovery with `changeCount` and never overwrite an observed external change. `NSPasteboard` has no atomic replace/compare-and-swap: final races, system writes, and rollback failures prevent an unconditional preservation guarantee. Report write/rollback errors distinctly.

## Identity, permission, and privacy

Display name Shot Clip; unchanged bundle `dev.shotclip.app`, executable `shotclip`; canonical installation `/Applications/Shot Clip.app`. The installer verifies the new app before recoverably backing up prior `ShotClip.app` and historical `sshot.app`, with rollback of all paths. The 0.4.x domain/settings/key remain; only historical `dev.sshot.app` needs selected validated-default migration. No whole-domain, Screen Recording, login or trust migration. Ad-hoc replacement may need regrant; no TCC reset/DB editing or bypass. Stock Sparkle may retain its old host path; canonical folder migration is manual.

English defaults; selecting saved `en` / `ko` immediately replaces the lock-protected explicit `AppLocalization` snapshot and posts a synchronous language notification for app-owned surfaces. Persist the choice for subsequent launches; preserve current pane, region and state during relabeling. Use native semantic tokens and labeled status/recovery, with M for mode and native Tab focus. The app-owned Updates pane participates in live refresh. A supported public Sparkle `SPUUserDriver` implements all 16 required callbacks and optional focus. `UpdateService` constructs one `SPUUpdater(hostBundle:applicationBundle:userDriver:delegate:)`, retains the driver and never resets services for language changes. New/visible native dialogs retain replies, progress, controls, focus and unchanged note selection/scroll. Both Updates tables are cached before installation; bounded plain UTF-8 notes and explicit credential-free HTTPS links avoid active HTML or untrusted signing-failure content. Synthetic callbacks are approved source evidence, not real appcast/download/install/relaunch evidence. No framework patch or private API is used. macOS permission/security prompts follow OS language. Permission-related restart guidance remains independent.

Images remain in memory, with no storage/upload. Do not log capture/screen/clipboard content, observed app names, or window titles. Diagnostics/harness may report safe case IDs, state, error codes, dimensions, or sample-match booleans. Exposing Shot Clip’s own path in a recovery view does not authorize logging it.

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
| D10 | Sparkle, canonical HTTPS, existing Ed25519 archive/feed signing | One public updater/retained localized driver, signed feed/pre-extraction verification and automatic defaults OFF; public archive/feed verified; actual manual no-update/live-dialog runtime observed; newer-build upgrade remains unrun |
| D11 | Capture-first NSMenu with native shortcut column; reference-style native settings; existing crop-copy icon | Source APPROVE and corrected integrated geometry/dispatch fixtures; actual inert native popup display observed, selected actions unverified; Carbon/focus/capture separate |
| D12 | Stable Shot Clip identity with verified folder/display rename | Approved 0.5; same-ID settings/key retained, historical allowlist migration retained; signed fixture rollback/identity checks required |
| D13 | English default; mutable explicit en/ko lookup and synchronous app-owned refresh | 159 app + 57 Updates keys per language, fallback/live-core and retained-state fixtures PASS; next-launch preference logic tested; normal runtime and macOS prompts separate |
| D14 | Source/tag/artifact alignment and explicit preview disclosure | Approved preview route; no key export/rotation, no fabricated release QA |

Apple primary references: [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager), [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter), [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard), [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen), and native guidance in the [design system](design-system.md). API availability is checked against the installed SDK; a link alone is not runtime evidence.

## 한국어

SwiftPM/AppKit 메뉴 막대 앱이며 ScreenCaptureKit으로 한 화면의 영역만 캡처합니다. 상태는 idle → selecting → processing → idle이고 세션 토큰·timeout으로 늦은 결과와 중복 쓰기를 막습니다. PNG/TIFF 인코딩과 전체 클립보드 snapshot 이후에만 교체하며 외부 변경을 보호합니다. OS 원자성·복원 실패 한계는 공개합니다.

표시 이름 Shot Clip과 `/Applications/Shot Clip.app`을 사용하고 `dev.shotclip.app`·기존 설정·키는 유지합니다. 새 앱 검증 후 이전 폴더를 백업하고 실패 시 복원합니다. 과거 Sshot의 다른 ID에서만 유효한 단축키/모드를 이전하며 ad-hoc 교체 후 권한 재허용이 필요할 수 있습니다. TCC는 조작하지 않습니다. 영어 기본/한국어 선택은 명시적 현지화 lookup과 알림으로 앱 소유 문구를 즉시 갱신하고 다음 실행에도 유지합니다. 현재 설정 페이지·선택 영역·상태를 보존하며 하나의 public updater와 유지되는 custom Sparkle driver가 새/열린 업데이트 창을 즉시 갱신하고 16개 필수 callback·선택적 focus·응답/진행률/포커스/노트 선택·스크롤 보존을 합성 검증했습니다. 언어 변경은 서비스 재시작을 하지 않고 프레임워크 수정·private API를 사용하지 않습니다. macOS 권한/보안 창은 OS 언어를 따릅니다. 권한 변경 후 필요한 재시작 안내는 유지합니다. D08은 승인된 ad-hoc 프리뷰로 변경되었고 Developer ID/공증은 이번 배포 조건이 아닙니다. 캡처·클립보드·앱/창 정보는 저장하거나 로그/원격으로 보내지 않습니다.
