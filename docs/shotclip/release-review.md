# ShotClip 0.4.0 independent release review

Date: 2026-10-05 (Asia/Seoul). Reviewer: `task_1c81dad4169f` / `ctx_1488a96f9f12`, separate from release operations and documentation authors. This follows the [source and local-package approval](qa-review.md).

## Verdict: APPROVE — public release, installed artifact and final documentation

No blocking defect was found in the public release, installed artifact or final five-document changes. Public assets, signatures, source/tag alignment, installed payload/resources and final documentation passed the independent checks below. This approves the bounded release evidence and the coordinator's documentation commit/push; it does not approve unrun GUI, permissions, clean-account first launch or real upgrade acceptance. No implementation correction was made in this lane.

## Release identity and provenance

- Immutable source/tag: `v0.4.0`, commit `ab57fcace589f2c786ba183778d1b1bb4e77fe87`.
- Product: ShotClip, `dev.shotclip.app`, executable `shotclip`, `ShotClip.app`, version `0.4.0`, build `5`, arm64.
- Distribution: **Ad-hoc signed; NOT notarized.** Ed25519 authenticates the archive and feed; it does not establish Gatekeeper acceptance, Screen Recording permission or an actual upgrade.
- [Public release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.4.0): published 2026-10-04 17:05:55 UTC / 2026-10-05 02:05:55 KST, not draft and not prerelease. Six assets are present.
- Existing public key: `gbN8bdU/ElNPW3vAeX0BCAv4qokA1biQeOUgXNEhdac=`. No private-key or Keychain access occurred in this reviewer lane.

| Asset | Bytes | SHA256 |
| --- | ---: | --- |
| `shotclip-0.4.0.zip` | 2,342,408 | `44efdefe0897e75a978677cc01a2adb0c5176da1caf8e3af3ccde3d1f6f2fb69` |
| `appcast.xml` | 1,269 | `844c60719f3740dcba3da4fc8038ad19a89e3d04425a3cd0eb06d4403424a166` |
| `release-manifest.json` | 631 | `cdd7afc00fa0a88ca64b21a27d6a771f3ae25d82ff2b5e0588334c73a5e6c12e` |
| `SHA256SUMS` | 411 | `55556a22f973522bca22b28b4d55f019730fa8a28e5ac9b70c77bccb06a863f9` |
| `RELEASE-NOTES.md` and identical `README.txt` | 2,017 each | `d258777c15907d66b0627b7da0ee851f9201c80d8d431299f0fc74e1fabc64b5` |

## Independently executed checks

All shell commands used the explicit repository working directory. The coordinator opened the clean-source gate at `PUBLICATION_AND_INSTALL_RECORD_READY` before this report was created and released its Swift lock before public-key verification. Only this report is modified by the reviewer.

| Check | Result and evidence |
| --- | --- |
| Git/source alignment | PASS: `git rev-parse HEAD`, `git rev-parse 'v0.4.0^{commit}'` and `git ls-remote origin refs/heads/main refs/tags/v0.4.0 'refs/tags/v0.4.0^{}'` agreed at the release milestone; remote tag is annotated and its peeled commit matches the source commit |
| Actual implementation | PASS: all 45 committed implementation files total, including Package manifests and files in Sources/Tests/resources/scripts, exactly match `git show` at that commit; the prior 46-file filesystem fingerprint also remains unchanged |
| Live GitHub/API/HTTPS reads | PASS: public release metadata, commit API, six live asset downloads and canonical latest feed were read independently in memory; every asset matches the prepared and coordinator-downloaded bytes and API size |
| Canonical signed feed | PASS: `https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml` returns the exact signed `appcast.xml` bytes and hash above |
| Archive/feed/manifest verification | PASS: `SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_BUILD_NUMBER=5 swift scripts/release-manifest.swift verify dist/public-0.4.0-verification ab57fcace589f2c786ba183778d1b1bb4e77fe87 0.4.0 gbN8bdU/ElNPW3vAeX0BCAv4qokA1biQeOUgXNEhdac=` exited 0; verifies Ed25519 archive and signed-feed content, exact URL/build/version/minimum OS, mode/provenance/hashes, matching bilingual notes/README and exact SHA256SUMS |
| ZIP safety | PASS: `python3 scripts/verify-release-archive.py dist/public-0.4.0-verification/shotclip-0.4.0.zip` exited 0; no extraction or installation by the reviewer |
| Installed code signature | PASS: `codesign --verify --deep --strict --verbose=2 /Applications/ShotClip.app`; `codesign -dv --verbose=4` confirms ad-hoc signature, no team, arm64 |
| Installed plist/binary/resources | PASS: exact brand/identifier/version/build/source commit/ad-hoc mode/canonical feed/key, mandatory signed-feed and verify-before-extraction flags, automatic checks/update default OFF; `lipo -archs` reports arm64; 109 keys per en/ko table; executable equals the final packaged executable |
| Installed/public payload equality | PASS: all 92 regular payload files and nine framework symlinks match the public archive bytes/targets, and the complete 101-entry file/symlink set matches with no extras, without extraction; archive metadata root is safely accepted |
| Installed localization diagnostic | PASS: `/Applications/ShotClip.app/Contents/MacOS/shotclip --localization-self-test` exited 0 with `installedBundle:true`, `fallback:true`, `keyCount:109`, languages en/ko; this exits before preferences/NSApplication startup |
| Exact installed process | PASS: read-only AppKit `NSRunningApplication` query found one running `dev.shotclip.app` at the exact installed bundle URL; no GUI automation or PID reuse |
| Legacy cleanup bounds | PASS: the four original legacy backup/development-app/fixture/archive paths recorded by root are absent; current installed and final packaged apps remain. Root's log records recoverable Trash moves; restoration was not tested |

