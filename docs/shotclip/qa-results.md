# Shot Clip QA results

[QA plan](qa-plan.md) · [Verification](verification.md) · [Handoff](handoff.md)

## 2026-10-05 0.5.0 publication, installation and cleanup

Shot Clip **0.5.0 (build 7)** is the latest public release: [v0.5.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.5.0) · [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/shotclip-0.5.0.zip). Published 2026-10-05 04:30:38 KST (2026-10-04T19:30:38Z), neither draft nor prerelease. **Ad-hoc signed; NOT notarized; arm64 only.** Source/tag/manifest/installed app identify `3d803a9c45f72c1eb3c7328ca68321e1fdb1d2b4`; subsequent documentation commits do not change artifact provenance.

| Check | Result and bounded evidence |
| --- | --- |
| Reviewed source and preparation | Separate [source review](qa-review-0.5.0.md) APPROVE; coordinator atomic main/tag push and clean-source preparation passed. Separate prepublication artifact APPROVE: `dist/review-0.5-prepublication.txt`. Existing Keychain `sshot` key used without export/rotation/regeneration |
| Automated/package checks | Coordinator: 34 core tests, 25 crypto/policy rejections, 16 release gates, 22 resource fixtures, 15 unsafe/two valid ZIP cases and eight signed temporary installer cases PASS. Final development build `dist/ui-0.5-build-5.log` and 125-key en/ko diagnostic PASS; fixture rollback is not real-app rollback |
| Safe native-view previews | Four inert English/Korean light/dark runs produced 76 synthetic images, including minimum/default pane layouts and menu models; `overlayKeyboardInvariants:true`. Five invalid argument cases exited 64 without output/startup. No capture, clipboard, preferences, TCC, hotkey or updater mutation; menu models do not test status-menu popups |
| Limited actual native inspection | Coordinator CUA checked English dark/default General, Access and Updates, the app's main menu open/Escape, and troubleshooting expand/collapse. Capture Area with missing access routed to Access without a system prompt or capture. Native Tab in General/Updates showed no observable accessibility-tree change and is **not PASS** |
| Public assets and installed app | Coordinator and separate verifier (`/root/explore`) PASS: all six live assets/canonical feed matched prepared bytes; Ed25519 archive/feed, manifest/checksums and ZIP/CRC passed. `/Applications/Shot Clip.app` has exact 0.5.0(7) source/ad-hoc metadata and deep/strict signature; all 168 entries (92 files, nine symlinks, 67 directories) match the public payload. Installed 125-key diagnostic PASS and one normal canonical instance confirmed; prior unspaced path absent |
| Superseded-version cleanup | After publication/install verification, v0.4.1 and six assets were removed; v0.5.0 is the sole public release. Twelve verified local items moved recoverably to Trash: nine generated apps/fixtures (including three superseded 0.5 development bundles), one prior installed backup and two old release directories. Separate verifier confirmed moves and retained latest assets/source/tags |

Archive: 2,516,248 bytes, SHA256 `768bf6043bd21cab373cadaca94154cf0a242e9141304b7b4f6ec735f8dcdb68`. Feed: 1,270 bytes, SHA256 `61f35332331845fbe03b8ffbe8085312a07739e6e779c91bd7c23f16859a95b7`. Public [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/SHA256SUMS) / [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/release-manifest.json). Ignored evidence: `dist/*-0.5*.log`, `dist/installed-metadata-0.5.json`, `dist/public-0.5.0-verification`, `dist/releases-after-0.5-cleanup.json`, `dist/visual-qa/cleanup-{plan,results}-0.5.json`.

Installed Finder reopen showed General and the new icon; the first quiet-launch observation timed out and does not prove quiet-launch behavior. Only the app's own window was inspected inline, without storing its screenshot. Stable ID/preferences/capture engine/key/feed remain; automatic checks are opt-in OFF. No TCC, quarantine, Gatekeeper or key changes. **Unrun:** actual capture/pixels, permission grants/TCC, paste, VoiceOver/native focus, status-menu popup, language restart, clean-account first launch, macOS 14/Intel runtime and an end-to-end Sparkle upgrade. Independent final documentation review and coordinator documentation commit/push follow this authoring record.

한국어: 04:30:38 KST에 0.5.0(7)을 공개하고 새 `Shot Clip.app` 설치·125개 언어 키·산출물 6개/feed·168개 설치 항목 일치를 확인했습니다. 별도 공개 자료/정리 검증도 통과했습니다. 최신 검증 뒤 0.4.1 공개 릴리스/산출물과 로컬 구버전 12개를 정리했으며 로컬 자료는 휴지통에서 복구 가능합니다. 제한된 영어 native 점검과 합성 미리보기는 실제 캡처·권한·붙여 넣기·접근성·자동 업그레이드 통과를 뜻하지 않습니다. 구현/tag `3d803a9`와 후속 문서 commit은 구분합니다.

