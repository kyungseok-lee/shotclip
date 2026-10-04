# Shot Clip GitHub preview and update operations

[Product decision](product-plan.md) · [QA plan](qa-plan.md) · [Results](qa-results.md) · [한국어](#한국어)

Published 2026-10-05 06:32:14 KST (2026-10-04T21:32:14Z): [Shot Clip v0.6.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.6.0), the latest public GitHub **ad-hoc developer preview; NOT notarized; arm64 only**. Developer ID is a separate route. All six public assets and canonical feed match approved preparation. Exact 171-entry installed payload/signature/resources, bounded normal local live-language/manual no-update runtime and final recoverable cleanup passed. An actual same-ID Sparkle upgrade remains unrun.

| Item | Current contract |
| --- | --- |
| Repository | `kyungseok-lee/shotclip` |
| Canonical feed | [Public signed appcast](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) |
| Archive | [shotclip-0.6.0.zip](https://github.com/kyungseok-lee/shotclip/releases/download/v0.6.0/shotclip-0.6.0.zip), 2,628,357 bytes; root `Shot Clip.app` |
| App | `dist/Shot Clip.app`; `dev.shotclip.app`; executable `shotclip` |
| Verified version / build | `0.6.0` / `8`, matches sealed public release and exact installed bundle |
| Implementation source / tag | `e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d` / `v0.6.0`; later documentation commits do not change artifact provenance |
| Installation | `/Applications/Shot Clip.app`; all 171 payload entries, deep/strict signature and installed 159+57 keys PASS; one normal canonical instance verified |
| Key | Existing `SUPublicEDKey`; Keychain account `SHOTCLIP_UPDATE_KEY_ACCOUNT=sshot` preserved |
| Required trust | Ed25519 archive/signed feed; `SUVerifyUpdateBeforeExtraction` and `SURequireSignedFeed` enabled |

Latest/download selects the latest public release, so each release must contain its correct appcast. Archive URLs remain tag-specific. Draft assets are not a public update feed. The current canonical feed matched the prepared/tag bytes; repeat this check for future releases.

## Verified 0.6.0 publication, installation and cleanup

The reviewed source is **0.6.0 (build 8)**. Root reports pushed `main`/annotated `v0.6.0` at `e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d`, existing-key clean ad-hoc preparation `dist/update-0.6.0.RZMRHP` and publisher `--check` PASS (`dist/check-publish-0.6.log`, no publication). Independent source APPROVE is in [source review](qa-review-0.6.0.md); independent exact-set prepared-artifact APPROVE is in `dist/prepublication-0.6-review.md`. Actual publication PASS: all six public assets/canonical latest feed equal the approved bytes (`dist/public-0.6-proof.json`); safe extraction matches the 171-entry prepared tree. Transactional installation and exact 171-entry byte/link/mode equality, signature and installed localization PASS (`dist/install-public-0.6.log`, `dist/installed-public-0.6-proof.json`). Root normal launch/reopen, same-PID ko→en→ko settings/menu text, actual manual signed-feed no-update result and existing result dialog relabel PASS (`dist/installed-runtime-0.6-proof.json`); original Korean restored. Mislabeled failed-restoration snapshots are excluded. This is bounded current-feed/runtime proof; updater installation/relaunch and newer-build upgrade remain unrun. Do not reuse `v0.6.0`, replace a prior tag or declare publication from a successful fixture/build alone. Record the exact reviewed source/tag, sealed version/build/mode, archive/feed hashes, public uploaded bytes and installed payload when each step actually completes.

Reference-style native settings/menu and immediate app-localization are the 0.6 scope. The supported public Sparkle user driver updates app-owned new/visible dialogs live, retaining callbacks/progress/focus and unchanged note selection/scroll. It implements 16 required callbacks plus optional focus with 1,158 assertions per final integrated run. One updater retains the existing signed-feed/pre-extraction/key/defaults; language changes do not reset it. No framework patch/private API is used. Synthetic callback/choice/progress/cancellation evidence is distinct from a real upgrade. macOS permission/security prompts still follow OS language; a Screen Recording restart/regrant remains independent of language changes.

Final fixtures supersede the earlier resource/installer baseline: reviewer fresh resource34/installer15/gate16 PASS in `dist/review-0.6-{resource,install,gate}-tests.log`; root crypto25/unsafeZIP15+valid2 PASS. New source/staged/canonical payloads require regular nonsymlink en/ko Localizable and Updates tables; older 0.5 backups retain rollback compatibility. Initial recoverable cleanup moved 14 prior build staging folders (11 iconsets, three empty), 12,897,238 bytes, to Trash; `.build/` and the current app retained. Fixture/initial-cleanup results remain separate from the actual public-byte proof above and the separately verified exact installation/limited runtime/final cleanup; they do not establish a real upgrade. See [current QA](qa-results.md#2026-10-05-060-publication-installation-and-cleanup).

After latest public/install/runtime checks, root removed v0.5.0/six public assets; only v0.6.0 remains public/latest, while old source/tags remain. Final `dist/cleanup-0.6-final.json` records 60 known local items / 616,854,254 regular-file bytes moved recoverably to Trash, including `.build/`, development/fixture apps, old archives/extractions, PNG/Swift caches and previous installed backup/empty stages. Latest prepared six-file set, installed app and small proof records remain. `dist/installed-after-cleanup-0.6-proof.json` / `dist/postcleanup-0.6-proof.json` confirm installed equality/localization and canonical feed again, with PID 8641 unchanged. This final cleanup is distinct from the initial 14-folder staging cleanup; Trash was not emptied.

Public [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.6.0/release-manifest.json) / [checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.6.0/SHA256SUMS) identify the exact set: ZIP 2,628,357 bytes / SHA-256 `cecdf5df2389737b4cbc64eae2bcf384ce11930311ace11da3e391f650efea8b`; feed 1,270 bytes / SHA-256 `29bc7c73da54866859888f363e1a6516b07e7d8f8562f1b484961c29af30834a`. Source/artifact/prepared approval and root public/install/runtime/cleanup proof remain separate from pending independent final document review and the root-owned documentation commit/push. Existing key/trust preserved without export/rotation/regeneration; no TCC/quarantine/Gatekeeper change.

Earlier v0.5.0 release/download URLs below are now historical and unavailable after authorized removal. Use the current 0.6 links above; generated old local evidence may be recoverable in Trash.

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

For the next release, increase both `CFBundleShortVersionString` and the monotonic `CFBundleVersion` in `resources/Info.plist`; implement, independently review, test and commit, create the corresponding **new** version tag, then prepare/check/publish with the same existing Keychain key. Do not reuse or replace `v0.6.0` or earlier tags.

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

English is the default. In 0.6, English / 한국어 changes app-owned text and update dialogs immediately and persists for next launch. The earlier 0.5 release applied the choice after restart; its dated evidence remains unchanged. Automatic update checks are opt-in and OFF by default. Public feed integrity is verified; an actual automatic upgrade is not.

Historical Sshot 0.2.1 local archive/feed cryptographic checks passed; the then-public feed returned HTTP 404. These remain dated legacy results; current Shot Clip publication is recorded above, while actual upgrades remain untested. See [historical results](qa-results.md).

## 한국어

0.6.0(8) 소스는 독립 APPROVE 후 구현/tag `e87e40e`로 push되고 기존 키 clean 준비·publisher check를 통과했습니다. 참조 스타일 native 설정/메뉴·즉시 언어 전환·public 단일 updater/사용자 driver·최종 fixture와 06:32:14 KST 실제 게시·171개 정확한 설치 항목/서명/159+57 문자열·동일 프로세스 즉시 언어 전환/실제 수동 최신 확인/기존 결과 창 현지화·최종 정리를 각각 검증했습니다. 초기 14개 staging 폴더/12,897,238바이트와 별도로 최종 60개 로컬 항목/616,854,254 regular 바이트를 복구 가능한 휴지통으로 옮겼으며 `.build/`·개발 앱·PNG/cache·기존 백업/stage는 제거되었습니다. 최신 여섯 준비 자료·설치 앱·작은 증거·소스/tag·기존 키는 보존하고 설치/tree/문자열/feed를 정리 후 재검증했습니다. 구 0.5 공개 자료는 제거되었으며 아래는 당시의 보존된 기록입니다.

다음 0.5/0.4 기록은 보존된 과거 운영 증거이며 현재 상태는 위 0.6 기록이 우선합니다.

2026-10-05 04:30:38 KST에 최신 [v0.5.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.5.0) / [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.5.0/shotclip-0.5.0.zip)을 공개했습니다. Shot Clip 0.5.0(7), arm64 전용 ad-hoc·미공증이며 tag/manifest/설치 앱의 source는 `3d803a9`로 후속 문서 commit과 구분합니다. 기존 키 서명·공개 자료 6개/feed·ZIP·새 `/Applications/Shot Clip.app`의 168개 항목/서명·125개 언어 키·단일 정상 실행을 확인했습니다. 별도 공개 자료/설치/정리 검증도 통과했습니다.

최신 검증 뒤 0.4.1 공개 릴리스/산출물을 제거하고 로컬 구버전 12개를 복구 가능한 휴지통으로 옮겼습니다. 소스·태그·기존 키와 최신 자료는 보존하며 이전 0.4.1/0.4.0 공개 링크는 사용할 수 없습니다. 제한된 영어 native 점검/안전한 합성 미리보기와 실제 캡처·권한·붙여 넣기·접근성·언어 재시작·깨끗한 계정·macOS 14/Intel·실제 자동 업그레이드 미실행을 구분합니다.

0.4.x → 0.5.0은 같은 `dev.shotclip.app`과 기존 설정을 유지합니다. 설치기는 새 공백 포함 경로의 설치·검증 후 기존 앱을 백업하고 실패 시 세 이전 경로를 복원합니다. 수동 경로 전환은 실제 설치로 확인했으며 rollback은 임시 서명 fixture로만 검증했습니다. 기본 Sparkle는 기존 공백 없는 호스트 경로를 유지할 수 있어 새 이름은 한 번 수동 설치로 적용합니다. 과거 Sshot의 다른-ID 이전은 단축키/모드만 옮기며 화면 기록을 새로 허용하고 로그인 등록은 이전하지 않습니다. TCC·quarantine·Gatekeeper·키를 변경하지 않았습니다.

다음 릴리스는 Info.plist의 버전과 단조 증가 build를 모두 높이고 구현·독립 리뷰·테스트·commit 후 **새** tag를 만듭니다. `v0.6.0` 및 이전 tag를 재사용·교체하지 않습니다. ad-hoc 모드/제약 인정, 독립 검토된 전체 commit, 일치하는 버전/build/tag와 기존 Keychain 계정 `sshot`을 명시합니다. 준비는 기존 키만 조회하고 게시하지 않으며 publisher `--check`는 Keychain 접근/업로드 없는 검증입니다. 기본 draft와 명시적 `--publish`를 구분하고 실제 준비 폴더·원격 commit/tag·산출물/feed·미실행 항목을 기록합니다. 위 0.4.0 설정은 과거 재현 기록이며 다시 게시하는 절차가 아닙니다.

0.6은 영어 기본/한국어 선택을 앱 소유 문구와 업데이트 창에 즉시 적용하고 다음 실행에도 유지합니다. 과거 0.5의 재시작 적용은 당시 버전 동작으로 구분합니다. macOS 권한/보안 창은 OS 언어를 따르며 화면 기록 재허용/재시작은 별개입니다. 자동 확인은 선택 사항이며 기본 OFF입니다. 최초 실행은 Apple의 앱별 허용 절차를 따릅니다. Ed25519는 공증·TCC를 대신하지 않고 기존 키를 내보내거나 재생성하지 않습니다. 최종 문서 독립 리뷰와 문서 commit/push는 이 작성 기록 이후 조정자가 수행합니다.
