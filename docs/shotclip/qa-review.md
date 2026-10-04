# ShotClip independent review

Review date: 2026-10-05 (Asia/Seoul). Reviewer lane: `task_18f060150e4f` / `ctx_e3ad56bc6de5`, separate from documentation, app, and release authors. Scope: the entire uncommitted rebrand, including actual untracked/renamed files, tracked diffs, tests, release scripts, resources, and public documentation.

## Verdict: APPROVE — code, documentation, and local packaging

No remaining blocking defect was found in the reviewed implementation/documentation and local packaging. Both release findings and the diagnostic correction below passed independent reinspection and final artifact checks. This approval supports committing/pushing reviewed source and proceeding with the authorized ad-hoc preview preparation; it does not claim complete GUI acceptance, final release provenance, publication, notarization, or an actual upgrade.

## Findings resolved by separate authors

**P1 — valid macOS archive metadata was rejected.** Before correction, `scripts/verify-release-archive.py:20–25` stripped trailing slashes but omitted the exact `__MACOSX/ShotClip.app` directory produced by `scripts/prepare-update.sh:25` using `ditto --sequesterRsrc`. A synthetic metadata-root fixture reproduced exit 1, and a historical local archive confirmed the real macOS metadata layout. This would block valid prepared archives at `scripts/publish-github-release.sh:27`; the reviewer escalated it without editing implementation.

Closed after independent verification: `verify-release-archive.py:24–29` now admits the exact metadata app root only as a directory with a safe type. The valid-ditto fixture and all 13 unsafe cases pass; original bounds/traversal/symlink checks remain. Both real generated QA ZIPs passed the validator; the final ZIP also passed independent `unzip -tq`, without extraction or installation.

**P1 — generated macOS localization bundle layout was rejected.** Before correction, the build/release presence checks required flat `shotclip_shotclip.bundle/en.lproj` and `ko.lproj`, whereas this SwiftPM backend emitted `shotclip_shotclip.bundle/Contents/Resources/{en,ko}.lproj/Localizable.strings`. Root's first packaging attempt failed after compilation; independent filesystem inspection confirmed both resources existed. The reviewer escalated the mismatch without editing implementation.

Closed after independent verification: `release-common.sh:12` validates native and flat layouts, rejects symlink/nonregular/incomplete tables, and prevents fallback from an incomplete native layout. `build-app.sh:28` and `release-common.sh:75` use that helper while copying the intact resource bundle. All 22 resource fixtures, fresh root packaging, independent sealed en/ko inspection and final bundled localization diagnostic pass.

**Diagnostic correction — equivalent URL representations falsely failed.** Root's initial bundled diagnostic failed at the installed-location guard despite both 109-key tables loading correctly. `Sources/shotclip/Localization.swift:44–47` now compares `absoluteURL.standardizedFileURL` values, retaining rejection of missing/outside resources. The reviewer reinspected the narrow diagnostic-only patch and independently reran the rebuilt app's `--localization-self-test`: exit 0, `result=PASS`, `installedBundle=true`, `keyCount=109`, languages `en`/`ko`, `fallback=true`. Author-provided positive and outside/nested rejection probes are additional evidence; the reviewer did not rerun those Swift probes.

## Checks executed by this reviewer

Environment independently read: macOS 27.0.1 (26A434), Xcode 27.0 (27A266a), arm64. No Swift/build command, GUI operation/capture, Screen Recording request/grant, general clipboard mutation, preference write, installation, Keychain access, commit, push, tag, or publication was performed in this lane. The localization-only executable diagnostic exits before preference preparation or NSApplication startup.

