# Shot Clip development plan

[Requirements](requirements.md#requirements) · [Architecture](architecture.md#decision-register) · [QA plan](qa-plan.md) · [한국어](#한국어)

## Documentation maintenance plan

The current request is documentation-only. Record its scope before editing, rewrite usage/current support, check links/trace/source facts and protected files, obtain separate document review, then perform the already-authorized ordinary main push through the coordinator. Do not build, test, install, retag or redeploy the app for this text change. The starting documentation baseline is `66cbe749a25b6bd289885420cb0fff89e8b5307e`; release source A and all public files remain immutable.

## Build from source

Use macOS with Xcode/its selected command-line tools and Python 3 installed, then run from the repository root. `Package.swift` declares Swift tools 5.9 and macOS 14 minimum runtime; the verified build host is macOS 27.0.1, Xcode 27 and Swift 6.4 on arm64. Other toolchains/architectures are not established by that evidence. SwiftPM resolves the pinned Sparkle 2.10.0 dependency.

Quit every Shot Clip process before building or replacing its generated bundle. With release-related environment overrides unset, the normal local build is:

```sh
bash scripts/build-app.sh
# Optional manual launch after a successful build:
open 'dist/Shot Clip.app'
```

This creates `dist/Shot Clip.app` with development/ad-hoc signing and the production code flavor, using `.build/production`. It does not publish or install the app. A normal launch shares `dev.shotclip.app` preferences with the installed app; it can initialize the ordinary updater and permission status. For inert tests use the separate development-only QA build and exact commands in [QA plan](qa-plan.md#production-and-isolated-qa-builds), rather than launching a normal app. No build or launch is performed for this documentation refresh.

## Ordered work and trace

Requirements precede design, implementation and verification. These identifiers retain their original scope; a phase does not imply every real-world acceptance check passed.

| Phase | Requirements | Decisions / implementation | Evidence and status |
| --- | --- | --- | --- |
| P0 | R01–R18 | Product/requirements/docs | Current scope and independent document review; this refresh changes text only |
| P1 | R06–R11 | D01–D05,D07; CaptureCore and capture/clipboard services | Logic/error/geometry/coordinator regressions; real pixels/paste remain separate |
| P2 | R01–R03,R06,R12,R14 | D03,D06,D09,D11; AppDelegate/Overlay/Settings/PermissionStatus | Native interaction source and synthetic tests; full real focus/Carbon/accessibility scope unverified |
| P3 | R14,R16 | D12; stable ID and installation/migration | Allowlist preferences, signed temporary installer/rollback fixtures, exact canonical payload |
| P4 | R15 | D13; localization/resources | English default, en/ko parity/fallback/live transitions, retained state, normal native language proof |
| P5 | R02–R12 | D02,D04–D07; capture acceptance | Real capture/permission/paste is user-owned and not newly run for current delivery |
| P6 | R13,R17 | D08,D10,D14; preview preparation | Reviewed clean source/tag, explicit mode, exact signed archive/feed/manifest |
| P7 | R13,R16,R17 | Public/latest installation and cleanup | Six public files/feed, real Sparkle upgrade, installed bytes, cold restart and scoped cleanup verified |
| P8 | R04,R06,R09,R11,R12,R14,R15,R18 | D11,D13,D15,D16; consistent UI/original preview/export | Historical independently reviewed synthetic/native-save evidence; current normal capture/export not newly tested |
| P9 | R14,R15 | D17; language-invariant settings | Complete paired geometry, glyph/line/padding guards, four sizes, preserved state and bounded normal native proof |
| P10 | R11,R13 | D18; feed expiry/QA exclusion/path purity | Security negative fixtures, retired argv, full artifact scan, isolated QA and exact current delivery |

<a id="2026-10-06-ordered-081-security-work"></a>
## Security implementation sequence

The completed P10 sequence was contract → official/pinned-source research → strict feed policy and production/QA split → resource/metadata packaging → negative tests and isolated UI proof → independent source review → immutable source/tag/preparation/public bytes → actual latest upgrade/install/cold restart → approved cleanup and documentation/main push. It introduced no key rotation, TCC reset or general clipboard mutation. [QA results](qa-results.md#current-evidence) separates each gate.

<a id="2026-10-06-ordered-080-work"></a>
## Settings implementation sequence

D17/P9 defined readable typography and a common bilingual full-content reservation before implementation. Code measured actual widths and fallback ink, fixed native control lanes and retained minimum-size scrolling. Full structural-frame comparisons and deliberately invalid geometry preceded review; native root/translation checks were a separate bounded runtime gate. The contract remains current in 0.8.1.

## Migration contract

Only missing, validated shortcut/mode values migrate from `dev.sshot.app`; destination values win. Do not copy entire defaults domains, image/region/privacy/login/updater/trust state. English remains the fresh/migrated default, login is opt-in, and the established Ed25519 key/Keychain account is retained. Legacy identity/folder transitions may require manual canonical installation and a fresh permission grant; stock Sparkle is not promised to rename an old host folder.

## Work and review boundaries

- Preserve user changes; use ordinary Git operations and never overwrite an existing version/tag/public asset.
- Consult official APIs before implementation; keep proposal, source evidence, runtime evidence and unsupported environments distinct.
- Separate authoring from approval. Review the exact inputs/artifacts used, then record actual commit/push/public equality.
- App tests may use synthetic content/private named pasteboards; real capture/grants/general paste stay explicitly scoped. No capture, clipboard, observed app/window or export-path data in logs/repo/remote services.
- A normal production-flavor development app shares the production preference domain. Use the explicit isolated QA flavor for inert fixtures; quit Shot Clip before build-app replacement.

## Next work

No app-development or release task is pending for this README refresh. Related-doc authoring, independent document review and an ordinary documentation commit/main push are the remaining steps. Record actual completion in [handoff](handoff.md#current-status); do not invent a future commit hash or app test run.

## 한국어

요구사항 → 설계 → 구현 → 검증 순서를 유지합니다. P0–P10은 기존 추적 번호이며 P5의 실제 캡처·권한·붙여 넣기와 전체 접근성은 별도 범위입니다. P9는 한영 전체 배치와 글리프, P10은 서명 feed/production QA 제외/개발 경로 제거를 검증하고 현재 0.8.1 배포에 포함했습니다.

소스 빌드는 저장소 루트에서 `bash scripts/build-app.sh`로 `dist/Shot Clip.app`을 만듭니다. 빌드 전 Shot Clip을 종료하고, 정상 개발 앱은 설치 앱과 설정을 공유하므로 합성 검증에는 [별도 QA 빌드](qa-plan.md#production-and-isolated-qa-builds)를 사용합니다.

이번 작업은 문서만 정리합니다. 시작 main은 `66cbe749…5307e`이고 앱 소스 A·태그·공개 파일을 유지합니다. 문서 검사와 별도 승인 후 조정자가 일반 commit/push를 진행하며 새 앱 빌드·테스트·설치·배포는 없습니다.
