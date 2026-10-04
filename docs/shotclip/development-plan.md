# Shot Clip development plan

[Product plan](product-plan.md) · [Design system](design-system.md) · [Requirements](requirements.md) · [한국어](#한국어)

Updated 2026-10-05. Follow requirements → design → implementation → verification. Prior Sshot 0.3.0 and ShotClip 0.4.x are dated evidence; the approved Shot Clip `0.5.0` (build `7`) interaction/display refresh needs its own checks. This plan does not record test passes.

## Ordered work and trace

| Phase | Requirements | Design / decision | Implementation target | Verification and exit evidence |
| --- | --- | --- | --- | --- |
| P0: product baseline | R01–R17 | Scope; D01–D14 | README and `docs/shotclip` | Independent document review; valid links; no unsupported claims |
| P1: technical baseline | R06–R11 | D01–D05, D07; API, coordinates, clipboard transaction | `Sources/CaptureCore`; `Sources/shotclip/Services.swift` | Apple docs/SDK checks; geometry, state, failure/rollback tests; limitations recorded |
| P2: native interaction | R01–R03, R06, R12, R14 | Tokens; D03, D06, D09, D11; permission recovery | `AppDelegate.swift`, `Overlay.swift`, `SettingsWindow.swift`, `PermissionStatus.swift` in `Sources/shotclip` | Shortcut conflict/restore; single-flight/cancel; labels/key handling review; UI checks separate |
| P3: identity and migration | R14, R16 | D12; allowlist old preferences, preserve destination values | `Package.swift`, `resources/Info.plist`, app/fixture and build/install scripts | Bundle `dev.shotclip.app`, executable `shotclip`, `Shot Clip.app`; migration rerun/invalid-value tests; fresh TCC grant explained |
| P4: localization | R15 | D13; English default with explicit `en` / `ko` selection | Localization resources, preference service, menu/settings/overlay/errors | Key parity, fallback, persisted choice, bundled resources; both layouts and accessibility labels reviewed |
| P5: capture acceptance | R02–R12 | D02, D04–D07; one display, in-memory image | Capture/clipboard services, opt-in synthetic fixture/harness | User-owned capture/permission/paste checks; PASS/FAIL/SKIP recorded; SKIP never PASS |
| P6: preview preparation | R13, R17 | D08, D10, D14; GitHub ad-hoc preview, signed feed/archive | Release scripts, appcast, manifest, source-commit metadata | Clean source/tag/artifact alignment; local signature/archive checks; existing Ed25519 archive **and feed** verification; preview notes |
| P7: release and update QA | R13, R16–R17 | Migration boundary and update compatibility | Draft assets and release operations | Publisher verifies uploaded assets/feed; user-owned first-launch/TCC/capture and actual upgrade evidence; gaps recorded |

Implementation paths are relative to the repository. No additional features beyond capture-to-clipboard, native interaction, localization, rebrand, and preview delivery are required.

### 0.5 interaction, brand and installation follow-up

1. Land R01/R03/R06/R14/R16 acceptance and the [workflow/design foundation](design-system.md#05-workflow-evidence-and-approved-direction) before UI implementation.
2. Implement native capture-first menus, grouped settings/Access recovery, quiet lifecycle and compact selection UI; preserve existing mode/shortcut and trust. Generate original crop/copy icon and matching menu glyph.
3. Change visible plist names and bundle folder to `Shot Clip.app`, retain stable IDs/executable/resources and prepare 0.5.0(7). The installer stages/verifies new bytes, installs/verifies the canonical app before backing up prior `ShotClip.app`/historical `sshot.app`, and restores prior paths on failure.
4. Run meaningful temporary signed-app transaction fixtures for spaces, same-ID previous-path migration, distinct backups, wrong-ID rejection and rollback; retain all unsafe ZIP tests while accepting only `Shot Clip.app` and matching AppleDouble metadata.
5. Render inert native UI previews across both languages/appearances/default/minimum sizes and panes; independently review source, render and package evidence. Real TCC/capture/paste remains user-owned.
6. Commit/push/tag reviewed clean source; existing-key prepare/sign/verify/publish; install/verify latest; only then remove authorized superseded releases/local versions while preserving Git history and recoverable backups. Final QA/handoff record actual results.

Stock Sparkle 2.10.0 matches an incoming app by unchanged bundle identifier, but normally replaces the old host path: [installer source](https://github.com/sparkle-project/Sparkle/blob/2.10.0/Autoupdate/SUInstaller.m), [compile-time default](https://github.com/sparkle-project/Sparkle/blob/2.10.0/Configurations/ConfigCommon.xcconfig). The canonical spaced folder uses manual installation; no custom Sparkle build or automatic-folder-rename claim. Actual automatic upgrade remains unrun.

### Earlier 0.4.1 visual refresh plan

R14 → the [icon/artwork contract](design-system.md#icon-and-brand-artwork) → deterministic icon/hero generation and English/Korean README assets → inspect 16/32/1024 px renders, all ICNS sizes and packaged icon. R16 → retain the existing bundle ID, preference domains and update trust while advancing to build 6. R17 → independent source/artifact review → main/tag push → prepare/sign/verify/publish → install and verify the newest app → remove superseded GitHub release artifacts and recoverably move verified old local versions. Preserve Git source/tag history and record the actual results in [QA](qa-results.md) and [handoff](handoff.md).

## Migration contract

Read historical `dev.sshot.app` defaults only for valid shortcut and selection mode. Keep already-set Shot Clip values, reject malformed values, and mark migration after safe processing. Do not copy the entire domain, images, rectangles, privacy state, updater internals, or trust material. New and migrated installs default to English until a person chooses Korean. Opt-in login registration belongs to the new identity; do not silently enable it.

Preserve the existing Ed25519 public key and Keychain `sshot` account. Renaming source/archive paths does not authorize changing keys. The legacy bundle-ID transition uses a **one-time manual Shot Clip installation**; preference migration does not establish automatic legacy Sparkle replacement compatibility.

## Work and review boundaries

- Author and verifier work in separate contexts; evidence determines acceptance.
- Run fast tests/build/static checks for code changes. Capture GUI, Screen Recording grants, and actual paste remain user-owned; do not operate TCC or claim these passed.
- Keep captured images, screen/app/window information, and clipboard data out of files, diagnostics, Git, and remote services. Harness output is metadata only.
- Version/build remain proposals until the sealed bundle is inspected. Ad-hoc code signing, Ed25519 signing, and notarization prove different things.
- Code push and binary publication are separate actions. Implementation/doc authoring and independent review are separate lanes; the coordinator owns commit/push, installation and publication.

## Decisions and next evidence

The approved route is the GitHub ad-hoc developer preview. Developer ID/notarization is outside this release; lack of a certificate is not a preview blocker. First-launch approval, TCC regrant, remote assets, upgrades, macOS 14, Intel, mixed-scale displays, and VoiceOver each need evidence before claims. See [QA plan](qa-plan.md), [QA results](qa-results.md), and [handoff](handoff.md).

## 한국어

요구사항 → 설계 → 구현 → 검증 순서로 진행합니다. P0 문서 → P1 API/좌표/클립보드 → P2 native 상호작용 → P3 새 식별자와 설정 이전 → P4 영어/한국어 → P5 사용자 캡처 QA → P6 ad-hoc 프리뷰 준비 → P7 게시 및 실제 업데이트 QA 순서입니다. 요구사항·결정·파일·완료 증거를 함께 갱신합니다.

기존 `dev.sshot.app`에서 유효한 단축키와 선택 모드만 이전하고 새 Shot Clip 값은 우선합니다. 전체 defaults·이미지·영역·권한·업데이트 내부 상태·키를 복사하지 않습니다. 영어가 기본이고 한국어 선택은 명시적으로 저장합니다. 새 앱의 권한·로그인 등록은 별개이며 과거 앱에서 Sparkle로 자동 이전되는지는 미검증입니다.

실제 캡처·권한·붙여 넣기는 사용자 담당입니다. 기존 Ed25519 키와 `sshot` 계정으로 archive/feed를 검증하는 ad-hoc 프리뷰를 유지합니다. 목표는 `0.5.0`(build `7`)이며 설계 문서 후 UI·표시 이름·공백 앱 경로와 설치 복원 fixture를 구현합니다. 합성 native 미리보기·독립 검토·정확한 공개/최신 설치를 확인한 뒤 승인된 구버전을 정리합니다. 기존 ShotClip 0.4.x ID·설정은 유지하고 앱 폴더 이름은 수동 설치로 전환하며 실제 자동 업그레이드는 별도 미검증입니다.
