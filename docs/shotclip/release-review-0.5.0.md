# Shot Clip 0.5.0 independent release review

Reviewed 2026-10-05 (Asia/Seoul) by `/root/explore`, separately from the implementation, release operations and final documentation authors. The [0.5 source review](qa-review-0.5.0.md) approved implementation and development packaging; this pass checks the published release, canonical installation and bounded cleanup. Earlier [source](qa-review.md) and [release](release-review.md) reviews retain their original bytes and scope.

**Final verdict: APPROVE — public artifacts, canonical installation, bounded cleanup and final documentation.** Public release [v0.5.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.5.0) was published at `2026-10-04T19:30:38Z` / `2026-10-05 04:30:38 KST`, is not draft/prerelease, and has exactly six assets. Its immutable artifact source is [`3d803a9`](https://github.com/kyungseok-lee/shotclip/commit/3d803a9c45f72c1eb3c7328ca68321e1fdb1d2b4), version 0.5.0, build 7. Later documentation commits must not move that tag or replace its assets. The final documentation approval below followed the separate writer's completed snapshot.

## Public artifacts and provenance

The reviewer independently read the live GitHub API and downloaded all six public assets over HTTPS to ignored `dist/review-0.5-final-live.vnxms5yn`. Each byte sequence equals both the prepared assets and the coordinator's fresh downloads. The [canonical latest feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml) also equals the signed feed before and after old-release cleanup.

| Asset | Bytes | SHA256 |
| --- | ---: | --- |
| `shotclip-0.5.0.zip` | 2,516,248 | `768bf6043bd21cab373cadaca94154cf0a242e9141304b7b4f6ec735f8dcdb68` |
| `appcast.xml` | 1,270 | `61f35332331845fbe03b8ffbe8085312a07739e6e779c91bd7c23f16859a95b7` |
| `release-manifest.json` | 631 | `b8965fb8444c5f7723cc4ca73df1398fa375dca32eb4756a87d946d4310b41f0` |
| `SHA256SUMS` | 411 | `69e877bc0553b8f42df35bb4a616c21fbae5a1786f42a2ccfa8bad84a34ca9fd` |
| `RELEASE-NOTES.md` | 3,340 | `9f8e78a92510dc1380e33c0b99e46739d9ba5021ab27e00e67d0971bcbb55dc3` |
| `README.txt` | 3,340 | `9f8e78a92510dc1380e33c0b99e46739d9ba5021ab27e00e67d0971bcbb55dc3` |

Public-key-only `release-manifest.swift verify` exited 0 for the independently downloaded bytes using build 7/ad-hoc mode and the established key. This verifies the Ed25519 archive signature and signed feed content, canonical HTTPS URLs, version/build/minimum OS, source/mode, manifest hashes, exact five checksum entries and bilingual notes/README. The ZIP safety validator also exited 0. The release is arm64-only, ad-hoc signed and **not notarized**; signatures authenticate update bytes and do not establish Gatekeeper trust or Screen Recording consent.

Local `v0.5.0`, remote peeled `v0.5.0`, remote main at artifact review and GitHub's tag-commit API match the full source commit above. The committed 42 authored files matched the source-review fingerprint `7ad2815a227f3b87f0e182218959a3f66f8762c758e5913881c6684b1ff6cb81` in the separate prepublication pass. Build 7 advances from v0.4.1 build 6, retaining `dev.shotclip.app`, executable `shotclip`, the canonical feed/public key and Keychain account `sshot`.

## Installed artifact and cleanup

| Independent check | Result and scope |
| --- | --- |
| Public/installed payload | PASS: `/Applications/Shot Clip.app` has exactly the public ZIP's 168 descendant entries: 92 regular files, nine framework symlinks and 67 directories. Every regular file byte and symlink target matches; no extra/missing entries. The bundle root itself is excluded from that count. |
| Metadata and signature | PASS: Shot Clip names/spaced path, stable ID/executable, 0.5.0(7), exact source commit, ad-hoc mode, arm64, canonical trust and signed-feed/verify-before-extraction flags; update checks and automatic updates remain OFF by default. `codesign --verify --deep --strict` passed; no team/Developer ID claim. |
| Icon and resources | PASS: installed/public icon matches approved ICNS SHA256 `d2ece6616fab9ae0929390d79b25cbcb46fafc8173abd3abfdb6b5339e74384d`; 125-key English/Korean resources match the public package. The installed localization-only diagnostic passed with both languages, fallback and bundled-resource checks. |
| Running copy | PASS: reviewer read-only `pgrep`/`lsof` checks found one `shotclip` process opening the exact canonical installed executable. Coordinator's `NSRunningApplication` check independently records one normal instance. The reviewer did not launch, quit or operate the app. |
| Prior install paths | PASS: old `/Applications/ShotClip.app` and historical `/Applications/sshot.app` paths are absent; the canonical latest app remains. |
| Local cleanup | PASS: all 12 planned originals are absent and their exact recorded Trash destinations exist. Marker hashes and bundle IDs/version/build or release-manifest version/build match the inventory: nine generated old/superseded apps/fixtures (including three superseded 0.5 development apps), one prior installed backup and two 0.4.1 release directories. Latest dist app/fixture, prepared/public assets and installed app remain. Restore-from-Trash was not tested. |
| GitHub cleanup | PASS: live releases API contains only public v0.5.0 with six assets; superseded v0.4.1 release/assets are absent. Remote v0.4.1 peeled tag still identifies `24f73ed008028d7e957df1e485af02e65a38c25f`; source/tag history is preserved. Canonical signed feed is unchanged after cleanup. |

Coordinator operations place publication/installation verification before removal of the superseded release and recoverable local moves. The reviewer inspected cleanup plan/results/logs and independently checked the resulting files and live API; it did not perform publication, installation, signing-key access, deletion or Trash moves. No private key was read/exported/recreated in this lane, and no TCC, quarantine, Gatekeeper, preference or clipboard changes were made.

## GUI evidence and limits

The coordinator's initial quiet-launch accessibility observation timed out and does not establish quiet-launch behavior; Finder reopen then displayed General with the installed icon. Its bounded English dark/default GUI observations cover General/Access/Updates, capture intent leading to Access without effective permission/prompt/capture, troubleshooting expansion/collapse and the application main menu opening/dismissing. These observations were not repeated by this reviewer. Tab caused no observable accessibility-focus change and is not a native-focus PASS. No screenshot of a desktop or user content was saved; synthetic view fixtures and source-level overlay keyboard invariants are separately recorded in the source review.

Still unrun: actual capture pixels and clipboard/paste, Screen Recording grant/deny/revoke/recheck, native status-menu popup, complete focus/VoiceOver, language restart, international shortcut hint display, clean-account first launch, macOS 14/Intel runtime and real Sparkle end-to-end upgrades. Stock Sparkle may retain the old host folder; the canonical spaced name was adopted through the verified manual installer. The release is an authorized unnotarized developer preview, without a blanket commercial-readiness claim.

## Final documentation review

The writer completed and froze exactly five documents before this approval pass. The reviewer read their actual final contents/diff, checked the record against independently verified artifacts, and resolved one chronology finding through the writer: source approval came before commit/tag/push and clean preparation; prepublication artifact approval came after preparation and before publication. The publisher check also followed preparation, and publication reran its gates.

**APPROVE:** both READMEs consistently identify 0.5.0(7), the correct public links/time/source and arm64 ad-hoc limits. QA/handoff distinguish source, automated fixtures, synthetic layouts, limited coordinator GUI observations, independent public/install/cleanup checks and unrun acceptance. Update operations preserve trust, manual folder adoption, new-version/build requirements and retired-tag limits. No future documentation commit or successful native focus/quiet launch/capture/upgrade was invented.

| Final writer file | SHA256 |
| --- | --- |
| `README.md` | `413bb1b8000ccfd5eab51dc28b931afa929c04c9a25d386b229f946c54788add` |
| `README.ko.md` | `5e110656b7f06a877be41aa5b2f30c4556ad231c7e7e0386c750a36a109138ac` |
| `docs/shotclip/qa-results.md` | `cc1fef0e4c1835b8c0adbb9302f7a4d32a62f5c14de6b25e854ea28b84413811` |
| `docs/shotclip/handoff.md` | `309c1f53e813e687ba5007e75f9f5436e7a1c61087d9996e1c22c674b48dd2ea` |
| `docs/shotclip/update-operations.md` | `bec84a4f45c85e9ce4b37abaf1a274aa5fe238fd83f7d26cbdd4f8699d3bc512` |

Their sorted path/NUL/bytes/NUL aggregate fingerprint is `68fa6ee1c094ec1f2c0036c9c9cd05c82ed27e16ad2c07bfa7cdf69e943a751d`. Independent six-document checks, including this report, passed for 52 relative file/fragment links, balanced fences, final newlines and whitespace. Previous dated QA/handoff and v0.4.1/v0.4.0 operations bodies remain byte-identical to the immutable source commit; the historical reviews and 0.5 source-review record are also unchanged. All 53 committed implementation/artwork files still matched that source during this pass.

At review settlement the separate final documentation commit/push is the coordinator's next action. This reviewer made no Git write and does not claim that future commit or its remote equality.

## 한국어

공개 산출물·최신 설치·범위가 정해진 정리와 최종 문서는 **APPROVE**입니다. 여섯 공개 asset와 canonical feed를 직접 다시 받아 준비/게시 바이트와 비교하고 기존 공개키만으로 archive/feed를 검증했습니다. `/Applications/Shot Clip.app`의 전체 168개 하위 항목·ad-hoc/arm64·0.5.0(7)/소스·125개 현지화·아이콘과 정확한 실행 경로를 독립 확인했습니다. 정리한 12개 원본은 없고 기록된 Trash 위치의 식별자·버전·marker hash가 일치하며 이전 Git tag/source 이력은 남아 있습니다. 별도 작성자가 다섯 문서를 동결한 뒤 실제 변경·게시 시간/소스·검증 범위·과거 기록 보존과 여섯 문서의 상대 링크 52개를 확인했습니다. 소스 승인→push/준비→산출물 승인→게시 순서를 바로잡았으며 최종 문서 commit/push는 조정자의 다음 작업입니다. 실제 캡처·권한·붙여 넣기·native 포커스/VoiceOver·quiet launch·자동 업데이트·공증·상용 완성도 통과를 뜻하지 않습니다.
