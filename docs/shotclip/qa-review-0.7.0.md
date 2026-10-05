# Independent QA review: 0.7.0 candidate

[Documentation](README.md) · [Earlier UI review](qa-review-ui-refresh.md) · [Release review](release-review-0.7.0.md)

## 2026-10-05 verdict

**APPROVE the frozen 0.7.0 (build 9) source, documentation and repository hygiene for commit, new tag, normal push and release preparation. No candidate blocker remains.** This verifier separately reviewed executor/writer work and actual evidence files. Prepared artifacts, publication, installation/upgrade and cleanup require subsequent review.

Candidate baseline: `main`, `f41630006556f895fbff5c3609a1dc35be7d4670`, prior user changes preserved. Public/installed baseline remains 0.6.0 (8), source `e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d`; development metadata does not establish publication.

## Scope and verification

All eight UI items remain accepted: readiness-gated capture commands/explicit Access, compact updater, bundled Roboto/Noto Sans KR/OFL and Korean weights, complete multiline/minimum12 pt padding, real44×44 pt rail/highlight with existing square icon, post-clipboard thumbnail/original preview/native PNG Save, shared design system and adaptive horizontal capture toolbar. The [prior independent review](qa-review-ui-refresh.md) records the detailed font/geometry/visual/lifecycle proof. Of its60 implementation inputs,54 remain byte-identical; six changes cover preview/QA, version fixture, plist/build defaults and release notes.

New save-error hook is nil by default, guarded by `--ui-preview`, and runs after actual native.OK immediately before the unchanged PNG writer. The fixture removes only its matching fresh empty synthetic directory, causing real filesystem failure into the production alert; clears the hook before recovery; never supplies a response/exporter/image. Source confirms clipboard commit precedes thumbnail and Save/cancel/close preserve clipboard. Related capture/preferences/updater/build/archive/signing/publication/transactional installer inspection found no blocker. Clean source/tag/reviewed-byte gates, Ed25519 verification and installer rollback remain intact.

| Accepted evidence | Result |
| --- | --- |
| Root corrected build/XCTest logs | Warning-free15.34 s release-configuration development build;36 tests/zero failures |
| Root bundled en/ko×light/dark matrix |136 views/run,544 total;1,236 updater/44 capture assertions per run;548 PNG CRCs including four originals |
| Root development bundle/icon proof |0.7.0(9), deep/strict ad-hoc signature,173+57 keys/language, five font/license/notice bytes exact, ten square16–1024 px icon representations |
| Root corrected Korean-dark native gate |70 assertions; real.OK/cancel/error alert/recovery, pending-close/replacement cancellation, no premature output, named clipboard/original pixels retained |
| Independent native audit |11 resources and unsigned development/QA executables equal; original/accepted/recovered PNG bytes equal; actual Korean error-alert PNG visually inspected |
| Fresh independent synthetic regressions |Resource34/gates16/archive15+valid2/installer15/Ed25519-manifest25+valid modes PASS |
| Independent repository rules |43 ignored/33 visible cases/all78 prior tracked files visible; effective attributes across87 inputs exempt only two exact OFL EOL paths; official license hashes unchanged; staged+unstaged whitespace checks PASS; bad Swift trailing space rejected |

Root logged initial Save, error Save and alert OK. Recovery is established by real native callback/fresh original bytes, without claiming a separately logged third CUA Save click. The earlier OS-validation-blocked attempt is excluded. Native unavailable menu omitted Area/Fixed; Escape dismissed without dispatch. Actual capture SelfTest is **SKIP: screen-recording-permission**.

Preference comparison proves equal final export/all ten key digests, no added/removed keys; it does not prove no writes. Unique QA identity isolates native-panel metadata only; normal localization/preparePreferences can write production defaults. Prior side-effect history remains disclosed. Reviewer made no app/build/install/user-data/key/Git/remote mutations.

Actual capture/general paste, permission grant, Carbon shortcut acceptance, full accessibility and real upgrade remain unpassed. Developer ID/notarization, macOS14/Intel and clean-account/hardware coverage remain unavailable/unrun. Error-alert runtime coverage is Korean-dark.

## Frozen inputs

| Set | Count | SHA-256 |
| --- | --- | --- |
| Repository inputs |87|`962b9f4f3c07e192754152487f530a6b978af0a77120dc5bb0d4a7fc814adf57`|
| Implementation/package/resources/scripts |60|`f174c632dd672de0ae2e46136c201d8446a8cd333a615d739b2957207282229e`|
| Writer-owned text |15|`b08006cf38dc6f45d6b4c9db9cbe2a5decef119d484c630575e38295c8f7ec08`|
| Documentation |14|`8059c3eb18f0b93d148168c38595391d8aa058065e0a98057a2670792efe1fe1`|

Repository/source: sorted relative path NUL file SHA-256 hex NUL. Writer/docs: sorted relative path NUL file bytes NUL. Exact inventory/per-file hashes: ignored `dist/review-0.7/frozen-candidate-inputs.json`; these two reports excluded for self-reference. Independent docs checks PASS185 links/65 fragments/37 source references and all twelve prior dated bodies preserved. Independent regression/rule/native proofs remain in `dist/review-0.7/`.

한국어: 후보 소스·문서·저장소 규칙을 별도 승인합니다. 준비 배포 파일·공개·설치/업그레이드·정리는 이후 증거로 따로 검토하며 권한 SKIP·환경 제한·설정 쓰기 가능성을 통과로 확대하지 않습니다.
