# Shot Clip documentation

[English README](../../README.md) · [한국어 README](../../README.ko.md)

Reviewed source: **0.6.0 (build 8)**, native reference-style settings/menu and immediate app language switching, including the supported Sparkle user driver. [Independent source APPROVE](qa-review-0.6.0.md) covers the frozen candidate; [current QA](qa-results.md#2026-10-05-060-publication-installation-and-cleanup) separates source/development/preparation checks from actual publication, exact installation, limited normal runtime and completed recoverable cleanup. Latest public release is [0.6.0](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.6.0).

Read requirements → design → implementation order → verification. Plans describe the target; QA results describe only performed checks.

| Document | Purpose |
| --- | --- |
| [Product plan](product-plan.md) | Audience, simple capture-to-clipboard scope, approved delivery |
| [Requirements](requirements.md) | R01–R17 and acceptance criteria |
| [Design system](design-system.md) | Native tokens, keyboard/permission/language design, labeled 2027 predictions |
| [Architecture](architecture.md) | Services, state, coordinate/clipboard rules, D01–D14 |
| [Development plan](development-plan.md) | Requirement → design → implementation → QA trace |
| [Verification](verification.md) | Requirement coverage and evidence rules |
| [QA plan](qa-plan.md) | Fast checks and user-owned GUI procedures |
| [QA results](qa-results.md) | Executed results and honest historical Sshot evidence |
| [Technical validation](technical-validation.md) | Apple/SDK probes and platform limits |
| [Update operations](update-operations.md) | GitHub ad-hoc preview, mandatory archive/feed signatures |
| [Handoff](handoff.md) | Current work, pending evidence, branch/commit/push status |

## 한국어

0.6.0(build 8)의 참조 스타일 native 설정/메뉴·즉시 영어/한국어 전환·지원되는 Sparkle driver 소스는 독립 승인되었고 최종 개발 fixture를 확인했습니다. 현재 공개 버전은 0.6.0이며 소스/합성 검사와 공개 바이트·정확한 설치·제한된 정상 런타임·완료된 복구 가능한 정리 증거를 구분합니다. 제품명은 Shot Clip이고 공개 문서는 영어를 기본으로 하며 한국어 README와 계획별 한국어 요약을 제공합니다. R01–R17을 설계·구현·QA까지 연결하고, 계획과 실제 검증 기록을 구분합니다. 과거 Sshot 기록의 이름·식별자·산출물은 당시 증거로 보존합니다. 실제 캡처 GUI 테스트는 사용자가 맡으며 문서 검증으로 대신하지 않습니다.