All older dated audits below remain unchanged. Their v0.4.1/v0.4.0 public release/download URLs are historical and unavailable after user-authorized removal; use current links above. Earlier local evidence may now be recoverable Trash contents.

## 2026-10-05 0.4.1 visual refresh publication, installation and cleanup

ShotClip **0.4.1 (build 6)** is the latest public release: [v0.4.1](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.4.1) · [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/shotclip-0.4.1.zip). Published 2026-10-05 02:52:28 KST (2026-10-04T17:52:28Z), neither draft nor prerelease. **Ad-hoc signed; NOT notarized; arm64 only.** Tag, manifest and installed app identify reviewed source `24f73ed008028d7e957df1e485af02e65a38c25f`; a later documentation commit on `main` does not change that artifact source.

| Check | Result / evidence owner and bounded evidence |
| --- | --- |
| Icon and brand artwork | Visual executor authored original, deterministic AppKit/vector artwork and four PNG/SVG assets; small/large icon and hero inspection completed. Independent source reviewer APPROVE covers the 15-file source set (fingerprint `cb3330e56047230a443c2cc6a18412a8fa7194c0a3094ca504b99b8935112faf`); flattened ICNS is not Icon Composer/Liquid Glass support |
| Fast checks | Coordinator `dist/visual-qa/core-tests-0.4.1.log`: 34 XCTest tests, zero failures. Separate verifier: 25 crypto/policy negatives, 16 release gates, 13 unsafe plus two valid ZIP cases, 22 resource fixtures and five source documents/44 relative links PASS. These are automated/source checks, not capture GUI acceptance |
| Source and release preparation | Coordinator atomic `main`/`v0.4.1` push verified local/remote peeled tag alignment. `dist/visual-qa/prepare-public-0.4.1.log`: clean reviewed-source ad-hoc release preparation and existing Keychain `sshot` signing passed; no key export/rotation/regeneration |
| Public assets and signed feed | Coordinator publisher check/publication and redownload byte comparisons passed for all six assets. Public-key manifest/feed/archive verification and ZIP validation passed; canonical latest feed matched the tag/prepared asset. Evidence: `dist/visual-qa/{publish-check,publish-public,public-signature}-0.4.1.log`, `dist/public-0.4.1-verification/release-metadata.json` and `SHA256SUMS` |
| Latest installation and startup | Coordinator `dist/visual-qa/install-public-0.4.1.log`: installed `/Applications/ShotClip.app`, `dev.shotclip.app`, executable `shotclip`, 0.4.1(6), exact source/ad-hoc metadata, deep/strict signature; executable and icon matched release bytes. Installed localization PASS: 109 en/ko keys, fallback/installedBundle true; exactly one normal installed-app running instance confirmed |
| Superseded versions | After new publication/installation checks, coordinator removed the v0.4.0 GitHub release and its six assets; v0.4.1 is the sole live release. Git tags/source history remain. Thirteen verified local items were recoverably moved to Trash: eight older apps/fixtures, one superseded 0.4.1 development app, two older release directories and two QA ZIPs. Plan/results: `dist/visual-qa/cleanup-{plan,results}-0.4.1.json`; latest app/archives retained |
| Independent public-artifact/cleanup verification | Separate verifier (`/root/explore`) PASS: six fresh HTTPS downloads and canonical feed matched prepared/root bytes; signatures/manifest/checksums/ZIP passed, remote source/tag matched, and all 101 installed entries (92 files/nine symlinks) matched public payload with no extras. Installed icon SHA256 `9616455c626e0c28c72da2877340563487f7f31298a650ff9f341ad5a4f0a094`; 109-key diagnostic and all 13 original-path absences/Trash identities passed |

Archive: 2,439,939 bytes, SHA256 `afca5c72abe5f898299414377b59e43f554ff16cbfd9ef8adfc2415dc76e30e7`. Feed: 1,269 bytes, SHA256 `d65c44d0babe87d6c542d72b31368fa687b7ff81bd052de05e5245e38d2add40`. Published [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/SHA256SUMS) and [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/release-manifest.json) record the signed set. Local `dist/` evidence is ignored. A cleanup helper compile error was corrected before any Trash operation; the failed preflight log remains, and the subsequent cleanup passed.

English remains the default, Korean applies after restart, automatic checks remain opt-in OFF, and the established bundle ID/preferences/Ed25519 trust remain unchanged. No TCC, quarantine or Gatekeeper settings changed. **Unrun:** capture/pixels, Screen Recording/TCC, paste, VoiceOver/native focus/rendered language/layout, clean-account downloaded first launch, macOS 14/Intel runtime, rollback and real same-ID automatic upgrade. Independent public-artifact/cleanup verification passed; final documentation review is pending at this writer record. This authoring lane reports evidence without issuing approval or a documentation commit/push result.

