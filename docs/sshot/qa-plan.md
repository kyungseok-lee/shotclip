# 구현 순서와 QA 실행 설계

사용자의 후속 요청으로 단계 1~6 구현·QA·push가 승인되었습니다. 이 문서는 검증 방법을 구체화하며, 테스트 실행 결과는 별도 증거 문서에 기록합니다. 아래 계획만으로 통과를 주장하지 않습니다.

최신 요청으로 캡처·권한 수동 테스트는 사용자가 인수합니다. 에이전트는 장시간 GUI 검증을 중단하고 코드 검토·빠른 자동 테스트·빌드/스크립트 검증 후 코드 커밋·push를 진행합니다. 아래 수동 절차는 사용자 인수 및 후속 배포 QA용이며 코드 push 전 모두 실행해야 하는 조건이 아닙니다. 공개 바이너리 배포의 production 서명·공증·배포 gate는 유지합니다.

## 사용자에게 인수할 짧은 체크

1. `/Applications/sshot.app`에서 화면 기록을 허용하고 ‘다시 확인’(필요 시 재시작) 후 준비 완료로 바뀌는지 확인합니다.
2. 고정 영역을 이동·조절해 캡처하고 이미지 지원 앱에서 ⌘V로 붙여 넣습니다. 드래그 모드도 같은 방식으로 확인합니다.
3. 기존 클립보드에 식별 가능한 내용을 넣고 캡처 UI에서 Escape로 취소한 뒤 기존 내용이 유지되는지 확인합니다.
4. 다른 앱을 활성화한 상태에서 기본 `⌃⇧⌘5`로 진입하고 단축키 변경·재실행 후에도 설정이 유지되는지 확인합니다.

문제가 있으면 모드·권한 상태·재현 순서·실행 버전과 오류 문구만 공유합니다. 실제 화면 이미지·클립보드 내용·비밀번호는 필요하지 않습니다.

## 단계별 실행

| 단계 | 구현 순서 | 검증 및 다음 단계 조건 |
| --- | --- | --- |
| 1 | 설치 SDK의 API availability 확인 → 지원 OS·좌표 정책 결정 → 합성 화면 캡처·clipboard 실험 | 실제 캡처 크기·색상·UI 제외 확인. 실패의 clipboard 보존 정책 확정 |
| 2 | Swift 패키지와 app bundle → 순수 coordinator → 메뉴·설정 → Carbon 전역 단축키 → 권한 안내 | 빌드, 상태 전이 테스트, 다른 앱 활성 상태의 단축키 및 취소 확인 |
| 3 | rect 순수 함수 → 화면별 overlay → 마스크 이동·리사이즈 → drag → 키보드 | 모든 드래그 방향, 경계, 음수 화면 원점, 1x/2x 픽셀 변환 테스트와 실제 UI 확인 |
| 4 | ScreenCaptureKit 필터 → PNG/TIFF 메모리 인코딩 → clipboard commit → focus 복귀 | 합성 화면 실제 캡처·pixel 검사·UI 제외 및 Preview 붙여넣기 확인 |
| 5 | timeout·취소·중복·display 변경·sleep/wake 처리 → 회귀 → 독립 리뷰 | 자동 테스트와 가능한 실제 UI QA 통과, 환경 부족 항목은 미검증 표기 |
| 6 | release bundle·서명 스크립트·설치 안내 → Developer ID 및 notarization → 별도 환경 검사 | 배포 artifact, 서명 검증, 새 사용자 또는 깨끗한 머신 Gatekeeper·권한 흐름 증거 |

## 자동 검증 경계

`CaptureCore`는 화면·권한·pasteboard·시간에 대한 protocol을 받고 AppKit 전역 객체를 직접 읽지 않습니다. 테스트는 fake를 통한 실제 공개 상태 전이를 관찰합니다. 캡처 서비스는 continuation으로 지연시켜 취소 이후 완료, timeout 이후 완료, 새 세션 이후 이전 결과를 재현합니다. clipboard 쓰기 횟수와 값으로 중복·늦은 결과를 검사합니다.

- Geometry: 네 drag 방향, 0/최소 크기, 비유한 숫자 거부, 화면 밖 clamp, 음수 global origin, top-left 캡처 좌표 변환, fractional rect의 outward 픽셀 반올림, 1x/2x, 화면 변경 후 보정.
- Coordinator: 권한 거부·capture 오류·encode 오류·clipboard 실패 시 idle 복귀, 기존 clipboard 유지, selecting 중 재진입은 같은 세션 활성화, processing 중 재진입 무시, 취소/timeout의 stale result 차단.
- Clipboard: PNG와 TIFF 준비가 먼저 완료되는지, 모든 기존 item/type 보존, 읽기 불가 타입이면 clear 전에 실패, commit 오류의 복원, 외부 changeCount 변경 시 외부 값 보존. restoration 실패를 성공으로 알리지 않음.
- Hotkey: 설정 유효성, 중복/등록 실패를 UI에 보고, 변경 실패 시 이전 등록 복구. 실제 시스템 충돌 확인은 통합 QA로 분리.

