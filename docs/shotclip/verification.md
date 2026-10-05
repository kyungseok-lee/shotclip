# Shot Clip verification and requirement trace

[Requirements](requirements.md) · [Development plan](development-plan.md) · [QA plan](qa-plan.md) · [Results](qa-results.md) · [한국어](#한국어)

## 2026-10-06 0.8.0 current trace

R01–R18 remain; **R14/R15 → D17 → P9** adds same-state/size bilingual settings geometry. Earlier dated current/latest/pending claims below are historical; current target 0.8.0(10) and baseline public/installed0.7.0(9) are distinct until [delivery QA](qa-results.md#2026-10-06-080-language-invariant-settings) records new proof.

| Requirement | New evidence required |
| --- | --- |
| R14/R15 | Full en→ko→en window/navigation/header/heading/row/card/form/control/document frame equality, preserved scroll/focus/pane/state, full TextKit/cell/glyph bounds and 12 pt vertical padding; default/minimum × light/dark × supported states; invalid geometry rejected; representative renders and actual normal native transition |
| R13/R16/R17 | Reviewed0.8 source/tag/ordinary remote push; exact signed prepared/public/latest-feed bytes and canonical installation; actual upgrade scope recorded; prior public/local-version deletion only afterward, preserving Git source/tags/key/user data |

Root baseline/regression evidence currently proves resource34/gate16/archive15 unsafe rejections+2 valid layouts/temporary installer15/crypto25 rejections+2 valid modes; it uses no Keychain or real installation and does not prove app runtime. Frozen candidate implementation/build/layout PASS: 36 author tests, 704 sealed rendered views/400 paired cases, 139 app-owned views per case, 416 negative executions across five guard types. Independent fresh 36 tests and two matrices (352 views/200 cases) reproduce the result; final independent verdict, normal native runtime, publication/install/cleanup and push remain separate gates. Complete accessibility, real capture/general paste/TCC and unavailable platform/hardware cases stay unverified unless actually executed.

한국어: R14/R15→D17→P9로 같은 상태/크기의 전체 배치/문서/스크롤/포커스·글리프/여백을 검증하고 R13/R16/R17로 최신 공개/설치 후 구버전 삭제를 추적합니다. 현재 회귀 자료와 작성자36 tests·704 합성 뷰/400 쌍별 case·별도36 tests/352뷰 재현을 확인했으며 실제 정상 native 동작·키·설치·새 배포/push 통과로 확대하지 않습니다.

## 2026-10-05 0.7.0 delivery trace

**Published and installed: Shot Clip 0.7.0 (build 9)**, 2026-10-05 22:06:35 KST (13:06:35Z). The immutable [release/tag](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0), public archive and installed app identify source `53bd5d2ad05375be7a6296da4534815260a38d98`. Normal source/tag push and remote equality passed; all six public redownloads and the canonical latest signed feed equal the independently approved preparation. Actual Sparkle 0.6.0(8)→0.7.0(9) download/extract/Install and Relaunch succeeded, with all 175 installed entries/bytes/links/file and directory modes equal the public ZIP; no manual installer was used. Ad-hoc signed, arm64 only, NOT notarized.

R13/R16/R17 delivery PASS: reviewed source A/new immutable v0.7.0/tag/remote equality, approved preparation/public bytes/Ed25519/latest feed, actual 0.6→0.7 updater and exact latest installed payload. R06 actual unavailable commands and explicit Access action PASS. R18 actual native synthetic PNG/error/recovery PASS 70; general paste/real captured pixels remain unpassed. Carbon UNVERIFIED after two attempts and environment-unavailable tests remain clearly separate. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records owners and safe metadata.

Korean normal runtime confirmed version/latest-feed result and acknowledgment; unavailable capture commands stay hidden and explicit Screen Recording recovery opens Access. Screen Recording is unavailable: candidate and installed capture harnesses report permission-SKIP, with no real capture/general paste/TCC grant/reset. Two native-automation shortcut attempts leave Carbon routing UNVERIFIED, without establishing a product defect. Full accessibility, macOS 14/Intel/clean-account and unprovided hardware/layout coverage remain unverified. The old 0.6 updater used a missing-plain-text notes fallback; notes display is not a passed claim. Nine non-time preference key digests remain equal, only `SULastCheckTime` changed after actual manual update checks, no keys added/removed and no raw values retained.

Recoverable cleanup and a true normal cold restart passed after cache removal: the installed 175-entry tree/signature and 173+57 language diagnostics remain valid; final canonical PID is 80286. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records the bounded removals and retained proof. Earlier snapshots below remain dated context. The [independent delivery verdict](release-review-0.7.0.md) is separate; documentation commits are verified by local/remote Git equality and do not change immutable release/tag/app source A.

한국어: 2026-10-05 22:06:35 KST에0.7.0(build 9)/소스`53bd5d2…`를 최신 공개했습니다. 공개6개 바이트/feed와 실제 Sparkle0.6→0.7 설치/재실행·175개 설치 항목/서명/173+57언어 자료를 확인했으며 수동 설치기는 사용하지 않았습니다. ad-hoc arm64·미공증입니다. 한국어 정상 최신 확인/권한 메뉴→Access를 확인했고 권한 없는 실제 캡처/붙여 넣기는SKIP, 전역 단축키는 자동화 두 시도로 미확정이며 결함 판정이 아닙니다. 전체 접근성/다른 OS·CPU·계정·장비와 이전 updater의 노트 표시는 통과를 주장하지 않습니다. 아홉 비시간 설정 digest는 같고 수동 확인 시각만 바뀌었습니다. 복구 가능한 정리 후 정상 cold restart/PID 80286과 설치 항목·서명·173+57 자료를 재확인했습니다. 과거 기록은 보존하고 독립 배포 판정/별도 문서 commit을 소스A와 구분합니다.

## 2026-10-05 0.7.0 release trace

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

R01–R18/D01–D16/P0–P8 carry forward. R13/R16/R17 additionally require reviewed new source/tag, exact signed prepared/public artifacts, canonicalfeed and latest installation. R02–R12/R18 normal capture/permission/paste and actual newer-build upgrade are distinct runtime gates. Declare environment-unavailable macOS 14/Intel/clean account/hardware coverage explicitly; synthetic/native fixtures cannot establish it. [Candidate QA](qa-results.md#2026-10-05-070-release-candidate) records owners/outcomes.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

Plans do not establish passes. Automatic tests cover deterministic geometry/state/failure paths; user-owned GUI tests cover real capture, permissions, paste, focus, and rendering.

| Requirement | Phase / decision | Automatic or review evidence | User-owned / release evidence |
| --- | --- | --- | --- |
| R01 | P1–P2 / D03 | Shortcut validation/conflict/restore; native key-equivalent character/modifiers and remembered-row mapping; repeated entry | Other app active; change/restart; real overlay |
| R02 | P2,P5 / D04,D06 | Clamp/move/resize and default region | Handles, Return/Capture, repeat region |
| R03 | P2,P5 / D04 | Four drag directions, zero/invalid rect | Valid release captures; reverse drag/cancel |
| R04 | P1,P5 / D05 | Encode-before-clear, write result/error | Immediate general clipboard image |
| R05 | P5 / D05 | No key injection source review | Image-capable app ⌘V; Preview ⌘N |
| R06 | P1–P2,P5,P8 / D08,D11,D12 | Preflight gating; unavailable capture rows omitted/explicit Access, shortcut recovery, production ready/unready dispatch | Fresh grant, deny/revoke, recheck/restart |
| R07 | P1–P2,P5 / D04 | Negative origins, scales, rounding, bounds | Real mixed-scale screens and changes |
| R08 | P1,P5 / D02 | Filter and cursor configuration review | Synthetic capture has no overlay/buttons/cursor |
| R09 | P1–P2,P5 / D05,D07 | Cancel/timeout/late result, rollback/external-change tests | UI cancel/failure preserves existing clipboard; OS limits disclosed |
| R10 | P1–P2,P5 / D07 | Single flight and stale result tests | Repeated shortcut/capture sessions |
| R11 | P1,P5 / D05 | Storage/network/log paths and buffer lifetime review | Metadata-only successful-capture diagnostics; no sensitive output |
| R12 | P2,P5 / D09,D11 | Key mapping and accessible-label/focus source review | M, native Tab/Shift-Tab, VoiceOver, error/sleep/display recovery |
| R13 | P6–P7 / D10,D14 | URL/key fail closed; signed feed/archive/manifest; tamper rejection | Uploaded bytes/canonical feed; actual version upgrade |
| R14 | P2–P4,P8 / D11–D13,D16 | Preserved square crop-copy artwork, true 44×44 rail, process-local Roboto/Noto cascade/weights/licenses, full multiline geometry, measured updater heights, Apple-reference toolbar and native menu fonts; inert native previews | Native popup/focus/accessibility separately tested; both languages/minimum sizes/appearances |
| R15 | P4 / D13 | English default, key parity/fallback, explicit live en→ko→en lookup, persisted choice and bundled resources; state-preserving refresh | Immediate app-owned UI/labels; minimum-size Korean layout; implemented new/visible public Sparkle driver dialogs and synthetic one-shot replies; macOS prompts separate |
| R16 | P3,P7 / D12 | Unchanged ID/executable/settings/key; spaced app root; signed temp migration/wrong-ID/three-path rollback fixtures | Canonical manual-folder migration and exact installed payload; historical Sshot grant separate; actual update unrun |
| R17 | P6–P7 / D08,D14 | Explicit ad-hoc mode, clean reviewed source/tag/artifact, signatures | Preview notes, downloaded artifact, per-app first launch; no notarization claim |
| R18 | P8 / D15 | Success-only thumbnail presentation, lower-right negative-origin geometry, original Fit/100%, production click/close/timeout, native save .OK/.cancel/failure, PNG pixel equivalence, isolated pasteboard retention, lifecycle cleanup | Normal capture-display placement, full-size image/native save interactions and general clipboard paste; no automatic storage/history |

## Current unreleased eight-item coverage

The new scope maps item1→R01/R06/R14; item2→R13/R14/R15; item3→R14/R15/D16; item4→R14/R15; item5→R14; item6→R04/R09/R11/R18/D15; item7→R14/R15/D16; item8→R02/R03/R08/R12/R14. Required evidence is the actual production source plus final build/resource/font/icon/geometry/callback fixtures and visual/native inspection. Current counts are 36 core tests and four 136-view matrices (544 total), 1236 updater/44 capture-preview assertions per run. Final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md` in [current QA](qa-results.md#2026-10-05-unreleased-eight-item-ui-refresh); earlier release/setting-polish counts below are retained history and cannot be reused as a new pass.

For previews and PNG export, use synthetic images and a uniquely named pasteboard to distinguish post-copy presentation from an actual screen-capture/general-clipboard test. Confirm unchanged pasteboard generation/data after thumbnail dismissal/timeout, original close, save cancellation and save failure; decode a synthetic PNG saved through the production path and compare original dimensions/pixels. These bounded fixtures do not establish TCC, general clipboard paste or actual capture pixels. Explicit user-selected product saving is permitted; no actual captured screen data or actual user-selected export destinations belong in evidence files. Ignored synthetic fixture images and QA output paths are permitted. Distinguish fixture app-preference equality from the whole session: native save panels may write OS folder metadata. Keep interactive QA on a unique signed QA bundle identity, report any observed defaults export change, and do not restore values without a recorded baseline.

한국어: 여덟 항목을 R01–R18/D15–D16에 연결하고 이번 최종 근거만으로 완료 여부를 판단합니다. 합성 이미지와 고유 named pasteboard로 썸네일/원본/PNG/취소/실패/닫기의 보존을 확인하며 실제 캡처·권한·일반 클립보드 붙여 넣기와 구분합니다.

## 0.6 scope and cleanup evidence

The earlier published/reviewed 0.6.0(8) follows R01/R14/R15 → D03/D11/D13 → P2/P4 → source/resource/transition/layout checks. Separate [source APPROVE](qa-review-0.6.0.md) covers the exact frozen candidate. Final author evidence includes 36 core tests, 159 app + 57 Updates keys per language, four 92-image integrated runs and 1,158 updater assertions in each run. Reviewer fresh checks passed resource 34 / installer 15 / gate 16; root crypto 25 / unsafe ZIP 15 plus two valid cases passed. These counts supersede the earlier baseline, without extending acceptance to unrun capture, accessibility or upgrades. Native menu models test title/key/modifier data; rendering a model does not establish native popup interaction or real global-hotkey delivery. A live-language synthetic runtime check must use the production refresh path, preserve state and avoid persistent defaults, TCC, capture, clipboard and updater actions.

Initial cleanup is coordinator-reported evidence: 14 previous `dist/build.*` staging folders (11 iconsets and three empty), 12,897,238 bytes, moved recoverably to Trash; `.build/` retained. That initial staging cleanup is distinct from the later root-verified 0.6 publication/exact installation/limited normal runtime and final 60-item recoverable cleanup (616,854,254 regular-file bytes). `.build/` and generated apps/caches are now absent, and installed 171-entry/localization checks pass after their removal. [Current results](qa-results.md#2026-10-05-060-publication-installation-and-cleanup) record both stages and the independent-review/commit boundary.

## Evidence rules

Record date, commit, environment (macOS/Xcode/CPU), case ID, method, expected/actual result, PASS/FAIL/SKIP, requirement, and remaining defect/limit. Hardware capture records can include display geometry/scale; never include captures, screen content, observed app names/window titles, or clipboard contents. Use synthetic content, inspect images in memory, and keep only safe metadata.

`swift test`, build success, and code review do not prove GUI acceptance. A harness SKIP (including permission absence) is not PASS; `open` returning zero does not prove harness PASS. Latest-host compilation does not prove macOS 14 or Intel support. Cryptographic archive/feed verification does not prove Gatekeeper acceptance, TCC consent, or a completed upgrade.

An independent verifier reviews final changes in a separate context. Keep document checks and runtime checks separate. Code push is verified by local HEAD/remote commit equality; binary release requires its own artifact/tag/upload verification. Capture QA is user-owned and is not a fabricated prerequisite for code push or the authorized preview; disclose missing runtime coverage.

## Document checks

Confirm R01–R18 appear in requirements and verification; phases/decisions map them in development/architecture. Check Markdown relative files/fragments and whitespace, current source paths, Shot Clip naming, bilingual entry points, and explicit prediction labels. Historical audit entries may keep legacy names only under an archive disclaimer. See [handoff](handoff.md) for this worker’s actual checks.

## 한국어

R01–R18을 단계·설계 결정·자동 검증·사용자/배포 검증에 연결합니다. 0.6은 참조 스타일 설정, native 단축키 열, 즉시 영어/한국어 전환과 상태 보존을 검증하고 custom Sparkle driver의 새/열린 업데이트 창과 callback도 검증하고 macOS 시스템 창은 별도 범위로 기록합니다. 자동 테스트는 순수 로직과 오류 경로를 검증하고 실제 캡처·권한·붙여 넣기·포커스·VoiceOver·레이아웃은 사용자 담당입니다. 빌드/문서 확인이나 SKIP을 앱 동작 PASS로 바꾸지 않습니다.

결과는 날짜·commit·환경·case·예상/실제·상태·요구사항·남은 한계만 기록합니다. 실제 캡처 이미지·화면·앱/창 이름·클립보드 내용·실제 사용자가 선택한 저장 경로는 QA 기록/로그/저장소에 남기지 않습니다. 합성 fixture 이미지와 ignored QA 출력 경로는 검증 근거로 허용합니다. 제품의 명시적 PNG 저장은 사용자 선택 위치에만 허용하며 자동 저장·이력은 제외합니다. 작성과 독립 검토를 분리하고 코드 push·공개 바이너리·실제 업데이트 증거를 각각 확인합니다.