한국어: 0.4.1(6)을 02:52:28 KST에 공개하고 산출물 6개·서명 feed/ZIP·정확한 최신 설치/정상 실행을 확인했습니다. 구현 source/tag는 `24f73ed`이며 후속 문서 commit과 구분합니다. 최신 검증 뒤 0.4.0 공개 릴리스/산출물을 제거하고 로컬 13개 항목을 복구 가능한 휴지통으로 이동했습니다. 소스·태그·기존 키와 최신 자료는 유지합니다. arm64 전용 ad-hoc·미공증, 자동 확인 OFF이며 실제 캡처·권한·붙여 넣기·GUI·깨끗한 계정·macOS 14/Intel·rollback·자동 업그레이드는 미실행입니다. 별도 공개 산출물/정리 검증은 통과했고 최종 독립 문서 리뷰와 문서 commit/push는 이 기록 시점에 별도 작업입니다.

All older dated audits below are retained unchanged. Their v0.4.0 release/download URLs are now historical and unavailable because the user authorized superseded-release removal; use the current links above. Earlier local evidence paths may now identify recoverable Trash contents rather than active `dist/` files.

## 2026-10-05 verified publication and installation

ShotClip **0.4.0 (build 5)** is public: [v0.4.0 release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.4.0) · [ZIP download](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/shotclip-0.4.0.zip). Published 2026-10-05 02:05:55 KST (2026-10-04T17:05:55Z), neither draft nor prerelease. **Ad-hoc signed; NOT notarized; arm64 only.** The immutable tag, archive manifest and installed bundle record implementation commit `ab57fcace589f2c786ba183778d1b1bb4e77fe87`; later documentation commits on `main` do not change that artifact provenance.

| Check | Verified result and evidence owner |
| --- | --- |
| Reviewed source/tag | Coordinator atomic push of `main`/`v0.4.0` succeeded; writer read-only local HEAD and remote peeled tag/main matched the implementation commit before these documentation edits. Independent source verdict is in [QA review](qa-review.md); this writer gives no approval |
| Clean-source preparation/signing | Coordinator `dist/prepare-public-0.4.0.log`: reviewed clean-source build, existing Keychain `sshot` lookup and real signed appcast/archive generation passed. `SHOTCLIPReleaseMode=ad-hoc`; no key rotation/export/regeneration |
| Publication and public bytes | Coordinator publisher `--check`/`--publish` passed; all six draft uploads were downloaded and compared before publication. Writer GitHub read confirmed public status and ZIP, `appcast.xml`, `SHA256SUMS`, `release-manifest.json`, `RELEASE-NOTES.md`, `README.txt`; release/ZIP/feed HTTP 200 and remote ZIP/feed bytes matched `dist/public-0.4.0-verification` |
| Public signature/archive/feed checks | Coordinator public-key-only manifest/feed/archive verification and ZIP validator passed with explicit `SHOTCLIP_RELEASE_MODE=ad-hoc`, `SHOTCLIP_BUILD_NUMBER=5`. An initial standalone invocation without release mode failed closed; corrected verification passed without asset changes. [Canonical signed feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) bytes matched the prepared/tag asset |
| Installation and normal local startup | Coordinator `dist/install-public-0.4.0.log` passed after quitting the exact old app normally. Writer read `/Applications/ShotClip.app`: `dev.shotclip.app`, executable `shotclip`, 0.4.0(5), exact implementation commit/ad-hoc mode, binary identical to release build. Coordinator deep/strict signature, installed localization JSON PASS (109 en/ko keys, `installedBundle:true`, `fallback:true`) and normal installed-app process confirmation passed; no GUI acceptance claim |
| Recoverable legacy cleanup | Coordinator `dist/legacy-cleanup-0.4.0.log`: verified old 0.3.0 backup, `dist/sshot.app`, `dist/sshot-fixture.app`, `dist/sshot-0.3.0.zip` moved to Trash; original paths absent, four items recoverable. Current/latest apps and signing key preserved |

Archive: 2,342,408 bytes, SHA256 `44efdefe0897e75a978677cc01a2adb0c5176da1caf8e3af3ccde3d1f6f2fb69`. Feed: 1,269 bytes, SHA256 `844c60719f3740dcba3da4fc8038ad19a89e3d04425a3cd0eb06d4403424a166`. See published [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/SHA256SUMS). Local `dist/` evidence remains ignored.

English is the default; select English / 한국어 and restart to apply. Automatic checks are opt-in and OFF. Historical Sshot needs one manual ShotClip installation; valid shortcut/mode migration is implemented, while Screen Recording needs a fresh grant and login/consent do not migrate. No TCC, quarantine or Gatekeeper changes were made.

