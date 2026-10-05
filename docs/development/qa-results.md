# Shot Clip QA results

[QA plan](qa-plan.md) · [Requirement trace](verification.md#requirement-trace) · [Handoff](handoff.md#current-status)

## Current evidence

The public and installed app is **0.8.1 (build 11)**, published 2026-10-06 05:42:17 KST: [release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.1). Its immutable source/tag is `3140c27629708eecca53ff820066356be7cf443d`. The archived completion checkpoint is `66cbe749a25b6bd289885420cb0fff89e8b5307e`; this reorganization starts from clean main `6844445205691a2ef9c697fad34295312c3ddbf6`. The coordinator's `dist/security-0.8.1-qa/final-completion-audit.json` records PASS, exact local/origin/GitHub main equality, ordinary push and unchanged source/tag/public bytes. This table records 0.8.1 evidence only; new-version results must be recorded separately.

| Verified scope | Accepted result and practical limit |
| --- | --- |
| Core and artifact regressions | 36 core tests; resource 34, publishing 17, archive 15 unsafe + two valid, installer 15, crypto 25 reject + two valid. Temporary fixtures do not prove a real installer/update/capture outcome |
| Security S01–S03 / D18 | Six accepted/71 rejected security fixtures; 27 production retired-QA-argument cases reject before startup. Production excludes capture-helper/self-test/UI-preview hooks and uses exact integer feed-expiry 0; later valid signed feeds remain eligible. No live 20-day invalid-feed simulation |
| Standalone resources and full artifact | Sealed/public/installed scanner: 99 regular files, nine symlinks, six Mach-O files; zero prohibited private-home/checkout/absolute-build paths, app-owned QA markers or unsafe RPATHs. Installed en/ko has 173 app + 57 update keys and source-identical fonts/licenses/icons. Standard Sparkle helpers remain |
| D17 settings layout | Author and independent lanes each ran two isolated matrices: 352 renders/200 paired cases/lane, 139 app-owned structural views/case, 25 states and four sizes. Full frame/document/window/scroll/focus equality, glyph containment/adjacent-line ink, native title ink and five negative guard kinds pass; matrix stderr is empty. Independent execution used the finalized test binary, not an independent rebuild |
| Source and public assets | Reviewed clean source A, signature/resources and existing-key Ed25519 archive/feed gates pass. All six public downloads and latest signed feed equal approved bytes; public ZIP is 8,195,818 bytes, SHA256 `95535fda907d2f4e50b18ae7b5c681c21440aa8c2f8ca2ecab8c7a407aa15829`. No key export/regeneration |
| Actual update and installed payload | Actual Sparkle 0.8.0(10)→0.8.1(11), without manual installer; all 177 installed entries including root match public bytes, links and modes, with strict signature/security/resources. Installation evidence is separate from fixture tests |
| Normal installed UI and cold restart | All three panes, current version, existing automatic checks ON and Screen Recording-needed state read. General ko→en→ko restores a 25-element accessibility tree/native 720×608 pt root/content 720×580. Normal cold restart PID 38014 passes the unchanged installed payload without build caches. This native tree scope is smaller than the isolated 139-view matrix |
| Preferences | Ten-key set and nine non-time digests remain baseline-equal; only `SULastCheckTime` changes with update checks. Korean/existing auto ON remain; fresh auto default is OFF. Digest equality does not establish that no writes occurred; raw values are not retained |
| Completed cleanup | 714 approved roots, 8,003 regular files/1,032,025,832 regular-file bytes removed; six synthetic representatives, compact logs/JSON/proofs and six public assets retained. Build/QA/dev/extracted/prepared duplicates are absent. Removed bytes are not measured freed disk space; no general Trash cleanup is claimed |

[Independent security review](../shotclip/qa-review-0.8.1.md) and [independent delivery review](../shotclip/release-review-0.8.1.md) cover their frozen inputs. All twelve immutable review reports remain unchanged. Named source/public/install/native/preference/cleanup proofs live in ignored `dist/security-0.8.1-author` and `dist/security-0.8.1-qa`; the [archived QA ledger](../shotclip/qa-results.md) retains exact reports and checkpoint limits.

## Unrun and distribution limits

Real 0.8.1 capture/paste, self-test/native-save, permission grants/resets and general clipboard actions were **not run**. Screen Recording-needed observation is not a capture-harness PASS/SKIP. Release-notes fallback was observed; rendered notes are not PASS. Full accessibility, macOS 14, Intel, clean-account and other hardware remain unverified. The release is arm64/ad-hoc, not Apple notarized, with the existing Sparkle library-validation exception.

## Current documentation and release task

The 2026-10-06 request reorganizes documentation and explicitly authorizes ordinary Git push and a new latest app release. Writer checks, independent review, new-version build/runtime checks and actual publication/download/installation evidence are separate gates. They remain pending until the coordinator records their actual results here and in the handoff. Historical reports remain [frozen](../archive.md).

## 0.8.2 candidate verification — 2026-10-06

The coordinator reports a successful **0.8.2 (build 12)** production candidate build. Fresh checks pass: 36 core tests; six accepted/71 rejected security fixtures; 17 publishing-gate rejections; 15 unsafe archive rejections; 15 temporary installer cases; 34 resource-layout checks. The candidate scanner inspects 99 regular files, nine symlinks and six Mach-O files with zero findings; 27 retired QA-argument cases reject with unchanged preference domains; deep/strict code signature verification passes. Candidate build output is retained in ignored `dist/docs-0.8.2-qa/candidate-build.log`; final compact evidence belongs in the same ignored QA directory.

These are candidate results, not final tagged-source, public-download, installation or runtime proof. Independent candidate/artifact approval, new tag/push, publication, public file/feed comparison and installation/runtime remain pending. No real capture/paste, Screen Recording grant/reset or general clipboard test is claimed.

Independent candidate verification separately passed bundle metadata, security scanning, 27 retired-argument cases, resources and licenses. This does not approve the final prepared release artifacts; exact-artifact review remains pending.
