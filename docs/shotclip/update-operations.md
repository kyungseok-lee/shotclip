# Shot Clip update and release operations

[Usage](../../README.md) · [Current evidence](qa-results.md#current-evidence) · [QA procedures](qa-plan.md) · [한국어](#한국어)

## Current operations

The current public/installed app is [0.8.1 (build 11)](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.1), with reviewed source/tag `3140c27629708eecca53ff820066356be7cf443d`. Its six public files and canonical signed feed were redownloaded and matched to independent approved preparation. Actual Sparkle update, exact installed payload and normal cold restart are recorded in [QA](qa-results.md#current-evidence). The documentation baseline `66cbe749a25b6bd289885420cb0fff89e8b5307e` is separate from the immutable app source.

This README/document refresh makes no new app, tag, install or publication. Ordinary documentation push follows separate review. Existing release files are not overwritten and historical source tags stay intact; prior public release assets were retired only after verified latest installation.

## User updates and first launch

**Check for Updates** performs a manual check. Fresh automatic checks default OFF; an existing ON/OFF choice is preserved. Automatic download/install is disabled. Both feed and archive authenticate against the established Ed25519 key; integer-zero signed-feed failure expiry prevents elapsed-time acceptance of an invalid signature, while later valid feeds remain eligible.

The public app is arm64 ad-hoc signed, not Apple-notarized. Verify the release/source before using Apple's [per-app first-launch flow](https://support.apple.com/en-us/102445). Do not globally disable Gatekeeper or reset TCC. Ad-hoc replacement can require Screen Recording reapproval; Access contains request/settings/recheck/restart recovery. Developer ID/notarization is a separate future route, not a claim about this release.

## Prepare, check, draft, publish

For a future explicitly authorized release, first update requirements/design, implement and verify, obtain independent approval, commit the reviewed new version/build and create/push a new immutable tag. Never repoint an existing version. Preparation requires clean reviewed HEAD and a matching version tag; it is not appropriate for a documentation-only commit.

Resolve the exact dependency into the production scratch directory, then select public mode explicitly:

```sh
swift package --scratch-path .build/production resolve
export SHOTCLIP_RELEASE_MODE=ad-hoc
export SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES
export SHOTCLIP_REVIEWED_COMMIT="$(git rev-parse HEAD)"
bash scripts/prepare-github-release.sh
```

The script prints the newly prepared `dist/update-VERSION.*` directory. Use that exact directory and reviewed version for `--check`, then obtain exact-artifact approval before publication:

```sh
bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY --check
bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY --draft
bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY --publish
```

`VERSION` and `PREPARED_DIRECTORY` are placeholders, not runnable literal arguments. The publisher snapshots verified bytes, checks archive/feed/manifest/checksums, safe extraction, complete production bundle gates and remote tag identity. `--check` creates no release. Preparation signs using the existing key; publisher verification is public-key-only.

Prepared assets are `shotclip-VERSION.zip`, `appcast.xml`, `SHA256SUMS`, `release-manifest.json`, `RELEASE-NOTES.md` and `README.txt`. They belong to that release, not an accumulated README changelog. Download all six after publication, compare exact approved bytes and canonical latest feed, then verify actual latest installation. Only afterward clean precisely authorized obsolete/generated outputs, preserving source/history/tags/key, preferences, unrelated files and compact evidence.

## Production bundle gates

Only production flavor may publish. Verify identity/version/build/source commit, explicit signing mode, canonical HTTPS feed/key, signed-feed/archive/pre-extraction policy and integer-zero expiry, native self-contained en/ko 173 app/57 update-key resources/fonts/licenses/icon, deep/strict signature and safe payload paths. Complete scanner checks regular bytes, symlink targets and all Mach-O debug/RPATHs, rejecting private-home/checkout/build metadata and app-owned QA types/hooks. Standard Sparkle updater helpers remain; development capture-test helpers do not ship.

Swift Build toolchain RPATH removal occurs only for verified active-toolchain library paths before signing; unknown absolute paths fail closed. Preserve `/usr/lib/swift` and safe bundle-relative lookup. Current ad-hoc Sparkle library-validation exception is disclosed; local validation does not convert it into Developer ID/notarization evidence.

## Trust and migration limits

Keep the established Ed25519 public key and private Keychain account `sshot`; lookup/sign only, no export/rotation/regeneration. A display/repository rename does not authorize changing trust. Historical `dev.sshot.app` migration copies only missing valid shortcut/mode values, not language, permission, login, updater state or keys.

The canonical spaced folder is `/Applications/Shot Clip.app`. Legacy folder/identity transition uses a verified manual installation; stock Sparkle can update its old host location and is not promised to rename it. [install-app](../../scripts/install-app.sh) stages/verifies before replacement and supports guarded backups/rollback. Current real newer-build update and exact installed bytes are verified; this does not prove every legacy identity, account, OS or permission scenario.

## 한국어

현재 0.8.1(11)의 공개 여섯 자료·서명 feed·실제 Sparkle/정확한 설치·정상 재시작은 QA에 기록돼 있습니다. 이번 문서 작업은 앱/태그/배포를 다시 만들지 않고 별도 문서 승인 뒤 일반 push만 수행합니다.

향후 배포는 새 버전의 검토된 clean 소스/태그 → 명시적 ad-hoc 준비 → exact 자료 검사/독립 승인 → 공개 → 재다운로드/최신 설치 검증 → 승인 범위 정리 순서입니다. 기존 키·Git 이력·사용자 데이터는 유지합니다. 미공증 최초 실행/권한 재허용 한계를 알리고 Gatekeeper/TCC를 우회하지 않습니다. interval 0은 invalid 서명 feed의 시간 경과 예외만 막으며 이후 유효한 feed는 허용합니다.

<details>
<summary>Historical evidence referenced by retained QA records</summary>

These original dated records preserve their actual scope; their old current/candidate/pending wording does not describe the installed app or this documentation-only task.

## 2026-10-06 0.8.1 current operations

Latest public/installed **0.8.1 (build 11)** was published 2026-10-06 05:42:17 KST: [release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.1), source A/tag `3140c27629708eecca53ff820066356be7cf443d`. Source/new tag/main ordinary push and remote equality passed. Exact six signed prepared/public files and latest feed passed independent approval before actual Sparkle 0.8.0(10)→0.8.1(11), without a manual installer. Canonical 176-entry payload below root/signature/full security/resources and bounded normal runtime/current signed-feed checks pass.

Invalid feed signatures have no time-based acceptance fallback; later valid feeds remain eligible. Production packaging excludes development QA routes/capture test helper, not standard Sparkle helpers, and rejects private/absolute path metadata across the artifact. Current canonical 0.8 can use Sparkle; only historical folder/Sshot migration needs conditional manual guidance. Existing key/identity/preferences/TCC and fresh auto-check default OFF/retained host ON remain.

Prior public v0.8.0/six assets are retired; only latest v0.8.1/six unchanged assets remain. Exact approved 714-root generated cleanup and normal cold restart complete with the same public payload/signature/security/resources. No older owned local app was found in the bounded inventory; only the exact obsolete ZIP was removed. Six representatives/all compact matrix logs/fingerprints/native proofs and current assets are retained, source tags/history/key/unrelated data and owned caches preserved. [Delivery QA](qa-results.md#2026-10-06-081-publication-installation-and-retirement) centralizes exact hashes and evidence; final document B approval/ordinary main push is separate from immutable A/tag/app/release-content/public bytes. No private-key export/regeneration, TCC reset/general clipboard or Gatekeeper bypass is claimed. Earlier current/latest/pending/retention instructions below are historical.

한국어: 최신 0.8.1(11)의 소스/태그/일반 push·서명 공개 자료/feed·실제 Sparkle·정확한 설치/정상 확인을 검증했습니다. 기존 키/설정/권한과 auto-check 상태를 유지하고 과거 설치의 수동 전환은 조건부 안내입니다. 과거 0.8 공개 자료/정확한 산출물 삭제·동일 payload의 정상 재시작은 완료이며 문서 B는 소스 A와 별도입니다.

[Independent delivery review](release-review-0.8.1.md) is separate from authoring. Final documentation B/main push is the remaining coordinator verification, using actual Git/remote proof after approval rather than a future hash embedded in these documents.

## 2026-10-06 0.8.0 current operations

Latest public **[v0.8.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.0)** was published 2026-10-06 03:17:40 KST (2026-10-05T18:17:40Z), build 10, ad-hoc arm64/NOT notarized. Reviewed source/tag/app A=`215bf102d87c049e00ec18264a9c1318265f39fe` was ordinarily pushed and prepared from clean source with the existing Keychain `sshot` key. The candidate/source [approval](qa-review-0.8.0.md) and exact prepared/public/install reviews are separate.

| Item | Verified current artifact / operation |
| --- | --- |
| Archive | [shotclip-0.8.0.zip](https://github.com/kyungseok-lee/shotclip/releases/download/v0.8.0/shotclip-0.8.0.zip),8,400,048 bytes/SHA256 `fe8a09352ebf30220b913523efe97ec43b1ae2cb5e3bb2f4377af19b12358c5c` |
| Latest signed feed | [appcast.xml](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml),1,271 bytes/SHA256 `1420fb400cf157d03a76c9e8f95629aa88686b934a35fab6323bb1801d08b5c2`; exact approved bytes/public-key-only archive+feed verification |
| Public six-file set | ZIP/feed/[manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.8.0/release-manifest.json)/[checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.8.0/SHA256SUMS)/bilingual notes/readme equal independently approved preparation and GitHub digests |
| Actual installation | Sparkle 0.7.0(9)→0.8.0(10) Download/Extract/Install and Relaunch; canonical 175 entries below root/176 including root match public bytes/symlinks/file+directory modes, strict signature/source A/173+57 strings; no manual installer |
| Retirement | Prior public v0.6/v0.7 and 12 assets deleted; latest v0.8/six assets retained.49 exact older local roots deleted after latest approval; historical Git source/tags/key preserved |

[Delivery QA](qa-results.md#2026-10-06-080-publication-installation-and-retirement) records bounded normal General language/root-frame evidence, preference preservation, release-notes fallback and exact old-version deletion. Automatic checks remain fresh default OFF; this host's existing ON preference is preserved. No private key export/regeneration, TCC/reset/general clipboard or Gatekeeper/quarantine changes. Historical release/download URLs below are unavailable; retained Git tags identify their source. Old-version and generated-output cleanup plus cold restart are complete. Six latest public files, six synthetic representatives and 30 final matrix JSON reports/log evidence remain; build caches/dev apps/extractions/prepared duplicates are absent. Final document B review/ordinary main push follows this record and never changes source A/tag/published bytes.

한국어: 최신0.8.0(10)/소스A를03:17:40 KST에 공개하고 정확한6개 자료/feed·실제 Sparkle 0.7→0.8·175항목 설치/서명/173+57 문자열을 검증했습니다. 이전 0.6/0.7 공개12자료와 확인한 로컬 구버전을 삭제하고 Git 이력/태그·기존 키/설정/권한은 보존합니다. 기존 자동 확인ON·새 기본OFF와 노트 fallback·실제 캡처 미실행을 구분하며 산출물 정리/재시작은 완료했으며 문서 B 검토/push는 후속 기록을 따릅니다.

## 2026-10-06 0.8.0 delivery and retirement

The active target is **0.8.0 (build 10)**, baseline public/installed 0.7.0(9). Earlier dated current/latest/pending and cleanup-retention statements below are historical snapshots; [current QA](qa-results.md#2026-10-06-080-language-invariant-settings) and [handoff](handoff.md#2026-10-06-080-settings-handoff) govern present state. Candidate source/build/resource/paired-layout checks and independent reproduction pass with exact reports in current QA; new publication, installation, retirement and ordinary push are pending until separately evidenced.

1. Verify source/version-specific core/build/package/paired settings geometry and native runtime; independently review exact source/docs. Commit approved inputs, create new `v0.8.0`, normal push and verify remote main/peeled tag equality. Never replace a retained version tag.
2. Prepare the clean reviewed0.8 source with the existing Keychain `sshot` key; verify ad-hoc/arm64/macOS14/source metadata, fonts/licenses/icons/language resources, safe ZIP/checksums/manifest, Ed25519 archive and signed feed. Independently approve the exact six-file set before public latest release.
3. Publish and redownload the same approved assets/latest feed; compare exact bytes, then perform/record the actual0.7→0.8 update attempt or verified latest manual installation as distinct evidence. Verify canonical installed payload/signature/resources and bounded normal runtime.
4. Only after latest public/install verification, delete **all prior public releases** and exact owned obsolete local app versions/generated build outputs, including verified past backups when present. Preserve Git source/tags/history, current approved public artifacts/proof, existing signing key/preferences/TCC and unrelated files/Trash. Record exact deletion inventory and remaining latest release/app.
5. Reconcile both READMEs/all current documents from actual results; obtain independent final review and normal documentation push/remote equality. Documentation commits never retag/rebuild the immutable reviewed source artifact.

Old release/download URLs retained below become historical and may be unavailable after authorized retirement; use the current latest URL only after its verification. Permanent deletion for this request supersedes earlier recoverable-copy retention policies only for positively identified obsolete Shot Clip items. It does not authorize emptying general Trash or removing Git source/tag history. Ad-hoc/Gatekeeper/Screen Recording limitations and existing Ed25519 trust remain unchanged.

한국어:0.8.0(10)의 정확한 소스/새 태그/일반push·기존 키 서명 준비·독립 자료 검토·공개 바이트/feed·최신 설치를 순서대로 검증합니다. 그 뒤 과거 공개 릴리스와 소유/식별자가 확인된 로컬 구버전·백업·빌드 산출물만 삭제하며 일반 휴지통·사용자 데이터·Git 이력/태그·기존 키/권한/설정은 보존합니다. 과거 공개 링크는 삭제 후 unavailable일 수 있고 문서commit은 소스/태그와 구분합니다.

## 2026-10-05 0.7.0 published update operations

Latest public [v0.7.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0) was published 2026-10-05 22:06:35 KST (13:06:35Z). Immutable source/tag/app A=`53bd5d2ad05375be7a6296da4534815260a38d98`, version 0.7.0/build 9, ad-hoc arm64/NOT notarized. Source/tag ordinary push and canonical GitHub main/tag equality passed before clean preparation; later documentation commit remains separate from artifact provenance.

| Item | Verified delivery |
| --- | --- |
| Archive | [shotclip-0.7.0.zip](https://github.com/kyungseok-lee/shotclip/releases/download/v0.7.0/shotclip-0.7.0.zip),8,370,291 bytes/SHA256 `8768b780bc43b4baf315b9fed4bc8fc0432faf58cc265426cdeb7c95cecff3be` |
| Feed | [Canonical latest signed appcast](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml),1,270 bytes/SHA256 `b7737de4b46791134e47d697bb8dbbbba67616a56ce658d127efa16749e2bc67` |
| Preparation | `dist/update-0.7.0.w1wWSB`, exact-set independent APPROVE, existing Keychain `sshot` key, Ed25519 archive/feed/public-key verification, deep/strict ad-hoc and safe ZIP/CRC;173+57 language keys/five font-license-notice files/10 icon sizes |
| Public bytes | All six redownloads and latest feed equal approved preparation; independent public-byte review PASS. Public [manifest](https://github.com/kyungseok-lee/shotclip/releases/download/v0.7.0/release-manifest.json)/[checksums](https://github.com/kyungseok-lee/shotclip/releases/download/v0.7.0/SHA256SUMS) identify exact set |
| Actual update route | Canonical0.6.0(8)→0.7.0(9) Sparkle Download/Extract/Install and Relaunch SUCCESS; no manual installer used |
| Latest installed app | `/Applications/Shot Clip.app`; full 175 entries/bytes/link targets/file+directory modes equal public ZIP, source A/deep-strict/ad-hoc/arm64/173+57 diagnostics; upgrade PID 67817 replaced 60933; post-cleanup normal cold-start PID 80286/tree/signature/173+57 still PASS |
| Normal runtime | Korean latest version/feed result acknowledged; hidden unavailable modes/explicit menu Access recovery PASS. Old 0.6 driver used missing-plain-text notes fallback, so notes display is not claimed |
| Preferences | Nine non-time baseline digests equal; only SULastCheckTime updated by actual manual signed-update checks, no added/removed keys/raw values retained. This is state comparison, not proof of no writes |
| Cleanup/final docs | 2,195 verified local items moved recoverably to Trash (never emptied); six prepared/six public files, metadata/reports and five synthetic representatives retained. Cache/generated apps absent; normal cold restart/exact installed tree/signature/resources PASS. [Independent delivery verdict](release-review-0.7.0.md) remains separate; documentation commits are verified by local/remote equality, with immutable tag/app A fixed |

Root reports are `dist/deploy-0.7-qa/{source-delivery,prepared-proof,public-delivery,public-release,installed-delivery,native-installed-runtime,installed-preferences-proof,cleanup-proof,post-cleanup-installed}.json`; independent source/artifact/public/installed proofs are under `dist/review-0.7/`. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records exact outcomes/limits. Candidate/installed real capture remains permission-SKIP; no TCC grant/reset/general clipboard use. Carbon two-attempt result UNVERIFIED, full accessibility/macOS 14/Intel/clean-account/hardware coverage unrun. Verified updater installation does not establish those.

Keep existing keys/source/tags and approved bytes. Do not overwrite v0.7.0 or reuse its build/tag; future releases increase version/build and repeat review. Older candidate/operations bodies below remain unchanged history; their pending/latest 0.6 wording is superseded by this actual 0.7 delivery.

한국어:0.7.0(build 9)/소스A를 기존 키로 준비/독립 승인 후22:06:35 KST 최신 공개했습니다. 공개6개/feed·실제 Sparkle0.6→0.7·수동 설치기 없는175개 정확한 canonical payload/서명/173+57문구/새PID를 확인했습니다. 한국어 최신 결과/권한 메뉴→Access는 통과했고 실제 캡처는 권한SKIP, 단축키는 미확정이며 별도 OS·CPU·계정·접근성/장비는 미검증입니다. 시간 외 설정은 같고 수동 확인 시각만 바뀌었습니다. 검증한 로컬 2,195개를 복구 가능한 휴지통으로 옮기고 최신 자료/메타데이터/합성 대표5개를 유지했습니다. 캐시 제거 후 정상 cold restart/PID 80286·정확한 설치/서명/언어 자료를 재확인했습니다. 현재 host 게시·설치·정리는 끝났으며 독립 판정/별도 문서 commit과 소스A/태그/공개 바이트를 구분합니다.

## 2026-10-05 0.7.0 release candidate operations

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

| Current release gate | Required evidence before claiming completion |
| --- | --- |
| New version/build | 0.7.0/build 9 in source and sealed bundle; strictly newer than public 0.6.0/build 8 |
| Reviewed source | Separate version/docs/release-text approval, scoped commit/new `v0.7.0`, normal push and remote main/peeled-tag equality; no old tag replacement |
| Clean preparation | Reviewed clean source/tag, explicit ad-hoc mode, existing Keychain `sshot` key; ZIP, signed appcast, manifest, checksums and bilingual notes/README. Same public key, no export/rotation/regeneration |
| Prepared artifact approval | Exact source/version/build, signature, archive/feed/hash/ZIP/resource/font/license/icon checks and independent exact-set approval |
| Latest publication | Publisher check, actual uploaded byte comparison/publication/latest flag, redownload all six public assets and canonical latest feed; compare approved bytes and signatures. Pending 0.7 URLs are not live downloads |
| Upgrade/installation | Attempt actual 0.6(8)→0.7(9) Sparkle upgrade before manual replacement when feasible; otherwise exact latest canonical transactional installation. Distinguish updater success from manual install, with payload/signature/resources/PID/path/runtime and post-replacement permission evidence |
| Final record/push | Actual source/tag/URLs/checksums/public/install/runtime/upgrade/limits, independent final docs review and normal docs push/equality |

The [latest-deployment rule](../../AGENTS.md#최신-배포-요청-규칙) supplies existing authorization; no repeat deployment permission is required within this scope. The source release text now describes the eight-item 0.7 behavior; notes are generated during clean preparation. Existing 0.6 operation records below remain unchanged, including their historical cleanup/limitations. Do not delete or overwrite existing releases/tags merely to complete the new version; preserve history and identify any authorized cleanup separately.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

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

</details>
