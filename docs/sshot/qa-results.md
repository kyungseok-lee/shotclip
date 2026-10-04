# QA 실행 기록

날짜: 2026-10-04. 환경: macOS 27.0.1 (26A434), Xcode 27.0, Swift 6.4, arm64.

아래 상태는 실제 명령·앱 관찰 후 갱신한다. 코드 리뷰, 자동 테스트, 현재 Mac에서의 UI QA, 다른 환경에서의 배포 QA는 서로 대체하지 않는다.

최신 사용자 지시에 따라 실제 캡처/권한 수동 QA는 사용자 인수 상태입니다. 에이전트는 코드 검토·빠른 자동 검증 후 코드 commit/push를 진행할 수 있으며 아래 미검증 runtime 항목을 통과로 바꾸지 않습니다. 공개 앱 release·실제 업데이트 성공은 별도 production gate입니다.

| 검증 | 현재 상태 | 증거 및 범위 |
| --- | --- | --- |
| 기술 probe | 통과 | [기술 기록](technical-validation.md): SDK 컴파일, exclusive hotkey 중복 오류, named pasteboard PNG/TIFF |
| 자동 회귀 | 통과 | 최신 부모 실행 2026-10-04 23:23 swift test 25개, 0 failure. 기존 20개에 permission presentation 2개·update configuration 3개 추가 |
| release app bundle | 통과(로컬) | 현재 0.2.1(build 3) release 및 codesign --verify --deep --strict 통과. Sparkle framework/rpath 검사, /Applications/sshot.app 설치·실행 확인. 0.2.0 검사도 과거 기록으로 존재. ad-hoc이며 Developer ID 배포와 구분 |
| 실제 합성 화면 캡처 | SKIP / 권한 대기 | 최신 제품 --self-test가 metadata SKIP와 exit 77. 3 display harness 준비, 통과 아님 |
| 고정 마스크 UI | 미실행 | 이동·resize·확정·취소·재사용 |
| 즉시 드래그 UI | 미실행 | 정방향·역방향·무효 영역·모드 전환 |
| 전역 단축키/설정 | 부분 통과 | Finder 활성화 시 변경한 키가 sshot 권한 안내를 여는 것 확인. 설정 저장·재실행 및 기본값 복구 확인. Shift 숫자 label 버그 수정 후 ⌃⇧⌘5 표시 확인. 반복 호출·실제 overlay는 권한 대기 |
| 다른 앱 이미지 붙여 넣기 | 미실행 | 합성 화면만 사용해 일반 clipboard와 Preview 검증 |
| 독립 코드/자동 검증 검토 | 통과(제한 범위) | 별도 scratch build에서 20 XCTest 재실행, 소스 검토 통과. 실제 화면·배포 포함 전체 QA 승인은 아님 |
| 다중 모니터/혼합 배율 실제 QA | 권한 대기 | 실제 3 display: 2x main, 음수 원점 2x, 오른쪽 1x. 순수 좌표 테스트 통과, 실제 pixel 검사 SKIP |
| macOS 14/Intel 실행 | 미검증 | 현재 host 최신 macOS/arm64로 대체 불가 |
| 권한 철회/sleep-wake/깨끗한 계정 | 미검증 | 사용자 환경 설정을 자동 reset하지 않음 |
| Developer ID/공증/Gatekeeper | 차단 | 유효 signing identity 0. 인증서·공증 및 별도 환경 필요 |
| 권한 안내 개선 | 부분 통과 | 설치 앱의 AX·화면으로 주황색 권한 미적용·비활성 캡처·ad-hoc 안내·경로/버전 확인. 다시 확인의 미허용 상태 유지, 같은 /Applications 앱 재시작·0.2.0(build 2)·기본 단축키 안내 확인. 설정 버튼은 시스템 설정의 ‘화면 및 시스템 오디오 녹음’ 페이지, 현재 앱 위치 버튼은 Finder Applications의 sshot.app 선택으로 확인. 권한 요청 및 실제 허용 후 갱신은 미검증 |
| Sparkle 자동 업데이트 | 로컬 구성·서명 QA 통과 / 공개 종단간 미검증 | 현재 0.2.1은 실제 공개키와 GitHub feed를 포함하고 로컬 archive/feed 검증 통과. 0.2.0의 미설정 modal은 과거 회귀 증거. 공개 feed asset은 미게시로 404이며 실제 업그레이드 없음 |