## 실제 캡처 harness

제품의 capture service를 호출하는 동일 app bundle 내부 opt-in QA 진입점을 둡니다. CLI 프로세스가 별도 identity로 권한을 받는 것과 제품의 TCC 동작을 혼동하지 않습니다. 일반 실행에서는 QA 창·데이터가 생성되지 않습니다.

합성 창은 충분히 큰 불투명 색상 격자와 서로 다른 네 모서리 표식을 표시합니다. 실제 화면 위의 안전한 rect를 선택하고 overlay와 cursor를 제외한 실제 `SCScreenshotManager` 결과를 메모리에서 검사합니다. 기대 pixel 크기, 내부 중심 샘플의 색상 허용오차, 모서리 방향으로 좌표 뒤집힘과 crop 오류를 식별합니다. Core Graphics bitmap으로 검사하며 색 공간 변환과 antialiasing 때문에 경계 1 pixel의 exact match에 의존하지 않습니다.

실제 clipboard 검사는 **고유한 named NSPasteboard**로 수행하여 일반 clipboard를 변경하지 않습니다. 이미지 타입과 디코딩 가능 여부, dimensions 및 합성 pixel을 검사하고 pasteboard를 release합니다. 일반 clipboard와 다른 앱 ⌘V는 별도의 명시적 UI QA 단계에서 합성 이미지로만 검사합니다. 해당 단계는 기존 clipboard를 백업할 수 없으면 진행하지 않고 이유를 기록합니다.

실제 이미지와 화면 내용은 로그·파일·저장소에 쓰지 않습니다. 출력은 case ID, pass/fail, 오류 코드, dimensions, sample 일치 여부만 포함합니다. 화면 권한이 없으면 integration을 `SKIP: screen-recording-permission`으로 보고하며 자동 테스트 성공과 구분합니다. TCC 설정을 자동 변경하거나 `tccutil reset`을 실행하지 않습니다.

## Native UI QA

권한 안내는 현재 프로세스 실행과 캡처 허용을 구분해야 합니다. 표시된 앱 경로/Finder 위치, 요청·설정 이동·재확인·재실행을 검사하고 다른 빌드의 설정 스위치와 API 결과 불일치를 설명하는지 확인합니다. 실제 권한 허용 후의 캡처 결과가 최종 증거입니다.

업데이트 QA는 feed/공개키 누락 및 HTTP 구성 비활성화, 메뉴 상태, 정식 서명 archive 검증 실패, 이전 버전에서의 실제 업데이트·재실행·설정 유지·캡처 회귀를 포함합니다. 실제 HTTPS feed·서명 키가 없으면 종단간 업데이트는 미검증으로 기록합니다.

두 모드 각각 메뉴와 전역 단축키 진입, mode 전환, Escape, Enter, capture 버튼, drag release, 역방향 drag, mask 이동/8개 handle resize를 확인합니다. overlay 종료 후 이전 앱 focus와 이미지 지원 앱 ⌘V를 확인합니다. 권한 안내, 단축키 충돌, 설정 저장·재실행, 20회 반복, 선택 중 screen change를 점검합니다. 화면 조작 자동화가 접근성 권한 때문에 불가능하면 제품에 그 권한을 추가하지 않고 수동 절차와 미실행 범위를 보고합니다.

실제 다중 화면/혼합 배율, sleep/wake, 권한 철회, Intel, macOS 14 runtime, 깨끗한 사용자 계정은 각 환경에서 따로 확인해야 합니다. 순수 좌표 테스트나 최신 macOS의 빌드로 해당 항목의 실제 통과를 대신하지 않습니다.

## 확인한 개발 환경

2026-10-04 로컬 명령 기준: macOS 27.0.1 (26A434), arm64, Xcode developer directory, Swift 6.4. `security find-identity -v -p codesigning`은 유효한 signing identity 0개를 보고했습니다. ad-hoc 로컬 실행 검증은 가능하지만 Developer ID 서명·notarization 완료 증거는 현재 없으며 단계 6의 배포 완료로 표시할 수 없습니다.

공식 API 근거는 [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager), [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard), [notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) 및 설치 SDK의 headers입니다. 실행 가능한 정확한 명령은 프로젝트 작성 후 README·검증 결과 문서에 확정합니다.
