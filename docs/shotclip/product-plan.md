# Shot Clip product plan

[Documentation](README.md) · [Development plan](development-plan.md) · [Design system](design-system.md) · [한국어](#한국어)

Decision date: 2026-10-05. This is the approved direction, not a claim that the proposed release has passed runtime QA.

## Product and audience

Shot Clip is a small macOS menu bar utility for people who repeatedly paste selected screen regions into another app. Its promise is **select a region, copy the image, paste with ⌘V**. Fixed Region reuses a selection during the current session; Drag Region selects a new region on release. Each capture stays within one display.

macOS already supports copying screenshots to the clipboard. Shot Clip adds a consistent copy-first workflow and a reusable region. See [Apple’s screenshot guide](https://support.apple.com/guide/mac-help/take-a-screenshot-mh26782/mac).

## Essential journey

1. Open Shot Clip. The existing first-run setup explains capture-to-clipboard once without a system permission prompt; later launches remain quiet and Finder reopen opens settings.
2. Choose Capture Area (drag) first or Fixed Region from the menu, or press the configurable shortcut (default `⌃⇧⌘5`) for the remembered mode. Fresh users default to drag; existing valid preferences remain.
3. If access is unavailable, capture intent opens explicit Access setup. Use one primary recovery action and keep restart/location/diagnostics in collapsed troubleshooting.
4. Adjust a valid region. Confirm Fixed Region with Capture or Return; release a valid drag to capture. Escape cancels.
5. Capture and encode PNG/TIFF in memory, then commit to the clipboard. Report success only after a successful write, dismiss the overlay, and return to the previous app.
6. The person presses `⌘V` in an image-capable destination; Preview can use `⌘N`. Shot Clip sends no keystrokes to other apps.

Cancellation, denial, capture failure, and encoding failure leave the clipboard untouched. Clipboard replacement uses a snapshot and guarded recovery, but `NSPasteboard` offers no atomic replacement guarantee; write/rollback failures remain visible. See [architecture](architecture.md).

## Scope and success

| In scope | Acceptance signal |
| --- | --- |
| Two region modes, global shortcut, session-only region reuse | R01–R03, R07, R10; logic checks plus user-owned capture QA |
| Immediate PNG/TIFF copy and clear success/failure | R04–R05, R08–R09; user checks image paste and cancellation |
| Reference-style native settings/menu, progressive permissions, keyboard operation | R06, R12, R14; accessible labels/focus and both language layouts |
| English default, explicit English / 한국어 setting | R15; immediate app-owned refresh, persistence, complete copy, fallback, and layout checks |
| Shot Clip display/path with stable identity | R16; unchanged bundle/executable/settings/key, verified manual canonical-folder migration |
| GitHub preview with verified signed updates | R13, R17; ad-hoc limitations disclosed, archive and feed verified |

No cloud, capture history, image storage, OCR, editing, annotations, video, scrolling capture, automatic paste, cross-display stitching, or quit-state shortcut launcher. Network access is for update distribution only. Do not log or upload captured images, screen content, clipboard contents, app names, or window titles.

Success is assessed through metadata-only QA: correct region/pixels, no overlay in results, unchanged clipboard before success, recoverable denial/cancellation, and usable keyboard/language flows. No telemetry is required.

## Native settings and language

Use the supplied reference to guide native window navigation, spacing and aligned preference rows. Keep General, Access and Updates focused on existing capture, shortcut, login, language, permission and update controls. The menu stays Capture Area first and Fixed Region second; mapped shortcuts use the native right-hand column. The app-owned English / 한국어 choice updates text immediately and persists for the next launch. Preserve the active pane, permission/update state, selected region and unrelated settings during language changes. A permission-related restart may still be required after changing Screen Recording access. New/visible app-owned update dialogs are planned to participate through a supported custom Sparkle driver; macOS system prompts follow OS language.

## Identity and delivery

| Item | Approved target |
| --- | --- |
| Brand / repository | Shot Clip / [kyungseok-lee/shotclip](https://github.com/kyungseok-lee/shotclip) |
| Bundle / executable / installation | `dev.shotclip.app` / `shotclip` / `/Applications/Shot Clip.app` |
| Next version | Target `0.6.0` (build `8`), subject to verified build metadata |
| Distribution | GitHub ad-hoc developer preview; no Apple developer enrollment required by this plan |
| Update trust | Existing Ed25519 public key and Keychain account `sshot` retained; no private-key export, regeneration, or rotation |

Shot Clip 0.6 retains the spaced app folder established in 0.5. ShotClip 0.4.x → Shot Clip 0.5 keeps `dev.shotclip.app` and preferences; manual installation adopts the new spaced app folder after verification, retaining recoverable prior copies. Stock Sparkle may keep the old host folder; actual automatic upgrade remains untested. Historical `dev.sshot.app` migration copies only selected valid preferences and needs a fresh grant; ad-hoc replacement can also need reapproval. Developer ID/notarization is outside this preview. Publication and actual updates need separate evidence; see [update operations](update-operations.md).

## 한국어

Shot Clip은 macOS 메뉴 막대에서 영역을 선택하고 이미지를 즉시 클립보드에 복사하는 작은 도구입니다. 고정 영역은 현재 실행 세션에서 재사용하고 드래그 영역은 놓는 즉시 캡처합니다. 사용자가 다른 앱에서 `⌘V`로 붙여 넣으며, 한 번의 선택은 한 화면 안으로 제한합니다.

첫 실행에서는 기능을 설명하고 캡처 요청 시 화면 기록 권한을 단계적으로 안내합니다. 취소·거부·캡처/인코딩 실패 전에는 클립보드를 변경하지 않습니다. 클립보드 쓰기와 복원에는 OS의 원자성 한계가 있으므로 오류를 숨기지 않습니다. 영어가 기본이며 일반 설정에서 **English / 한국어**를 선택하면 앱 소유 메뉴·설정·오버레이 문구가 즉시 바뀌고 재실행 후에도 선택을 유지합니다. 화면 기록 권한 변경 후 필요한 재시작은 언어 전환과 별개입니다. 지원되는 custom Sparkle driver의 새/열린 업데이트 창도 즉시 바꿀 계획이며 macOS 권한/보안 창은 OS 언어를 따릅니다.

브랜드는 Shot Clip, 저장소는 `kyungseok-lee/shotclip`, 기존 식별자는 `dev.shotclip.app`, 실행 파일은 `shotclip`, 새 설치 위치는 `/Applications/Shot Clip.app`입니다. 목표 `0.6.0`(build `8`)은 검증 완료를 뜻하지 않습니다. 기존 0.4.x 설정을 유지하고 새 앱 검증 후 기존 폴더를 복구 가능한 백업으로 옮깁니다. 과거 Sshot의 다른 ID에서만 선택 설정을 이전하며 ad-hoc 교체 후 권한 재허용이 필요할 수 있습니다.

GitHub ad-hoc 개발자 프리뷰 배포가 승인되었고 Developer ID/공증은 이번 범위에서 제외합니다. 기존 Keychain `sshot` 계정과 Ed25519 공개키는 유지하며 키를 내보내거나 재생성하지 않습니다. 캡처 GUI 테스트는 사용자가 맡고 클라우드·저장·OCR로 범위를 넓히지 않습니다.
