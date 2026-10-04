# ShotClip requirements and acceptance criteria

[Product plan](product-plan.md) · [Development trace](development-plan.md) · [Verification](verification.md) · [한국어](#한국어)

Updated 2026-10-05. The approved scope is local capture-to-clipboard with two region modes. Acceptance criteria below are requirements, not completed QA.

| ID | Requirement | Acceptance criteria |
| --- | --- | --- |
| R01 | Configurable global shortcut | While ShotClip runs, opens selection from another app; reports registration conflict, permits change, restores previous binding on failure |
| R02 | Fixed Region | Move/resize; Capture or Return confirms; reuses last valid region within the session and clamps it to the display |
| R03 | Drag Region | Press → drag → release captures a valid region immediately; reverse directions normalize; invalid/zero selection does not capture |
| R04 | Immediate image copy | Encodes PNG/TIFF in memory and commits to NSPasteboard; success feedback only after write; no extra thumbnail/copy step |
| R05 | Normal paste | Person presses ⌘V in an image-capable destination; no automatic keystroke injection; Preview ⌘N is documented |
| R06 | Progressive permission and recovery | Request Screen Recording at capture intent; unavailable/revoked access blocks capture/write; distinguish running from ready, show current app location in recovery, allow request/settings/recheck/restart |
| R07 | Display/pixel accuracy | One selection stays within its starting display; negative origins and mixed scales map correctly; independent selections on other displays; no stitching |
| R08 | Exclude capture UI | Result contains no ShotClip overlay, handles, buttons, or cursor |
| R09 | Safe cancellation/failure | Escape, invalid region, denial, capture/encoding failure leave clipboard untouched; snapshot before replacement, guarded rollback on write failure, explicit rollback error and OS limits |
| R10 | Single-flight capture | Repeated shortcut brings selecting UI forward or ignores processing; no duplicate overlay/write; cancelled/timeout results cannot commit later |
| R11 | Local privacy | No capture storage/upload; no images, screen content, app names, window titles, or clipboard contents in diagnostics/repo; temporary buffers released |
| R12 | Operation/accessibility | Menu bar actions; Return/Escape/arrows/Option resize; M mode switch; Tab/Shift-Tab native focus; accessible labels and visible focus; recover after error/screen change/sleep |
| R13 | Signed updates | Canonical GitHub HTTPS feed and tag archive; fail closed on invalid configuration/signatures; Ed25519 archive **and feed** verification retained; automatic checks default OFF; actual upgrades separately tested |
| R14 | Native ShotClip presentation | ShotClip display name/icon/settings; semantic AppKit tokens; General/Permissions/Updates; readable English/Korean copy at minimum size and appearance/accessibility variations |
| R15 | English default and Korean choice | Fresh/migrated install defaults English; explicit English / 한국어 setting persists; restart applies to app-owned text/labels; missing keys fall back safely; system/Sparkle language behavior distinguished |
| R16 | New identity and selected migration | Bundle dev.shotclip.app, executable shotclip, /Applications/ShotClip.app; valid legacy shortcut/mode migrate once, existing new values win; no wholesale domain/TCC/login/key migration; fresh grant explained |
| R17 | GitHub ad-hoc developer preview | Approved no-enrollment route; clearly unnotarized/ad-hoc; source/tag/artifact and uploaded assets checked; first-launch/regrant limitations documented; no production/Gatekeeper PASS claim without evidence |

Default shortcut is `⌃⇧⌘5`; first direct launch is required and the shortcut does not run after quit. Login start is opt-in. The default Fixed Region is 400×300 points clamped to the display. Region geometry remains session-only; mode/shortcut/language are settings, not stored captures.

R14 supersedes the historical Sshot branding requirement. R16 deliberately replaces the old “keep dev.sshot.app / executable / installation path” decision. Existing Ed25519 trust remains unchanged: Keychain account `sshot` is a compatibility anchor, not branding to rotate or export. Proposed release is `0.4.0` (build `5`); confirm sealed metadata before release.

## Excluded scope

Cloud, history, image storage, OCR, editing, annotations, full-screen/window/scroll/video capture, automatic paste, multi-display composition, and quit-state cold launch. No Accessibility or Full Disk Access permission requirement for product use.

## 한국어

MVP는 전역 단축키 → 고정/드래그 영역 → 캡처 → 즉시 클립보드 → 사용자 ⌘V 흐름입니다. R01–R12는 기본 기능·권한·좌표·안전·접근성, R13은 feed/archive 서명 업데이트, R14는 ShotClip native 표현, R15는 영어 기본/한국어 선택, R16은 새 식별자와 선택적 설정 이전, R17은 GitHub ad-hoc 개발자 프리뷰를 정의합니다.

실제 GUI·권한·붙여 넣기 QA는 사용자 담당이고 이 표는 통과 기록이 아닙니다. 기존 단축키/모드만 유효성·새 값 우선 정책으로 이전하고 화면 기록은 새로 허용합니다. 기존 Ed25519 키와 `sshot` Keychain 계정은 유지하며 저장·클라우드·OCR 등은 제외합니다.
