# Shot Clip documentation

[English README](../../README.md) · [한국어 README](../../README.ko.md)

## 2026-10-06 current 0.8.1 security work

**Target: 0.8.1 (build 11); verified public/installed baseline: 0.8.0 (build 10).** R13/R11 → D18 → P10 fixes invalid-feed timeout fallback, removes production QA entry paths while preserving isolated development QA, and rejects private developer-home and absolute source/build paths anywhere in the published app. Shipped bilingual layout/fonts, native behavior, identity/preferences/keys and privacy limits remain required.

Read [requirements](requirements.md#2026-10-06-081-security-requirements) → [design](design-system.md#2026-10-06-d18-security-and-qa-boundaries) → [ordered plan](development-plan.md#2026-10-06-ordered-081-security-work) → [QA ledger](qa-results.md#2026-10-06-081-security-findings-and-candidate-status) and [handoff](handoff.md#2026-10-06-081-security-handoff). Frozen author core/security/isolated QA and separate root candidate package/native checks pass; independent approval and new source/tag/public/install/push evidence remain pending; older dated current/latest/pending statements remain historical. Independent historical reviews retain their original scope.

한국어: 현재 작업은 0.8.1 (build 11)의 R13/R11·D18/P10 보안 수정입니다. 검증된 공개·설치 기준은 0.8.0 (build 10)이며 새 결과/배포 통과를 앞서 주장하지 않습니다. 과거 날짜별 기록과 별도 리뷰는 그대로 보존합니다.

## 2026-10-06 current 0.8.0 delivery

**Published and installed: Shot Clip 0.8.0 (build 10)**, [latest release](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.8.0). Follow [delivery QA](qa-results.md#2026-10-06-080-publication-installation-and-retirement), [current operations](update-operations.md#2026-10-06-080-current-operations), [delivery trace](verification.md#2026-10-06-080-delivery-trace), [independent delivery review](release-review-0.8.0.md) and [handoff](handoff.md#2026-10-06-080-delivery-handoff) for source A, exact artifacts, normal runtime and completed retirement/cleanup. R14/R15→D17→P9 is shipped; full paired geometry fixtures and bounded normal General language transition remain distinct evidence.

Only v0.8.0/six assets remain public. Earlier current/latest/pending and retention statements below are historical; retired release/download links are unavailable, while Git source/tags and dated records remain. Independent final document review and ordinary documentation commit B/main push follow this record without changing source A/tag/app/public bytes.

한국어: 현재 공개·설치는 0.8.0(10)이며 D17/P9 한·영 설정 불변성·실제 Sparkle 설치·구버전 삭제·산출물 정리/재시작을 검증했습니다. 전체 프레임 matrix와 실제 General 전환을 구분하고 과거 공개 링크는 unavailable, Git 이력/태그는 보존합니다. 문서 B 검토/push는 소스 A·공개 바이트와 별도입니다.

## 2026-10-06 current 0.8.0 work

The active target is **0.8.0 (build 10)** with language-invariant settings. Public/installed 0.7.0(9) remains the baseline until new delivery evidence exists. Earlier dated current/latest/pending statements below are historical snapshots; follow [current requirements](requirements.md#2026-10-06-080-bilingual-settings-contract), [settings design](design-system.md#2026-10-06-language-invariant-settings-design), [ordered work](development-plan.md#2026-10-06-ordered-080-work), [QA ledger](qa-results.md#2026-10-06-080-language-invariant-settings), [operations](update-operations.md#2026-10-06-080-delivery-and-retirement) and [handoff](handoff.md#2026-10-06-080-settings-handoff).

The current trace adds **D17/P9** to R01–R18/D01–D16/P0–P8. It covers same-state/size en→ko→en window/row/card/control/document/scroll/focus equality, full text bounds and native form sizing. Latest public/install verification comes before prior public-release and owned local-version deletion; retained source tags preserve historical versions when their download links are retired. The candidate passes 36 author tests and four sealed matrices (704 views/400 paired cases); independent 36-test/two-matrix reproduction and current limits are in the QA ledger. Plans, inert rendering, normal runtime and delivery evidence remain separate.

한국어: 현재0.8.0(10) 작업은 D17/P9의 한·영 설정 배치 불변성을 추가합니다. 새 공개·설치가 검증되기 전 기준은0.7.0(9)이며 최신 검증 후 과거 공개/로컬 버전을 삭제하고 Git 이력/태그를 보존합니다. 아래의 과거 최신/대기 문구는 당시 기록이며 현재 상태는 위 링크의 새 기록을 따릅니다.

## 2026-10-05 0.7.0 current delivery

**Published and installed: Shot Clip 0.7.0 (build 9)**, 2026-10-05 22:06:35 KST (13:06:35Z). The immutable [release/tag](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0), public archive and installed app identify source `53bd5d2ad05375be7a6296da4534815260a38d98`. Normal source/tag push and remote equality passed; all six public redownloads and the canonical latest signed feed equal the independently approved preparation. Actual Sparkle 0.6.0(8)→0.7.0(9) download/extract/Install and Relaunch succeeded, with all 175 installed entries/bytes/links/file and directory modes equal the public ZIP; no manual installer was used. Ad-hoc signed, arm64 only, NOT notarized.

[Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation), [candidate approval](qa-review-0.7.0.md), [operations](update-operations.md#2026-10-05-070-published-update-operations) and [handoff](handoff.md#2026-10-05-070-delivery-handoff) connect final evidence and limits. Both languages remain supported; R01–R18/D01–D16/P0–P8 retain the eight-item contract.

Korean normal runtime confirmed version/latest-feed result and acknowledgment; unavailable capture commands stay hidden and explicit Screen Recording recovery opens Access. Screen Recording is unavailable: candidate and installed capture harnesses report permission-SKIP, with no real capture/general paste/TCC grant/reset. Two native-automation shortcut attempts leave Carbon routing UNVERIFIED, without establishing a product defect. Full accessibility, macOS 14/Intel/clean-account and unprovided hardware/layout coverage remain unverified. The old 0.6 updater used a missing-plain-text notes fallback; notes display is not a passed claim. Nine non-time preference key digests remain equal, only `SULastCheckTime` changed after actual manual update checks, no keys added/removed and no raw values retained.

Recoverable cleanup and a true normal cold restart passed after cache removal: the installed 175-entry tree/signature and 173+57 language diagnostics remain valid; final canonical PID is 80286. [Delivery QA](qa-results.md#2026-10-05-070-publication-and-sparkle-installation) records the bounded removals and retained proof. Earlier snapshots below remain dated context. The [independent delivery verdict](release-review-0.7.0.md) is separate; documentation commits are verified by local/remote Git equality and do not change immutable release/tag/app source A.

한국어: 2026-10-05 22:06:35 KST에0.7.0(build 9)/소스`53bd5d2…`를 최신 공개했습니다. 공개6개 바이트/feed와 실제 Sparkle0.6→0.7 설치/재실행·175개 설치 항목/서명/173+57언어 자료를 확인했으며 수동 설치기는 사용하지 않았습니다. ad-hoc arm64·미공증입니다. 한국어 정상 최신 확인/권한 메뉴→Access를 확인했고 권한 없는 실제 캡처/붙여 넣기는SKIP, 전역 단축키는 자동화 두 시도로 미확정이며 결함 판정이 아닙니다. 전체 접근성/다른 OS·CPU·계정·장비와 이전 updater의 노트 표시는 통과를 주장하지 않습니다. 아홉 비시간 설정 digest는 같고 수동 확인 시각만 바뀌었습니다. 복구 가능한 정리 후 정상 cold restart/PID 80286과 설치 항목·서명·173+57 자료를 재확인했습니다. 과거 기록은 보존하고 독립 배포 판정/별도 문서 commit을 소스A와 구분합니다.

## 2026-10-05 0.7.0 release candidate

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

[Current candidate QA](qa-results.md#2026-10-05-070-release-candidate), [release gates](update-operations.md#2026-10-05-070-release-candidate-operations), [remaining acceptance](qa-plan.md#2026-10-05-070-release-acceptance) and [handoff](handoff.md#2026-10-05-070-release-candidate-handoff) distinguish host-actionable checks, unavailable environments and pending public/install proof.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

Current source: **UNRELEASED eight-item UI refresh**, retaining development version 0.6.0(8), `main` HEAD `f416300…` and public/installed source `e87e40e…`. [Current requirements](requirements.md#2026-10-05-unreleased-eight-item-ui-refresh), [design foundations](design-system.md#2026-10-05-unreleased-design-system-refresh) and [current QA](qa-results.md#2026-10-05-unreleased-eight-item-ui-refresh) cover ready-only capture menus/Access, content-sized update dialogs, bundled Google fonts, full multiline padding, square rail geometry, success-only thumbnail/original/explicit PNG export, central tokens and the Apple-reference toolbar. Existing icon artwork and prior unreleased settings polish are preserved. 36 core tests and four 136-view synthetic runs (544 total) passed; final sealed development-bundle checks and the 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`; no new commit/push/tag/deployment or installation occurred.

한국어: 여덟 UI 개선은 미배포 소스이며 새 R18 원본/사용자 선택 PNG 저장과 중앙 디자인 토큰을 추적합니다. 저장 취소·닫기에도 클립보드를 유지하고 자동 저장·이력은 제외합니다. 공개 0.6과 현재 개발 변경, 문서 검사와 실제 앱 검증을 구분합니다.

Published reviewed source: **0.6.0 (build 8)**, native reference-style settings/menu and immediate app language switching, including the supported Sparkle user driver. [Independent source APPROVE](qa-review-0.6.0.md) covers the frozen candidate; [current QA](qa-results.md#2026-10-05-060-publication-installation-and-cleanup) separates source/development/preparation checks from actual publication, exact installation, limited normal runtime and completed recoverable cleanup. Latest public release is [0.6.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.6.0).

Read requirements → design → implementation order → verification. Plans describe the target; QA results describe only performed checks.

| Document | Purpose |
| --- | --- |
| [Product plan](product-plan.md) | Audience, simple capture-to-clipboard scope, approved delivery |
| [Requirements](requirements.md) | R01–R18 and acceptance criteria |
| [Design system](design-system.md) | Native tokens, keyboard/permission/language design, labeled 2027 predictions |
| [Architecture](architecture.md) | Services, preview/export state, coordinate/clipboard rules, D01–D16 |
| [Development plan](development-plan.md) | Requirement → design → implementation → QA trace |
| [Verification](verification.md) | Requirement coverage and evidence rules |
| [QA plan](qa-plan.md) | Fast checks and user-owned GUI procedures |
| [QA results](qa-results.md) | Executed results and honest historical Sshot evidence |
| [Technical validation](technical-validation.md) | Apple/SDK probes and platform limits |
| [Update operations](update-operations.md) | GitHub ad-hoc preview, mandatory archive/feed signatures |
| [Handoff](handoff.md) | Current work, pending evidence, branch/commit/push status |

## 한국어

0.6.0(build 8)의 참조 스타일 native 설정/메뉴·즉시 영어/한국어 전환·지원되는 Sparkle driver 소스는 독립 승인되었고 최종 개발 fixture를 확인했습니다. 현재 공개 버전은 0.6.0이며 소스/합성 검사와 공개 바이트·정확한 설치·제한된 정상 런타임·완료된 복구 가능한 정리 증거를 구분합니다. 제품명은 Shot Clip이고 공개 문서는 영어를 기본으로 하며 한국어 README와 계획별 한국어 요약을 제공합니다. R01–R18을 설계·구현·QA까지 연결하고, 계획과 실제 검증 기록을 구분합니다. 과거 Sshot 기록의 이름·식별자·산출물은 당시 증거로 보존합니다. 실제 캡처 GUI 테스트는 사용자가 맡으며 문서 검증으로 대신하지 않습니다.
