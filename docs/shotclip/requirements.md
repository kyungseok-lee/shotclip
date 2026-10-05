# Shot Clip requirements and acceptance criteria

[Product plan](product-plan.md) · [Development trace](development-plan.md) · [Verification](verification.md) · [한국어](#한국어)

## 2026-10-05 0.7.0 release requirements

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

R01–R18 remain the acceptance contract. This request activates P6/P7 delivery in addition to P8 UI: independently reviewed new-version source/docs, clean signed artifacts, new commit/tag and remote equality, latest public byte/feed verification, exact latest installation and bounded normal-runtime/upgrade checks. Missing hardware/OS/account environments must be recorded as unverified rather than fabricated PASS. Permission-dependent checks use real system authorization and never bypass TCC. [Current QA](qa-results.md#2026-10-05-070-release-candidate) is the evidence ledger.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

## 2026-10-05 UNRELEASED eight-item UI refresh

This current extension supersedes earlier presentation and no-storage/no-thumbnail wording, while dated settings-polish and release records below retain their original evidence. The source candidate remains **0.6.0 (build 8), development, uncommitted and unreleased**; public/installed source remains `e87e40e…`, with `main` HEAD `f416300…`. No new deployment, commit, push or tag is part of this request. Current four-way layout/font/callback/isolated-preview fixtures and 36 core tests passed; final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`. Requirements are not passes.

| User item | Requirement trace and proof needed |
| --- | --- |
| 1: redundant capture menu actions | R01/R06/R14: omit both unavailable capture actions; explicit Access action and shortcut recovery; production menu/dispatch fixtures |
| 2: oversized update result | R13/R14/R15: 420 pt ordinary notice width, content-measured multiline height; larger notes views and action widths; state/callback/language fixtures |
| 3: popular Google font | R14/R15: bundle Roboto and Noto Sans KR with both OFL licenses; process registration, cascade/weight and packaged font checks |
| 4: padding and long text | R14/R15: actual full text bounds, minimum 12 pt vertical row padding, three-or-more-line content without clipping/overlap at both settings sizes |
| 5: square icons | R14: physical 44×44 pt settings rail controls and preserved square app-icon canvas/artwork audit; native geometry and icon inspection |
| 6: thumbnail/original/save | R04/R09/R11/R18: success-only lower-right thumbnail, original preview, explicit PNG save, isolated-clipboard retention and original-pixel fixtures |
| 7: design system | R14/R15: shared typography, spacing, dimensions, corners and surfaces in `DesignTokens.swift`; English/Korean component contracts |
| 8: native screenshot toolbar | R02/R03/R08/R12/R14: Apple-reference compact material toolbar, supported mode controls, close/Capture; keyboard and synthetic/native checks |

한국어: 여덟 요청을 기존 요구사항과 새 R18에 연결합니다. 권한이 없을 때 의미 없는 캡처 메뉴를 숨기고 권한 메뉴를 제공합니다. 업데이트 창은 내용에 맞춰 줄이며 Google 폰트·여러 줄 여백·정사각형 rail/아이콘·Apple 스타일 도구막대와 성공 후 썸네일/원본/사용자 선택 PNG 저장을 요구합니다. 저장하지 않거나 닫아도 클립보드는 유지하고 자동 저장·캡처 이력은 만들지 않습니다. 기존 날짜별 증거는 보존하며 새 검증·독립 승인·배포를 아직 통과로 표시하지 않습니다.

## 2026-10-05 UNRELEASED settings polish

R14 gains this bounded acceptance extension: configured-ready settings omit redundant guidance; complete nested multiline labels retain at least 12 pt top/bottom padding without clipping or crossing cards, separators or footers at 720×560 and 620×480 pt in both supported languages/appearances. Headings retain available width and one line; permission and login-approval columns use the remaining width beside native controls. R06 retains operational permission/recovery information, R13 retains meaningful unavailable/error states and update trust, and R15 retains same-process language/state behavior.

[Author QA](qa-results.md#2026-10-05-unreleased-settings-polish) includes full-glyph/cell-height, nested-width, padding and overlap checks plus deliberately invalid geometry. These are local unreleased source/fixture results awaiting independent review, not new normal-app or published behavior. Published/installed 0.6.0(8) remains on source `e87e40e…`; a new release requires the [explicit deployment trigger](../../AGENTS.md#최신-배포-요청-규칙).

한국어: R14에 실제 중첩 여러 줄 문구의 위아래 12pt 이상 여백·잘림/겹침 방지·남은 너비 활용 기준을 추가합니다. R06 권한 안내, R13 의미 있는 업데이트 상태와 신뢰, R15 같은 프로세스 언어/상태 보존은 유지합니다. 합성 작성자 검증과 독립 검토·실제 앱·새 배포를 구분하며 기존 요구사항 번호와 배포 기록은 보존합니다.

Updated 2026-10-05. The approved scope is local capture-to-clipboard with two region modes, optional original-image preview and explicit user-selected PNG export. Acceptance criteria below are requirements, not completed QA.

| ID | Requirement | Acceptance criteria |
| --- | --- | --- |
| R01 | Configurable global shortcut | While Shot Clip runs, opens the remembered mode from another app; only that menu row displays the configured shortcut in the native key-equivalent column when the current keyboard layout maps the physical key; preserves valid saved mode/shortcut, reports conflict and restores the previous binding on failure |
| R02 | Fixed Region | Move/resize; Capture or Return confirms; reuses last valid region within the session and clamps it to the display |
| R03 | Capture Area (Drag Region) | First capture action and fresh-user default; starts with no selected rectangle; press → drag → release captures a valid region immediately; reverse directions normalize; invalid/zero selection does not capture |
| R04 | Immediate image copy | Encodes PNG/TIFF in memory and commits to NSPasteboard; success feedback and thumbnail only after write; no preview or save action required to copy |
| R05 | Normal paste | Person presses ⌘V in an image-capable destination; no automatic keystroke injection; Preview ⌘N is documented |
| R06 | Progressive permission and recovery | When access is unavailable, omit unusable Capture Area/Fixed Region menu actions and show an explicit Access setup action; the global shortcut still opens access setup; unavailable/revoked access blocks actual capture/write; one primary action and brief recovery, with location/restart/diagnostics in collapsed troubleshooting; no launch-time system permission prompt |
| R07 | Display/pixel accuracy | One selection stays within its starting display; negative origins and mixed scales map correctly; independent selections on other displays; no stitching |
| R08 | Exclude capture UI | Result contains no Shot Clip overlay, handles, buttons, or cursor |
| R09 | Safe cancellation/failure | Escape, invalid region, denial, capture/encoding failure leave clipboard untouched; snapshot before replacement, guarded rollback on write failure, explicit rollback error and OS limits |
| R10 | Single-flight capture | Repeated shortcut brings selecting UI forward or ignores processing; no duplicate overlay/write; cancelled/timeout results cannot commit later |
| R11 | Local privacy | No automatic capture storage/history or upload; PNG export only after the person accepts a native save panel; no images, screen content, app names, window titles, clipboard contents or chosen export paths in diagnostics/repo; release temporary preview buffers on dismiss/close/replacement |
| R12 | Operation/accessibility | Menu bar actions; Return/Escape/arrows/Option resize; M mode switch; Tab/Shift-Tab native focus; accessible labels and visible focus; recover after error/screen change/sleep |
| R13 | Signed updates | Canonical GitHub HTTPS feed and tag archive; fail closed on invalid configuration/signatures; Ed25519 archive **and feed** verification retained; automatic checks default OFF; actual upgrades separately tested |
| R14 | Native Shot Clip presentation | Visible Shot Clip name; Capture Area first/Fixed Region second native menu when ready, explicit Access when unavailable; reference-style native General/Access/Updates settings, true 44×44 pt icon navigation and aligned multiline preference rows; process-local Roboto with Noto Sans KR cascade; central semantic tokens; content-sized update dialogs; square icon artwork and Apple-reference capture toolbar; first 0.5 setup shown once/subsequent launches quiet/Finder reopen opens settings; crop-plus-copy-sheet icon and matching template menu glyph, complete 16–1024 px ICNS; compact selection toolbar/dimensions; readable English/Korean light/dark layouts |
| R15 | English default and Korean choice | Fresh/migrated install defaults English; explicit English / 한국어 setting persists; selection immediately refreshes app-owned menu/settings/overlay/status/error/accessibility text without restarting, preserving current pane, capture selection and unrelated settings; missing keys fall back safely; supported custom Sparkle driver relabels new/visible app-owned update dialogs with callback evidence; macOS prompts follow OS language |
| R16 | Stable identity and display/path migration | Bundle dev.shotclip.app, executable shotclip, canonical /Applications/Shot Clip.app; existing ShotClip.app retained until new app verifies, then recoverably backed up; fail closed on wrong IDs/symlinks with rollback of all prior paths; valid settings and existing Ed25519 key retained; no wholesale domain/TCC/login/key migration |
| R17 | GitHub ad-hoc developer preview | Approved no-enrollment route; clearly unnotarized/ad-hoc; source/tag/artifact and uploaded assets checked; first-launch/regrant limitations documented; superseded release artifacts removed only after latest publication/installation verification, preserving Git source/tag history; no production/Gatekeeper PASS claim without evidence |
| R18 | Post-capture preview and explicit PNG export | After successful clipboard commit, show a nonactivating thumbnail at the capture display’s lower-right; click opens the same original image with Fit/100% and Save PNG; preserve original pixels on export; dismiss, timeout, preview close, save cancel and save failure never clear or rewrite the clipboard; no automatic file save or history |

Default shortcut is `⌃⇧⌘5`; first direct launch is required and the shortcut does not run after quit. New users default to Capture Area (drag); existing valid mode/shortcut preferences win. Login start is opt-in. The default Fixed Region is 400×300 points clamped to the display. Region geometry remains session-only; mode/shortcut/language are settings, not stored captures.

The published reviewed native settings/menu and live-language source is `0.6.0` (build `8`). Source approval and sealed preparation are recorded separately from actual publication, exact installation, limited normal runtime/cleanup and remaining acceptance checks in [current QA](qa-results.md#2026-10-05-060-publication-installation-and-cleanup). R14 retains the existing crop-and-copy artwork while aligning native controls with the supplied reference. R15 includes implemented new/visible update-dialog relabeling through the supported public Sparkle `SPUUserDriver`, with all 16 required callbacks plus optional focus and synthetic live-relabel/one-shot-reply evidence; macOS permission/security dialogs follow OS language. R16 retains the identity established in ShotClip 0.4.x and the spaced app folder established in 0.5; the earlier display/path migration remains a compatibility contract. The repo/package/executable/resource-bundle names and Keychain `sshot` account remain compatibility anchors. Stock Sparkle may update the old host folder in place; the canonical rename uses one manual installation, without an automatic-rename claim. Requirements are not QA; see [results](qa-results.md) and [handoff](handoff.md).

## Excluded scope

Cloud, capture history, automatic image storage, OCR, editing, annotations, full-screen/window/scroll/video capture, automatic paste, multi-display composition, and quit-state cold launch. No Accessibility or Full Disk Access permission requirement for product use.

## 한국어

MVP는 전역 단축키 → 고정/드래그 영역 → 캡처 → 즉시 클립보드 → 사용자 ⌘V 흐름입니다. R01–R12는 기본 기능·권한·좌표·안전·접근성, R13은 feed/archive 서명 업데이트, R14는 작은 크기에서도 구분되는 아이콘·합성 브랜드 이미지와 Shot Clip native 표현, R15는 영어 기본/한국어 선택, R16은 기존 식별자 유지와 선택적 과거 설정 이전, R17은 GitHub ad-hoc 개발자 프리뷰, R18은 우측 하단 썸네일·원본 보기·사용자 선택 PNG 저장과 클립보드 보존을 정의합니다.

`0.6.0`(build `8`)은 참조 스타일의 native 설정/메뉴와 즉시 언어 전환을 목표로 기존 Shot Clip 이름·아이콘·식별자·설정·키를 유지합니다. 메뉴 단축키는 현재 키보드에서 해석 가능한 경우 native 오른쪽 단축키 열에 표시합니다. English / 한국어를 선택하면 앱 소유 문구를 즉시 갱신하고 재시작 후에도 선택을 유지합니다. 지원되는 public Sparkle driver의 새/열린 업데이트 창도 즉시 갱신하며 16개 필수 callback·선택적 focus·one-shot 응답을 합성 fixture로 검증했고 macOS 권한/보안 창은 OS 언어를 따릅니다. 신규 기본 모드는 드래그이고 기존 유효한 모드/단축키는 보존합니다. 새 `/Applications/Shot Clip.app` 검증 후 기존 `ShotClip.app`을 복구 가능한 백업으로 옮기며 자동 업데이트의 폴더 이름 변경은 보장하지 않습니다. 실제 배포·GUI 검증 결과는 별도로 기록합니다.

실제 GUI·권한·붙여 넣기 QA는 사용자 담당이고 이 표는 통과 기록이 아닙니다. 과거 `dev.sshot.app`에서 전환할 때만 유효한 단축키/모드와 새 값 우선 정책으로 이전하고 화면 기록을 새로 허용합니다. 같은 `dev.shotclip.app`의 0.4.x→0.5는 설정을 그대로 사용하며 강제 권한 재설정은 없고 ad-hoc 교체 후 재허용이 필요할 수 있습니다. 기존 Ed25519 키와 `sshot` Keychain 계정은 유지합니다. 명시적인 PNG 저장만 허용하며 자동 저장·캡처 이력·클라우드·OCR은 제외합니다.
