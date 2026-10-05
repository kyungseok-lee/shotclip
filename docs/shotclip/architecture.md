# Shot Clip architecture and decisions

[Design system](design-system.md) · [Development plan](development-plan.md) · [Technical evidence](technical-validation.md) · [한국어](#한국어)

## 2026-10-06 D17 settings geometry

The active candidate is 0.8.0(10), with public/installed 0.7.0(9) as baseline. Earlier dated active/latest/pending statements below are historical snapshots; [current QA](qa-results.md#2026-10-06-080-language-invariant-settings) determines actual delivery state.

| Decision | Implementation boundary / required proof |
| --- | --- |
| D17: shared bilingual settings geometry | R14/R15/P9; settings-only role/line tokens, read-only explicit bilingual alternatives at each assigned width, shared maximum full TextKit/cell/glyph reservation and fixed native form lanes; same-state/size en→ko→en complete frame/document/scroll/focus equality and no clipping |

Language refresh relabels retained native views without changing the window frame, current pane, disclosure or interaction state. Reserving both languages does not change the active localization/preferences. Arbitrary dynamic diagnostic values use the same current value in both alternatives; real state updates or resize may enlarge the shared reservation. Capture/clipboard/preview, one updater, stable identity and Ed25519 trust retain their existing boundaries. The frozen source is exercised by exact paired-frame/text fixtures; current QA records all 139 app-owned structural views per case, including hidden/offscreen inventory. Latest public/install verification precedes deletion of obsolete public/local versions; Git source/tags/key are preserved.

한국어: D17은 R14/R15·P9의 설정 전용 글자/행간·읽기 전용 두 언어 최대 높이·고정 native 폼을 정의합니다. 같은 상태/크기의 전환은 전체 프레임/문서 높이/스크롤/포커스를 유지하고 상태/resize의 긴 진단은 공통 높이로 다시 계산합니다. 캡처/클립보드/업데이트·식별자·키는 보존하며 최신 공개/설치 검증 후 구버전을 삭제합니다.

## 2026-10-05 0.7.0 delivered scope

**Published and installed: Shot Clip 0.7.0 (build 9)**, 2026-10-05 22:06:35 KST (13:06:35Z). The immutable [release/tag](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0), public archive and installed app identify source `53bd5d2ad05375be7a6296da4534815260a38d98`. Normal source/tag push and remote equality passed; all six public redownloads and the canonical latest signed feed equal the independently approved preparation. Actual Sparkle 0.6.0(8)→0.7.0(9) download/extract/Install and Relaunch succeeded, with all 175 installed entries/bytes/links/file and directory modes equal the public ZIP; no manual installer was used. Ad-hoc signed, arm64 only, NOT notarized.

The delivered runtime retains clipboard-first capture, clipboard-independent preview/export, stable `dev.shotclip.app`/`shotclip`/canonical `/Applications/Shot Clip.app`, one public updater and existing Ed25519 trust. The actual signed 0.6→0.7 updater replaced the canonical host and relaunched a new normal process. Full175-entry bytes/link/mode equality proves the installed payload, while real capture permission remains a distinct boundary. No automatic capture persistence or sensitive diagnostics were introduced.

Korean normal runtime confirmed version/latest-feed result and acknowledgment; unavailable capture commands stay hidden and explicit Screen Recording recovery opens Access. Screen Recording is unavailable: candidate and installed capture harnesses report permission-SKIP, with no real capture/general paste/TCC grant/reset. Two native-automation shortcut attempts leave Carbon routing UNVERIFIED, without establishing a product defect. Full accessibility, macOS 14/Intel/clean-account and unprovided hardware/layout coverage remain unverified. The old 0.6 updater used a missing-plain-text notes fallback; notes display is not a passed claim. Nine non-time preference key digests remain equal, only `SULastCheckTime` changed after actual manual update checks, no keys added/removed and no raw values retained.

Recoverable cleanup and a true normal cold restart passed after cache removal: the installed 175-entry tree/signature and 173+57 language diagnostics remain valid; final canonical PID is 80286. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records the bounded removals and retained proof. Earlier snapshots below remain dated context. The [independent delivery verdict](release-review-0.7.0.md) is separate; documentation commits are verified by local/remote Git equality and do not change immutable release/tag/app source A.

한국어: 2026-10-05 22:06:35 KST에0.7.0(build 9)/소스`53bd5d2…`를 최신 공개했습니다. 공개6개 바이트/feed와 실제 Sparkle0.6→0.7 설치/재실행·175개 설치 항목/서명/173+57언어 자료를 확인했으며 수동 설치기는 사용하지 않았습니다. ad-hoc arm64·미공증입니다. 한국어 정상 최신 확인/권한 메뉴→Access를 확인했고 권한 없는 실제 캡처/붙여 넣기는SKIP, 전역 단축키는 자동화 두 시도로 미확정이며 결함 판정이 아닙니다. 전체 접근성/다른 OS·CPU·계정·장비와 이전 updater의 노트 표시는 통과를 주장하지 않습니다. 아홉 비시간 설정 digest는 같고 수동 확인 시각만 바뀌었습니다. 복구 가능한 정리 후 정상 cold restart/PID 80286과 설치 항목·서명·173+57 자료를 재확인했습니다. 과거 기록은 보존하고 독립 배포 판정/별도 문서 commit을 소스A와 구분합니다.

## 2026-10-05 0.7.0 release boundary

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

Architecture and D01–D16 remain unchanged by the version target: the capture transaction commits the clipboard before presentation; preview/export never touches the clipboard and writes only after native `.OK`. Stable `dev.shotclip.app`, executable `shotclip`, canonical `/Applications/Shot Clip.app`, existing Ed25519 trust and one public updater are retained. New artifacts must carry the reviewed 0.7 source commit/build 9; manual installation and an actual Sparkle upgrade have separate evidence. [Current QA](qa-results.md#2026-10-05-070-release-candidate) records permission and runtime boundaries.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

## Unreleased UI and preview boundary

The current refresh extends presentation without changing the capture transaction or update trust. Production menu construction omits unavailable Capture Area/Fixed Region commands and exposes Access. After a successful clipboard commit, the app passes the original `CGImage` and the capture screen’s visible frame to `CapturePreviewController`; a nonactivating panel anchors at lower-right. Thumbnail timeout/close, preview close and replacement release image references. Clicking opens the same original image with Fit/100%; native PNG save encodes that original, then atomically writes only after `.OK`. Save cancel/failure keeps the clipboard and existing preview usable. Four normal language/appearance runs passed 44 production-preview assertions each using synthetic images/private pasteboards; final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`.

A separate Korean-dark native gate passed 62 assertions, including actual Save-button acceptance, cancel, closing/replacing with a pending sheet, original-pixel equality and private pasteboard retention. Unique-ID QA payload preserves the unsigned executable/all resources. Production error-alert UI and the default-button-cell route remain unrun.

한국어: 캡처/클립보드 트랜잭션과 업데이트 신뢰는 유지하고 성공 뒤 원본·캡처 화면 좌표만 미리보기 계층에 전달합니다. 우측 하단 비활성 썸네일과 원본 창은 클립보드를 건드리지 않으며 native 저장 창의 명시적 승인 뒤에만 PNG를 저장합니다. timeout·닫기·새 캡처는 메모리 참조를 해제하고 최종 fixture/독립 검토는 별도입니다.

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
| Preview and export | Clipboard-independent thumbnail/original window and explicit PNG save; `Sources/shotclip/CapturePreview.swift` |
| Design foundations | Process-local bundled Roboto/Noto Sans KR, semantic colors and component metrics; `Sources/shotclip/DesignTokens.swift` |
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

Images remain in memory until preview dismissal, closure or replacement; no automatic storage/history or upload. Only accepting the native Save PNG panel writes the original image to the person’s chosen destination. The presentation layer never reads or writes the clipboard; export does not clear or replace it. Do not log capture/screen/clipboard content, observed app names, or window titles. Diagnostics/harness may report safe case IDs, state, error codes, dimensions, or sample-match booleans. Exposing Shot Clip’s own path in a recovery view does not authorize logging it.

## Decision register

| ID | Adopted decision | Evidence / limit |
| --- | --- | --- |
| D01 | macOS 14+, SwiftPM/AppKit | SDK/current-host compile; macOS 14/Intel runtime unverified |
| D02 | SCScreenshotManager | API probe and implementation; real pixel/exclusion QA pending |
| D03 | Configurable exclusive ⌃⇧⌘5 | Historical registration/conflict/event evidence; current overlay QA pending |
| D04 | Independent one-display selections | Geometry tests; mixed-scale hardware capture pending |
| D05 | Pre-encode, snapshot, guarded rollback | Error-injection tests; platform atomicity limits remain |
| D06 | Session region; persisted mode/shortcut | No automatic image or persisted region storage; explicit PNG export is separate |
| D07 | Single flight, timeout/session token | Historical coordinator regression evidence |
| D08 | GitHub ad-hoc developer preview | Supersedes Developer ID prerequisite; no notarization claim |
| D09 | Running menu bar process; opt-in login | First launch needed; no quit-state launcher |
| D10 | Sparkle, canonical HTTPS, existing Ed25519 archive/feed signing | One public updater/retained localized driver, signed feed/pre-extraction verification and automatic defaults OFF; public archive/feed verified; actual manual no-update/live-dialog runtime observed; newer-build upgrade remains unrun |
| D11 | Ready-only capture NSMenu, explicit Access recovery, native shortcut column; square rail/icon and Apple-reference toolbar; content-sized update dialogs | Earlier 0.6 source APPROVE/fixtures remain historical; current four-way square/full-text/menu/font/updater/toolbar fixtures PASS; independent frozen-scope verdict recorded separately in `qa-review-ui-refresh.md`; native focus/Carbon/capture separate |
| D12 | Stable Shot Clip identity with verified folder/display rename | Approved 0.5; same-ID settings/key retained, historical allowlist migration retained; signed fixture rollback/identity checks required |
| D13 | English default; mutable explicit en/ko lookup and synchronous app-owned refresh | Published0.6 has159 app +57 Updates keys per language; current core/inert diagnostic has173+57/fallback/live transitions and final sealed development resources PASS; independent verdict recorded separately in `qa-review-ui-refresh.md`; next-launch preference logic tested; normal runtime and macOS prompts separate |
| D14 | Source/tag/artifact alignment and explicit preview disclosure | Approved preview route; no key export/rotation, no fabricated release QA |
| D15 | Success-only in-memory thumbnail/original and native explicit PNG export | R04/R09/R11/R18; clipboard-independent presentation, original pixels, cancellation/failure/lifetime checks; 44 assertions in each of four synthetic/private-pasteboard runs PASS; native-sheet and normal-capture evidence separate |
| D16 | Central semantic design tokens and process-local Roboto/Noto Sans KR | R14/R15; official Google OFL artifacts, CoreText process registration, explicit cascade/weight; official bytes/OFL/axes/cascade/weights and four-way renders PASS; final sealed development resources PASS; independent verdict recorded separately in `qa-review-ui-refresh.md` |

Apple primary references: [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager), [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter), [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard), [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen), and native guidance in the [design system](design-system.md). API availability is checked against the installed SDK; a link alone is not runtime evidence.

## 한국어

SwiftPM/AppKit 메뉴 막대 앱이며 ScreenCaptureKit으로 한 화면의 영역만 캡처합니다. 상태는 idle → selecting → processing → idle이고 세션 토큰·timeout으로 늦은 결과와 중복 쓰기를 막습니다. PNG/TIFF 인코딩과 전체 클립보드 snapshot 이후에만 교체하며 외부 변경을 보호합니다. OS 원자성·복원 실패 한계는 공개합니다.

표시 이름 Shot Clip과 `/Applications/Shot Clip.app`을 사용하고 `dev.shotclip.app`·기존 설정·키는 유지합니다. 새 앱 검증 후 이전 폴더를 백업하고 실패 시 복원합니다. 과거 Sshot의 다른 ID에서만 유효한 단축키/모드를 이전하며 ad-hoc 교체 후 권한 재허용이 필요할 수 있습니다. TCC는 조작하지 않습니다. 영어 기본/한국어 선택은 명시적 현지화 lookup과 알림으로 앱 소유 문구를 즉시 갱신하고 다음 실행에도 유지합니다. 현재 설정 페이지·선택 영역·상태를 보존하며 하나의 public updater와 유지되는 custom Sparkle driver가 새/열린 업데이트 창을 즉시 갱신하고 16개 필수 callback·선택적 focus·응답/진행률/포커스/노트 선택·스크롤 보존을 합성 검증했습니다. 언어 변경은 서비스 재시작을 하지 않고 프레임워크 수정·private API를 사용하지 않습니다. macOS 권한/보안 창은 OS 언어를 따릅니다. 권한 변경 후 필요한 재시작 안내는 유지합니다. D08은 승인된 ad-hoc 프리뷰로 변경되었고 Developer ID/공증은 이번 배포 조건이 아닙니다. 캡처·클립보드·앱/창 정보는 자동 저장하거나 로그/원격으로 보내지 않습니다. 성공 후 메모리의 원본을 우측 하단 썸네일/원본 창에 표시하며 사용자가 native PNG 저장 창을 승인한 경우에만 선택한 위치에 저장합니다. 미리보기·취소·닫기·저장 실패는 클립보드를 읽거나 다시 쓰지 않습니다. D15는 이 미리보기/저장 경계, D16은 중앙 토큰과 프로세스 한정 Google 폰트 등록을 정의합니다.
