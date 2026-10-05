# Shot Clip documentation

[English README](../../README.md) · [한국어 README](../../README.ko.md)

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