**Unrun:** user-owned capture/pixels, Screen Recording/TCC, paste, VoiceOver/native focus and rendered language/layout; downloaded first launch in a clean account, macOS 14/Intel runtime, installer rollback and a same-ID newer-build automatic upgrade end-to-end. Only normal local startup on the arm64 host was confirmed. Separate final release/document review remains with the reviewer; publication is not full app QA.

한국어: 0.4.0(5)를 2026-10-05 02:05:55 KST에 공개하고 공개 자료/feed·기존 키 서명·로컬 설치/정상 시작을 확인했습니다. tag·ZIP·설치 앱의 구현 commit은 `ab57fca`이며 후속 문서 commit과 구분합니다. arm64 전용 ad-hoc·미공증 프리뷰이고 영어 기본/한국어는 재시작 적용, 자동 확인은 기본 OFF입니다. 과거 Sshot은 한 번 수동 설치하고 화면 기록을 새로 허용해야 합니다. 실제 캡처·권한·붙여 넣기·GUI/접근성·깨끗한 계정·macOS 14/Intel·rollback·실제 자동 업그레이드는 미실행이며 독립 최종 리뷰는 별도입니다.

The following two 2026-10-05 sections are retained prepublication documentation/development QA snapshots. Their development baseline and pending publication/installation statements describe that earlier stage and are superseded by the verified record above.

## 2026-10-05 documentation and rebrand scope

Current brand/repository: ShotClip / `kyungseok-lee/shotclip`. The development bundle now verifies as `dev.shotclip.app`, executable `shotclip`, version `0.4.0` (build `5`); `/Applications/ShotClip.app` remains the installation target. The authorized route is GitHub ad-hoc developer preview; Developer ID/notarization is outside this release, and the old certificate gate below is historical.

| Check | Status in this documentation task | Evidence / limit |
| --- | --- | --- |
| Source and old-document inspection | Performed | AppDelegate, Overlay, SettingsWindow, Services, permission/update/core preferences and release scripts; no GUI operation |
| Apple primary-source consultation | Performed | Native design/accessibility/materials/privacy/localization and first-launch guidance; methods in [technical validation](technical-validation.md) |
| Product/development/design plans and EN/KO docs | Authored; document checks passed | 14 Markdown files, 88 local links/fragments, R01–R17, D01–D14, P0–P7, bilingual companions, explicit prediction column, whitespace/fences; this is not app QA |
| ShotClip automatic tests/build/signatures | Not run by this worker | Code/release workers report their own exact evidence; historical counts below are not a new pass |
| Capture/permission/paste GUI | Not run; user-owned | No TCC changes, actual capture, or general clipboard writes |
| VoiceOver/native focus/language layout GUI | Not run | Source/key mapping review cannot establish assistive or rendered UI behavior |
| Install, Git commit/push, release, real upgrade | Not performed by this worker | Ownership limited to docs; source/tag/public feed and manual legacy migration need separate evidence |

한국어: 현재 제품은 ShotClip이고 승인된 배포는 ad-hoc 개발자 프리뷰입니다. 이 작업은 문서와 원문/소스 확인만 수행했으며 실제 캡처·권한·붙여 넣기·VoiceOver·포커스·설치·게시·업그레이드를 통과로 표시하지 않습니다. 아래 이름·경로·commit·테스트 수와 과거 production gate는 당시 Sshot 증거이며 현재 ShotClip 상태로 확대하지 않습니다.

## 2026-10-05 current code and package QA

Environment inspected: macOS 27.0.1 (26A434), Xcode 27.0 (27A266a), Swift 6.4, arm64. Evidence below supersedes the proposed-version wording for the local development bundle only. Its sealed metadata is `SHOTCLIPReleaseMode=development` and `SHOTCLIPSourceCommit=4f5dcaee4dfa95e5603c57c5760e75c90aeb6503`; it was packaged from dirty source on `main`, not a final reviewed release commit. Logs and archives under `dist/` are ignored local QA evidence.