| Check | Result and scope |
| --- | --- |
| Documentation reading | Read both READMEs and every current document; English entry points/Korean companions, approved ad-hoc delivery, R01–R17, native design, historical disclaimers, and explicit 2027 hypotheses are consistent |
| Final evidence-document review | PASS: current QA and handoff additions distinguish root reruns, writer read-only checks, dirty development provenance and unrun GUI/public release/install/upgrade; approval remains in this separate reviewer lane |
| Final evidence/report document checks | PASS: three files, 13 relative file/fragment links, fences, whitespace and final newlines; unchanged implementation fingerprint confirmed |
| Direct filesystem Markdown validation | PASS: 14 authored Markdown files, 88 relative file/fragment links, R01–R17 rows, D01–D14, P0–P7, balanced fences and whitespace; included untracked docs |
| String-table/static key audit | PASS: 109 en/ko keys, nonempty values, exact format-placeholder parity, and 86 literal `L10n.text`/`format` key usages present; dynamic branch keys also inspected |
| Shell syntax | PASS: all ten shell scripts including build/install/prepare/publish/common/content/notarization/gate/resource tests |
| Plist/string syntax | PASS: `resources/Info.plist`, `resources/local-entitlements.plist`, and both `Localizable.strings` tables |
| `bash scripts/test-release-gates.sh` | PASS: 16 mode/acknowledgement/configuration/dirty/review/tag rejection cases; no remote/Keychain access |
| `python3 scripts/test-release-archive.py` | PASS after correction: valid framework symlink and ditto metadata, 13 unsafe cases; original suite lacked the valid metadata-root case |
| Additional valid-metadata reproduction | Initial FAIL established the finding; corrected valid-metadata regression now passes; synthetic archive only, no extraction or install |
| `bash scripts/test-resource-bundle.sh` | PASS after correction: 22 native/flat layout, missing-language, nonregular-table and symlink checks; temporary fixtures only |
| Fresh sealed development bundle | PASS: independent deep/strict codesign, actual ad-hoc/no authority/no team, exact ShotClip identity/executable/0.4.0/build5, arm64, canonical feed/key, signed update/feed flags, checks OFF and 109 bundled en/ko keys |
| Final bundled diagnostic | PASS: independently ran `dist/ShotClip.app/Contents/MacOS/shotclip --localization-self-test`; exit 0, installed bundle, 109 keys, en/ko lookup and fallback |
| Final actual macOS archive | PASS: independently ran `python3 scripts/verify-release-archive.py dist/shotclip-package-final-qa.zip` and `unzip -tq`; original real ZIP inspection confirmed metadata root, both language tables, 406 entries and nine framework links |
| `git diff --check` | PASS for tracked changes; untracked document/string whitespace checked directly |
| Renaming/privacy scan | Legacy source/script matches are selected defaults, verified old installation/backup/process checks, and existing Keychain account anchors; no user-specific absolute documentation paths found; sensitive capture/clipboard output paths absent |

## Requirement review

These are implementation/review observations, not completed GUI acceptance.

| Requirement | Evidence reviewed | Remaining runtime or delivery evidence |
| --- | --- | --- |
| R01 | `Sources/shotclip/Services.swift:21` validates and registers the candidate before removing the old hotkey; localized recorder/conflict handling in `AppDelegate.swift:186` | Real registration/entry and change/restart UI |
| R02 | `Overlay.swift:44` and unchanged geometry handle valid confirmation, clamping, move/resize and session region reuse | Fixed-region GUI and pixels |
| R03 | `Overlay.swift:77` and `:95` preserve bounded drag normalization/release | Reverse/invalid drag GUI |
| R04 | `Services.swift:70` encodes PNG/TIFF and snapshots before replacement; `AppDelegate.swift:116` shows success only after store succeeds | Real image copy |
| R05 | No automatic paste/key injection; EN/KO README explains image-capable paste and Preview | Actual paste |
| R06 | `PermissionStatus.swift:11` uses effective preflight; `AppDelegate.swift:93` gates selection and `:149` requests only through the explicit action; no grant-history inference/TCC manipulation | Grant/deny/revoke/recheck/restart |
| R07 | Unchanged `Geometry.swift:18` maps/snaps bounded display-local points; `Services.swift:52` resolves display ID/scale | Mixed-scale hardware, negative-origin captures, macOS 14/Intel |
| R08 | `Services.swift:57` excludes the current process and `:62` disables cursor; `AppDelegate.swift:115` hides normal overlay | Actual exclusion/pixels |
| R09 | `Services.swift:73` preserves snapshot bounds, generation guards and distinct rollback errors; core clipboard algorithm unchanged | UI cancel/failure and real clipboard races; OS atomicity limits remain |
| R10 | `Coordinator.swift:14` preserves selecting/processing reentry and `:22` session token/cancel/timeout checks | Repeated GUI capture and recovery |
| R11 | Source scan found in-memory capture and metadata-only diagnostics/harness; no new sensitive storage/logging | User-owned successful-capture observation |
| R12 | `Preferences.swift:53`, `Overlay.swift:40`, `:51`, `:96` separate M mode change from Tab/native key-view focus and localize accessibility labels/value | Native focus, VoiceOver, screen-change/sleep GUI |
| R13 | `UpdateService.swift:26` fails closed on configuration; `release-manifest.swift:34` verifies signed feed and `:63` verifies archive; existing public key retained and automatic checks default OFF | Actual existing-key signing, public assets/feed, real newer-build upgrade |
| R14 | `DesignTokens.swift:5` uses semantic AppKit colors/fonts; settings layout uses wrapping/scrolling and localized controls | Minimum size, both languages, light/dark/contrast/transparency rendering |
| R15 | `main.swift:2` keeps diagnostic separate; `Localization.swift:8` captures launch language, `:16` uses installed resources, `:28`/`:35` prepare/save explicit choice; English fallback in core `Localization.swift:36`; final packaged diagnostic PASS | User language restart/layout and system/Sparkle language behavior |
| R16 | Package/plist/scripts use ShotClip / `dev.shotclip.app` / `shotclip` / `ShotClip.app`; `Preferences.swift:25` copies valid missing shortcut/mode only; `install-app.sh:27` preserves recoverable old/new backups | Actual manual migration/installer rollback and fresh TCC grant; login remains opt-in |
| R17 | `release-common.sh:29` requires explicit acknowledged ad-hoc mode, `:55` requires clean reviewed HEAD/tag; publisher `:17` snapshots assets, `:31` checks remote/GitHub tag, `:52` compares uploaded bytes; safe real ZIP checks pass; no security bypass | Reviewed commit/tag preparation, exact release/upload/canonical-feed checks, clean-account first launch |

