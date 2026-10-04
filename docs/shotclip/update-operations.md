# ShotClip GitHub preview and update operations

[Product decision](product-plan.md) · [QA plan](qa-plan.md) · [Results](qa-results.md) · [한국어](#한국어)

Published 2026-10-05 02:52:28 KST: [ShotClip v0.4.1](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.4.1), the latest GitHub **ad-hoc developer preview; NOT notarized; arm64 only**. Public assets/feed and local installation/startup were verified. Developer ID is a separate route outside this release; an actual same-ID automatic upgrade remains unrun.

| Item | Current contract |
| --- | --- |
| Repository | `kyungseok-lee/shotclip` (renamed by the user) |
| Canonical feed | [Public signed appcast](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) |
| Archive | [shotclip-0.4.1.zip](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/shotclip-0.4.1.zip), 2,439,939 bytes |
| App | `dist/ShotClip.app`; `dev.shotclip.app`; executable `shotclip` |
| Verified version / build | `0.4.1` / `6`, matches sealed release and installed bundle |
| Implementation source / tag | `24f73ed008028d7e957df1e485af02e65a38c25f` / `v0.4.1`; later documentation commits on `main` do not change artifact provenance |
| Installation | `/Applications/ShotClip.app`; exact version/source/ad-hoc metadata, release binary and normal local startup verified |
| Key | Existing `SUPublicEDKey`; `SHOTCLIP_UPDATE_KEY_ACCOUNT=sshot` intentionally preserved |
| Required trust | Ed25519 archive and signed feed verification; `SUVerifyUpdateBeforeExtraction` and `SURequireSignedFeed` remain enabled |

Latest/download refers to the latest public release, so each published release must include its correct appcast. Archive URLs stay tag-specific. Draft assets are not a public update feed. The current canonical feed returned HTTPS 200 and matched the prepared/tag asset bytes; future releases must repeat that check.

## Verified v0.4.1 operations

Independent source review, atomic main/tag push and clean reviewed-source preparation passed. Existing Keychain `sshot` signed the archive/feed without key export/rotation/regeneration. Publisher `--check`/`--publish`, six uploaded/public byte comparisons, public-key-only manifest/archive/feed verification and ZIP validation passed with explicit ad-hoc mode/build 6. The published [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/release-manifest.json) and [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/SHA256SUMS) identify the exact artifact.

Latest installation verified source/version/signature and identical executable/icon, 109-key installed localization PASS and one normal running instance. The user-authorized cleanup then removed the v0.4.0 GitHub release/six assets and moved 13 verified superseded local items recoverably to Trash. Source/tag history, latest app/archives and existing signing key are retained. No TCC, quarantine or Gatekeeper settings changed. Independent public-artifact/cleanup verification passed; see [current QA](qa-results.md#2026-10-05-041-visual-refresh-publication-installation-and-cleanup). Final documentation approval is separate from this writer’s evidence record.

Clean-account first launch, capture/TCC/paste, VoiceOver/native focus/rendered language, macOS 14/Intel runtime, rollback and a real automatic upgrade remain unrun. The following v0.4.0 operation record is historical; its public URLs are now unavailable after authorized removal, and its local artifacts may be in Trash. Use the current links above.

## Verified v0.4.0 operations

Coordinator atomic main/tag push and clean reviewed-source preparation passed before publication. Existing Keychain `sshot` lookup and real Ed25519 archive/feed signing succeeded without private-key rotation/export/regeneration. Publisher `--check` and `--publish` validated six assets, downloaded/compared uploaded bytes before publication, and verified the canonical feed. Public-key-only verification of the downloaded public set and ZIP validation passed with explicit ad-hoc mode/build 5. The published [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/release-manifest.json) and [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/SHA256SUMS) identify the exact implementation artifact.

Installation succeeded after normal old-app quit. Installed metadata/binary/deep-strict signature and localization diagnostic PASS (109 en/ko keys, installedBundle/fallback true) were confirmed; normal local startup was observed on the arm64 host. Four verified legacy items were recoverably moved to Trash, preserving the current app and signing key. No TCC, quarantine or Gatekeeper setting changed. See [current QA](qa-results.md#2026-10-05-verified-publication-and-installation) for logs, hashes and evidence ownership.

These checks do not establish clean-account downloaded first launch, Screen Recording/capture/paste, VoiceOver/native focus/rendered language, macOS 14/Intel runtime, installer rollback or a real same-ID newer-build automatic upgrade. Those remain unrun; separate final release/document review is independently owned.

## Prepare, check, draft, publish

For the next release, increase both `CFBundleShortVersionString` and the monotonic `CFBundleVersion` in `resources/Info.plist`; implement, independently review, test and commit, create the corresponding **new** version tag, then prepare/check/publish with the same existing Keychain key. Do not reuse or replace `v0.4.1` or earlier tags.

1. Finish implementation and independent review, record fast checks and remaining user-owned GUI gaps, then commit the approved source. Do not release from a dirty tree. Create the matching local version tag on that reviewed HEAD; publisher checks the pushed tag and GitHub repository too.
2. Explicitly select preview mode and acknowledge its limitations. Set the full independently reviewed commit; version/build must equal reviewed `resources/Info.plist`.
3. Prepare with `scripts/prepare-github-release.sh`. It checks the reviewed clean HEAD/local tag, looks up the existing Keychain account/public key, builds ad-hoc, and creates/verifies archive, signed appcast, manifest, checksums, and bilingual preview notes. It neither creates/exports/rotates a key nor publishes.
4. Push the exact reviewed commit/tag before publisher checks. Run `--check` against the actual prepared directory: public-key-only validation, bundle signature/metadata, archive/feed/hash and local/remote/GitHub tag checks. No Keychain prompts, upload, or release creation.
5. Run the default action (or `--draft`) to create a draft. Publisher downloads uploaded assets and compares bytes with validated local files. Review the actual draft target/assets and evidence; never overwrite an unexpected existing release.
6. Explicit `--publish` creates a validated draft, checks uploaded bytes, transitions it to public, and verifies the canonical feed. It is not an “edit an existing draft” resume command. For an existing draft, the authorized coordinator must revalidate target/assets and perform the separate publication action.
7. Record remote URLs, artifact/tag/commit/build/mode, signature/checksum results, and unperformed GUI/upgrade checks. Publication does not make those checks PASS.
8. If superseded-version removal is authorized, perform it only after verifying the latest public feed/assets and installed app. Preserve source/tag history and signing keys, identify old local versions by metadata, and move those local items to Trash so they remain recoverable.

Historical v0.4.0 setup for reproducibility, **not instructions to republish from a later documentation HEAD**:

```sh
export SHOTCLIP_RELEASE_MODE=ad-hoc
export SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES
export SHOTCLIP_REVIEWED_COMMIT="$(git rev-parse HEAD)"
export SHOTCLIP_VERSION=0.4.0
export SHOTCLIP_BUILD_NUMBER=5
export SHOTCLIP_UPDATE_KEY_ACCOUNT=sshot
bash scripts/prepare-github-release.sh
```

Use the directory actually printed by preparation as the second publisher argument: `bash scripts/publish-github-release.sh 0.4.0 PREPARED_DIRECTORY --check`, then the approved draft/publication action. `PREPARED_DIRECTORY` is notation, not a literal path. This block describes reproducible setup; the completed v0.4.0 executions are recorded above. Do not recreate or overwrite the existing release.

## Trust and migration limits

Ad-hoc code signing checks bundle integrity without an identified developer/notarization assertion. Apple may block the first launch; document the per-app [Privacy & Security → Open Anyway flow](https://support.apple.com/en-us/102445) where available, not global Gatekeeper disablement. Do not call an ad-hoc codesign pass a Gatekeeper pass.

Ed25519 verifies update archive/feed authenticity; it does not notarize the app or grant Screen Recording. Keep the established public key and private Keychain `sshot` account unchanged. The account name is a compatibility anchor. No private-key export, regeneration, rotation, secrets in logs/assets/repo, or signing fallback.

The old bundle `dev.sshot.app` → `dev.shotclip.app` change uses a **one-time manual ShotClip installation**. Do not promise legacy Sparkle replacement compatibility. Selected valid shortcut/mode preferences migrate; permission and login registration do not. Grant Screen Recording to ShotClip afresh; later ad-hoc replacements may require regrant. Actual ShotClip-to-ShotClip upgrades need an end-to-end test with a real newer build.

English is the default; choose English / 한국어 in General settings and restart to apply. Automatic update checks are opt-in and OFF by default. Public feed integrity is verified; an actual automatic upgrade is not.

Historical Sshot 0.2.1 local archive/feed cryptographic checks passed; the then-public feed returned HTTP 404. These remain dated legacy results; current ShotClip publication is recorded above, while actual upgrades remain untested. See [historical results](qa-results.md).

## 한국어

2026-10-05 02:52:28 KST에 최신 [v0.4.1](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.4.1) / [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/shotclip-0.4.1.zip)을 공개했습니다. 0.4.1(6), arm64 전용 ad-hoc·미공증이며 tag·manifest·설치 앱은 구현 commit `24f73ed`를 유지하고 후속 문서 commit과 구분합니다. 깨끗한 검토 소스·기존 키 서명·공개 산출물 6개/feed bytes·설치/정상 시작을 확인했습니다. 최신 검증 뒤 0.4.0 릴리스와 산출물을 제거하고 로컬 13개 항목은 휴지통에 옮겼습니다. 소스·태그·기존 키와 최신 자료는 보존합니다. 이전 0.4.0 기록의 공개 링크는 과거 자료이며 이제 사용할 수 없습니다. 영어 기본/한국어는 재시작 적용, 자동 확인은 기본 OFF입니다. 실제 캡처/TCC/붙여 넣기·GUI/접근성·깨끗한 계정·macOS 14/Intel·rollback·실제 자동 업그레이드는 미실행입니다.

다음 릴리스는 `resources/Info.plist`의 `CFBundleShortVersionString`과 단조 증가하는 `CFBundleVersion`을 모두 높이고 구현·독립 리뷰·테스트·commit 후 해당 **새** 버전 tag를 만듭니다. 같은 기존 Keychain 키로 prepare/check/publish하며 `v0.4.1` 및 이전 tag를 재사용·교체하지 않습니다. 위 0.4.0 예시는 과거 설정 재현용이고 이후 문서 HEAD에서 같은 릴리스를 다시 게시하는 절차가 아닙니다. 과거 버전 정리가 승인되면 최신 공개 자료와 설치를 먼저 검증하고 구버전 메타데이터를 확인하여 로컬 자료를 복구 가능한 휴지통으로 옮깁니다.

이번 경로는 Developer ID 등록·공증 없는 GitHub ad-hoc 개발자 프리뷰입니다. `SHOTCLIP_RELEASE_MODE=ad-hoc`, `SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES`, 독립 검토된 전체 commit, 일치하는 버전/build 및 tag를 명시합니다. 준비는 기존 `sshot` Keychain 계정만 조회하고 archive/feed 서명·manifest·해시를 검증하며 게시하지 않습니다.

publisher의 `--check`는 읽기/검증만 수행하고 Keychain에 접근하지 않습니다. 기본은 draft이며 `--publish`는 새 draft 생성·업로드 bytes 검증 후 명시적으로 공개합니다. 기존 draft 재개 명령과 혼동하지 않습니다. 실제 출력된 준비 폴더를 사용하고 원격 commit/tag/산출물/공개 feed 및 미실행 GUI 항목을 기록합니다.

최초 실행은 차단될 수 있어 Apple의 앱별 허용 절차를 안내합니다. Ed25519는 공증·TCC를 대신하지 않습니다. 기존 키는 내보내거나 재생성하지 않습니다. 과거 Sshot에서 새 ShotClip은 한 번 수동 설치하고 단축키/모드만 이전하며 화면 기록은 새로 허용합니다. 실제 업데이트 성공은 별도 증거가 필요합니다.