| Check | Result / evidence owner | Evidence and limit |
| --- | --- | --- |
| `swift test` | PASS, root final rerun | `dist/core-final-qa.log`: 2026-10-05 01:54:06 KST, 34 XCTest tests, zero failures; the separate Apple Testing runner's zero tests are not added |
| `bash scripts/build-app.sh` | PASS, root rerun, exit 0 | `dist/package-qa.log`: production compile, icon generation, nested/app/fixture signing and `dist/ShotClip.app` packaging completed after resource-layout correction |
| Sealed bundle identity/resources/signature | PASS, writer read-only reinspection | Actual ShotClip / `dev.shotclip.app` / `shotclip` / 0.4.0(5), arm64; `codesign --verify --deep --strict --verbose=2` passed; `Signature=adhoc`, no authority/team; packaged en/ko tables each contain 109 keys |
| Installed-resource diagnostic | PASS, coordinator-supplied JSON | `fallback:true`, `installedBundle:true`, `keyCount:109`, languages `en`/`ko`; this verifies packaged resource lookup and fallback, not rendered language, installation in Applications, or capture |
| Release regression suites | PASS, root reruns reported at 01:55:40 KST, all exit 0 | `swift scripts/test-release-manifest.swift`: valid synthetic cases in both modes and 25 crypto/policy negatives; `bash scripts/test-release-gates.sh`: 16 gates; `python3 scripts/test-release-archive.py`: 13 unsafe ZIP cases plus two valid cases; `bash scripts/test-resource-bundle.sh`: 22 resource fixtures. The writer did not rerun these suites; the earlier supplied release-author report had eight archive negatives |
| Fresh real package ZIP | PASS, root creation and writer read-only checks | Fresh `ditto` archive `dist/shotclip-package-final-qa.zip` (2,342,408 bytes); `python3 scripts/verify-release-archive.py dist/shotclip-package-final-qa.zip` and `unzip -tq dist/shotclip-package-final-qa.zip` passed. Archive metadata matches 0.4.0(5); this is a development QA archive, not a public release asset |

Independent approval belongs to the separate reviewer in [QA review](qa-review.md); this authoring record does not issue a verdict. The legacy Keychain account `sshot` and existing Ed25519 trust remain preserved without key rotation, export or recreation; this writer performed no Keychain access, TCC reset, or security bypass.

Still unrun and user-owned: capture, Screen Recording permission flows, paste, rendered English/Korean layout, VoiceOver and native focus. macOS 14 and Intel runtime are untested; the current artifact intended for public preparation is arm64. Commit, push, tag, final reviewed-source release preparation/signing, public assets/feed, installation/manual migration and end-to-end upgrade remain pending coordinator operations. Ad-hoc code-signature validity is not Gatekeeper, notarization or TCC approval.

한국어: 조정자의 최종 34개 XCTest·빌드와 25개 암호 거부·16개 gate·13개 unsafe ZIP·22개 리소스 fixture 재실행 결과를 기록했습니다. 문서 작성자는 번들 메타데이터·서명·109개 영어/한국어 키와 실제 ZIP만 읽기 전용으로 재확인했으며, 리소스 진단은 조정자가 제공한 JSON 증거입니다. 0.4.0(5)는 baseline `4f5dcae`의 미커밋 소스로 만든 개발 QA 자료이며 최종 배포가 아닙니다. 독립 승인은 별도 reviewer가 맡고, 수동 GUI·macOS 14/Intel·commit/push/tag·설치·공개 게시·실제 업데이트는 미완료입니다.

## Historical Sshot audit — retained as recorded

Everything below is historical 2026-10-04 evidence. Legacy `Sshot`, `sshot`, `dev.sshot.app`, old archive names, and `/Applications/sshot.app` identify what was actually tested; they are not current instructions. The prior “preview approval unanswered” statement has been superseded by the approved ad-hoc route above.

날짜: 2026-10-04. 환경: macOS 27.0.1 (26A434), Xcode 27.0, Swift 6.4, arm64.

아래 상태는 실제 명령·앱 관찰 후 갱신한다. 코드 리뷰, 자동 테스트, 현재 Mac에서의 UI QA, 다른 환경에서의 배포 QA는 서로 대체하지 않는다.

최신 사용자 지시에 따라 실제 캡처/권한 수동 QA는 사용자 인수 상태입니다. 에이전트는 코드 검토·빠른 자동 검증 후 코드 commit/push를 진행할 수 있으며 아래 미검증 runtime 항목을 통과로 바꾸지 않습니다. 공개 앱 release·실제 업데이트 성공은 별도 production gate입니다.

