# Shot Clip handoff

[Developer guide](README.md) · [QA results](qa-results.md) · [Release operations](update-operations.md)

## Current status

The 2026-10-06 request is documentation reorganization **and a new latest app release**, with ordinary Git push explicitly authorized. It supersedes the archived documentation-only restriction. The starting clean main is `6844445205691a2ef9c697fad34295312c3ddbf6`. The starting public/installed baseline is 0.8.1 (build 11), source/tag `3140c27629708eecca53ff820066356be7cf443d`. A new candidate does not become public or installed until actual evidence proves it.

## Documentation changes

The root English README is an app overview and quick start. `README.ko.md` is the only maintained Korean document and retains complete app instructions. `docs/user-guide.md` contains detailed English app instructions. `docs/development` contains English build, product/requirements/design, QA/trace, technical and release references. `docs/README.md` is the entry point. `docs/shotclip` remains byte-identical frozen historical evidence; its original bilingual prose and old pending claims are historical.

R01–R18, D01–D18 and P0–P10 remain traceable. The app still supports Korean; documentation language policy does not alter localization resources. No capture feature is added by the document reorganization.

## Verification and remaining work

Writer link/fragment/trace/source checks and independent review must be recorded separately. New-version tests, artifact/signature/resources/ZIP/feed/Ed25519 verification, reviewed Git commit/tag/push, actual public redownload equality, installation and bounded UI verification remain coordinator gates until their results are recorded.

Real capture/paste, Screen Recording grants/resets, general clipboard actions, current-version native save, full accessibility, macOS 14/Intel/clean-account and other hardware are not proven by documentation checks or synthetic fixtures. The current preview remains arm64/ad-hoc, without Apple notarization; first-launch and permission-reapproval limitations remain.

## Resume and completion record

Check `git status --short --branch`, this handoff and QA results before continuing. Preserve user changes, established signing keys and Git history/tags. Record the actual changed files, executed checks with environment/evidence, unrun limits, remaining decisions, next steps and branch/commit/push/public-release state here. Read actual Git/public state rather than inventing the hash of a future documentation commit.

## 0.8.2 candidate verification — 2026-10-06

The coordinator reports a successful **0.8.2 (build 12)** production candidate build. Fresh checks pass: 36 core tests; six accepted/71 rejected security fixtures; 17 publishing-gate rejections; 15 unsafe archive rejections; 15 temporary installer cases; 34 resource-layout checks. The candidate scanner inspects 99 regular files, nine symlinks and six Mach-O files with zero findings; 27 retired QA-argument cases reject with unchanged preference domains; deep/strict code signature verification passes. Candidate build output is retained in ignored `dist/docs-0.8.2-qa/candidate-build.log`; final compact evidence belongs in the same ignored QA directory.

These are candidate results, not final tagged-source, public-download, installation or runtime proof. Independent candidate/artifact approval, new tag/push, publication, public file/feed comparison and installation/runtime remain pending. No real capture/paste, Screen Recording grant/reset or general clipboard test is claimed.

## Writer documentation checks

Static checks pass for 17 current Markdown files, 111 local links and 26 fragments. R01–R18/D01–D18/P0–P10 coverage is present; all 28 historical documentation/assets files remain byte-identical to HEAD. `git diff --check` passes. Writer evidence is `dist/docs-0.8.2-qa/document-author-check.json`. These are author checks, not independent approval. Current branch is `main`; this writer created no commit or push. Final coordinator review and release gates remain pending.

Independent candidate verification separately passed bundle metadata, security scanning, 27 retired-argument cases, resources and licenses. This does not approve the final prepared release artifacts; exact-artifact review remains pending.
