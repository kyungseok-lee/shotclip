# ShotClip handoff

[Documentation](README.md) · [Development plan](development-plan.md) · [QA results](qa-results.md)

## 2026-10-05 current documentation handoff

- Direction: ShotClip / `kyungseok-lee/shotclip`; `dev.shotclip.app`, executable `shotclip`, `/Applications/ShotClip.app` installation target; sealed local development bundle now confirms `0.4.0` (build `5`), as recorded below.
- Approved delivery: GitHub ad-hoc developer preview. Developer ID/notarization is separate and rejected for this release; historical certificate/publication gates below do not override the new authorization.
- Compatibility: one-time manual installation from historical Sshot; validated shortcut/mode migration preserves new values. Fresh Screen Recording grant expected; login/consent are not migrated. Existing Ed25519 archive/feed trust and Keychain `sshot` account retained without private-key export/rotation/regeneration.
- Interaction: English default with persistent English / 한국어 setting, restart to apply; M switches mode and Tab/Shift-Tab traverses native controls. VoiceOver/native-focus/language-layout GUI checks are not run.
- Owned changes: `README.md`, `README.ko.md`, and all twelve Markdown files in `docs/shotclip` (index, product-plan, requirements, design-system, architecture, development-plan, verification, qa-plan, qa-results, technical-validation, update-operations, handoff). No code, script, AGENTS, commit, push, installation, or publication was performed by this documentation worker.
- Evidence: source/old-doc inspection and Apple primary-source consultation completed. Document checks passed for 14 files, 88 relative file/fragment links, R01–R17 rows, D01–D14 rows, P0–P7 phases, Korean companion sections, labeled predictions, balanced fences and whitespace; `git diff --check -- README.md README.ko.md docs/shotclip` passed. Since relocated docs are untracked, the file-level validator also checked their content directly. No app build/tests or actual capture/permission/paste checks run in this lane; code/release workers provide separate evidence.
- Review: foundational three-plan milestone sent to coordinator before remaining docs work. Independent approval belongs to the coordinator's verifier, not this authoring lane.
- Next: independent docs/code/release review → commit/push/tag reviewed source → prepare the final preview from that source and verify/upload as authorized. Current development QA results are recorded below. Capture/permission/paste remains user-owned; do not turn missing GUI coverage into PASS.
- Git at task start: `main`, HEAD `4f5dcae`; shared rebrand changes already present. This worker creates no commit/push and makes no remote equality claim. Coordinator must record final commit/tag/push/public asset evidence separately.

한국어: 제품·개발·디자인과 영어/한국어 README를 갱신하고 요구사항·설계·구현 순서·QA를 연결했습니다. 승인된 경로는 ad-hoc 프리뷰이며 기존 키를 유지합니다. 실제 GUI·권한·붙여 넣기·배포는 이 문서 작업에서 실행하지 않았고 독립 검토와 코드/원격 증거는 별도로 기록합니다.

## 2026-10-05 current code and package QA handoff

- Writer changes: only `docs/shotclip/qa-results.md` and this file; replaced current proposed-version wording with verified development-bundle metadata and appended English-first QA evidence with Korean summaries. Historical Sshot audits remain intact; [independent QA review](qa-review.md) belongs to the separate reviewer and is not authored or approved here.
- Document checks: PASS for these two files and 13 relative file/fragment links, balanced fences, whitespace and final newlines; historical audit sections match their pre-edit SHA256 hashes. Untracked files were checked directly, in addition to scoped `git diff --check`; these are document checks, not app or source approval.
- Root evidence: final `swift test` in `dist/core-final-qa.log` at 01:54:06 KST passed 34 XCTest tests with zero failures; `bash scripts/build-app.sh` in `dist/package-qa.log` completed with exit 0. Root separately reported independent reruns at 01:55:40 KST: 25 crypto/policy negatives, 16 release gates, 13 unsafe ZIP cases plus two valid cases, and 22 resource fixtures, all exit 0. These are root reruns, not writer reruns or the earlier release-author report's eight archive negatives.
- Read-only artifact checks: actual `dist/ShotClip.app` is ShotClip / `dev.shotclip.app` / executable `shotclip` / 0.4.0(5), arm64, with valid deep/strict ad-hoc signature and 109 keys in each packaged en/ko table. Coordinator-supplied resource diagnostic JSON is PASS with `fallback:true`, `installedBundle:true`, `keyCount:109`, languages en/ko; that field does not establish installation or rendered GUI behavior. Fresh `ditto` archive `dist/shotclip-package-final-qa.zip` (2,342,408 bytes) passed the writer's archive-validator and `unzip -tq` checks; exact commands and evidence ownership are in [QA results](qa-results.md#2026-10-05-current-code-and-package-qa).
- Provenance/support: `SHOTCLIPReleaseMode=development`, source baseline `4f5dcaee4dfa95e5603c57c5760e75c90aeb6503`, dirty `main`; this package is development QA evidence, not a final reviewed-commit release. Host inspected: macOS 27.0.1 (26A434), Xcode 27.0 (27A266a), Swift 6.4, arm64. macOS 14/Intel runtime remains untested; the current artifact intended for public preparation is arm64.
- Limits: capture/permission/paste, rendered language layout, VoiceOver and native-focus manual GUI QA remain user-owned and unrun. Installation/migration, clean-account first launch, public feed/assets and end-to-end update are unrun. Existing Keychain account `sshot` and Ed25519 trust are preserved without rotation/export/recreation; this writer made no build, GUI, Keychain, TCC/security or Git mutations.
- Pending coordinator operations: obtain the separate reviewer's final verdict, then commit/push/tag reviewed source, prepare and sign the final ad-hoc preview from that source, verify/publish public assets/feed and record exact remote evidence; installation/manual migration and end-to-end upgrade remain pending. Developer ID/notarization is separate from the authorized preview. No final commit, push, tag, public-asset or installation completion is claimed here.