| 검증 | 현재 상태 | 증거 및 범위 |
| --- | --- | --- |
| 기술 probe | 통과 | [기술 기록](technical-validation.md): SDK 컴파일, exclusive hotkey 중복 오류, named pasteboard PNG/TIFF |
| 자동 회귀 | 통과 | 최신 부모 실행 2026-10-04 23:38:30 swift test 25개, 0 failure. 기존 20개에 permission presentation 2개·update configuration 3개 추가 |
| release app bundle | 통과(로컬) | 현재 0.3.0(build 4) clean 구현 HEAD release·ICNS·codesign --verify --deep --strict 통과, /Applications 설치 재확인. 0.2.0/0.2.1은 과거 검증 기록. ad-hoc이며 Developer ID 배포와 구분 |
| 실제 합성 화면 캡처 | 과거 0.2.1 SKIP / 사용자 인수 | 0.2.1 self-test metadata SKIP, 3 display harness 준비. 0.3.0 self-test는 실행하지 않았으며 통과 아님 |
| 고정 마스크 UI | 미실행 | 이동·resize·확정·취소·재사용 |
| 즉시 드래그 UI | 미실행 | 정방향·역방향·무효 영역·모드 전환 |
| 전역 단축키/설정 | 부분 통과 | Finder 활성화 시 변경한 키가 sshot 권한 안내를 여는 것 확인. 설정 저장·재실행 및 기본값 복구 확인. Shift 숫자 label 버그 수정 후 ⌃⇧⌘5 표시 확인. 반복 호출·실제 overlay는 권한 대기 |
| 다른 앱 이미지 붙여 넣기 | 미실행 | 합성 화면만 사용해 일반 clipboard와 Preview 검증 |
| 독립 코드/자동 검증 검토 | 통과(제한 범위) | 별도 scratch build에서 20 XCTest 재실행, 소스 검토 통과. 실제 화면·배포 포함 전체 QA 승인은 아님 |
| 다중 모니터/혼합 배율 실제 QA | 권한 대기 | 실제 3 display: 2x main, 음수 원점 2x, 오른쪽 1x. 순수 좌표 테스트 통과, 실제 pixel 검사 SKIP |
| macOS 14/Intel 실행 | 미검증 | 현재 host 최신 macOS/arm64로 대체 불가 |
| 권한 철회/sleep-wake/깨끗한 계정 | 미검증 | 사용자 환경 설정을 자동 reset하지 않음 |
| Developer ID/공증/Gatekeeper | 차단 | 유효 signing identity 0. 인증서·공증 및 별도 환경 필요 |
| 권한 안내 개선 | 부분 통과 | 설치 앱의 AX·화면으로 주황색 권한 미적용·비활성 캡처·ad-hoc 안내·경로/버전 확인. 다시 확인의 미허용 상태 유지, 같은 /Applications 앱 재시작·0.2.0(build 2)·기본 단축키 안내 확인. 설정 버튼은 시스템 설정의 ‘화면 및 시스템 오디오 녹음’ 페이지, 현재 앱 위치 버튼은 Finder Applications의 sshot.app 선택으로 확인. 권한 요청 및 실제 허용 후 갱신은 미검증 |
| Sparkle 자동 업데이트 | 로컬 구성·서명 QA 통과 / 공개 종단간 미검증 | 현재 0.3.0은 실제 공개키/GitHub feed 유지·설정 UI 확인. archive/feed 암호 검증은 0.2.1 로컬 QA 증거. 0.2.0 미설정 modal은 과거 회귀 증거. 공개 asset 미게시, 실제 업그레이드 없음 |

별도 reviewer가 권한 상태·정확한 bundle 재시작/단축키 해제·복구, Sparkle fail-closed 구성, 내부부터의 framework/helper 서명, installer 백업·검증·복원, 릴리스 script의 기존 키 조회 및 게시 미수행을 검토하여 차단 결함 없음을 확인했습니다. shell syntax와 diff 검사 통과. 독립 scratch 테스트의 실행 결과 로그는 회수하지 못했으므로 추가 통과 증거로 사용하지 않습니다.

첫 UI 자동화 provider는 window_not_focused 오류로 클릭을 완료하지 못했습니다. 이후 사용 가능한 대체 UI 도구로 업데이트 확인·다시 확인·재시작을 실제 실행하고 위 표의 제한 범위를 확인했습니다. 재시작 직후 기존 프로세스 조회 실패는 종료에 따른 정상 상태이며 새 프로세스의 같은 앱 경로·안내 창을 별도로 확인했습니다. 3-screen self-test의 window lifetime crash 수정은 소스에 반영했으나 현재 권한 SKIP이므로 수정 후 실제 캡처 경로의 runtime 통과는 미검증입니다.

## 요구사항별 완료 감사

### 0.2.1(build 3) GitHub 구성 후속 증거

Keychain `sshot` Ed25519 키 생성, 개인 키 export 없음. 공개키·GitHub stable feed 포함 앱을 로컬 빌드·nested deep/strict 서명 검사 후 `/Applications/sshot.app`에 설치했습니다. 실제 UI에서 설정된 updater 설명·활성 자동 확인 toggle(OFF 기본값)을 확인했으며 화면 기록 권한은 여전히 미적용입니다. 독립 자동 테스트 25개 및 synthetic negative 6개 통과가 보고되었습니다. 이전 미설정 안내 UI 결과는 0.2.0 기록입니다.

