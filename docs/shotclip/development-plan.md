# Shot Clip development plan

[Product plan](product-plan.md) · [Design system](design-system.md) · [Requirements](requirements.md) · [한국어](#한국어)

## 2026-10-05 0.7.0 ordered release work

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

1. Review 0.7.0/build 9 metadata and bilingual release content, preserve approved UI/settings changes and record remaining host/environment acceptance.
2. Run exclusive candidate core/build/resource/font/icon/localization/UI/security/installer checks; attempt safe metadata-only real capture and normal interaction where permission/environment supports them. Retain exact PASS/FAIL/SKIP and independent candidate review.
3. Commit approved source/docs, create new `v0.7.0`, normal push and verify remote main/peeled tag; prepare clean reviewed source with the existing key. Separately approve the exact prepared six-file set.
4. Publish new latest release, redownload/compare public assets and canonical signed feed; attempt actual 0.6→0.7 Sparkle upgrade before manual replacement where feasible. Install/verify exact latest canonical payload and bounded normal runtime.
5. Reconcile only actual publication/install/runtime/upgrade/cleanup facts into final bilingual docs; independent final review, documentation commit/push and remote equality. Retain latest artifacts/source/tags/key and small proof.

The agent may attempt the earlier user-owned acceptance under the latest all-remaining request, using nonsensitive synthetic content and actual system permission; missing permission/environment remains SKIP/unverified. No actual captured screen or sensitive clipboard content or actual user-selected save destination in evidence; ignored synthetic fixture images and QA output paths are allowed.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

Updated 2026-10-05. Follow requirements → design → implementation → verification. Prior Sshot 0.3.0 and ShotClip 0.4.x are dated evidence; the current eight-item Shot Clip `0.6.0` (build `8`) development refresh needs its own checks and is not a new release. This plan does not record test passes.

## Ordered work and trace

| Phase | Requirements | Design / decision | Implementation target | Verification and exit evidence |
| --- | --- | --- | --- | --- |
| P0: product baseline | R01–R18 | Scope; D01–D16 | README and `docs/shotclip` | Independent document review; valid links; no unsupported claims |
| P1: technical baseline | R06–R11 | D01–D05, D07; API, coordinates, clipboard transaction | `Sources/CaptureCore`; `Sources/shotclip/Services.swift` | Apple docs/SDK checks; geometry, state, failure/rollback tests; limitations recorded |
| P2: native interaction | R01–R03, R06, R12, R14 | Tokens; D03, D06, D09, D11; permission recovery | `AppDelegate.swift`, `Overlay.swift`, `SettingsWindow.swift`, `PermissionStatus.swift` in `Sources/shotclip` | Shortcut conflict/restore; single-flight/cancel; labels/key handling review; UI checks separate |
| P3: identity and migration | R14, R16 | D12; allowlist old preferences, preserve destination values | `Package.swift`, `resources/Info.plist`, app/fixture and build/install scripts | Bundle `dev.shotclip.app`, executable `shotclip`, `Shot Clip.app`; migration rerun/invalid-value tests; fresh TCC grant explained |
| P4: localization | R15 | D13; English default with explicit `en` / `ko` selection | Localization resources, preference service, menu/settings/overlay/errors | Key parity, fallback, live en→ko→en transition, persisted choice, bundled resources and state preservation; both layouts/accessibility labels reviewed; custom update-dialog live/callback fixtures; macOS prompts separate |
| P5: capture acceptance | R02–R12 | D02, D04–D07; one display, in-memory image | Capture/clipboard services, opt-in synthetic fixture/harness | User-owned capture/permission/paste checks; PASS/FAIL/SKIP recorded; SKIP never PASS |
| P6: preview preparation | R13, R17 | D08, D10, D14; GitHub ad-hoc preview, signed feed/archive | Release scripts, appcast, manifest, source-commit metadata | Clean source/tag/artifact alignment; local signature/archive checks; existing Ed25519 archive **and feed** verification; preview notes |
| P7: release and update QA | R13, R16–R17 | Migration boundary and update compatibility | Draft assets and release operations | Publisher verifies uploaded assets/feed; user-owned first-launch/TCC/capture and actual upgrade evidence; gaps recorded |

Implementation paths are relative to the repository. Current scope includes capture-to-clipboard, optional original preview/user-selected PNG export, consistent native interaction/localization and approved preview delivery. No automatic capture storage/history is required.

### Current eight-item UI refresh — implementation/review only

| Phase | Requirements / decisions | Implementation | Required evidence |
| --- | --- | --- | --- |
| P8: consistent UI and post-copy preview | R01/R04/R06/R09/R11/R12/R14/R15/R18; D11/D13/D15/D16 | `CaptureGlyph.swift`, `DesignTokens.swift`, `SettingsWindow.swift`, `LocalizedUpdateDriver.swift`, `Overlay.swift`, `CapturePreview.swift`, `AppDelegate.swift`, resources and `UIPreview.swift` | Production unavailable/ready menu dispatch; process font/cascade/licenses/package; square rail and all icon sizes; full multiline bounds; content-sized updater/callbacks; Apple-reference toolbar; lower-right/original/PNG/isolated clipboard fixtures; independent source/document/evidence review |

Keep prior unreleased settings-polish source fixes and all dated evidence. First update requirements/design, then inspect the implementation, run exclusive build/core/resource/localization and four language/appearance fixtures, inspect representative renders/native panels, and obtain independent review. Current author results: 36 core tests, four 136-view matrices (544 total), 1236 updater and 44 capture-preview assertions per run. Final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`, with exact evidence/ownership in QA/handoff. Development remains 0.6.0(8); do not claim a new install, public release, commit, push or tag for this ordinary improvement request. A later explicit deployment request uses [AGENTS](../../AGENTS.md#최신-배포-요청-규칙).

한국어: P8은 권한 메뉴·Google 폰트·여러 줄 여백·정사각형 rail·작은 업데이트 창·Apple 참고 toolbar·성공 후 썸네일/원본/PNG 저장을 구현하고 검토합니다. 기존 미배포 설정 개선을 보존하며 원본 PNG와 고유 pasteboard fixture를 확인합니다. 새 배포/설치/commit/push/tag는 이 요청에 포함하지 않습니다.

### 0.6 native reference and immediate-language follow-up

1. Update R01/R14/R15, D11/D13 and this trace from the supplied reference before implementation. Keep the current identity, crop-copy artwork, capture engine, trust and defaults.
2. Align native settings navigation and rows with the reference, using system colors and controls in General/Access/Updates. Populate the native NSMenu shortcut column from the configured physical-key/layout mapping on the remembered capture mode; include Settings `⌘,` and Quit `⌘Q`.
3. Replace the launch-only app-localization snapshot with explicit en/ko selection and immediate view/menu/accessibility refresh. Preserve pane, shortcut/login/update state and current capture region. Keep Screen Recording restart guidance separate; include new/visible update dialogs through the implemented public Sparkle driver with synthetic live-refresh/callback/choice fixtures and independent review; macOS prompts remain OS-controlled.
4. Advance the bundle/default metadata to 0.6.0(8), then run core, resource, release/archive and installer regressions. Render inert English/Korean light/dark settings/menu and repeated-language-transition previews; inspect default/minimum layouts and keyboard/focus evidence.
5. Obtain independent source/docs/artifact review, commit/push/tag the reviewed source, prepare/sign with the existing key, verify/publish the new assets/feed and install/verify the exact payload. Each step needs its own recorded evidence.
6. Reconcile workspace cleanup with the actual coordinator report. Initial recoverable cleanup removed 14 prior staging folders (11 iconsets, three empty), totaling 12,897,238 bytes; `.build/` remains until verification. Retire additional superseded artifacts only after latest release/install checks.

Actual capture/TCC/paste, macOS 14/Intel, clean-account first launch and a real Sparkle upgrade remain separate unrun checks unless performed and recorded.

### 0.6 performed checkpoints and next gate

Requirements R01/R14/R15 → D03/D11/D13 → P2/P4 are implemented and independently source-approved: ordinary native settings chrome/geometry, native physical-key shortcut equivalents, mutable localization with synchronous retained-view refresh and one public updater/custom driver. Final author checks passed 36 core tests, 159 app + 57 Updates keys per language and four integrated 92-image runs (368 total). Reviewer fresh resource 34 / signed temporary installer 15 / gate 16 checks passed; coordinator crypto 25 / unsafe ZIP 15 plus two valid cases passed. New payloads require regular nonsymlink Localizable and Updates tables in both languages; older 0.5 rollback backups keep compatibility.

The coordinator reports `main` and annotated `v0.6.0` pushed at source `e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d`, followed by existing-key clean preparation and publisher `--check` PASS. Public release at 06:32:14 KST, six-asset/feed equality, all 171 installed entries/signature/159+57 resource keys, same-process normal-app live language/manual no-update result and postcleanup checks passed. Final cleanup moved 60 known local items (616,854,254 regular-file bytes) recoverably to Trash and removed superseded v0.5.0 public assets; latest prepared set, installed app, small proof records/source/tags/key retained. `.build/` and generated apps are now absent; rebuilding recreates development outputs. The final documentation commit is separate and has no hash yet. See [current QA](qa-results.md#2026-10-05-060-publication-installation-and-cleanup) for exact ownership and unrun checks.

한국어: 구현·독립 소스 승인·36 test·159+57 문자열·368 합성 뷰·최종 resource34/installer15/gate16을 확인했습니다. 새 payload의 두 문자열 표는 regular/nonsymlink 필수이며 이전 0.5 백업 복원 호환은 유지합니다. 구현/tag `e87e40e`의 준비/check 이후 06:32:14 KST 공개·171개 설치 항목/서명/159+57 문자열·동일 프로세스 즉시 언어 전환/수동 최신 확인·60개 로컬 항목 복구 가능한 정리·0.5 공개 제거를 확인했습니다. `.build/` 제거 후 설치 앱 재검증도 통과했으며 독립 최종 문서 리뷰/후속 문서 commit은 별도입니다.

### Earlier 0.5 interaction, brand and installation follow-up

1. Land R01/R03/R06/R14/R16 acceptance and the [workflow/design foundation](design-system.md#workflow-evidence-and-approved-06-direction) before UI implementation.
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
- Keep captures, screen/app/window information, clipboard contents and export paths out of diagnostics, Git and remote services. Only a deliberate accepted native Save PNG panel may write the original to the person’s selected file; automatic capture storage/history is absent. Harness fixtures use synthetic content and isolated pasteboards; retained proof is metadata-only or synthetic artwork.
- Inspect sealed version/build for each candidate; current 0.6.0(8) development and clean-preparation metadata are recorded in QA, with publication/install proof separate. Ad-hoc code signing, Ed25519 signing, and notarization prove different things.
- Code push and binary publication are separate actions. Implementation/doc authoring and independent review are separate lanes; the coordinator owns commit/push, installation and publication.

## Decisions and next evidence

The approved route is the GitHub ad-hoc developer preview. Developer ID/notarization is outside this release; lack of a certificate is not a preview blocker. First-launch approval, TCC regrant, remote assets, upgrades, macOS 14, Intel, mixed-scale displays, and VoiceOver each need evidence before claims. See [QA plan](qa-plan.md), [QA results](qa-results.md), and [handoff](handoff.md).

## 한국어

요구사항 → 설계 → 구현 → 검증 순서로 진행합니다. P0 문서 → P1 API/좌표/클립보드 → P2 native 상호작용 → P3 기존 식별자 유지와 선택적 과거 설정 이전 → P4 영어/한국어 → P5 사용자 캡처 QA → P6 ad-hoc 프리뷰 준비 → P7 게시 및 실제 업데이트 QA 순서입니다. 요구사항·결정·파일·완료 증거를 함께 갱신합니다.

기존 `dev.sshot.app`에서 유효한 단축키와 선택 모드만 이전하고 새 Shot Clip 값은 우선합니다. 전체 defaults·이미지·영역·권한·업데이트 내부 상태·키를 복사하지 않습니다. 영어가 기본이고 한국어 선택은 명시적으로 저장합니다. 새 앱의 권한·로그인 등록은 별개이며 과거 앱에서 Sparkle로 자동 이전되는지는 미검증입니다.

실제 캡처·권한·붙여 넣기는 사용자 담당입니다. 기존 Ed25519 키와 `sshot` 계정으로 archive/feed를 검증하는 ad-hoc 프리뷰를 유지합니다. 현재 목표는 `0.6.0`(build `8`)이며 참조 스타일의 native 설정/메뉴·오른쪽 단축키 열·즉시 언어 전환을 구현하고 기존 이름·아이콘·공백 경로·식별자·키를 유지합니다. 영어→한국어→영어 전환과 상태 보존을 검증하며 지원되는 custom Sparkle driver의 새/열린 업데이트 창/callback을 함께 검증하고 권한 재시작 및 macOS 시스템 창은 별도로 다룹니다. 합성 native 미리보기·독립 검토·정확한 공개/최신 설치를 확인한 뒤 승인된 구버전을 정리합니다. 기존 ShotClip 0.4.x ID·설정은 유지하고 앱 폴더 이름은 수동 설치로 전환하며 실제 자동 업그레이드는 별도 미검증입니다.
