# ShotClip GitHub preview and update operations

[Product decision](product-plan.md) · [QA plan](qa-plan.md) · [Results](qa-results.md) · [한국어](#한국어)

Approved 2026-10-05: GitHub **ad-hoc developer preview**, without Developer ID enrollment/notarization. Developer ID is a separate route retained in tooling, outside this release. No release or upgrade is claimed by this document.

| Item | Current contract |
| --- | --- |
| Repository | `kyungseok-lee/shotclip` (renamed by the user) |
| Canonical feed | `https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml` |
| Archive | `https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/shotclip-0.4.0.zip` |
| App | `dist/ShotClip.app`; `dev.shotclip.app`; executable `shotclip` |
| Proposed version / build | `0.4.0` / `5`, must match reviewed Info.plist and sealed artifact |
| Key | Existing `SUPublicEDKey`; `SHOTCLIP_UPDATE_KEY_ACCOUNT=sshot` intentionally preserved |
| Required trust | Ed25519 archive and signed feed verification; `SUVerifyUpdateBeforeExtraction` and `SURequireSignedFeed` remain enabled |

Latest/download refers to the latest public release, so each published release must include its correct appcast. Archive URLs stay tag-specific. Draft assets are not a public update feed. Configured URLs do not establish public reachability.

## Prepare, check, draft, publish

1. Finish implementation and independent review, record fast checks and remaining user-owned GUI gaps, then commit the approved source. Do not release from a dirty tree. Create the matching local version tag on that reviewed HEAD; publisher checks the pushed tag and GitHub repository too.
2. Explicitly select preview mode and acknowledge its limitations. Set the full independently reviewed commit; version/build must equal reviewed `resources/Info.plist`.
3. Prepare with `scripts/prepare-github-release.sh`. It checks the reviewed clean HEAD/local tag, looks up the existing Keychain account/public key, builds ad-hoc, and creates/verifies archive, signed appcast, manifest, checksums, and bilingual preview notes. It neither creates/exports/rotates a key nor publishes.
4. Push the exact reviewed commit/tag before publisher checks. Run `--check` against the actual prepared directory: public-key-only validation, bundle signature/metadata, archive/feed/hash and local/remote/GitHub tag checks. No Keychain prompts, upload, or release creation.
5. Run the default action (or `--draft`) to create a draft. Publisher downloads uploaded assets and compares bytes with validated local files. Review the actual draft target/assets and evidence; never overwrite an unexpected existing release.
6. Explicit `--publish` creates a validated draft, checks uploaded bytes, transitions it to public, and verifies the canonical feed. It is not an “edit an existing draft” resume command. For an existing draft, the authorized coordinator must revalidate target/assets and perform the separate publication action.
7. Record remote URLs, artifact/tag/commit/build/mode, signature/checksum results, and unperformed GUI/upgrade checks. Publication does not make those checks PASS.

Example setup **only after independent review and commit/tag preparation**:

```sh
export SHOTCLIP_RELEASE_MODE=ad-hoc
export SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES
export SHOTCLIP_REVIEWED_COMMIT="$(git rev-parse HEAD)"
export SHOTCLIP_VERSION=0.4.0
export SHOTCLIP_BUILD_NUMBER=5
export SHOTCLIP_UPDATE_KEY_ACCOUNT=sshot
bash scripts/prepare-github-release.sh
```

Use the directory actually printed by preparation as the second publisher argument: `bash scripts/publish-github-release.sh 0.4.0 PREPARED_DIRECTORY --check`, then the approved draft/publication action. `PREPARED_DIRECTORY` is notation, not a literal path. These commands are documentation examples, not recorded executions.

## Trust and migration limits

Ad-hoc code signing checks bundle integrity without an identified developer/notarization assertion. Apple may block the first launch; document the per-app [Privacy & Security → Open Anyway flow](https://support.apple.com/en-us/102445) where available, not global Gatekeeper disablement. Do not call an ad-hoc codesign pass a Gatekeeper pass.

Ed25519 verifies update archive/feed authenticity; it does not notarize the app or grant Screen Recording. Keep the established public key and private Keychain `sshot` account unchanged. The account name is a compatibility anchor. No private-key export, regeneration, rotation, secrets in logs/assets/repo, or signing fallback.

The old bundle `dev.sshot.app` → `dev.shotclip.app` change uses a **one-time manual ShotClip installation**. Do not promise legacy Sparkle replacement compatibility. Selected valid shortcut/mode preferences migrate; permission and login registration do not. Grant Screen Recording to ShotClip afresh; later ad-hoc replacements may require regrant. Actual ShotClip-to-ShotClip upgrades need an end-to-end test with a real newer build.

Historical Sshot 0.2.1 local archive/feed cryptographic checks passed; the then-public feed returned HTTP 404. Neither establishes a published ShotClip feed or upgrade. See [historical results](qa-results.md).

## 한국어

이번 경로는 Developer ID 등록·공증 없는 GitHub ad-hoc 개발자 프리뷰입니다. `SHOTCLIP_RELEASE_MODE=ad-hoc`, `SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES`, 독립 검토된 전체 commit, 일치하는 버전/build 및 tag를 명시합니다. 준비는 기존 `sshot` Keychain 계정만 조회하고 archive/feed 서명·manifest·해시를 검증하며 게시하지 않습니다.

publisher의 `--check`는 읽기/검증만 수행하고 Keychain에 접근하지 않습니다. 기본은 draft이며 `--publish`는 새 draft 생성·업로드 bytes 검증 후 명시적으로 공개합니다. 기존 draft 재개 명령과 혼동하지 않습니다. 실제 출력된 준비 폴더를 사용하고 원격 commit/tag/산출물/공개 feed 및 미실행 GUI 항목을 기록합니다.

최초 실행은 차단될 수 있어 Apple의 앱별 허용 절차를 안내합니다. Ed25519는 공증·TCC를 대신하지 않습니다. 기존 키는 내보내거나 재생성하지 않습니다. 과거 Sshot에서 새 ShotClip은 한 번 수동 설치하고 단축키/모드만 이전하며 화면 기록은 새로 허용합니다. 실제 업데이트 성공은 별도 증거가 필요합니다.
