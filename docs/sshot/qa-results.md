# QA 실행 기록

날짜: 2026-10-04. 환경: macOS 27.0.1 (26A434), Xcode 27.0, Swift 6.4, arm64.

아래 상태는 실제 명령·앱 관찰 후 갱신한다. 코드 리뷰, 자동 테스트, 현재 Mac에서의 UI QA, 다른 환경에서의 배포 QA는 서로 대체하지 않는다.

| 검증 | 현재 상태 | 증거 및 범위 |
| --- | --- | --- |
| 기술 probe | 통과 | [기술 기록](technical-validation.md): SDK 컴파일, exclusive hotkey 중복 오류, named pasteboard PNG/TIFF |
| 자동 회귀 | 통과 | swift test 20개, 0 failure. Core 15개 + Coordinator 5개. 취소 전파·timeout·늦은 결과·4방향 drag/4모서리·Retina·clipboard 오류 경로 |
| release app bundle | 통과(로컬) | release 빌드 + codesign --verify --strict 통과. ad-hoc이며 Developer ID 배포와 구분 |
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

## 알려진 플랫폼 한계

NSPasteboard 교체와 복원은 OS atomic transaction이 아니다. 캡처·인코딩·snapshot 실패는 쓰기 전에 중단하며, 쓰기 실패는 가능한 경우 기존 타입별 데이터를 복원한다. 다른 앱의 외부 변경은 보존한다. 시스템 write/restore 장애에 대한 무조건적인 데이터 보존은 보장하지 않으며 복원 실패를 별도 오류로 표시한다.

## 재현 명령

실행한 명령: `swift test`, `bash scripts/build-app.sh`, `bash -n scripts/build-app.sh scripts/notarize-app.sh`, `plutil -lint resources/Info.plist`, `git diff --check`. 빌드 스크립트가 release build와 codesign 검증을 수행했다.

실제 캡처 명령: `dist/sshot.app/Contents/MacOS/sshot --self-test`. 출력은 `{"case":"real-capture","reason":"screen-recording-permission","result":"SKIP"}`, exit 77. 이미지·일반 clipboard 변경 없이 종료했다.

Native UI는 orca computer get-app-state/hotkey 및 실행 후 실제 앱 상태를 확인했다. 합성 키 입력의 provider 성공만으로 통과하지 않고 sshot 권한 modal 또는 설정 label 변화를 확인했다. 앱의 안내 창 스크린샷도 확인했으며 이미지 파일은 저장소에 추가하지 않았다.

시스템 설정의 sshot 스위치는 켜짐으로 관찰했으나 최신 앱의 권한 요청·preflight와 self-test는 여전히 거부/SKIP이다. ad-hoc 서명의 designated requirement는 `codesign -d -r-`에서 cdhash 기반으로 확인했다. 빌드 교체로 기존 허용이 현재 바이너리에 적용되지 않는 상황으로 추정하며, 최신 앱을 기준으로 사용자가 화면 기록 허용을 다시 적용하고 재실행한 뒤 검증해야 한다. 설정 스위치만으로 권한 QA 통과를 주장하지 않는다.
