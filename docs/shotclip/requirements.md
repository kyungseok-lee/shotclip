# Shot Clip requirements and acceptance criteria

[Product plan](product-plan.md) · [Development trace](development-plan.md#ordered-work-and-trace) · [Verification](verification.md#requirement-trace) · [한국어](#한국어)

## Documentation maintenance request

The current request is a usage-first English/Korean README and a concise, current documentation set. It adds no app feature or release. Keep verified 0.8.1 (build 11) behavior, requirement/decision/phase identifiers and linked QA evidence; remove obsolete delivery-pending claims and release-note chronology from the normal reading path. Document checks and independent review precede the authorized ordinary main push.

## Requirements

These are acceptance criteria, not automatic PASS claims. [QA results](qa-results.md#current-evidence) distinguishes logic, synthetic UI, normal runtime and delivery evidence.

| ID | Requirement | Acceptance criteria |
| --- | --- | --- |
| R01 | Configurable global shortcut | While running, open the remembered mode from another app; preserve valid saved preferences; display the mapped physical shortcut on only that native menu row; report conflicts and restore the previous binding on failure |
| R02 | Fixed Region | Move/resize, confirm with Capture or Return, reuse the last valid session region and clamp to the display |
| R03 | Capture Area | Fresh-user default and first capture menu action; start without a rectangle; a valid drag release captures immediately; normalize reverse drags and reject invalid/zero selection |
| R04 | Immediate image copy | Encode PNG/TIFF in memory before clipboard replacement; success feedback and thumbnail only after commit |
| R05 | User-controlled paste | Person presses `⌘V` in an image-capable app or Preview `⌘N`; no injected paste keystroke |
| R06 | Progressive Access recovery | Unavailable access hides unusable capture actions and routes shortcut/menu to explicit setup; no launch-time system prompt; denial/revocation blocks capture/write; concise primary recovery and collapsed details |
| R07 | Display/pixel accuracy | Selection stays on its starting display; negative origins, scale conversion and rounding are correct; no multi-display stitching |
| R08 | Exclude capture UI | Result excludes Shot Clip overlay, handles, buttons and cursor |
| R09 | Safe cancellation/failure | Cancel, denial and capture/encode failures preserve clipboard before commit; snapshot and guarded rollback for write failure; external-change and platform race limits disclosed |
| R10 | Single-flight capture | Reentry brings selecting UI forward or ignores processing; cancellation/timeout/session changes prevent a late commit |
| R11 | Local privacy | No automatic capture storage/history/upload; explicit PNG save only; no capture, screen, observed app/window, clipboard or chosen export-path content in logs/repo/remote services; release preview buffers when dismissed/replaced |
| R12 | Keyboard/accessibility | Menu actions, Return/Escape, arrows/Option resize, M mode switch, native Tab/Shift-Tab focus, labels and visible focus; recover after errors/screen changes/sleep |
| R13 | Signed updates | Canonical HTTPS feed; Ed25519 archive/feed verification and pre-extraction verification; exact integer-zero signed-feed failure expiry; invalid signatures/configuration fail closed; later valid signed feeds remain eligible; fresh automatic checks OFF |
| R14 | Native readable presentation | Shot Clip identity, ready-only native capture menu, 44×44 pt navigation, aligned full-text settings, semantic tokens, process-local Roboto/Noto Sans KR, compact toolbar/update dialogs and complete icon assets |
| R15 | English default/Korean choice | Fresh/migrated default English; explicit choice persists and relabels app-owned UI immediately without losing state; safe fallback; supported update driver retains callbacks/state; system prompts follow OS language |
| R16 | Stable identity/migration | `dev.shotclip.app`, executable `shotclip`, canonical spaced folder; verify new payload before backup/replacement; reject wrong IDs/symlinks; validated selected settings and established key retained; no wholesale consent/login/trust migration |
| R17 | Reviewed GitHub preview delivery | Explicit ad-hoc/not-notarized disclosure; independently reviewed source/tag/artifact/public bytes; first-launch/regrant limits; latest verification precedes approved obsolete-output cleanup; Git source/tag history retained |
| R18 | Original preview and PNG export | Success-only nonactivating capture-display thumbnail; same original Fit/100%/Save PNG; original pixels; dismiss/timeout/close/save cancellation/failure do not clear or rewrite clipboard; no automatic history |

Defaults are running-process `⌃⇧⌘5`, Capture Area, optional login OFF and automatic update checks OFF. Existing valid shortcut/mode and automatic-check choices win. Fixed Region fallback is 400×300 pt, clamped to the display; region geometry is session-only.

<a id="2026-10-06-080-bilingual-settings-contract"></a>
<a id="2026-10-05-unreleased-eight-item-ui-refresh"></a>
<a id="2026-10-05-unreleased-settings-polish"></a>
## Settings acceptance

R14/R15 → D17 → P9 requires complete window/navigation/header/heading/row/card/control/document-frame equality and preserved pane, scroll and focus through en→ko→en at the same state and size. Default content is 720×580 pt; minimum 620×480 pt; common form lane is 160 pt. Typography and glyph-safe bilingual reservations must avoid clipping/line collision and keep at least 12 pt vertical row padding. Arbitrary diagnostics may enlarge a shared reservation after state changes or resizing; language alone must not change geometry.

<a id="2026-10-06-081-security-requirements"></a>
## Security acceptance

R13/R11 → D18 → P10 requires: (S01) integer `SUSignedFeedFailureExpirationInterval=0`, without preventing later valid signed-feed retry; (S02) no production QA helper/self-test/UI-preview dispatch regardless of argv or neighboring files, with explicit isolated development QA retained; (S03) no private developer-home or absolute source/build metadata in the published app, proved by complete artifact inspection and contaminated negative fixtures. Existing fonts, layouts, preferences, keys and privacy limits stay intact. These changes are delivered in 0.8.1; [recorded evidence](qa-results.md#current-evidence) bounds the proof.

## Excluded scope

Cloud/history/automatic capture storage, OCR, editing/annotation, full-screen/window/scroll/video capture, automatic paste, display stitching and quit-state launch. Product use does not require Accessibility or Full Disk Access permission.

## 한국어

이번 요청은 사용법 중심의 README와 현재 문서 정리이며 앱 기능·새 배포를 추가하지 않습니다. R01–R12는 선택·복사·권한·좌표·안전·키보드, R13은 서명 업데이트, R14/R15는 읽기 쉬운 한영 native UI, R16/R17은 식별자·검증된 배포, R18은 메모리 원본 보기와 명시적 PNG 저장 기준입니다. 요구사항 표는 QA 통과 목록이 아닙니다.

D17/P9는 같은 상태/크기의 전체 프레임·스크롤·포커스와 글리프를 유지합니다. D18/P10은 invalid feed의 시간 경과 수용 차단, 공개 앱의 QA 실행 제거, 전체 배포물의 개발자 경로 제거를 요구하며 0.8.1에 포함되어 있습니다. 이후 유효한 서명 feed는 허용하고 기존 설정·키·폰트·개인정보 경계를 유지합니다.
