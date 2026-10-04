# ShotClip product plan

[Documentation](README.md) · [Development plan](development-plan.md) · [Design system](design-system.md) · [한국어](#한국어)

Decision date: 2026-10-05. This is the approved direction, not a claim that the proposed release has passed runtime QA.

## Product and audience

ShotClip is a small macOS menu bar utility for people who repeatedly paste selected screen regions into another app. Its promise is **select a region, copy the image, paste with ⌘V**. Fixed Region reuses a selection during the current session; Drag Region selects a new region on release. Each capture stays within one display.

macOS already supports copying screenshots to the clipboard. ShotClip adds a consistent copy-first workflow and a reusable region. See [Apple’s screenshot guide](https://support.apple.com/guide/mac-help/take-a-screenshot-mh26782/mac).

## Essential journey

1. Open ShotClip. A compact welcome explains capture-to-clipboard without automatically prompting for access.
2. Choose Fixed Region or Drag Region from the menu bar or press the configurable shortcut (default `⌃⇧⌘5`).
3. If access is unavailable, explain why Screen Recording is needed and let the person request it. Offer System Settings, recheck, and restart as recovery actions.
4. Adjust a valid region. Confirm Fixed Region with Capture or Return; release a valid drag to capture. Escape cancels.
5. Capture and encode PNG/TIFF in memory, then commit to the clipboard. Report success only after a successful write, dismiss the overlay, and return to the previous app.
6. The person presses `⌘V` in an image-capable destination; Preview can use `⌘N`. ShotClip sends no keystrokes to other apps.

Cancellation, denial, capture failure, and encoding failure leave the clipboard untouched. Clipboard replacement uses a snapshot and guarded recovery, but `NSPasteboard` offers no atomic replacement guarantee; write/rollback failures remain visible. See [architecture](architecture.md).

## Scope and success

| In scope | Acceptance signal |
| --- | --- |
| Two region modes, global shortcut, session-only region reuse | R01–R03, R07, R10; logic checks plus user-owned capture QA |
| Immediate PNG/TIFF copy and clear success/failure | R04–R05, R08–R09; user checks image paste and cancellation |
| Native settings, progressive permissions, keyboard operation | R06, R12, R14; accessible labels/focus and both language layouts |
| English default, explicit English / 한국어 setting | R15; persistence, complete copy, fallback, and layout checks |
| ShotClip identity and selected legacy preference migration | R16; new bundle/executable/path, existing preferences respected |
| GitHub preview with verified signed updates | R13, R17; ad-hoc limitations disclosed, archive and feed verified |

No cloud, capture history, image storage, OCR, editing, annotations, video, scrolling capture, automatic paste, cross-display stitching, or quit-state shortcut launcher. Network access is for update distribution only. Do not log or upload captured images, screen content, clipboard contents, app names, or window titles.

Success is assessed through metadata-only QA: correct region/pixels, no overlay in results, unchanged clipboard before success, recoverable denial/cancellation, and usable keyboard/language flows. No telemetry is required.

## Identity and delivery

| Item | Approved target |
| --- | --- |
| Brand / repository | ShotClip / [kyungseok-lee/shotclip](https://github.com/kyungseok-lee/shotclip) |
| Bundle / executable / installation | `dev.shotclip.app` / `shotclip` / `/Applications/ShotClip.app` |
| Next version | Proposed `0.4.0` (build `5`), subject to verified build metadata |
| Distribution | GitHub ad-hoc developer preview; no Apple developer enrollment required by this plan |
| Update trust | Existing Ed25519 public key and Keychain account `sshot` retained; no private-key export, regeneration, or rotation |

The bundle identity changes from historical `dev.sshot.app` and requires a one-time manual ShotClip install. Preferences migrate selectively; Screen Recording consent cannot. A fresh grant is expected, and later ad-hoc replacements may require another grant. Developer ID/notarization is a separate, rejected route for this release, not a prerequisite for the authorized preview. Publication and actual updates still need evidence; see [update operations](update-operations.md).

## 한국어

ShotClip은 macOS 메뉴 막대에서 영역을 선택하고 이미지를 즉시 클립보드에 복사하는 작은 도구입니다. 고정 영역은 현재 실행 세션에서 재사용하고 드래그 영역은 놓는 즉시 캡처합니다. 사용자가 다른 앱에서 `⌘V`로 붙여 넣으며, 한 번의 선택은 한 화면 안으로 제한합니다.

첫 실행에서는 기능을 설명하고 캡처 요청 시 화면 기록 권한을 단계적으로 안내합니다. 취소·거부·캡처/인코딩 실패 전에는 클립보드를 변경하지 않습니다. 클립보드 쓰기와 복원에는 OS의 원자성 한계가 있으므로 오류를 숨기지 않습니다. 영어가 기본이며 설정에서 **English / 한국어**를 선택하고 재실행 후에도 유지합니다.

브랜드는 ShotClip, 저장소는 `kyungseok-lee/shotclip`, 새 식별자는 `dev.shotclip.app`, 실행 파일은 `shotclip`, 설치 위치는 `/Applications/ShotClip.app`입니다. 다음 버전 `0.4.0`(build `5`)은 제안이며 검증 완료를 뜻하지 않습니다. 기존 설정은 허용된 항목만 이전하고 화면 기록 권한은 새로 허용해야 합니다.

GitHub ad-hoc 개발자 프리뷰 배포가 승인되었고 Developer ID/공증은 이번 범위에서 제외합니다. 기존 Keychain `sshot` 계정과 Ed25519 공개키는 유지하며 키를 내보내거나 재생성하지 않습니다. 캡처 GUI 테스트는 사용자가 맡고 클라우드·저장·OCR로 범위를 넓히지 않습니다.
