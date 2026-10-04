# Shot Clip GitHub preview and update operations

[Product decision](product-plan.md) · [QA plan](qa-plan.md) · [Results](qa-results.md) · [한국어](#한국어)

Published 2026-10-05 04:30:38 KST (2026-10-04T19:30:38Z): [Shot Clip v0.5.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.5.0), the latest public GitHub **ad-hoc developer preview; NOT notarized; arm64 only**. Developer ID is a separate route. Public assets and the exact installed app passed verification; an actual same-ID Sparkle upgrade remains unrun.

| Item | Current contract |
| --- | --- |
| Repository | `kyungseok-lee/shotclip` |
| Canonical feed | [Public signed appcast](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) |
| Archive | [shotclip-0.5.0.zip](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/shotclip-0.5.0.zip), 2,516,248 bytes; root `Shot Clip.app` |
| App | `dist/Shot Clip.app`; `dev.shotclip.app`; executable `shotclip` |
| Verified version / build | `0.5.0` / `7`, matches sealed release and installed bundle |
| Implementation source / tag | `3d803a9c45f72c1eb3c7328ca68321e1fdb1d2b4` / `v0.5.0`; later documentation commits do not change artifact provenance |
| Installation | `/Applications/Shot Clip.app`; exact public payload, source/version/ad-hoc metadata, strict signature and one normal instance verified |
| Key | Existing `SUPublicEDKey`; Keychain account `SHOTCLIP_UPDATE_KEY_ACCOUNT=sshot` preserved |
| Required trust | Ed25519 archive/signed feed; `SUVerifyUpdateBeforeExtraction` and `SURequireSignedFeed` enabled |

Latest/download selects the latest public release, so each release must contain its correct appcast. Archive URLs remain tag-specific. Draft assets are not a public update feed. The current canonical feed matched the prepared/tag bytes; repeat this check for future releases.

## Verified v0.5.0 operations

Independent source APPROVE preceded source commit/tag and atomic main/tag push, then clean reviewed-source preparation and existing-Keychain signing without export/rotation/regeneration. Publisher `--check` and independent prepublication artifact APPROVE followed preparation; `--publish` then reran the gates and published. Publication and six public byte comparisons passed. Public-key-only Ed25519 archive/feed verification, manifest/checksums and ZIP/CRC passed; [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/release-manifest.json) / [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/SHA256SUMS) identify the artifact.

The fixed-Applications installer stages/verifies the new spaced bundle, installs/verifies the canonical target, then backs up verified prior unspaced/legacy copies. Existing canonical copies also receive distinct recoverable backups. Failure rollback restores all three prior paths; eight signed temporary fixtures tested migration, wrong-identity rejection and rollback, without installing real apps. Actual 0.5.0 installation passed: all 168 file/directory/symlink entries equal the public payload, strict signature, 125-key installed diagnostic and one normal canonical instance; prior unspaced path absent. Actual app rollback remains unrun.

After latest publication/install verification, v0.4.1/six assets were removed and 12 verified superseded local items moved recoverably to Trash. Source/tags, latest assets/app and signing key retained; no TCC/quarantine/Gatekeeper changes. Separate verifier passed public-artifact/install/cleanup checks. [Current QA](qa-results.md#2026-10-05-050-publication-installation-and-cleanup) distinguishes 76 inert previews and limited English native settings inspection from unrun capture/TCC/paste, accessibility/focus, status-menu popup, language restart, clean-account/macOS 14/Intel and automatic-upgrade checks. Final documentation review/commit/push follows this authoring record.

The following dated v0.4.1/v0.4.0 operation records remain historical. Their public URLs are now unavailable after authorized removal; old local evidence may be recoverable in Trash. Use the current links above.

## Verified v0.4.1 operations

Independent source review, atomic main/tag push and clean reviewed-source preparation passed. Existing Keychain `sshot` signed the archive/feed without key export/rotation/regeneration. Publisher `--check`/`--publish`, six uploaded/public byte comparisons, public-key-only manifest/archive/feed verification and ZIP validation passed with explicit ad-hoc mode/build 6. The published [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/release-manifest.json) and [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.1/SHA256SUMS) identify the exact artifact.

Latest installation verified source/version/signature and identical executable/icon, 109-key installed localization PASS and one normal running instance. The user-authorized cleanup then removed the v0.4.0 GitHub release/six assets and moved 13 verified superseded local items recoverably to Trash. Source/tag history, latest app/archives and existing signing key are retained. No TCC, quarantine or Gatekeeper settings changed. Independent public-artifact/cleanup verification passed; see [current QA](qa-results.md#2026-10-05-041-visual-refresh-publication-installation-and-cleanup). Final documentation approval is separate from this writer’s evidence record.

Clean-account first launch, capture/TCC/paste, VoiceOver/native focus/rendered language, macOS 14/Intel runtime, rollback and a real automatic upgrade remain unrun. The following v0.4.0 operation record is historical; its public URLs are now unavailable after authorized removal, and its local artifacts may be in Trash. Use the current links above.

## Verified v0.4.0 operations

Coordinator atomic main/tag push and clean reviewed-source preparation passed before publication. Existing Keychain `sshot` lookup and real Ed25519 archive/feed signing succeeded without private-key rotation/export/regeneration. Publisher `--check` and `--publish` validated six assets, downloaded/compared uploaded bytes before publication, and verified the canonical feed. Public-key-only verification of the downloaded public set and ZIP validation passed with explicit ad-hoc mode/build 5. The published [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/release-manifest.json) and [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/SHA256SUMS) identify the exact implementation artifact.

Installation succeeded after normal old-app quit. Installed metadata/binary/deep-strict signature and localization diagnostic PASS (109 en/ko keys, installedBundle/fallback true) were confirmed; normal local startup was observed on the arm64 host. Four verified legacy items were recoverably moved to Trash, preserving the current app and signing key. No TCC, quarantine or Gatekeeper setting changed. See [current QA](qa-results.md#2026-10-05-verified-publication-and-installation) for logs, hashes and evidence ownership.

These checks do not establish clean-account downloaded first launch, Screen Recording/capture/paste, VoiceOver/native focus/rendered language, macOS 14/Intel runtime, installer rollback or a real same-ID newer-build automatic upgrade. Those remain unrun; separate final release/document review is independently owned.

## Prepare, check, draft, publish

For the next release, increase both `CFBundleShortVersionString` and the monotonic `CFBundleVersion` in `resources/Info.plist`; implement, independently review, test and commit, create the corresponding **new** version tag, then prepare/check/publish with the same existing Keychain key. Do not reuse or replace `v0.5.0` or earlier tags.

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

Use the directory actually printed by preparation as the second publisher argument: `bash scripts/publish-github-release.sh 0.4.0 PREPARED_DIRECTORY --check`, then the approved draft/publication action. `PREPARED_DIRECTORY` is notation, not a literal path. This block describes reproducible setup; the completed v0.4.0 executions are recorded above. Do not republish retired versions or reuse their retained tags.

## Trust and migration limits

Ad-hoc code signing checks bundle integrity without an identified developer/notarization assertion. Apple may block the first launch; document the per-app [Privacy & Security → Open Anyway flow](https://support.apple.com/en-us/102445) where available, not global Gatekeeper disablement. Do not call an ad-hoc codesign pass a Gatekeeper pass.

Ed25519 verifies update archive/feed authenticity; it does not notarize the app or grant Screen Recording. Keep the established public key and private Keychain `sshot` account unchanged. The account name is a compatibility anchor. No private-key export, regeneration, rotation, secrets in logs/assets/repo, or signing fallback.

The 0.4.x → 0.5.0 visible-name/path change keeps `dev.shotclip.app` and saved settings. Stock Sparkle may retain the old `ShotClip.app` host path; a **one-time manual installation** adopts `/Applications/Shot Clip.app`. It does not force a new defaults migration or reset TCC, although ad-hoc replacements may require permission reapproval. A real same-ID automatic upgrade needs an end-to-end test with a newer build.

The historical `dev.sshot.app` → `dev.shotclip.app` migration also requires manual installation. Only selected valid shortcut/mode preferences migrate; Screen Recording and login registration do not. Grant access to Shot Clip afresh for that older-ID migration; do not promise legacy Sparkle replacement compatibility.

English is the default; choose English / 한국어 in General settings and restart to apply. Automatic update checks are opt-in and OFF by default. Public feed integrity is verified; an actual automatic upgrade is not.

Historical Sshot 0.2.1 local archive/feed cryptographic checks passed; the then-public feed returned HTTP 404. These remain dated legacy results; current Shot Clip publication is recorded above, while actual upgrades remain untested. See [historical results](qa-results.md).

## 한국어

2026-10-05 04:30:38 KST에 최신 [v0.5.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.5.0) / [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/shotclip-0.5.0.zip)을 공개했습니다. Shot Clip 0.5.0(7), arm64 전용 ad-hoc·미공증이며 tag/manifest/설치 앱의 source는 `3d803a9`로 후속 문서 commit과 구분합니다. 기존 키 서명·공개 자료 6개/feed·ZIP·새 `/Applications/Shot Clip.app`의 168개 항목/서명·125개 언어 키·단일 정상 실행을 확인했습니다. 별도 공개 자료/설치/정리 검증도 통과했습니다.

최신 검증 뒤 0.4.1 공개 릴리스/산출물을 제거하고 로컬 구버전 12개를 복구 가능한 휴지통으로 옮겼습니다. 소스·태그·기존 키와 최신 자료는 보존하며 이전 0.4.1/0.4.0 공개 링크는 사용할 수 없습니다. 제한된 영어 native 점검/안전한 합성 미리보기와 실제 캡처·권한·붙여 넣기·접근성·언어 재시작·깨끗한 계정·macOS 14/Intel·실제 자동 업그레이드 미실행을 구분합니다.

0.4.x → 0.5.0은 같은 `dev.shotclip.app`과 기존 설정을 유지합니다. 설치기는 새 공백 포함 경로의 설치·검증 후 기존 앱을 백업하고 실패 시 세 이전 경로를 복원합니다. 수동 경로 전환은 실제 설치로 확인했으며 rollback은 임시 서명 fixture로만 검증했습니다. 기본 Sparkle는 기존 공백 없는 호스트 경로를 유지할 수 있어 새 이름은 한 번 수동 설치로 적용합니다. 과거 Sshot의 다른-ID 이전은 단축키/모드만 옮기며 화면 기록을 새로 허용하고 로그인 등록은 이전하지 않습니다. TCC·quarantine·Gatekeeper·키를 변경하지 않았습니다.

다음 릴리스는 Info.plist의 버전과 단조 증가 build를 모두 높이고 구현·독립 리뷰·테스트·commit 후 **새** tag를 만듭니다. `v0.5.0` 및 이전 tag를 재사용·교체하지 않습니다. ad-hoc 모드/제약 인정, 독립 검토된 전체 commit, 일치하는 버전/build/tag와 기존 Keychain 계정 `sshot`을 명시합니다. 준비는 기존 키만 조회하고 게시하지 않으며 publisher `--check`는 Keychain 접근/업로드 없는 검증입니다. 기본 draft와 명시적 `--publish`를 구분하고 실제 준비 폴더·원격 commit/tag·산출물/feed·미실행 항목을 기록합니다. 위 0.4.0 설정은 과거 재현 기록이며 다시 게시하는 절차가 아닙니다.

영어 기본/한국어는 재시작 적용, 자동 확인은 선택 사항이며 기본 OFF입니다. 최초 실행은 Apple의 앱별 허용 절차를 따릅니다. Ed25519는 공증·TCC를 대신하지 않고 기존 키를 내보내거나 재생성하지 않습니다. 최종 문서 독립 리뷰와 문서 commit/push는 이 작성 기록 이후 조정자가 수행합니다.