The exact Sparkle 2.10.0 local primary sources were inspected for signed-feed format (`common_cli/Signing.swift`, `Sparkle/SPUExtractSignedFeed.m`), ad-hoc/unchanged EdDSA update policy (`Sparkle/SUUpdateValidator.m:271`), and lookup-only `generate_keys -p` (`generate_keys/main.swift:206`). This supports source compatibility review; it does not prove a real upgrade or key access occurred.

## Evidence supplied by authors/coordinator

The release-author report records 25 synthetic crypto/policy rejection cases, the initial 16 gate rejections and eight archive cases, and no real existing-key access/build/install/publication. Its Swift result is author-provided evidence, not a reviewer rerun. Root independently reran `swift test` at 01:37:58 and finally 01:54:06 KST: 34 XCTest tests, zero failures, confirmed from `dist/core-qa.log` and `dist/core-final-qa.log`; the separate Apple Testing runner's zero tests are not counted. The first package/diagnostic failures were resolved; final `dist/package-qa.log` records production build success (3.97 seconds), icon generation, nested/app/fixture signing and packaging. The reviewer independently verified the final deep/strict signature, packaged diagnostic and real archive, rather than treating the authors' summaries alone as proof.

Root additionally reported fresh serialized release-suite reruns at 01:55:40 KST, all exit 0: valid synthetic manifest cases in both modes and 25 crypto/policy negatives, 16 release gates, 13 unsafe ZIP cases plus two valid cases, and 22 resource fixtures. Root reported lookup-only `generate_keys --account sshot -p` matching the canonical public key, without export, regeneration or rotation; this is existing-key lookup evidence, not final archive/feed signing. These Swift/key results are coordinator-supplied; this reviewer did not run Swift or access the Keychain. The final QA/handoff writer's additions were independently read and checked against this evidence before settlement.

The tested artifact is explicitly `SHOTCLIPReleaseMode=development`, from uncommitted source with baseline `SHOTCLIPSourceCommit=4f5dcaee4dfa95e5603c57c5760e75c90aeb6503`. It is fast development QA evidence, not a final reviewed-commit release artifact.

## Limitations and handoff

Capture GUI, Screen Recording grants, paste, VoiceOver/native focus, language layout/restart, actual installer rollback/migration, clean-account/downloaded first launch, Intel/macOS 14, uploaded assets/public feed, and actual updates are unverified. Developer ID/notarization is deliberately outside the approved preview; ad-hoc codesign or Ed25519 validity must not be labeled Gatekeeper/notarization/TCC PASS. Captured content, clipboard data, app/window names, and keys were not collected.

At review start, branch was `main`, baseline HEAD `4f5dcaee4dfa95e5603c57c5760e75c90aeb6503`, with shared uncommitted/untracked rebrand changes. Reviewer modification: this report only. No commit/push/remote equality or final artifact provenance claim is made. Next: coordinator commits/pushes the reviewed source, prepares the matching tag and clean ad-hoc artifact, verifies actual existing-key archive/feed signing and uploaded/canonical assets, and records install/GUI/upgrade coverage separately. Source changes require a fresh review of the affected scope; evidence-only handoff/QA updates must remain honest.

Final implementation snapshot: 46 files total, comprising files under `Sources`, `Tests`, `resources`, `scripts`, and `Package.swift` and `Package.resolved`; SHA256 `3038e9f1b7b8ed48c2cbcad2212895e822d357b3548a78a5637e92d83d8e9378`. Reproduce with Python `sorted()` on relative `pathlib.Path` objects (component-wise ordering), then hash each UTF-8 `str(path)`, NUL, file bytes, NUL in that order. Sorting complete path strings instead produces `e3d5d457f264573e08d0866f463f7ce46eba456a83c0e0b762914ade62737190` for these same unchanged files. Documentation and this report are excluded from both implementation fingerprints.

## 한국어

최종 판정은 코드·문서·로컬 패키징 범위에서 **APPROVE**입니다. 정상 `ditto` 메타데이터 거부와 SwiftPM 리소스 구조 불일치 두 결함, 진단 URL 비교의 오검출을 별도 작성자가 수정했고 독립 재검토했습니다. 조정자의 최종 34개 테스트와 빌드가 통과했으며 검토자가 deep/strict 서명, 109개 영어/한국어 문자열의 설치 번들 진단, 실제 ZIP을 직접 재검증했습니다. 현재 산출물은 미커밋 개발 QA용이며 최종 배포 commit/tag 자료가 아닙니다. 실제 GUI·권한·붙여 넣기·설치·깨끗한 계정 첫 실행·공개 서명 feed·업그레이드는 통과로 표시하지 않고 별도 증거가 필요합니다.
