# Shot Clip requirements and acceptance criteria

[Product plan](product-plan.md) · [Development trace](development-plan.md) · [Verification](verification.md) · [한국어](#한국어)

Updated 2026-10-05. The approved scope is local capture-to-clipboard with two region modes. Acceptance criteria below are requirements, not completed QA.

| ID | Requirement | Acceptance criteria |
| --- | --- | --- |
| R01 | Configurable global shortcut | While Shot Clip runs, opens the remembered mode from another app; only that menu row displays the actual configured shortcut; preserves valid saved mode/shortcut, reports conflict and restores the previous binding on failure |
| R02 | Fixed Region | Move/resize; Capture or Return confirms; reuses last valid region within the session and clamps it to the display |
| R03 | Capture Area (Drag Region) | First capture action and fresh-user default; starts with no selected rectangle; press → drag → release captures a valid region immediately; reverse directions normalize; invalid/zero selection does not capture |
| R04 | Immediate image copy | Encodes PNG/TIFF in memory and commits to NSPasteboard; success feedback only after write; no extra thumbnail/copy step |
| R05 | Normal paste | Person presses ⌘V in an image-capable destination; no automatic keystroke injection; Preview ⌘N is documented |
| R06 | Progressive permission and recovery | Capture menu actions remain enabled and lead to explicit access setup when permission is missing; unavailable/revoked access blocks actual capture/write; one primary action and brief recovery, with location/restart/diagnostics in collapsed troubleshooting; no launch-time system permission prompt |
| R07 | Display/pixel accuracy | One selection stays within its starting display; negative origins and mixed scales map correctly; independent selections on other displays; no stitching |
| R08 | Exclude capture UI | Result contains no Shot Clip overlay, handles, buttons, or cursor |
| R09 | Safe cancellation/failure | Escape, invalid region, denial, capture/encoding failure leave clipboard untouched; snapshot before replacement, guarded rollback on write failure, explicit rollback error and OS limits |
| R10 | Single-flight capture | Repeated shortcut brings selecting UI forward or ignores processing; no duplicate overlay/write; cancelled/timeout results cannot commit later |
| R11 | Local privacy | No capture storage/upload; no images, screen content, app names, window titles, or clipboard contents in diagnostics/repo; temporary buffers released |
| R12 | Operation/accessibility | Menu bar actions; Return/Escape/arrows/Option resize; M mode switch; Tab/Shift-Tab native focus; accessible labels and visible focus; recover after error/screen change/sleep |
| R13 | Signed updates | Canonical GitHub HTTPS feed and tag archive; fail closed on invalid configuration/signatures; Ed25519 archive **and feed** verification retained; automatic checks default OFF; actual upgrades separately tested |
| R14 | Native Shot Clip presentation | Visible Shot Clip name; Capture Area first/Fixed Region second native menu; compact General/Access/Updates with grouped preferences and a capture card; first 0.5 setup shown once/subsequent launches quiet/Finder reopen opens settings; crop-plus-copy-sheet icon and matching template menu glyph, complete 16–1024 px ICNS; compact selection toolbar/dimensions; readable English/Korean light/dark layouts |
| R15 | English default and Korean choice | Fresh/migrated install defaults English; explicit English / 한국어 setting persists; restart applies to app-owned text/labels; missing keys fall back safely; system/Sparkle language behavior distinguished |
| R16 | Stable identity and display/path migration | Bundle dev.shotclip.app, executable shotclip, canonical /Applications/Shot Clip.app; existing ShotClip.app retained until new app verifies, then recoverably backed up; fail closed on wrong IDs/symlinks with rollback of all prior paths; valid settings and existing Ed25519 key retained; no wholesale domain/TCC/login/key migration |
| R17 | GitHub ad-hoc developer preview | Approved no-enrollment route; clearly unnotarized/ad-hoc; source/tag/artifact and uploaded assets checked; first-launch/regrant limitations documented; superseded release artifacts removed only after latest publication/installation verification, preserving Git source/tag history; no production/Gatekeeper PASS claim without evidence |

Default shortcut is `⌃⇧⌘5`; first direct launch is required and the shortcut does not run after quit. New users default to Capture Area (drag); existing valid mode/shortcut preferences win. Login start is opt-in. The default Fixed Region is 400×300 points clamped to the display. Region geometry remains session-only; mode/shortcut/language are settings, not stored captures.

The approved display/interaction refresh targets `0.5.0` (build `7`); confirm sealed metadata before release. R14 replaces the photo/landscape metaphor with crop and copy. R16 retains the identity established by ShotClip 0.4.x while changing only its visible name and canonical app folder. The repo/package/executable/resource-bundle names and Keychain `sshot` account remain compatibility anchors. Stock Sparkle may update the old host folder in place; the canonical rename uses one manual installation, without an automatic-rename claim. Requirements are not QA; see [results](qa-results.md) and [handoff](handoff.md).

## Excluded scope

Cloud, history, image storage, OCR, editing, annotations, full-screen/window/scroll/video capture, automatic paste, multi-display composition, and quit-state cold launch. No Accessibility or Full Disk Access permission requirement for product use.

## 한국어

MVP는 전역 단축키 → 고정/드래그 영역 → 캡처 → 즉시 클립보드 → 사용자 ⌘V 흐름입니다. R01–R12는 기본 기능·권한·좌표·안전·접근성, R13은 feed/archive 서명 업데이트, R14는 작은 크기에서도 구분되는 아이콘·합성 브랜드 이미지와 Shot Clip native 표현, R15는 영어 기본/한국어 선택, R16은 새 식별자와 선택적 설정 이전, R17은 GitHub ad-hoc 개발자 프리뷰를 정의합니다.

`0.5.0`(build `7`)은 표시 이름 Shot Clip과 간결한 native 메뉴/설정/아이콘을 목표로 기존 식별자·설정·키를 유지합니다. 신규 기본 모드는 드래그이고 기존 유효한 모드/단축키는 보존합니다. 새 `/Applications/Shot Clip.app` 검증 후 기존 `ShotClip.app`을 복구 가능한 백업으로 옮기며 자동 업데이트의 폴더 이름 변경은 보장하지 않습니다. 실제 배포·GUI 검증 결과는 별도로 기록합니다.

실제 GUI·권한·붙여 넣기 QA는 사용자 담당이고 이 표는 통과 기록이 아닙니다. 과거 `dev.sshot.app`에서 전환할 때만 유효한 단축키/모드와 새 값 우선 정책으로 이전하고 화면 기록을 새로 허용합니다. 같은 `dev.shotclip.app`의 0.4.x→0.5는 설정을 그대로 사용하며 강제 권한 재설정은 없고 ad-hoc 교체 후 재허용이 필요할 수 있습니다. 기존 Ed25519 키와 `sshot` Keychain 계정은 유지하며 저장·클라우드·OCR 등은 제외합니다.
