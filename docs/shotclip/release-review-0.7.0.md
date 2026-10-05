# Independent release review: 0.7.0

[Documentation](README.md) · [Candidate QA review](qa-review-0.7.0.md) · [Update operations](update-operations.md)

## 2026-10-05 final delivery verdict

**APPROVE the exact prepared/public release, actual Sparkle upgrade, installed bundle and scoped cleanup.** Separate candidate and artifact reviews preceded commit/publication. Source A is `53bd5d2ad05375be7a6296da4534815260a38d98`; ordinary push and annotated remote `v0.7.0` peeled to A. [Public latest release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0) is non-draft/non-prerelease, published2026-10-05T13:06:35Z. The source/tag/app SourceCommit remain A when a later documentation commit B records delivery.

| Approved/public file | SHA-256 |
| --- | --- |
| shotclip-0.7.0.zip | `8768b780bc43b4baf315b9fed4bc8fc0432faf58cc265426cdeb7c95cecff3be` |
| appcast.xml | `b7737de4b46791134e47d697bb8dbbbba67616a56ce658d127efa16749e2bc67` |
| release-manifest.json | `82bdd7b237b9af526c546e7c924a90227f5db2f86adf8e0070444116cba9e0c6` |
| SHA256SUMS | `746cc73395fe1b95a190c78f8fbc11878570762728bfbdb6ea389c06a39db885` |
| RELEASE-NOTES.md | `671c5d533c0d782def84a5be6049c221c7386d2789208baa0ab5b0a0b014259f` |
| README.txt | `671c5d533c0d782def84a5be6049c221c7386d2789208baa0ab5b0a0b014259f` |

Independent archive/RSS Ed25519 verification used only the embedded public key. Exact manifest/checksums, ZIP safety/CRC, deep/strict ad-hoc signature, source0.7.0(9)/arm64/macOS14/feed/key/verification flags,173+57 keys/language, five source-identical font/license/notice resources and ten square icon representations PASS. All six public redownloads and captured latest feed equal the approved files; captured GitHub asset digests match. Proof: ignored `dist/review-0.7/prepared-artifact-review.{md,json}` and `public-byte-review.json`.

Root observed real0.6.0(8)→0.7.0(9) Download/Extract/Install/Relaunch and old PID replacement; no manual installer was used. Independent read-only comparison confirms all175 installed entries' bytes, link targets and file/directory modes equal the public ZIP, plus root directory mode and strict signature. Root observed installed version, no-installable-update response, unavailable capture menu/explicit Access recovery and later cold restart/Korean General after cache removal. Installed early-exit localization diagnostic passed173+57 without build cache. Detailed proof: `installed-byte-review.json`, root `installed-delivery.json`, `native-installed-runtime.json` and `post-cleanup-installed.json`.

Independent cleanup audit verified2195 original paths absent and recoverable Trash entries present: seven signed generated apps,2182 synthetic PNGs, one build cache, one prior local ZIP two publisher snapshots and two provenance-matched unsigned QA executable copies.2185 regular-file hashes and seven app identities/signatures match; snapshots match approved files. Twelve latest prepared/public files, five representative synthetic PNGs and metadata proof are retained. No generated app remains in `dist`; installed175-entry tree/signature and source60/repository rules remain unchanged. Four emptied generated iconset directories were removed after their contents/directories became recoverable in the same Trash. Trash was not emptied. Proof: `dist/review-0.7/cleanup-review.json` and root `cleanup-proof.json`.

Limitations remain explicit: actual capture SelfTest SKIP Screen Recording permission; target-specific shortcut attempts UNVERIFIED; general paste/full accessibility/clean-account/macOS14/Intel coverage unrun; ad-hoc app not Developer ID/notarized. Previous0.6 updater showed unavailable plain release-notes fallback; displayed notes are not claimed. Final preference comparison keeps nine non-time key digests equal, only `SULastCheckTime` changed after manual checks; no added/removed keys/raw values retained. Equality is not proof of no writes; historical defaults side-effect disclosure remains intact. No TCC grant/reset, private-key export/regeneration or reviewer app/user-data/Git/remote mutation.

**Final documentation APPROVE:**14-file writer fingerprint `412d620da4c77ed60681e406da433c02036288de1e0d74fb1a159297e3c2ea9a` (sorted relative path NUL file SHA-256 hex NUL),216 local links/80 fragments, source references and all twelve prior dated bodies including candidate checkpoints verified. Exact final proof is in ignored `dist/review-0.7/final-delivery-review.json`; documentation commit B must preserve source A/tag/public files and report the actual normal push. The following candidate checkpoint is retained as history.

한국어: 준비 파일·공개 다운로드·실제 Sparkle 업그레이드·최신 설치본·복구 가능한 정리를 별도 승인합니다. 소스/태그A를 보존하고 문서B를 별도로 반영합니다. 권한 SKIP·단축키 UNVERIFIED·환경/공증 한계와 설정 변경 사실은 그대로 남깁니다.

## 2026-10-05 candidate checkpoint

**Candidate source/docs APPROVE; prepared artifacts/publication are not yet approved at this checkpoint.** The separate [candidate review](qa-review-0.7.0.md) accepts 0.7.0(build9) for commit/tag/push/preparation. Its87-input fingerprint is `962b9f4f3c07e192754152487f530a6b978af0a77120dc5bb0d4a7fc814adf57` (sorted relative path NUL file SHA-256 hex NUL; these two review reports excluded).

Source baseline is `f41630006556f895fbff5c3609a1dc35be7d4670`; new reviewed source commit/immutable `v0.7.0` tag are still to be created. Current public/installed0.6.0(8) source is `e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d`.

| Phase | State/required evidence |
| --- | --- |
| Candidate | APPROVE; source/docs/runtime/hygiene proof recorded separately |
| Remote source | Await new commit/tag, ordinary push and remote equality |
| Prepared files | Await exact source-bound ZIP/feed/manifest/checksums/bilingual notes/readme, signature/archive safety/metadata/fonts/icon and Ed25519 verification |
| Public delivery | Await same approved bytes redownloaded, latest release/feed and source/tag identity |
| Installation/cleanup | Await verified latest installed bytes/signature, real updater attempt and accurate outcome, preservation and scoped cleanup |
| Final records | Await reconciled bilingual docs, independent review, documentation push and zero pending work |

Prepared approval belongs in ignored `dist/review-0.7/` evidence while source commit A stays clean/tag=A. After public/install/cleanup checks, update tracked records in documentation commit B; immutable release tag/app SourceCommit remain A. No future asset hash or public URL is invented here.

Ad-hoc arm64 developer preview remains distinct from Developer ID/notarized distribution. Existing keys/tags/user changes are preserved; no key export/regeneration, release overwrite or TCC bypass. Candidate real capture is permission SKIP; actual paste/accessibility and unavailable platform/hardware coverage remain explicit limitations. Attempt real0.6→0.7 updater before manual replacement when feasible. Preference proof establishes observed state equality, not absence of writes; prior side-effect history is retained.

한국어: 후보는 승인되었으며 준비 파일·공개·다운로드·설치/업그레이드·정리는 후속 증거로 검토합니다. 소스A/태그를 고정하고 실제 결과 확인 후 문서B를 별도로 갱신합니다.
