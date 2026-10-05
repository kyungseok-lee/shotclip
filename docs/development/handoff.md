# Shot Clip handoff

[Developer guide](README.md) · [QA results](qa-results.md) · [Release operations](update-operations.md)

<a id="current-status"></a>
## Current evidence — 0.8.2 (build 12)

Published **2026-10-06 08:01:51 KST** (2026-10-05T23:01:51Z): [v0.8.2](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.2). Reviewed source/tag `d7c5d700fe906e3d8b8958fa919e5f21d7aa7d30` was verified equal to local main, remote main, remote tag and GitHub at source delivery. The source tag/app remains immutable while the final documentation main advances separately. All six public assets and the canonical latest signed feed equal the approved files. ZIP: 8,195,816 bytes; SHA256 `bd55e133766734fe9f2cce907c69372b45a355efa6a720c2c4760f0f5b11175f`.

The verified **manual installer** installed the release; all 177 public/installed entries match bytes, symlinks and file/directory modes. Deep/strict signature, security scanner and resource verification pass. This release has no new actual Sparkle upgrade test. Normal installed runtime shows all three Korean settings panes, version 0.8.2 (12), existing automatic checks ON and a manual current signed-feed latest check. General exposes 25 accessibility elements with a 720×608 pt native root. Ten preference keys remain; nine non-time digests match and only `SULastCheckTime` changes.

New isolated QA passes 352 renders/200 paired cases without changing normal preferences or the general clipboard. Candidate regression counts remain 36 core tests, six accepted/71 rejected security fixtures, 17 publishing-gate rejections, 15 unsafe archive rejections, 15 temporary installer cases, 34 resource checks and 27 retired production QA-argument rejections. New-version evidence does not substitute for real capture/paste, permission grants, native save, full accessibility, macOS 14, Intel or clean-account tests; those remain unrun.

Evidence is retained under ignored `dist/docs-0.8.2-qa`: `artifact-review.json`, `public-check.json`, `public-release.json`, `installed-check.json`, `installed-security.json`, `native-general.json`, `native-updates.json`, `native-access.json`, `native-latest-check.json`, `preferences-after-install.json` and `candidate-summary.json`. Exact-artifact and independent delivery approval pass. Cleanup and same-payload cold restart also pass as recorded below. No app delivery task remains. Final documentation approval and exact ordinary main commit/push are recorded by the coordinator in ignored `dist/docs-0.8.2-qa/final-completion-audit.json` after those gates; inspect that proof and actual `git log -1`/`git ls-remote origin refs/heads/main` for completion.

## Documentation changes

The root English README is an app overview and quick start. `README.ko.md` is the only maintained Korean document and retains complete app instructions. `docs/user-guide.md` contains detailed English app instructions. `docs/development` contains English build, product/requirements/design, QA/trace, technical and release references. `docs/README.md` is the entry point. `docs/shotclip` remains byte-identical frozen historical evidence; its original bilingual prose and old pending claims are historical.

R01–R18, D01–D18 and P0–P10 remain traceable. The app still supports Korean; documentation language policy does not alter localization resources. No capture feature is added by the document reorganization.

## Remaining work and limits

Source/tag/publication/manual installation, independent delivery review, scoped cleanup and same-payload cold restart are complete. The coordinator records final documentation approval and exact ordinary final main commit/push in ignored `dist/docs-0.8.2-qa/final-completion-audit.json` after those gates. No app delivery task remains. Preserve the tagged source and six approved public files; final documentation commits do not rebuild or retag the app.

Real capture/paste, Screen Recording grants/resets, general clipboard actions, current-version native save, full accessibility, macOS 14/Intel/clean-account and other hardware remain unrun. The current preview is arm64/ad-hoc, without Apple notarization; first-launch and permission-reapproval limitations remain. Only the existing update-check timestamp changed among recorded preferences.

## Resume and completion record

Check `git status --short --branch`, this handoff and QA results before continuing. Preserve user changes, established signing keys and Git history/tags. Record the actual changed files, executed checks with environment/evidence, unrun limits, remaining decisions, next steps and branch/commit/push/public-release state here. Read actual Git/public state rather than inventing the hash of a future documentation commit.

## Delivery completion and scoped cleanup

Independent delivery review passes for the exact public/manual-installed/native/preference evidence. Scoped cleanup removes six positively identified generated/backup roots and 348 redundant synthetic PNGs, retaining six representative renders, JSON/log/review evidence, six public files and the canonical app. The inventory records 7,306 regular files and 939,586,767 regular-file bytes removed; this is not measured freed disk space. The old backup was verified as the same bundle identity, version 0.8.1 (11), before removal. No general Trash or public release removal is claimed; Git history and the existing key are preserved.

Same-payload cold restart after cleanup succeeds with process 61956 replaced by 65489: Korean General retains 25 accessibility elements and a 720×608 pt native root, `.build` is absent, all 177 installed entries remain byte/link/mode identical, deep/strict signature passes and the ten-key/nine non-time preference digests remain equal. Only `SULastCheckTime` differs from the initial baseline. An immediate app lookup failed while launch was pending; success is established by the fresh PID-based observation, not by the failed lookup. Evidence: `dist/docs-0.8.2-qa/delivery-review.json`, `cleanup-result.json` and `cold-restart-check.json`.

No app delivery task remains. The coordinator records final documentation approval and exact ordinary main commit/push in ignored `dist/docs-0.8.2-qa/final-completion-audit.json` after those gates; inspect the audit and actual Git state for completion. Final documentation commits do not rebuild or retag the published source.