Keychain 승인 후 `generate_appcast`가 새 update 1개를 생성하고 exit 0으로 완료했습니다. 실제 0.2.1 테스트 zip(1,178,413 bytes)과 canonical tag URL·최소 OS 14·arm64 feed를 생성했으며 공식 `sign_update --account sshot --verify` 및 공개 CryptoKit manifest/archive 검증이 exit 0으로 통과했습니다. 산출물은 ignored dist의 로컬 QA 자료로, 생성 당시 ad-hoc 앱·미커밋 소스와 기존 HEAD baseline을 사용했으므로 production release나 최종 커밋 일치 배포 증거가 아닙니다.

설치 앱에서 업데이트 확인 클릭 후 ‘Checking for updates…’ 창을 확인했습니다. Sparkle OS 로그는 실제 canonical GitHub feed 조회의 HTTP 404(code 2001)를 보고했습니다. 공개 asset이 없는 현재 상태와 일치하며 실제 업그레이드 통과가 아닙니다. 최종 오류 UI는 미확인, 앱은 실행 중이고 새 crash는 관찰되지 않았습니다. 최신 LaunchServices self-test JSONL은 권한 미적용 SKIP입니다. 공개 asset·release 게시와 production 서명/공증·종단간 업그레이드는 수행하지 않았습니다.

아래는 현재 파일·자동 테스트·UI 실행 증거의 범위를 연결한 감사입니다. 구현 존재와 전체 수용 기준 완료를 구분합니다.

| ID | 현재 증거 | 남은 완료 증거 |
| --- | --- | --- |
| R01 | 단축키 등록/충돌 probe, 다른 앱에서 권한 안내 진입, 재시작 후 기본 단축키 표시·시작 오류 없음 | 권한 허용 후 실제 캡처 UI 진입·반복 호출 |
| R02 | 마스크 구현과 geometry 자동 테스트 | 실제 이동·핸들 조절·Enter/버튼 확정·영역 재사용 |
| R03 | 드래그 구현과 네 방향 geometry 테스트 | 실제 드래그 종료 캡처·역방향·무효 선택 |
| R04 | PNG/TIFF 및 clipboard 오류 경로 테스트 | 실제 캡처 성공 직후 일반 클립보드 이미지 |
| R05 | 제품 흐름과 수동 QA 절차 | 실제 지원 앱 ⌘V/Preview 새 문서 |
| R06 | 거부 분기 테스트·미허용 안내·재확인·같은 앱 재시작·정확한 시스템 설정 페이지·Finder의 현재 설치 앱 선택 실제 확인 | 권한 요청·실제 허용 후 live 갱신·철회 복구 |
| R07 | 음수 좌표·배율 자동 테스트, 실제 세 화면 harness 준비 | 권한 허용 후 각 화면의 실제 영역·픽셀 비교 |
| R08 | SCK 자체 앱/커서 제외 구현 | 실제 결과에 overlay 없는지 검사 |
| R09 | 취소·오류·rollback·외부 clipboard 변경 보호 테스트 | 실제 UI 취소/권한 철회·실제 clipboard 보존 확인. OS 원자성 한계는 공개 |
| R10 | coordinator 중복·timeout·늦은 결과 테스트 | 실제 캡처 중 반복 단축키·연속 UI 세션 |
| R11 | 로컬 메모리 처리 및 소스 검토, 메타데이터-only SKIP 출력 | 실제 캡처 성공 경로의 로그/임시 파일/메모리 점검 |
| R12 | 메뉴/설정 구현, 안내 렌더링·재시작 실제 확인 | 두 모드 키보드·오류 재시도·sleep/wake·화면 변경 |
| R13 | 실제 GitHub feed URL·공개키 구성, 로컬 Ed25519 archive·signed feed 검증, synthetic negative 6개, 설정 UI·실제 조회/404 확인. 과거 미설정 modal 회귀 증거 | 공개 feed/archive asset 게시, production Developer ID·공증, 공개 종단간 업그레이드·설정/권한 회귀 |

실제 캡처 검증은 사용자 담당으로 남아 있으며 공개 배포·종단간 업데이트도 미완료입니다. 최신 요청에 따른 코드 작업은 독립 검토·빠른 자동 검증 후 commit/push로 인계할 수 있습니다. 이것은 실제 캡처나 공개 앱 배포 완료 선언이 아닙니다.

## 표시·설정 개선 후속 요청

사용자가 이전 버전의 기본 기능에 대해 ‘잘 되는 것 같다’고 보고했습니다. 이는 정성적인 사용 확인이며 새 0.3.0의 캡처·전체 지원 환경 통과 증거는 아닙니다. R14/D11의 표시·설정 변경은 아래 설치 기록을 따릅니다. GitHub Releases는 0개로 삭제 대상이 없고 Developer ID 인증서는 0개입니다. 미공증 developer preview 공개 여부 응답이 없으므로 기존 production 공개 gate를 유지합니다.