한국어: 두 문서에 최종 34개 테스트·빌드와 조정자의 릴리스 회귀 재실행, 0.4.0(5) 번들·서명·109개 영어/한국어 키·실제 ZIP 증거를 추가했습니다. baseline `4f5dcae`의 미커밋 개발 QA 자료이며 최종 배포가 아닙니다. 독립 리뷰는 별도 작업자가 맡고 수동 GUI·macOS 14/Intel·commit/push/tag·최종 서명/게시·설치·실제 업데이트는 인수 항목으로 남습니다.

## Historical Sshot handoff — retained as recorded

Everything below is historical 2026-10-04/0.2.x–0.3.0 evidence. Legacy branding, identifiers, installation/archive paths, commits and old certificate gates are kept to identify the tested artifacts honestly. Resume using the current ShotClip plans and operation guide above, not archived commands or superseded approval requests.

### 2026-10-04 state (historical)

- 단계: 기술 probe·앱 구현·자동 회귀 및 로컬 release 빌드 완료. 실제 캡처 QA는 권한 대기이며 전체 QA·배포 완료를 선언하지 않았습니다.
- 사용자 승인 범위: 문서 기반 개발 및 Git push. 최신 요청에 따라 캡처/권한 수동 QA는 사용자가 맡고 에이전트는 코드 검토와 빠른 자동 검증 후 코드 커밋·push를 진행합니다. 장시간 GUI 테스트는 중단합니다.
- 산출물: CaptureCore, AppKit 앱, 합성 fixture/self-test, 자동 테스트, 앱 빌드·공증 준비 스크립트, 설계·QA 문서.
- 제품 표시 이름: Sshot. 실행 파일·저장소 이름은 sshot입니다.
- 앱 빌드/테스트: 최신 빠른 자동 테스트 25개·negative 6개 통과. 현재 0.3.0(build 4) 로컬 release·ICNS 및 deep/strict ad-hoc 서명 검사·`/Applications/sshot.app` 설치와 설정 3섹션 확인. 실제 캡처·붙여 넣기는 사용자 인수 상태입니다.
- 기술 결정: architecture.md와 technical-validation.md에 채택한 D01~D11 및 플랫폼 한계 기록. Developer ID 인증서 0으로 D08 공증 배포는 미완료.
- 원격 반영: 코드 검토·빠른 자동 검증 후 검토된 변경을 커밋·push할 수 있습니다. 사용자 수동 캡처 QA 미완료를 코드 push 차단 조건으로 사용하지 않습니다. 실제 commit은 `git log -1`, 원격 반영은 로컬 HEAD와 `git ls-remote origin refs/heads/main`으로 확인합니다. 공개 바이너리 release gate는 유지합니다.

## 2026-10-04 구현 기록

