# Shot Clip verification and requirement trace

[Requirements](requirements.md#requirements) · [Development phases](development-plan.md#ordered-work-and-trace) · [Results](qa-results.md#current-evidence) · [한국어](#한국어)

## Current evidence

0.8.1 (build 11) is published/installed, with immutable source A `3140c27629708eecca53ff820066356be7cf443d`. Existing recorded proof covers exact signed public/latest/installed bytes, a real newer-build Sparkle upgrade, normal cold restart and bounded native language/pane behavior. This documentation-only refresh reruns no app test or release operation. Logic/synthetic/native/delivery evidence below is deliberately separate.

## Requirement trace

| Requirement | Phase / decision | Recorded proof / remaining scope |
| --- | --- | --- |
| R01 | P1–P2 / D03 | Shortcut validation/conflict/mapping and remembered native menu row; real Carbon/input-source/global interaction not newly tested |
| R02 | P2,P5 / D04,D06 | Clamp/move/resize/session fallback logic; current real handles/Return capture unrun |
| R03 | P2,P5 / D04 | Reverse/zero/invalid drag logic; current real mouse-release capture unrun |
| R04 | P1,P5 / D05 | Encode-before-clear and commit/error logic; real general clipboard image/paste unrun |
| R05 | P5 / D05 | No keystroke injection in source; destination paste is user-owned |
| R06 | P1–P2,P5,P8 / D08,D11,D12 | Permission gating/source/synthetic dispatch and normal permission-needed view; actual grant/deny/revoke cycle unrun |
| R07 | P1–P2,P5 / D04 | Negative origins/scale/rounding geometry; real mixed-display hardware unrun |
| R08 | P1,P5 / D02 | Filter/cursor configuration; current captured pixel/exclusion proof unrun |
| R09 | P1–P2,P5 / D05,D07 | Cancellation/timeout/late-result/rollback/external-change regressions; OS atomicity limits remain |
| R10 | P1–P2,P5 / D07 | Single-flight/session-token tests; full repeated real capture sessions unrun |
| R11 | P1,P5,P10 / D05,D15,D18 | Local storage/export/lifetime boundaries; production QA exclusion, retired argv and full path scanner negatives |
| R12 | P2,P5 / D09,D11 | Key/label/focus source and synthetic evidence; full VoiceOver/native focus/sleep/hardware scope unrun |
| R13 | P6–P7,P10 / D10,D14,D18 | Signed archive/feed, integer-zero failure expiry, tamper/policy fixtures and real valid-feed newer-build update; no live 20-day invalid-feed experiment |
| R14 | P2–P4,P8–P9 / D11–D13,D16–D17 | Square rail/icon, font provenance/shaping, full bilingual geometry/ink; normal native root/tree proof is narrower than fixture inventory |
| R15 | P4,P9 / D13,D17 | 173/57 en/ko keys, fallback/live transitions/persistence and preserved synthetic/native state; OS prompts separate |
| R16 | P3,P7 / D12 | Stable identity/key/settings, signed temporary migration/rollback and exact canonical installed payload; legacy grant remains separate |
| R17 | P6–P7 / D08,D14 | Explicit ad-hoc mode, reviewed source/tag/public equality and scoped cleanup; no notarization/Gatekeeper universal pass |
| R18 | P8 / D15 | Historical synthetic original/PNG/private clipboard/native-save evidence; current real capture/export/general paste unrun |

## Evidence rules

PASS requires execution in the named environment/input scope. Source approval is not runtime PASS; a synthetic view is not a desktop capture; a private named pasteboard is not normal general clipboard paste. SKIP is not PASS. Never imply normal language root/tree evidence proves all offscreen/hidden frames, or that numeric cleanup bytes equal measured freed disk space.

Record source/artifact hashes, commands and owner; keep authoring and independent approval separate. Do not record capture/screen/clipboard/observed app/window/export-path content. Follow [QA procedures](qa-plan.md) for future code changes.

## Document checks

This request checks 14 current Markdown files through separate author lanes: relative file/fragment links, requirement/decision/phase coverage, English/Korean navigation, source-backed usage commands and immutable file hashes. It runs no app build/test/install. Related-doc evidence is ignored `dist/readme-refresh-2026-10-06/related-docs-check.json`; independent approval and ordinary push are recorded afterward by the coordinator.

## 한국어

요구사항 → P0–P10 → D01–D18 → 실제 근거를 연결합니다. 현재 0.8.1의 서명 공개/설치·실제 Sparkle·정상 재시작·한영 native 제한 범위는 검증됐지만 실캡처·일반 붙여 넣기·권한 허용·전체 접근성·다른 OS/CPU/계정은 새로 검증되지 않았습니다. 합성 전체 프레임과 정상 창/AX tree 근거를 구분합니다.

이번 문서 정리는 링크·번호·사실·보존 범위만 검사하고 앱 QA를 다시 실행하지 않습니다. 작성자 검사와 독립 승인·일반 push도 구분합니다.

<details>
<summary>Historical UI-refresh trace referenced by an immutable review</summary>

## Current unreleased eight-item coverage

The new scope maps item1→R01/R06/R14; item2→R13/R14/R15; item3→R14/R15/D16; item4→R14/R15; item5→R14; item6→R04/R09/R11/R18/D15; item7→R14/R15/D16; item8→R02/R03/R08/R12/R14. Required evidence is the actual production source plus final build/resource/font/icon/geometry/callback fixtures and visual/native inspection. Current counts are 36 core tests and four 136-view matrices (544 total), 1236 updater/44 capture-preview assertions per run. Final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md` in [current QA](qa-results.md#2026-10-05-unreleased-eight-item-ui-refresh); earlier release/setting-polish counts below are retained history and cannot be reused as a new pass.

For previews and PNG export, use synthetic images and a uniquely named pasteboard to distinguish post-copy presentation from an actual screen-capture/general-clipboard test. Confirm unchanged pasteboard generation/data after thumbnail dismissal/timeout, original close, save cancellation and save failure; decode a synthetic PNG saved through the production path and compare original dimensions/pixels. These bounded fixtures do not establish TCC, general clipboard paste or actual capture pixels. Explicit user-selected product saving is permitted; no actual captured screen data or actual user-selected export destinations belong in evidence files. Ignored synthetic fixture images and QA output paths are permitted. Distinguish fixture app-preference equality from the whole session: native save panels may write OS folder metadata. Keep interactive QA on a unique signed QA bundle identity, report any observed defaults export change, and do not restore values without a recorded baseline.

한국어: 여덟 항목을 R01–R18/D15–D16에 연결하고 이번 최종 근거만으로 완료 여부를 판단합니다. 합성 이미지와 고유 named pasteboard로 썸네일/원본/PNG/취소/실패/닫기의 보존을 확인하며 실제 캡처·권한·일반 클립보드 붙여 넣기와 구분합니다.

This is the original pre-delivery checkpoint. Its “current/unreleased” wording applies to that recorded stage, not the installed 0.8.1 app.

</details>

<details>
<summary>Historical evidence referenced by retained QA records</summary>

These original dated records preserve their actual scope; their old current/candidate/pending wording does not describe the installed app or this documentation-only task.

## 2026-10-06 0.8.1 delivery trace

| Trace | Actual evidence / limit |
| --- | --- |
| S01/R13 → D18 → P10 | Exact integer expiry 0/both signature switches and malformed-policy gates; pinned source proves no time-based invalid-feed acceptance, not a live 20-day run. Installed valid signed-feed latest check passes; existing archive/key trust remains |
| S02/S03/R11 → D18 → P10 | Production QA-route exclusion/27 retired-argument cases; separate portable QA and complete public/installed scanner/contaminated negatives pass. Standard Sparkle helpers and harmless relative identifiers remain; private-home/absolute source/build paths are absent |
| R14/R15 → D17 → P9 | Retained fonts/resources/native layout; full exact 139-view paired matrices and normal installed General root/translation/restored 25-element tree have distinct scope |
| R13/R16/R17 → P6/P7 | Source A/new v0.8.1/ordinary main/tag remote equality, exact signed/public/latest feed, real Sparkle 0.8→0.8.1 and canonical installed bytes/signature/resources/runtime pass; prior public retirement/exact generated cleanup and same-payload normal cold restart pass, compact proof/history/key retained |
| R01–R12/R18 | Existing capture/preview/privacy behavior retained; no new real capture/paste/self-test/native-save/TCC/full accessibility/alternate-platform PASS |

[Delivery QA](qa-results.md#2026-10-06-081-publication-installation-and-retirement) centralizes source, owners and hashes; [candidate approval](qa-review-0.8.1.md) is historical under its own frozen scope, and [independent delivery review](release-review-0.8.1.md) covers final evidence/documents. Nine non-time preference digests remain equal; only check time changes. Earlier current/latest/pending statements are historical, and documentation B/main push is separately verified without changing A/tag/public bytes.

한국어: R13/R11·D18/P10 보안/전체 artifact·별도 QA, D17 합성/정상 UI, R13/R16/R17 소스/공개/실제 Sparkle/설치를 범위별 추적합니다. 정리/재시작은 새 QA 상태를 따르며 미실행 캡처/권한/별도환경을 통과로 표시하지 않습니다.

## 2026-10-06 0.8.0 delivery trace

| Trace | Actual evidence / limit |
| --- | --- |
| R14/R15→D17→P9 | Candidate/source APPROVE; full paired four-way structural/text/scroll/focus fixtures and fresh independent reproduction. Normal General ko→en→ko separately proves native root/content size and restored complete AX tree, not every runtime frame |
| R13/R16/R17→P6/P7 | Source A/new v0.8/tag/ordinary remote equality; exact signed prepared/public/latest feed; real Sparkle 0.7→0.8 and canonical payload/signature/resources; prior public/local versions and generated outputs removed only after latest approval; cold restart and retained proof pass |
| R01–R12/R18 | Existing capture/preview behavior retained; 0.8 capture/paste/TCC/full accessibility not run. Screen Recording-needed hint is not a harness result; older captured-pixel/shortcut/native-save evidence remains dated |

[Delivery QA](qa-results.md#2026-10-06-080-publication-installation-and-retirement) centralizes counts, owners and hashes; [independent delivery review](release-review-0.8.0.md) is separate from authoring. Existing automatic-check preference and non-time key digests are retained; only last-check time changes are observed. Earlier current/latest/pending and retention statements below are historical; old downloads are unavailable, source tags remain. Document B/main push follows independently reviewed final records.

한국어: R14/R15·D17/P9의 전체 배치는 합성 matrix, 정상 paired 전환은 General 루트/AX로 구분합니다. R13/R16/R17의 소스/서명 공개·실제 Sparkle/정확한 설치·이후 구버전/산출물 삭제·재시작을 확인했고 0.8 실제 캡처/접근성은 미실행입니다. 문서 B push는 소스 A와 별도입니다.

## 2026-10-05 0.7.0 delivery trace

**Published and installed: Shot Clip 0.7.0 (build 9)**, 2026-10-05 22:06:35 KST (13:06:35Z). The immutable [release/tag](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0), public archive and installed app identify source `53bd5d2ad05375be7a6296da4534815260a38d98`. Normal source/tag push and remote equality passed; all six public redownloads and the canonical latest signed feed equal the independently approved preparation. Actual Sparkle 0.6.0(8)→0.7.0(9) download/extract/Install and Relaunch succeeded, with all 175 installed entries/bytes/links/file and directory modes equal the public ZIP; no manual installer was used. Ad-hoc signed, arm64 only, NOT notarized.

R13/R16/R17 delivery PASS: reviewed source A/new immutable v0.7.0/tag/remote equality, approved preparation/public bytes/Ed25519/latest feed, actual 0.6→0.7 updater and exact latest installed payload. R06 actual unavailable commands and explicit Access action PASS. R18 actual native synthetic PNG/error/recovery PASS 70; general paste/real captured pixels remain unpassed. Carbon UNVERIFIED after two attempts and environment-unavailable tests remain clearly separate. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records owners and safe metadata.

Korean normal runtime confirmed version/latest-feed result and acknowledgment; unavailable capture commands stay hidden and explicit Screen Recording recovery opens Access. Screen Recording is unavailable: candidate and installed capture harnesses report permission-SKIP, with no real capture/general paste/TCC grant/reset. Two native-automation shortcut attempts leave Carbon routing UNVERIFIED, without establishing a product defect. Full accessibility, macOS 14/Intel/clean-account and unprovided hardware/layout coverage remain unverified. The old 0.6 updater used a missing-plain-text notes fallback; notes display is not a passed claim. Nine non-time preference key digests remain equal, only `SULastCheckTime` changed after actual manual update checks, no keys added/removed and no raw values retained.

Recoverable cleanup and a true normal cold restart passed after cache removal: the installed 175-entry tree/signature and 173+57 language diagnostics remain valid; final canonical PID is 80286. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records the bounded removals and retained proof. Earlier snapshots below remain dated context. The [independent delivery verdict](release-review-0.7.0.md) is separate; documentation commits are verified by local/remote Git equality and do not change immutable release/tag/app source A.

한국어: 2026-10-05 22:06:35 KST에0.7.0(build 9)/소스`53bd5d2…`를 최신 공개했습니다. 공개6개 바이트/feed와 실제 Sparkle0.6→0.7 설치/재실행·175개 설치 항목/서명/173+57언어 자료를 확인했으며 수동 설치기는 사용하지 않았습니다. ad-hoc arm64·미공증입니다. 한국어 정상 최신 확인/권한 메뉴→Access를 확인했고 권한 없는 실제 캡처/붙여 넣기는SKIP, 전역 단축키는 자동화 두 시도로 미확정이며 결함 판정이 아닙니다. 전체 접근성/다른 OS·CPU·계정·장비와 이전 updater의 노트 표시는 통과를 주장하지 않습니다. 아홉 비시간 설정 digest는 같고 수동 확인 시각만 바뀌었습니다. 복구 가능한 정리 후 정상 cold restart/PID 80286과 설치 항목·서명·173+57 자료를 재확인했습니다. 과거 기록은 보존하고 독립 배포 판정/별도 문서 commit을 소스A와 구분합니다.

</details>
