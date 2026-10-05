# Shot Clip product plan

[Documentation](README.md) · [Development plan](development-plan.md) · [Design system](design-system.md) · [한국어](#한국어)

## 2026-10-05 0.7.0 release candidate

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

The 0.7 journey remains copy-first: permission-ready capture, successful clipboard commit, optional lower-right thumbnail/original Fit/100%, and PNG only at an explicitly accepted native destination. No automatic capture storage/history/upload or sensitive logs. Release delivery adds reviewed new source/tag, signed public artifacts and verified latest installation; it does not imply unperformed macOS 14/Intel/clean-account or capture/upgrade acceptance. [Current QA](qa-results.md#2026-10-05-070-release-candidate) records each result.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

## Current unreleased UI extension

The eight-item refresh is an implementation/review request, separate from the public/installed 0.6.0(8) release. It adds consistent typography/layout, square navigation/icon presentation, compact update dialogs and a native-style capture toolbar. Four language/appearance fixtures and 36 core tests passed; final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`. Optional original-image preview and **user-selected PNG export** extend the copy-first journey; copying still succeeds before any thumbnail, preview or save interaction. No automatic file saving/history or sensitive logs are introduced. See [requirements R18](requirements.md) and [current QA](qa-results.md#2026-10-05-unreleased-eight-item-ui-refresh).

한국어: 현재 여덟 UI 개선은 미배포 구현/검토 범위입니다. 복사는 미리보기보다 먼저 완료하며 원본 보기와 명시적 PNG 저장을 선택적으로 제공합니다. 자동 저장·이력·민감정보 로그는 만들지 않고 기존 공개/설치 0.6.0과 구분합니다.

Decision date: 2026-10-05. This is the approved direction, not a claim that the proposed release has passed runtime QA.

## Product and audience

Shot Clip is a small macOS menu bar utility for people who repeatedly paste selected screen regions into another app. Its promise is **select a region, copy the image, paste with ⌘V**. Fixed Region reuses a selection during the current session; Drag Region selects a new region on release. Each capture stays within one display.

macOS already supports copying screenshots to the clipboard. Shot Clip adds a consistent copy-first workflow and a reusable region. See [Apple’s screenshot guide](https://support.apple.com/guide/mac-help/take-a-screenshot-mh26782/mac).

## Essential journey

1. Open Shot Clip. The existing first-run setup explains capture-to-clipboard once without a system permission prompt; later launches remain quiet and Finder reopen opens settings.
2. Choose Capture Area (drag) first or Fixed Region from the menu, or press the configurable shortcut (default `⌃⇧⌘5`) for the remembered mode. Fresh users default to drag; existing valid preferences remain.
3. If access is unavailable, the menu hides both unusable capture actions and offers explicit Access setup; the global shortcut also opens that setup. Use one primary recovery action and keep restart/location/diagnostics in collapsed troubleshooting.
4. Adjust a valid region. Confirm Fixed Region with Capture or Return; release a valid drag to capture. Escape cancels.
5. Capture and encode PNG/TIFF in memory, then commit to the clipboard. Only after a successful write, dismiss the overlay, return to the previous app and show a lower-right thumbnail on the capture display.
6. The person presses `⌘V` in an image-capable destination; Preview can use `⌘N`. Clicking the thumbnail opens the original image with Fit/100% and an explicit Save PNG action. Closing without saving keeps the clipboard usable. Shot Clip sends no keystrokes to other apps.

Cancellation, denial, capture failure, and encoding failure leave the clipboard untouched. Clipboard replacement uses a snapshot and guarded recovery, but `NSPasteboard` offers no atomic replacement guarantee; write/rollback failures remain visible. See [architecture](architecture.md).

## Scope and success

| In scope | Acceptance signal |
| --- | --- |
| Two region modes, global shortcut, session-only region reuse | R01–R03, R07, R10; logic checks plus user-owned capture QA |
| Immediate PNG/TIFF copy and clear success/failure | R04–R05, R08–R09; user checks image paste and cancellation |
| Lower-right thumbnail, original-image preview, optional PNG export | R11/R18; original pixels, user-driven save and clipboard retention |
| Reference-style native settings/menu, progressive permissions, keyboard operation | R06, R12, R14; accessible labels/focus and both language layouts |
| English default, explicit English / 한국어 setting | R15; immediate app-owned refresh, persistence, complete copy, fallback, and layout checks |
| Shot Clip display/path with stable identity | R16; unchanged bundle/executable/settings/key, verified manual canonical-folder migration |
| GitHub preview with verified signed updates | R13, R17; ad-hoc limitations disclosed, archive and feed verified |

No cloud, capture history, automatic image storage, OCR, editing, annotations, video, scrolling capture, automatic paste, cross-display stitching, or quit-state shortcut launcher. Network access is for update distribution only. Do not log or upload captured images, screen content, clipboard contents, app names, or window titles.

Success is assessed through metadata-only QA: correct region/pixels, no overlay in results, unchanged clipboard before success, recoverable denial/cancellation, and usable keyboard/language flows. No telemetry is required.

## Native settings and language

Use the supplied reference to guide native window navigation, spacing and aligned preference rows. Keep General, Access and Updates focused on existing capture, shortcut, login, language, permission and update controls. When ready, the menu stays Capture Area first and Fixed Region second; when unavailable it shows explicit Access instead. Mapped shortcuts use the native right-hand column. The unreleased refresh uses process-local Roboto/Noto Sans KR, semantic tokens, square rail/icon geometry, consistent full-text padding, compact content-sized update dialogs and an Apple-reference capture toolbar. The app-owned English / 한국어 choice updates text immediately and persists for the next launch. Preserve the active pane, permission/update state, selected region and unrelated settings during language changes. A permission-related restart may still be required after changing Screen Recording access. A supported custom Sparkle `SPUUserDriver` relabels new and already-visible app-owned update dialogs while retaining callbacks, progress, focus and unchanged release-note selection/scroll. One updater retains signed-feed/archive verification and automatic checks OFF; changing language never recreates the updater. macOS system prompts follow OS language.

## Identity and delivery

| Item | Approved target |
| --- | --- |
| Brand / repository | Shot Clip / [kyungseok-lee/shotclip](https://github.com/kyungseok-lee/shotclip) |
| Bundle / executable / installation | `dev.shotclip.app` / `shotclip` / `/Applications/Shot Clip.app` |
| Current reviewed source | `0.6.0` (build `8`); sealed release/public bytes, exact installation and bounded runtime/cleanup verified; full acceptance remains separate |
| Distribution | GitHub ad-hoc developer preview; no Apple developer enrollment required by this plan |
| Update trust | Existing Ed25519 public key and Keychain account `sshot` retained; no private-key export, regeneration, or rotation |

Shot Clip 0.6 retains the spaced app folder established in 0.5. ShotClip 0.4.x → Shot Clip 0.5 keeps `dev.shotclip.app` and preferences; manual installation adopts the new spaced app folder after verification, retaining recoverable prior copies. Stock Sparkle may keep the old host folder; actual automatic upgrade remains untested. Historical `dev.sshot.app` migration copies only selected valid preferences and needs a fresh grant; ad-hoc replacement can also need reapproval. Developer ID/notarization is outside this preview. Publication and actual updates need separate evidence; see [update operations](update-operations.md).

## 한국어

Shot Clip은 macOS 메뉴 막대에서 영역을 선택하고 이미지를 즉시 클립보드에 복사하는 작은 도구입니다. 고정 영역은 현재 실행 세션에서 재사용하고 드래그 영역은 놓는 즉시 캡처합니다. 사용자가 다른 앱에서 `⌘V`로 붙여 넣으며, 한 번의 선택은 한 화면 안으로 제한합니다.

첫 실행에서는 기능을 설명하고 캡처 요청 시 화면 기록 권한을 단계적으로 안내합니다. 취소·거부·캡처/인코딩 실패 전에는 클립보드를 변경하지 않습니다. 클립보드 쓰기와 복원에는 OS의 원자성 한계가 있으므로 오류를 숨기지 않습니다. 영어가 기본이며 일반 설정에서 **English / 한국어**를 선택하면 앱 소유 메뉴·설정·오버레이 문구가 즉시 바뀌고 재실행 후에도 선택을 유지합니다. 화면 기록 권한 변경 후 필요한 재시작은 언어 전환과 별개입니다. 지원되는 custom Sparkle driver의 새/열린 업데이트 창도 즉시 바꾸며 callback·진행률·포커스·변경되지 않은 릴리스 노트 선택/스크롤을 유지합니다. 언어 변경은 updater를 재생성하지 않고 서명 feed/archive·기본 자동 확인 OFF를 유지합니다. macOS 권한/보안 창은 OS 언어를 따릅니다.

브랜드는 Shot Clip, 저장소는 `kyungseok-lee/shotclip`, 기존 식별자는 `dev.shotclip.app`, 실행 파일은 `shotclip`, 새 설치 위치는 `/Applications/Shot Clip.app`입니다. `0.6.0`(build `8`) 소스 승인은 실제 캡처·접근성·업그레이드 전체 검증을 뜻하지 않습니다. 기존 0.4.x 설정을 유지하고 새 앱 검증 후 기존 폴더를 복구 가능한 백업으로 옮깁니다. 과거 Sshot의 다른 ID에서만 선택 설정을 이전하며 ad-hoc 교체 후 권한 재허용이 필요할 수 있습니다.

GitHub ad-hoc 개발자 프리뷰 배포가 승인되었고 Developer ID/공증은 이번 범위에서 제외합니다. 기존 Keychain `sshot` 계정과 Ed25519 공개키는 유지하며 키를 내보내거나 재생성하지 않습니다. 캡처 GUI 테스트는 사용자가 맡습니다. 성공 후 우측 하단 썸네일을 누르면 원본을 보고 PNG 저장을 선택할 수 있고 닫거나 저장을 취소해도 클립보드는 유지합니다. 자동 저장·캡처 이력·클라우드·OCR은 제공하지 않습니다.
