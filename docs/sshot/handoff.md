# 현재 상태와 작업 인수인계

## 현재 상태

- 단계: 기술 probe·앱 구현·자동 회귀 및 로컬 release 빌드 완료. 실제 캡처 QA는 권한 대기이며 전체 QA·배포 완료를 선언하지 않았습니다.
- 사용자 승인 범위: 문서 기반 개발 및 Git push. 최신 요청에 따라 캡처/권한 수동 QA는 사용자가 맡고 에이전트는 코드 검토와 빠른 자동 검증 후 코드 커밋·push를 진행합니다. 장시간 GUI 테스트는 중단합니다.
- 산출물: CaptureCore, AppKit 앱, 합성 fixture/self-test, 자동 테스트, 앱 빌드·공증 준비 스크립트, 설계·QA 문서.
- 제품 이름: sshot(잠정).
- 앱 빌드/테스트: 2026-10-04 23:23 SwiftPM 자동 테스트 25개·0 failure. 현재 0.2.1(build 3) 로컬 release 및 deep/strict ad-hoc 서명 검사·`/Applications/sshot.app` 설치 확인. self-test는 권한 SKIP이며 실제 캡처·붙여 넣기는 사용자 인수 상태입니다.
- 기술 결정: architecture.md와 technical-validation.md에 채택한 D01~D10 및 플랫폼 한계 기록. Developer ID 인증서 0으로 D08 공증 배포는 미완료.
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