- 구현: 전역 단축키 변경/충돌 처리, 마스크·즉시 드래그 선택, SCK 자체 앱 제외, PNG/TIFF 메모리 복사, 오류 복원, 화면 변경/잠자기 취소, timeout 및 늦은 결과 차단.
- QA: 자동 테스트, shell/plist/서명 검사 통과. native 안내 창 확인, Finder에서 전역 단축키가 권한 안내를 여는 것 확인. recorder의 Shift 숫자 표시 버그 수정·실제 기본값 ⌃⇧⌘5 표시 확인.
- 실제 하드웨어: 화면 0 (0,0,3360,1890) 2x, 화면 1 (-1728,773,1728,1117) 2x, 화면 2 (3360,810,1920,1080) 1x. 권한 허용 후 self-test가 세 화면을 검사한다.
- 권한: 설정 스위치는 켜짐이지만 최신 앱의 API는 거부/SKIP이다. ad-hoc 빌드 교체로 허용 identity가 맞지 않는 것으로 추정한다. 사용자가 최신 sshot에 화면 기록 허용을 다시 적용한 뒤 재실행해야 한다. TCC 자동 변경/reset 없음. 앱과 권한 설정 화면을 열어 두었으며 실행 PID는 재사용하지 않는다.
- 남은 gate: 실제 capture pixel/overlay/clipboard, 두 모드 mouse·keyboard UI, Preview 붙여 넣기, 반복/취소 및 실제 화면 변화 QA. 서명·공증·macOS 14/Intel·깨끗한 계정 QA는 별도 환경 필요.
- 작업 환경 복구: recorder 테스트로 변경했던 단축키를 기본 ⌃⇧⌘5로 돌렸다. 일반 clipboard를 변경한 테스트는 실행하지 않았다.
- 다음 시작: `open dist/sshot.app` → 화면 기록 허용 → 필요 시 재실행 → README의 LaunchServices 기반 self-test 명령. 직접 binary 실행은 터미널 권한 귀속과 혼동할 수 있습니다. open 종료 코드 대신 JSON PASS/FAIL/SKIP을 구분하고 qa-results.md에 실제 결과 기록.

## 과거 0.2.0 업데이트·권한 안내 작업 기록

- 이 절은 0.2.0 시점의 과거 기록입니다. 당시 Sparkle 연동 및 권한 UI 검토는 완료했고 업데이트 키/feed는 미구성이었습니다. 현재 0.2.1의 키/feed·로컬 서명 검증은 아래 GitHub 후속 기록을 따릅니다.
- 운영 경로: 일반 실행은 `/Applications/sshot.app`. 앱을 종료한 뒤 빌드하고 `bash scripts/install-app.sh`로 검증·백업·설치합니다. 기존 앱 백업 위치는 스크립트가 출력합니다. 개발 self-test는 sibling fixture가 있는 `dist`에서 LaunchServices로 실행합니다.
- 배포 상태: Developer ID 인증서 0이라는 이전 증거가 있으며 실제 인증서·HTTPS appcast·호스팅·업데이트 키·종단간 업그레이드 성공은 없습니다. 개인 키를 저장소에 넣지 않습니다.
- 권한 한계: ad-hoc 교체는 재허용이 필요할 수 있습니다. 안정적인 Developer ID identity는 이를 줄이지만 권한 재요청이 절대 없음을 보장하지 않습니다. TCC 자동 초기화는 하지 않습니다.
- 최신 작업 분담: 코드 검토·빠른 자동 검증 → 코드 커밋/push. 실제 권한 허용과 두 모드 캡처·붙여 넣기는 사용자 인수입니다. 자동 업데이트 공개 배포는 production 인증서·공증 및 배포 QA가 준비된 뒤 진행합니다.