별도 reviewer가 권한 상태·정확한 bundle 재시작/단축키 해제·복구, Sparkle fail-closed 구성, 내부부터의 framework/helper 서명, installer 백업·검증·복원, 릴리스 script의 기존 키 조회 및 게시 미수행을 검토하여 차단 결함 없음을 확인했습니다. shell syntax와 diff 검사 통과. 독립 scratch 테스트의 실행 결과 로그는 회수하지 못했으므로 추가 통과 증거로 사용하지 않습니다.

첫 UI 자동화 provider는 window_not_focused 오류로 클릭을 완료하지 못했습니다. 이후 사용 가능한 대체 UI 도구로 업데이트 확인·다시 확인·재시작을 실제 실행하고 위 표의 제한 범위를 확인했습니다. 재시작 직후 기존 프로세스 조회 실패는 종료에 따른 정상 상태이며 새 프로세스의 같은 앱 경로·안내 창을 별도로 확인했습니다. 3-screen self-test의 window lifetime crash 수정은 소스에 반영했으나 현재 권한 SKIP이므로 수정 후 실제 캡처 경로의 runtime 통과는 미검증입니다.

## 요구사항별 완료 감사

### 0.2.1(build 3) GitHub 구성 후속 증거

Keychain `sshot` Ed25519 키 생성, 개인 키 export 없음. 공개키·GitHub stable feed 포함 앱을 로컬 빌드·nested deep/strict 서명 검사 후 `/Applications/sshot.app`에 설치했습니다. 실제 UI에서 설정된 updater 설명·활성 자동 확인 toggle(OFF 기본값)을 확인했으며 화면 기록 권한은 여전히 미적용입니다. 독립 자동 테스트 25개 및 synthetic negative 6개 통과가 보고되었습니다. 이전 미설정 안내 UI 결과는 0.2.0 기록입니다.

Keychain 승인 후 `generate_appcast`가 새 update 1개를 생성하고 exit 0으로 완료했습니다. 실제 0.2.1 테스트 zip(1,178,413 bytes)과 canonical tag URL·최소 OS 14·arm64 feed를 생성했으며 공식 `sign_update --account sshot --verify` 및 공개 CryptoKit manifest/archive 검증이 exit 0으로 통과했습니다. 산출물은 ignored dist의 로컬 QA 자료로, 생성 당시 ad-hoc 앱·미커밋 소스와 기존 HEAD baseline을 사용했으므로 production release나 최종 커밋 일치 배포 증거가 아닙니다.

설치 앱에서 업데이트 확인 클릭 후 ‘Checking for updates…’ 창을 확인했습니다. Sparkle OS 로그는 실제 canonical GitHub feed 조회의 HTTP 404(code 2001)를 보고했습니다. 공개 asset이 없는 현재 상태와 일치하며 실제 업그레이드 통과가 아닙니다. 최종 오류 UI는 미확인, 앱은 실행 중이고 새 crash는 관찰되지 않았습니다. 최신 LaunchServices self-test JSONL은 권한 미적용 SKIP입니다. 공개 asset·release 게시와 production 서명/공증·종단간 업그레이드는 수행하지 않았습니다.

아래는 현재 파일·자동 테스트·UI 실행 증거의 범위를 연결한 감사입니다. 구현 존재와 전체 수용 기준 완료를 구분합니다.

| ID | 현재 증거 | 남은 완료 증거 |
| --- | --- | --- |
| R01 | 단축키 등록/충돌 probe, 다른 앱에서 권한 안내 진입, 재시작 후 기본 단축키 표시·시작 오류 없음 | 권한 허용 후 실제 캡처 UI 진입·반복 호출 |
| R02 | 마스크 구현과 geometry 자동 테스트 | 실제 이동·핸들 조절·Enter/버튼 확정·영역 재사용 |
| R03 | 드래그 구현과 네 방향 geometry 테스트 | 실제 드래그 종료 캡처·역방향·무효 선택 |
| R04 | PNG/TIFF 및 clipboard 오류 경로 테스트 | 실제 캡처 성공 직후 일반 클립보드 이미지 |
| R05 | 제품 흐름과 수동 QA 절차 | 실제 지원 앱 ⌘V/Preview 새 문서 |
| R06 | 거부 분기 테스트·미허용 안내·재확인·같은 앱 재시작·정확한 시스템 설정 페이지·Finder의 현재 설치 앱 선택 실제 확인 | 권한 요청·실제 허용 후 live 갱신·철회 복구 |
| R07 | 음수 좌표·배율 자동 테스트, 실제 세 화면 harness 준비 | 권한 허용 후 각 화면의 실제 영역·픽셀 비교 |
| R08 | SCK 자체 앱/커서 제외 구현 | 실제 결과에 overlay 없는지 검사 |
| R09 | 취소·오류·rollback·외부 clipboard 변경 보호 테스트 | 실제 UI 취소/권한 철회·실제 clipboard 보존 확인. OS 원자성 한계는 공개 |
| R10 | coordinator 중복·timeout·늦은 결과 테스트 | 실제 캡처 중 반복 단축키·연속 UI 세션 |
| R11 | 로컬 메모리 처리 및 소스 검토, 메타데이터-only SKIP 출력 | 실제 캡처 성공 경로의 로그/임시 파일/메모리 점검 |
| R12 | 메뉴/설정 구현, 안내 렌더링·재시작 실제 확인 | 두 모드 키보드·오류 재시도·sleep/wake·화면 변경 |
| R13 | 실제 GitHub feed URL·공개키 구성, 로컬 Ed25519 archive·signed feed 검증, synthetic negative 6개, 설정 UI·실제 조회/404 확인. 과거 미설정 modal 회귀 증거 | 공개 feed/archive asset 게시, production Developer ID·공증, 공개 종단간 업그레이드·설정/권한 회귀 |

