# Shot Clip QA results

[QA plan](qa-plan.md) · [Requirement trace](verification.md#requirement-trace) · [Handoff](handoff.md#current-status)

<a id="current-evidence"></a>
## Current evidence — 0.8.2 (build 12)

Published **2026-10-06 08:01:51 KST** (2026-10-05T23:01:51Z): [v0.8.2](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.2). Reviewed source/tag `d7c5d700fe906e3d8b8958fa919e5f21d7aa7d30` was verified equal to local main, remote main, remote tag and GitHub at source delivery. The source tag/app remains immutable while the final documentation main advances separately. All six public assets and the canonical latest signed feed equal the approved files. ZIP: 8,195,816 bytes; SHA256 `bd55e133766734fe9f2cce907c69372b45a355efa6a720c2c4760f0f5b11175f`.

The verified **manual installer** installed the release; all 177 public/installed entries match bytes, symlinks and file/directory modes. Deep/strict signature, security scanner and resource verification pass. This release has no new actual Sparkle upgrade test. Normal installed runtime shows all three Korean settings panes, version 0.8.2 (12), existing automatic checks ON and a manual current signed-feed latest check. General exposes 25 accessibility elements with a 720×608 pt native root. Ten preference keys remain; nine non-time digests match and only `SULastCheckTime` changes.

New isolated QA passes 352 renders/200 paired cases without changing normal preferences or the general clipboard. Candidate regression counts remain 36 core tests, six accepted/71 rejected security fixtures, 17 publishing-gate rejections, 15 unsafe archive rejections, 15 temporary installer cases, 34 resource checks and 27 retired production QA-argument rejections. New-version evidence does not substitute for real capture/paste, permission grants, native save, full accessibility, macOS 14, Intel or clean-account tests; those remain unrun.

Evidence is retained under ignored `dist/docs-0.8.2-qa`: `artifact-review.json`, `public-check.json`, `public-release.json`, `installed-check.json`, `installed-security.json`, `native-general.json`, `native-updates.json`, `native-access.json`, `native-latest-check.json`, `preferences-after-install.json` and `candidate-summary.json`. Exact-artifact and independent delivery approval pass. Cleanup and same-payload cold restart also pass as recorded below. No app delivery task remains. Final documentation approval and exact ordinary main commit/push are recorded by the coordinator in ignored `dist/docs-0.8.2-qa/final-completion-audit.json` after those gates; inspect that proof and actual `git log -1`/`git ls-remote origin refs/heads/main` for completion.

## Historical baseline — 0.8.1

The following table records the earlier 0.8.1 delivery and must not be read as new 0.8.2 runtime evidence.

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

Real 0.8.2 capture/paste, self-test/native-save, permission grants/resets and general clipboard actions were **not run**. Screen Recording-needed observation is not a capture-harness PASS/SKIP. Historical 0.8.1 release-notes fallback was observed; no new 0.8.2 upgrade or release-notes rendering is proven. Full accessibility, macOS 14, Intel, clean-account and other hardware remain unverified. The release is arm64/ad-hoc, not Apple notarized, with the existing Sparkle library-validation exception.

## Documentation verification

Current detailed documentation is English; only `README.ko.md` is maintained in Korean. Author checks cover 17 current Markdown files, 111 local links, 26 fragments and complete R01–R18/D01–D18/P0–P10 trace identifiers. All 28 archived documentation/assets files remain byte-identical. These checks and `git diff --check` are author evidence, not independent final approval. The coordinator records final document review and ordinary main commit/push with exact remote equality in ignored `dist/docs-0.8.2-qa/final-completion-audit.json` after those gates.

## Delivery completion and scoped cleanup

Independent delivery review passes for the exact public/manual-installed/native/preference evidence. Scoped cleanup removes six positively identified generated/backup roots and 348 redundant synthetic PNGs, retaining six representative renders, JSON/log/review evidence, six public files and the canonical app. The inventory records 7,306 regular files and 939,586,767 regular-file bytes removed; this is not measured freed disk space. The old backup was verified as the same bundle identity, version 0.8.1 (11), before removal. No general Trash or public release removal is claimed; Git history and the existing key are preserved.

Same-payload cold restart after cleanup succeeds with process 61956 replaced by 65489: Korean General retains 25 accessibility elements and a 720×608 pt native root, `.build` is absent, all 177 installed entries remain byte/link/mode identical, deep/strict signature passes and the ten-key/nine non-time preference digests remain equal. Only `SULastCheckTime` differs from the initial baseline. An immediate app lookup failed while launch was pending; success is established by the fresh PID-based observation, not by the failed lookup. Evidence: `dist/docs-0.8.2-qa/delivery-review.json`, `cleanup-result.json` and `cold-restart-check.json`.

No app delivery task remains. The coordinator records final documentation approval and exact ordinary main commit/push in ignored `dist/docs-0.8.2-qa/final-completion-audit.json` after those gates; inspect the audit and actual Git state for completion. Final documentation commits do not rebuild or retag the published source.
