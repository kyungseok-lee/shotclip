# Shot Clip QA plan

[Usage](../../README.md) · [Recorded results](qa-results.md#current-evidence) · [Trace](verification.md#requirement-trace) · [한국어](#한국어)

## Production and isolated QA builds

These are procedures for future authorized code work, not commands run by this documentation refresh. Run from the repository root. Quit every Shot Clip process before either bundle build; build-app refuses replacement while the executable is running.

```sh
# Production code flavor; local development signing, no publication.
bash scripts/build-app.sh
python3 scripts/verify-app-security.py 'dist/Shot Clip.app'
python3 scripts/test-production-qa-arguments.py 'dist/Shot Clip.app'

# Explicit development-only QA flavor, distinct bundle/identity/scratch.
SHOTCLIP_BUILD_FLAVOR=qa bash scripts/build-app.sh
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --localization-self-test
python3 scripts/test-qa-build.py 'dist/qa/Shot Clip QA.app'
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --ui-preview dist/ui-qa/en-light --language en --appearance light
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --ui-preview dist/ui-qa/ko-dark --language ko --appearance dark
```

Production defaults to `.build/production` / `dist/Shot Clip.app` / `dev.shotclip.app`. Isolated QA uses `.build/qa` / `dist/qa/Shot Clip QA.app` / `dev.shotclip.qa` and the explicit `SHOTCLIP_QA` define. QA has no normal startup route; production rejects retired QA arguments before preferences/AppDelegate/updater/permission work. A normal production-flavor development launch shares product preferences, so use QA for inert checks. Published artifacts never contain the QA helper or hooks.

## Fast code and artifact checks

```sh
swift test
python3 scripts/test-app-security.py
bash scripts/test-resource-bundle.sh
bash scripts/test-release-gates.sh
python3 scripts/test-release-archive.py
python3 scripts/test-install-migration.py
swift scripts/test-release-manifest.swift
codesign --verify --deep --strict 'dist/Shot Clip.app'
```

Record exact inputs, environment, commands and counts when performed. Synthetic signing fixtures use ephemeral keys, not the user's Keychain key. Installer tests use temporary roots, not the canonical app. Local ad-hoc signature validation is not Apple notarization or universal first-launch acceptance.

## Inert layout and state acceptance

Repeat en/ko × light/dark at 720×580, 620×480, 670×520 and 820×620 pt. Cover General/Access/Updates, ready/blocked, collapsed/expanded diagnostics, login approval, busy/error/unconfigured update states, long paths/status/shortcut fallback glyphs and resize→switch→resize-back.

Compare all 139 app-owned structural views, including nested labels/control composites, offscreen/hidden structures, separators/footer and document extent, with exact same-state/size en→ko→en frames. Verify full text/cell/tight glyph ink, adjacent-line nonoverlap, at least 12 pt vertical padding, native button title ink, preserved pane/focus/scroll/state and unchanged preferences. Resizing may clamp scroll; fixture restoration after resize is disclosed separately from unassisted language-transition preservation.

Prove guards are active with truncated status, stale wrapping width, missing padding, overlapping line ink and deliberate structural-frame drift. Inspect representative renders as well as machine reports. The renderer draws synthetic product views with inert callbacks; it starts no capture/hotkey/updater/TCC, takes no desktop screenshot and touches no general clipboard. Capture-preview fixtures use a private named pasteboard and synthetic PNGs only. A drawn menu is not native popup or Carbon event evidence.

## Security acceptance

R11/R13 → D18 → P10 verifies exact integer-zero feed-failure expiry and both signature switches, later valid signed-feed eligibility, production flavor/no QA dispatch, complete artifact path purity and standalone resources. Negative fixtures cover missing/wrong-type policy, QA flavor/types/hooks/files, case-insensitive UTF-8/UTF-16 paths/both alignments, symlink and unsafe/escaping RPATH cases. Whole scanner includes all regular files, symlink targets and Mach-O debug/RPATH data; report categories/counts without matched private paths. Pinned Sparkle source/configuration is not a live 20-day failure experiment.

## User’s short acceptance check

1. Launch the verified app, handle any per-app macOS first-launch block, then inspect General/Access/Updates and version.
2. Use Access to grant Screen Recording only if desired; check denial, Check Again and restart recovery without bypassing TCC.
3. With nonsensitive content, try both capture modes, reverse drag, Return/Capture and Escape. Paste normally into an image-capable app and confirm capture UI/cursor exclusion.
4. Click the thumbnail, inspect original Fit/100%, save a deliberate PNG, cancel another save and verify clipboard retention. Starting a new capture closes the old preview.
5. Check the running-process shortcut from another app, conflict/recovery, M, arrows/Option resize and Tab/Shift-Tab focus.
6. Switch English↔한국어 without restarting; inspect retained pane/state/region, small windows and both appearances. Restart once to verify the saved language. OS dialogs follow OS language.

Report only version, case ID, mode/permission state, safe error code, expected/actual result and steps. Do not submit capture/screen/clipboard/observed app/window/export-path content. These checks remain user-owned unless a specific recorded run proves them.

## Optional real-capture harness — user-owned

Only the isolated development QA flavor provides `--self-test`, with its sibling `dist/qa/shotclip-fixture.app`. A person must explicitly choose real capture and grant access to the QA identity. Launch through LaunchServices to keep permission responsibility clear; this recipe has not been run for current delivery:

```sh
qa_output_dir=$(mktemp -d)
open -n -W -o "$qa_output_dir/self-test.json" 'dist/qa/Shot Clip QA.app' --args --self-test
```

Inspect the harness JSON PASS/FAIL/SKIP, not `open`'s status. It compares synthetic screen colors/pixels in memory and uses a unique named pasteboard; missing access is SKIP, never PASS. Do not run this route on the published app, which rejects it.

## Extended coverage

Clean-account first launch, macOS 14/other OS versions, Intel, mixed-scale/multiple displays, keyboard input sources, VoiceOver/full focus and normal capture/paste/save require distinct runs. Developer ID/notarization is a separate route. Public delivery needs exact source/tag/artifact/download/feed/install equality and scoped cleanup, as described in [operations](update-operations.md).

## 한국어

향후 코드 변경 때만 위 명령으로 검증합니다. production은 기본 앱이고 QA는 `SHOTCLIP_BUILD_FLAVOR=qa`의 별도 앱/식별자이며 공개 앱에서는 QA 인자를 거부합니다. 실제 설정을 공유하는 정상 개발 앱 대신 합성 검증에는 격리 QA를 사용하고 빌드 전에는 실행 중인 Shot Clip을 종료합니다.

전체 한영 프레임·잉크·여백·상태와 의도적 오류, 서명 정책/경로 오염을 검사합니다. 합성 뷰·고유 pasteboard와 실제 캡처·일반 붙여 넣기·TCC·접근성은 다른 범위입니다. 이번 문서 변경은 앱 빌드/테스트를 실행하지 않으며 optional 실캡처 harness도 현재 배포에서는 미실행입니다.

<details>
<summary>Historical evidence referenced by retained QA records</summary>

These original dated records preserve their actual scope; their old current/candidate/pending wording does not describe the installed app or this documentation-only task.

## 2026-10-06 0.8.1 security acceptance plan

Follow **R13/R11 → D18 → P10** for candidate 0.8.1 (build 11); do not substitute 0.8 test results for new evidence. [Finding ledger](qa-results.md#2026-10-06-081-security-findings-and-candidate-status) records the baseline and actual outcomes.

| Gate | Required independent-checkable evidence |
| --- | --- |
| S01 feed policy | Bundle `SUSignedFeedFailureExpirationInterval` is exact integer 0; reject absent, nonzero, negative, Boolean, string and floating-point values. invalidly signed feed remains rejected after elapsed recovery intervals, preference/language refresh and subsequent checks. Later valid signed feed succeeds. Archive Ed25519 authentication stays enforced; separate policy tests from public crypto and native update results |
| S02 production isolation | Production argument/helper-neighbor fixtures cannot reach sibling QA/self-test/UI-preview routes or create QA output; inspect the published binary. Explicit separate QA host runs the retained synthetic suites without normal startup, production preference/TCC/general-clipboard actions or capture-content logs |
| S03 artifact hygiene | Scan every published regular file and symlink/metadata path, all Mach-O code/resources including bundled frameworks/helpers and load commands. Reject private developer-home and absolute source/build paths using relative match-class diagnostics. Contaminated app-owned, nested dependency/resource and metadata fixtures demonstrate active failure; no raw home path in shared evidence |
| Retained behavior | Fresh core tests, isolated bilingual layout matrices and representative renders; production localization/fonts/licenses/icons/self-contained resource resolution and signature checks. Normal native language/runtime evidence is distinct from synthetic geometry |
| Delivery | Independently approved source/docs and exact clean signed preparation; new immutable source/tag/ordinary push, public redownload/latest feed equality, actual latest canonical install/runtime, exact owned obsolete-output cleanup and final document review |

Production is the default; development QA requires an explicit build flavor. The current executor recipe uses separate scratch trees and a separate bundle ID, and source guards use `SHOTCLIP_QA`. QA rejects launch without an explicit localization/UI-preview/self-test route; production rejects retired QA arguments before localization/preferences/AppKit startup. Final source is frozen, and author security/production-argument/portable-resource/layout fixtures pass as recorded in the current QA ledger. Independent candidate approval and new delivery remain pending.

```sh
# Quit all Shot Clip processes before either build.
bash scripts/build-app.sh
python3 scripts/verify-app-security.py 'dist/Shot Clip.app'
SHOTCLIP_BUILD_FLAVOR=qa bash scripts/build-app.sh
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --localization-self-test
```

Production uses `.build/production` and `dist/Shot Clip.app`; QA uses `.build/qa`, `dist/qa/Shot Clip QA.app` and `dev.shotclip.qa`. Preview outputs must stay in ignored synthetic evidence directories. Historical commands below that address QA flags in the production app are superseded by this split. Retain the source fonts/strings in each self-contained resource bundle. Preparing updates resolves tools with `swift package --scratch-path .build/production resolve`; publishing QA flavor is rejected.

Preserve existing identity/settings/key, fresh automatic-check default OFF and this host's retained preference. Capture/TCC/general paste, full accessibility and alternate OS/CPU/hardware coverage remain unverified unless actually executed. Existing ad-hoc/not-notarized/library-validation constraints remain separate from these findings. Earlier dated plans/results below are historical.

한국어: S01 무효 feed의 interval 0/시간 경과 거부·이후 유효 feed 수용, S02 production 비실행과 별도 QA, S03 전체 artifact/오염 negative를 새 근거로 검증합니다. 한영 배치·자료·서명·실제 정상 동작/설치·정리는 따로 확인하고 미실행 캡처/권한/접근성/별도환경을 통과로 표시하지 않습니다.

Executed author scope: 36 core tests, security six accepts/71 rejects, 27 retired-argument rejects, a complete production scanner and two 176-render/100-case matrices. Feed expiry semantics are grounded in pinned source and exact plist/negative fixtures; no live 20-day feed wait or network acceptance run is claimed. Root normal candidate/package and temporary regressions have separate evidence. Retained manual capture/self-test/native-save/TCC/general paste and alternate environment checks were not run for this version.

## 2026-10-05 0.7.0 release acceptance

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

| Remaining check | Current host action / evidence boundary |
| --- | --- |
| Candidate core/UI/package/security | Rerun the version-specific build, tests, localization, font/license/icon packaging, four language/appearance fixtures, archive/feed/security and installer regressions. Record actual counts and independent approval; earlier counts are baseline evidence |
| Real capture and clipboard | Attempt the LaunchServices `--self-test` with synthetic fixture content, actual permission preflight, in-memory pixels and a private pasteboard. Separately check normal drag/fixed/cancel/reverse drag, lower-right thumbnail/original/Save and actual paste using nonsensitive synthetic content. No captured screen files or sensitive clipboard data in evidence |
| Screen Recording recovery | Actual grant/deny/revoke/recheck/restart requires system authorization. Missing permission is SKIP, not PASS; never reset/edit/bypass TCC |
| Native Save/error | Prior real Save/cancel/close/replacement passed on the same copied payload. Exercise the production save-error catch/alert safely if feasible. The alternate default-button-cell automation route is optional and its unrun state does not negate actual GUI acceptance |
| Keyboard/language/accessibility | Actual native popup, Carbon with another app active, M/Tab/Shift-Tab/focus, shortcut and language persistence, live update dialog, VoiceOver/Full Keyboard Access and appearance accommodations require bounded runtime evidence. Preserve or restore only recorded intentional setting changes |
| Display/input cases | Real mixed-scale/negative-origin/second-display, disconnect/sleep/wake and alternate layouts depend on available hardware/input sources; synthetic geometry remains separate |
| Platform/first launch | macOS 14, Intel and clean-account downloaded first launch require separate environments. Current macOS 27 arm64/current-account tests cannot establish them; record unavailable/unverified coverage and arm64 archive scope |
| Actual upgrade | After publication, attempt canonical 0.6(8) → 0.7(9) signed Sparkle download/install/relaunch before manual replacement when feasible. Exact latest manual installation does not prove an updater upgrade |
| Public/latest installation | Separate reviewed source/tag/remote equality, prepared artifact approval, public byte/feed checks, exact canonical installation/signature/resources and normal PID/path/runtime; final documentation review/push afterward |

The latest all-remaining instruction permits the coordinator to attempt earlier user-owned acceptance checks within this safe scope. The earlier user-owned procedures below remain reproducible steps, not PASS claims. Unavailable environments are disclosed limitations rather than invented successes. [Candidate results](qa-results.md#2026-10-05-070-release-candidate) record actual outcomes.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

</details>