실제 캡처 검증은 사용자 담당으로 남아 있으며 공개 배포·종단간 업데이트도 미완료입니다. 최신 요청에 따른 코드 작업은 독립 검토·빠른 자동 검증 후 commit/push로 인계할 수 있습니다. 이것은 실제 캡처나 공개 앱 배포 완료 선언이 아닙니다.

## 표시·설정 개선 후속 요청

사용자가 기본 기능에 대해 ‘잘 되는 것 같다’고 보고했습니다. 이는 정성적인 사용 확인이며 요구사항별 수동 QA나 전체 지원 환경 통과 증거는 아닙니다. R14/D11에 따라 Sshot 표시명·독자 아이콘·native 설정 창과 0.3.0(build 4)을 준비하며, 새 버전 빌드·설치·검증 결과는 실행 후 기록합니다. GitHub Releases는 현재 0개로 삭제 대상이 없고 Developer ID 인증서는 0개입니다. 미공증 developer preview 공개 여부에 대한 응답이 없는 상태에서는 기존 production 공개 gate를 유지합니다.

## 알려진 플랫폼 한계

NSPasteboard 교체와 복원은 OS atomic transaction이 아니다. 캡처·인코딩·snapshot 실패는 쓰기 전에 중단하며, 쓰기 실패는 가능한 경우 기존 타입별 데이터를 복원한다. 다른 앱의 외부 변경은 보존한다. 시스템 write/restore 장애에 대한 무조건적인 데이터 보존은 보장하지 않으며 복원 실패를 별도 오류로 표시한다.

## 재현 명령

실행한 명령: `swift test`, `bash scripts/build-app.sh`, `bash -n scripts/build-app.sh scripts/notarize-app.sh`, `plutil -lint resources/Info.plist`, `git diff --check`. 빌드 스크립트가 release build와 codesign 검증을 수행했다.

이전 직접 binary 실행 기록: `dist/sshot.app/Contents/MacOS/sshot --self-test`는 `{"case":"real-capture","reason":"screen-recording-permission","result":"SKIP"}`, exit 77을 출력했다. 직접 실행은 터미널의 권한 귀속과 혼동할 수 있어 최신 절차는 README의 LaunchServices `open -n -W -o` 방식이다. 최신 실행도 JSON SKIP이며 실제 캡처 통과가 아니다. `open` exit 0을 harness PASS로 해석하지 않는다. 이미지·일반 clipboard 변경 없이 종료했다.

Native UI는 orca computer get-app-state/hotkey 및 실행 후 실제 앱 상태를 확인했다. 합성 키 입력의 provider 성공만으로 통과하지 않고 sshot 권한 modal 또는 설정 label 변화를 확인했다. 앱의 안내 창 스크린샷도 확인했으며 이미지 파일은 저장소에 추가하지 않았다.

시스템 설정의 sshot 스위치는 켜짐으로 관찰했으나 최신 앱의 권한 요청·preflight와 self-test는 여전히 거부/SKIP이다. ad-hoc 서명의 designated requirement는 `codesign -d -r-`에서 cdhash 기반으로 확인했다. 빌드 교체로 기존 허용이 현재 바이너리에 적용되지 않는 상황으로 추정하며, 최신 앱을 기준으로 사용자가 화면 기록 허용을 다시 적용하고 재실행한 뒤 검증해야 한다. 설정 스위치만으로 권한 QA 통과를 주장하지 않는다.
