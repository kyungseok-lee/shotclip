# 현재 상태와 작업 인수인계

## 현재 상태

- 단계: 기술 probe·앱 구현·자동 회귀 및 로컬 release 빌드 완료. 실제 캡처 QA는 권한 대기이며 전체 QA·배포 완료를 선언하지 않았습니다.
- 사용자 승인 범위: 문서 기반 순차 개발, QA 및 이후 Git push.
- 산출물: CaptureCore, AppKit 앱, 합성 fixture/self-test, 자동 테스트, 앱 빌드·공증 준비 스크립트, 설계·QA 문서.
- 제품 이름: sshot(잠정).
- 앱 빌드/테스트: SwiftPM 자동 테스트 20개 통과, release 및 ad-hoc 서명 검사 통과. 화면 권한이 없어 self-test는 exit 77 SKIP. 실제 이미지 캡처·붙여 넣기는 미실행.
- 기술 결정: architecture.md와 technical-validation.md에 채택한 D01~D09 및 플랫폼 한계 기록. Developer ID 인증서 0으로 D08 공증 배포는 미완료.
- 원격 반영: 개발 변경은 QA gate 확인 후 커밋·push한다. 실제 상태는 git log/status/ls-remote로 확인한다.

## 2026-10-04 구현 기록

- 구현: 전역 단축키 변경/충돌 처리, 마스크·즉시 드래그 선택, SCK 자체 앱 제외, PNG/TIFF 메모리 복사, 오류 복원, 화면 변경/잠자기 취소, timeout 및 늦은 결과 차단.
- QA: 자동 테스트, shell/plist/서명 검사 통과. native 안내 창 확인, Finder에서 전역 단축키가 권한 안내를 여는 것 확인. recorder의 Shift 숫자 표시 버그 수정·실제 기본값 ⌃⇧⌘5 표시 확인.
- 실제 하드웨어: 화면 0 (0,0,3360,1890) 2x, 화면 1 (-1728,773,1728,1117) 2x, 화면 2 (3360,810,1920,1080) 1x. 권한 허용 후 self-test가 세 화면을 검사한다.
- 권한: 설정 스위치는 켜짐이지만 최신 앱의 API는 거부/SKIP이다. ad-hoc 빌드 교체로 허용 identity가 맞지 않는 것으로 추정한다. 사용자가 최신 sshot에 화면 기록 허용을 다시 적용한 뒤 재실행해야 한다. TCC 자동 변경/reset 없음. 앱과 권한 설정 화면을 열어 두었으며 실행 PID는 재사용하지 않는다.
- 남은 gate: 실제 capture pixel/overlay/clipboard, 두 모드 mouse·keyboard UI, Preview 붙여 넣기, 반복/취소 및 실제 화면 변화 QA. 서명·공증·macOS 14/Intel·깨끗한 계정 QA는 별도 환경 필요.
- 작업 환경 복구: recorder 테스트로 변경했던 단축키를 기본 ⌃⇧⌘5로 돌렸다. 일반 clipboard를 변경한 테스트는 실행하지 않았다.
- 다음 시작: `open dist/sshot.app` → 화면 기록 허용 → 필요 시 재실행 → `dist/sshot.app/Contents/MacOS/sshot --self-test`. PASS와 SKIP을 구분하고 qa-results.md에 실제 결과 기록.

## 2026-10-04 문서 준비 기록

- 변경: 문서 8개 작성. 앱 구현 파일과 의존성은 없음.
- 검증: 별도 verifier가 요구사항 R01~R12의 개발·검증 추적과 상대 링크 13개를 확인함. `git diff --check` 통과. 앱 빌드·동작 테스트는 미실행.
- 다음 작업: 후속 구현 요청을 받은 뒤 단계 1에서 D01~D05 및 D09를 검증·확정.
- Git: `main`에 문서 초기 커밋 예정. 최종 커밋은 `git log -1`로 확인하고, push 반영은 `git rev-parse HEAD`와 `git ls-remote origin refs/heads/main`의 일치로 검증한다. 커밋 내부에 자기 자신의 ID를 기록하지 않는다.

## 다음 작업자의 재개 절차

1. `git status --short --branch`, `git log -5 --oneline`, `git remote -v`로 현재 브랜치·사용자 변경·원격을 확인합니다. 공유용 로그에는 인증 정보가 포함된 원격 URL을 출력하지 않습니다.
2. 루트 AGENTS.md와 이 폴더의 모든 문서를 읽고 요청 범위를 확인합니다.
3. QA 실행 기록과 남은 gate를 확인하고, 앱을 다시 빌드할 때는 먼저 실행 중인 sshot을 종료합니다. 현재 지원 후보와 미검증 환경을 혼동하지 않습니다.
4. 화면 기록 권한이 있다면 실제 self-test와 두 선택 모드·붙여 넣기 QA부터 이어갑니다. 배포는 Developer ID 인증서와 기존 notarytool profile이 준비된 환경에서 검증합니다.
5. 변경 후 독립 리뷰·관련 검증을 수행하고 이 문서에 실제 변경과 다음 단계를 기록합니다.

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