### 0.3.0(build 4) 설치 및 설정 확인

- 구현 commit `32685dcb5b03f2ea450798c44e26e10c5eb0a557`의 clean HEAD에서 release 빌드(3.53초)·ICNS 생성·nested deep/strict 서명 검사 통과. `/Applications/sshot.app`에 설치 후 동일 경로·버전·서명 재확인.
- 실제 native 설정 화면의 Sshot 이름·독자 아이콘·일반/권한/업데이트 3섹션, 기본 단축키 `⌃⇧⌘5`, 버전 0.3.0(4), 자동 확인 OFF를 확인. dark appearance의 각 화면을 검사했고 권한 미적용 주황 표시·disabled capture·세부 정보의 현재 경로/ad-hoc 안내를 확인했습니다.
- 일반 크기에서 내용은 보였으나 resize 시도는 실제 창 크기를 바꾸지 못했습니다. resizing/minimum size 동작은 미검증입니다. 실제 캡처는 실행하지 않았으며 사용자 인수 상태입니다.
- 식별자와 버전을 검증한 구버전 앱 7개를 휴지통으로 이동했습니다(Applications 백업 3개, dist 중간 빌드 4개). 원래 경로가 없어졌음을 확인했고 휴지통에서 복원할 수 있습니다. 현재 설치 앱은 유지했습니다.
- `dist/sshot-0.3.0.zip`(약 2.2MB)을 로컬 앱 archive로 생성하고 `unzip -tq` 무결성 검사를 통과했습니다. production 서명·업데이트 feed가 없는 개발용 archive이며 공개 release가 아닙니다. 이전 `dist/github-local-qa.*`의 0.2.1 zip/feed/manifest 3개를 확인한 뒤 해당 QA 폴더도 별도로 휴지통에 옮겼습니다. 현재 앱과 최신 zip은 유지하며 휴지통 자료는 복원 가능합니다.
- stable bundle ID·설정 domain은 유지했지만 실제 ad-hoc 코드 hash는 바뀝니다. 0.3.0에서 권한 미적용 상태를 관찰했으며 새 버전 캡처/self-test는 사용자 인수입니다.
- 공개 GitHub Releases 0개·Developer ID 인증서 0개. 공개 asset 게시·자동 업데이트 성공은 없습니다. 후속 문서 commit은 구현 commit과 다르며 현재 개발 번들을 production artifact로 재사용하지 않습니다.

## 알려진 플랫폼 한계

NSPasteboard 교체와 복원은 OS atomic transaction이 아니다. 캡처·인코딩·snapshot 실패는 쓰기 전에 중단하며, 쓰기 실패는 가능한 경우 기존 타입별 데이터를 복원한다. 다른 앱의 외부 변경은 보존한다. 시스템 write/restore 장애에 대한 무조건적인 데이터 보존은 보장하지 않으며 복원 실패를 별도 오류로 표시한다.

## 재현 명령

실행한 명령: `swift test`, `bash scripts/build-app.sh`, `bash -n scripts/build-app.sh scripts/notarize-app.sh`, `plutil -lint resources/Info.plist`, `git diff --check`. 빌드 스크립트가 release build와 codesign 검증을 수행했다.

이전 직접 binary 실행 기록: `dist/sshot.app/Contents/MacOS/sshot --self-test`는 `{"case":"real-capture","reason":"screen-recording-permission","result":"SKIP"}`, exit 77을 출력했다. 직접 실행은 터미널의 권한 귀속과 혼동할 수 있어 최신 절차는 README의 LaunchServices `open -n -W -o` 방식이다. 최신 실행도 JSON SKIP이며 실제 캡처 통과가 아니다. `open` exit 0을 harness PASS로 해석하지 않는다. 이미지·일반 clipboard 변경 없이 종료했다.

Native UI는 orca computer get-app-state/hotkey 및 실행 후 실제 앱 상태를 확인했다. 합성 키 입력의 provider 성공만으로 통과하지 않고 sshot 권한 modal 또는 설정 label 변화를 확인했다. 앱의 안내 창 스크린샷도 확인했으며 이미지 파일은 저장소에 추가하지 않았다.

시스템 설정의 sshot 스위치는 켜짐으로 관찰했으나 최신 앱의 권한 요청·preflight와 self-test는 여전히 거부/SKIP이다. ad-hoc 서명의 designated requirement는 `codesign -d -r-`에서 cdhash 기반으로 확인했다. 빌드 교체로 기존 허용이 현재 바이너리에 적용되지 않는 상황으로 추정하며, 최신 앱을 기준으로 사용자가 화면 기록 허용을 다시 적용하고 재실행한 뒤 검증해야 한다. 설정 스위치만으로 권한 QA 통과를 주장하지 않는다.