The source-only snapshot is 45 committed files, SHA256 `15764975c7183ecc03a3fce42b2251575dd411245e64af485bb1ddc3670a25d6`. Reproduce with `git ls-tree -r --name-only -z` at the immutable commit for `Sources`, `Tests`, `resources`, `scripts`, `Package.swift` and `Package.resolved`, sort the relative `pathlib.Path` objects, then hash UTF-8 path, NUL, file bytes, NUL. The earlier 46-file filesystem hash `3038e9f1b7b8ed48c2cbcad2212895e822d357b3548a78a5637e92d83d8e9378` additionally includes ignored `Sources/.DS_Store`; it is unchanged, and that metadata is not committed source. Documentation commits do not change this release's tag/source identity.

## Final documentation review

Coordinator accepted the separate final writer's `task_ae05e068f0e5` / `ctx_0edcd092f995` as succeeded before this pass read the final files and tracked additions. Exactly five documents changed in that authoring lane; this reviewer only authors the sixth document, this report.

| File / line | Independent outcome |
| --- | --- |
| `README.md:7`, `README.ko.md:7` | APPROVE: matching release/download/source links, 0.4.0(5), arm64-only ad-hoc/non-notarized preview, local-startup evidence and explicit runtime gaps; English default/Korean restart, manual legacy migration and update opt-in limits remain consistent |
| `docs/shotclip/qa-results.md:5` | APPROVE: current public hashes/provenance match independently checked assets; root operations and writer read-only checks are attributed, initial missing-mode rejection is recorded honestly, old development/legacy snapshots are explicitly superseded |
| `docs/shotclip/handoff.md:5` | APPROVE: immutable artifact commit is separate from later documentation commits, completed root operations and user-owned limits are clear; task accounting says active **at recording**, not unresolved final work |
| `docs/shotclip/update-operations.md:31` | APPROVE: next release increases version and monotonic build, uses a new independently reviewed clean commit/tag and existing key, repeats asset/feed checks, and must not reuse/replace v0.4.0; line 41 labels its 0.4.0 command block historical, not republishing from later documentation HEAD |

Document checks independently passed for all six final files: 44 relative file/fragment links, fences, whitespace and final newlines; `git diff --check` passed. All prior dated QA/handoff sections are byte-identical to the implementation commit. No false GUI, TCC, Gatekeeper, notarization or actual-upgrade PASS was found. No approval from the writer was treated as this reviewer's verdict.

At review settlement, branch `main` still has the immutable implementation HEAD above; the writer's five documentation updates and this new report await the coordinator's documentation commit/push. The reviewer made no Git write and claims no subsequent documentation commit or remote equality. The source tag and public artifact must remain unchanged.

## Coordinator evidence and limits

Coordinator evidence records clean reviewed-source preparation, existing `sshot` Keychain lookup and actual archive/feed signing without private-key export/rotation/regeneration, publisher draft download/comparison before publication, installation with recoverable backup, normal local launch and metadata-bounded Trash cleanup. The reviewer read installation/cleanup logs and verified the resulting public and installed artifacts; it did not repeat publication, installation, signing-key access, cleanup or restoration.

The previous 34-test and release-suite results are recorded in [QA results](qa-results.md) and [source review](qa-review.md); they were not rerun here. Source/tag/artifact alignment and signatures are now independently verified, unlike the earlier dirty development QA artifact.

Still unrun: capture pixels, Screen Recording grant/deny/revoke/recheck, paste/general clipboard tests, rendered English/Korean layout or restart, VoiceOver/native focus, downloaded first launch on a clean account, actual installer rollback/legacy preference migration, macOS 14/Intel runtime and a real newer-build automatic upgrade on the new bundle identity. Normal local running-process observation does not replace those checks. No GUI/capture/TCC/quarantine/Gatekeeper/preferences/clipboard changes were made by this reviewer, and no sensitive screen/clipboard data or private keys were collected.

## 한국어

최종 판정은 공개 배포·설치 산출물·최종 문서 범위에서 **APPROVE**입니다. 공개된 여섯 asset와 canonical feed의 실제 바이트, 기존 공개키를 이용한 archive/feed 서명, 고정 tag/source commit, 설치 앱의 ad-hoc 서명·arm64·109개 영어/한국어 문자열·전체 payload 일치와 안전한 리소스 진단을 독립 검증했습니다. 별도 작성자의 다섯 문서 완료 후 실제 변경과 재현/차기 릴리스 지침을 검토했고 여섯 최종 파일의 상대 링크 44개와 문서 검사를 통과했습니다. ad-hoc 배포는 공증되지 않았으며 화면 기록 권한·Gatekeeper·실제 자동 업그레이드 통과를 뜻하지 않습니다. 실제 GUI·캡처·권한·붙여 넣기·깨끗한 계정 첫 실행·macOS 14/Intel·rollback·자동 업데이트 인수는 미검증으로 남깁니다.