- 최신 증거: 부모 실행 25 tests pass(22:39), deep/strict 서명 검사 및 안정 경로 설치 통과. GUI의 미허용 상태·disabled capture·ad-hoc 안내·경로/버전·미설정 update toggle 확인. 대체 UI 도구로 업데이트 미설정 modal·다시 확인의 미허용 상태 유지·재시작 후 같은 `/Applications/sshot.app`의 새 프로세스/0.2.0(build 2)/기본 단축키 표시를 확인했습니다. 설정 버튼으로 정확한 화면 기록 설정 페이지, 위치 버튼으로 Finder Applications의 sshot.app 선택도 확인했습니다. 실제 권한 요청·허용 후 갱신·철회 복구는 미검증입니다.
- 설치 백업: 설치 스크립트가 기존 앱을 보존하고 경로를 출력했습니다. 현재 로컬 백업 경로는 작업 로그에 기록되며 이식 가능한 문서에서는 `/Applications/.sshot-install.…/previous-sshot.app` 패턴으로 안내합니다.
- 남은 검증: 사용자 담당 실제 캡처·붙여 넣기/권한 복구, production 인증서·공증 및 공개 업데이트 QA. [요구사항별 완료 감사](qa-results.md#요구사항별-완료-감사)에 남은 증거를 연결했습니다. 이 기록은 이전 0.2.0 단계의 증거이며 최신 키·feed 구성은 아래 후속 기록을 따릅니다. 코드 push 가능과 공개 바이너리 배포 완료를 구분합니다.

## 2026-10-04 문서 준비 기록

- 변경: 문서 8개 작성. 앱 구현 파일과 의존성은 없음.
- 검증: 별도 verifier가 요구사항 R01~R12의 개발·검증 추적과 상대 링크 13개를 확인함. `git diff --check` 통과. 앱 빌드·동작 테스트는 미실행.
- 다음 작업: 후속 구현 요청을 받은 뒤 단계 1에서 D01~D05 및 D09를 검증·확정.
- Git: `main`에 문서 초기 커밋 예정. 최종 커밋은 `git log -1`로 확인하고, push 반영은 `git rev-parse HEAD`와 `git ls-remote origin refs/heads/main`의 일치로 검증한다. 커밋 내부에 자기 자신의 ID를 기록하지 않는다.

## 다음 작업자의 재개 절차

1. `git status --short --branch`, `git log -5 --oneline`, `git remote -v`로 현재 브랜치·사용자 변경·원격을 확인합니다. 공유용 로그에는 인증 정보가 포함된 원격 URL을 출력하지 않습니다.
2. 루트 AGENTS.md와 이 폴더의 모든 문서를 읽고 요청 범위를 확인합니다.
3. QA 실행 기록과 남은 gate를 확인하고, 앱을 다시 빌드할 때는 먼저 실행 중인 sshot을 종료합니다. 현재 지원 후보와 미검증 환경을 혼동하지 않습니다.
4. 현재 에이전트는 코드 검토와 빠른 자동 검증을 진행합니다. 실제 캡처/권한 QA는 사용자가 인수했으므로 결과를 요청하고 실행하지 않은 항목은 미검증으로 둡니다. 배포는 Developer ID 인증서와 기존 notarytool profile이 준비된 환경에서 검증합니다.
5. 변경 후 독립 리뷰·관련 검증을 수행하고 이 문서에 실제 변경과 다음 단계를 기록합니다.

## GitHub 공개 배포 후속 요청

- 사용자 승인: 별도 서버 없이 GitHub를 통한 공개 배포 구성. stable feed는 Releases latest/download/appcast.xml, archive는 tag별 URL로 설계합니다. Pages는 사용하지 않습니다.
- 진행: Keychain `sshot` 키 생성(개인 키 export 없음), 공개키·stable feed 포함 0.2.1(build 3) 로컬 빌드/서명 검사 및 `/Applications/sshot.app` 설치 완료. 현재 UI는 설정된 updater·자동 확인 OFF이며 캡처 권한은 미적용입니다. 이전 0.2.0 미설정 UI 결과와 구분합니다.
- 로컬 서명 QA: Keychain 승인 완료, 실제 테스트 archive/appcast 생성 및 공식 sign_update·공개키 기반 manifest/archive 암호 검증 통과. 개인 키 export 없음. 산출물은 ignored dist의 ad-hoc 로컬 QA용으로 생성 당시 미커밋 소스와 기존 HEAD baseline을 사용했으며 production/최종 commit 일치 release가 아닙니다.
- 최신 runtime: 설치 앱의 업데이트 확인이 실제 조회를 시작했으며 canonical feed는 공개 asset 미게시로 HTTP 404(code 2001). 최종 오류 UI는 미확인이고 앱은 살아 있으며 새 crash는 관찰되지 않았습니다. LaunchServices 캡처 self-test는 여전히 권한 SKIP입니다.
- production 제한: Developer ID 인증서·공증이 아직 없습니다. Ed25519 키는 archive 서명용이며 OS 신뢰·TCC 문제를 해결하지 않습니다. 실제 release/asset 게시·feed 접근·자동 업그레이드는 미검증입니다.
- 다음 단계: 코드 검토·빠른 자동 검증 후 코드 commit/push → 사용자 수동 QA 결과 기록. 공개 앱 배포는 원격 commit/tag 일치·production 서명/공증·release QA 후 draft를 명시적으로 공개합니다. 세부 운영은 [업데이트 운영](update-operations.md)에 기록합니다.

## 코드 인계 및 원격 반영 기록

- 변경 범위: GitHub 업데이트 구성·서명/게시 준비, 권한 안내·복구 UI, 캡처 QA 창 lifetime 수정.
- 빠른 검증: 자동 테스트 25개·synthetic negative 6개 통과, shell/plist/diff 검사 및 독립 코드 리뷰 승인. 실제 캡처 QA는 사용자 인수입니다.
- 코드 커밋: `3fc3eb80a1bd2b2444b373f55decd881d07a6740`, `main`. `git push origin main` 성공 및 원격 main=로컬 HEAD 확인, 해당 시점 worktree clean.
- 설치 앱: 0.2.1(build 3)은 코드 커밋 전 개발 번들의 source baseline을 사용하므로 production artifact가 아닙니다. 불필요한 TCC identity 변경을 피하기 위해 이 인계 기록만으로 재빌드하지 않았습니다.
- 남은 항목: 사용자 수동 캡처/권한 QA, Developer ID·공증, 공개 release asset 게시 및 종단간 업데이트. 공개 asset은 게시하지 않았습니다.
- 이 종료 문서의 후속 커밋 ID는 `git log -1`로 확인합니다. 문서 내부에 자기 자신의 커밋 hash를 기록하지 않습니다.

## Sshot 0.3.0 표시·설정 개선 기록

- 사용자 보고: 기본 동작이 잘 된다는 정성 확인. 실제 전체 수동 QA 통과로 확대하지 않습니다. 캡처 장시간 테스트는 계속 사용자 담당입니다.
- 완료 변경: Sshot 표시명, 독자 macOS 아이콘, native AppKit 설정 창, 0.3.0(build 4) 로컬 설치. 구현 commit은 `32685dcb5b03f2ea450798c44e26e10c5eb0a557`입니다. 이 종료 문서의 실제 commit은 `git log -1`로 확인합니다.
- 유지: `dev.sshot.app`, executable `sshot`, `/Applications/sshot.app`, 기존 UserDefaults domain 및 GitHub feed·공개키. stable ID는 유지하지만 ad-hoc 코드 hash는 변경되며 현재 0.3.0에서 권한 미적용을 관찰했습니다. 필요하면 재허용해야 합니다.
- 검증: 독립 코드/아이콘 검토·빠른 25개 자동 테스트/negative 6개·shell/plist/diff 검사, clean 구현 HEAD release 빌드·서명·설치 통과. 실제 dark 설정 화면의 3섹션/아이콘/단축키/버전/자동 확인 OFF/권한 세부 정보를 확인했습니다. resize 시도는 크기를 바꾸지 못해 미검증이며 캡처 GUI 테스트는 수행하지 않았습니다.
- 정리: 같은 앱 ID와 구버전 build를 확인한 백업/중간 앱 7개를 휴지통으로 이동하고 기존 경로 제거를 확인했습니다. 현재 설치 앱은 유지하고 삭제 앱은 휴지통에서 복구할 수 있습니다.
- 추가 산출물/정리: `dist/sshot-0.3.0.zip`(약 2.2MB) 생성 및 unzip 무결성 검사 통과. production 서명/feed 없는 로컬 개발 archive입니다. 이전 `dist/github-local-qa.*`의 zip/feed/manifest 3개를 검증한 뒤 해당 폴더를 별도로 휴지통 이동했고 최신 zip·현재 앱은 유지했습니다. 0.3.0 self-test는 실행하지 않았습니다.
- 인수: 개발 ad-hoc 교체 후 필요하면 사용자가 화면 기록을 다시 허용하고 짧은 캡처 체크를 수행합니다. 코드·종료 문서 push 반영은 HEAD/원격 일치로 확인합니다. 설치 앱은 구현 commit의 개발 번들이며 이후 문서 commit과 production 자료로 혼동하지 않습니다.
- 공개 배포: Releases 0개로 삭제 대상 없음, Developer ID 인증서 0개. 미공증 developer preview 공개 여부 질문의 답이 없으므로 공개 앱 게시 gate는 유지합니다.

## 후속 기록 템플릿

| 항목 | 기록할 내용 |
| --- | --- |
| 작업 범위 | 요구사항 ID와 개발 단계 |
| 변경 | 파일, 변경 이유, 결정 대장 변경 |
| 검증 | 명령/수동 절차, 환경, 결과, 증거 위치 |
| 남은 작업 | 미확정 결정, 결함, 재현 절차 |
| 다음 단계 | 필요한 입력 및 시작 지점 |
| Git | 브랜치, 최종 commit ID, 원격 일치 확인 결과 |

작업자의 로컬 절대 경로나 비밀값에 의존하는 지시를 남기지 않습니다. 진행 중 작업이 있는 경우 완료한 작업과 미완료 작업을 분리하고, 도구가 지원하지 않는 명령을 실행했다고 기록하지 않습니다.
