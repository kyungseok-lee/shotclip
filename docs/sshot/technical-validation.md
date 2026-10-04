# 기술 검증 기록

## 2026-10-04: 단계 1

환경: macOS 27.0.1 (26A434), Xcode 27.0 (27A266a), Swift 6.4, Apple Silicon. 저장소는 문서 초기 커밋에서 시작했으며 후속 구현·QA·push 요청을 받았다.

| 항목 | 수행 및 증거 | 결과 |
| --- | --- | --- |
| 캡처 API | 설치 SDK 헤더 확인 및 `swift -e` 컴파일 probe: SCScreenshotManager.captureImage, SCContentFilter.pointPixelScale | macOS 14부터 제공. 실제 화면 픽셀 검사는 앱 harness에서 별도 수행 |
| 좌표 | SDK sourceRect 주석 확인 | display-local top-left point 단위. AppKit 전역 rect에서 x=rect.minX-screen.minX, y=screen.maxY-rect.maxY. 출력 크기는 pixel 단위 |
| UI 제외 | 자체 SCRunningApplication 제외 filter 및 showsCursor=false API 확인 | 컴파일 가능. 실제 UI 제외 통합 QA 필요 |
| 단축키 | Carbon RegisterEventHotKey에 kEventHotKeyExclusive로 ⌃⇧⌘5 등록·중복 등록·해제 | 최초 OSStatus 0, 중복 -9878. 기본 nonexclusive 옵션은 충돌 검출에 부적합 |
| 클립보드 | unique named NSPasteboard에 PNG+TIFF item 기록 | write true, item 1, type 2. clear와 write의 changeCount 관찰. 일반 clipboard 변경 없음 |
| 권한 | swift probe CGPreflightScreenCaptureAccess | false. CLI의 결과이며 제품 identity의 결과가 아님 |
| 배포 | security find-identity -v -p codesigning | 유효 identity 0. Developer ID 공증·배포 QA 미완료 |

## 구현 결정과 한계

- D01/D02: macOS 14 이상, SwiftPM + AppKit, ScreenCaptureKit의 still-image API 사용. 하위 OS의 실제 실행 검증은 별도 필요하다.
- D03: 기본 ⌃⇧⌘5, 사용자 변경 지원, exclusive 등록으로 충돌을 처리한다. 단축키 이벤트 전달은 실제 UI QA에서 확인한다.
- D04: 각 디스플레이에서 독립적인 영역 선택을 지원한다. 한 번의 선택은 시작 디스플레이 내부로 제한하고 UI에 안내한다. 혼합 배율 화면을 합치는 기능은 제공하지 않는다.
- D05: 이미지 인코딩을 먼저 완료하고, 모든 기존 pasteboard item/type의 eager snapshot을 확보한 경우만 교체한다. 읽기 불가·너무 큰 백업·snapshot 중 외부 변경은 교체 전 실패 처리한다. write 실패 시 own changeCount가 유지된 경우만 복원하며 외부 데이터는 덮어쓰지 않는다.
- NSPasteboard에는 atomic replace나 compare-and-swap가 없다. 시스템 pasteboard 장애·복원 실패·외부 프로세스와의 최종 경쟁까지 기존 데이터 보존을 무조건 보장할 수 없다. 이 한계를 성공으로 숨기지 않고 오류와 미검증 범위를 남긴다. 취소·권한 거부·캡처/인코딩 실패는 clipboard 쓰기 이전에 종료한다.
- D06: 영역은 실행 세션 안에서 재사용하고 모드와 단축키 설정은 저장한다. 화면 이미지는 저장하지 않는다.
- D07: 선택 중 재호출은 기존 UI를 활성화하고 처리 중 호출은 무시한다. 세션 토큰으로 취소·timeout 후 늦은 결과를 차단한다.
- D08: 로컬 ad-hoc 앱 번들을 우선 빌드한다. Developer ID·공증 인증정보가 없는 상태에서는 배포 완료로 선언하지 않는다.
- D09: 메뉴 막대 상주 앱에서 캡처 UI를 단축키로 연다. 처음 앱을 직접 실행한다. 로그인 시작은 명시적인 opt-in이며 종료한 프로세스의 cold launch는 제공하지 않는다. 이 동작은 사용자 가이드에 공개한다.

최종 구현 일치 여부와 실제 화면 캡처 결과는 QA 기록에서 검증한다. 위 probe만으로 단계 1의 실제 캡처 gate 또는 전체 QA 완료를 주장하지 않는다.

## 공식 근거

- [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager)
- [sourceRect](https://developer.apple.com/documentation/screencapturekit/scstreamconfiguration/sourcerect)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice)

실험은 별도 document-specialist가 수행했다. 실제 앱 테스트와 원격 반영은 별도 verifier가 검증한다.
