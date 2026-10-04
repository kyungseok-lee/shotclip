# 설계와 결정 대장

## 후보 구조

Swift 기반 메뉴 막대 앱을 후보로 삼습니다. SwiftUI는 메뉴·설정, AppKit은 화면 오버레이·포인터 및 키 이벤트·NSPasteboard에 사용하고, ScreenCaptureKit을 캡처 후보로 검증합니다. 아직 코드나 API 선택은 확정하지 않았습니다.

| 구성 | 책임 |
| --- | --- |
| App/Settings | 메뉴 막대, 두 모드, 단축키 설정, 오류 안내 |
| HotkeyService | 전역 등록·해제, 충돌 및 중복 입력 처리 |
| CaptureCoordinator | 단일 캡처 세션, 상태 전이, 취소, 결과 처리 |
| PermissionService | 화면 기록 허용 상태 확인 및 복구 안내 |
| SelectionOverlay | 디스플레이별 UI, 마스크/드래그, 키보드 확정·취소 |
| CoordinateMapper | AppKit 화면 좌표, 캡처 좌표, 픽셀 배율 변환 |
| CaptureService | UI를 제외한 영역 캡처, 오류·타임아웃 처리 |
| ClipboardService | 이미지 표현 준비 및 성공 시 클립보드 교체 |

## 상태 및 실패 처리

`idle → permissionCheck → selecting → capturing → committingClipboard → idle`을 정상 경로로 둡니다. 취소·권한 실패·캡처 실패는 클립보드를 건드리지 않고 `idle`로 복구합니다. 단일 세션 ID와 취소 토큰으로 이전 비동기 결과가 새 세션에 쓰이지 않게 합니다. selecting 중 재호출은 현재 UI를 앞으로 가져오고 capturing/committing 중 재호출은 무시하며 완료 상태를 알리는 잠정 정책입니다.

이미지 획득과 PNG/이미지 표현 생성에 성공한 뒤 클립보드를 변경합니다. `clearContents` 이후 `writeObjects` 실패의 원자성은 보장된다고 가정하지 않습니다. 지원 pasteboard 타입을 보존·복구하는 방식의 실현 가능성과 동시 타 앱 쓰기 충돌을 D05에서 검증하고, 실패 시 기존 데이터를 보존한다는 R09를 충족하는 정책을 확정해야 합니다. 실패를 성공 알림으로 바꾸지 않습니다.

지연 제공되는 pasteboard 타입은 완전한 백업이 불가능할 수 있습니다. 복원 전에 changeCount 등으로 외부 변경을 확인해 다른 앱의 새 데이터를 덮어쓰지 않는 정책을 검증합니다. R09를 만족하지 못하면 조용히 완화하지 않고 설계 대안 또는 명시적 요구사항 변경을 검토합니다.

전역 단축키는 살아 있는 메뉴 막대 프로세스가 등록하는 기본안입니다. 이 방식은 앱 종료 후 키 감지가 불가능하며 첫 직접 실행이 필요합니다. cold launch 요구 여부와 로그인 자동 시작 또는 별도 launcher는 D09에서 확정합니다.

## 화면과 오버레이

디스플레이 식별자·전역 logical point rect·배율을 별도로 관리합니다. 화면 배열의 첫 항목을 주 화면이나 현재 화면으로 가정하지 않습니다. AppKit과 캡처 API의 좌표 방향·원점 차이를 명시적으로 변환하고, 음수 원점과 역방향 드래그를 정규화한 뒤 디스플레이 경계로 제한합니다. 픽셀 경계의 반올림 정책을 결정하고 순수 함수로 검증합니다.

초기안은 시작한 디스플레이 내부 선택만 허용하고 경계 횡단 시 제한·안내하는 방식입니다. 사용자 의도와 기술 검증을 바탕으로 D04에서 확정하며, 횡단 캡처가 필요하면 서로 다른 배율 합성도 설계합니다. 화면 분리·해상도·배율 변경은 세션 취소 또는 영역 재보정 정책으로 처리합니다. 잠정적으로 선택 중 화면 구성 변경은 취소하고 다음 호출에서 다시 구성합니다.

캡처 UI 제외는 ScreenCaptureKit content filter에서 자체 오버레이 창을 제외하는 방법을 우선 실험합니다. 단순히 창을 숨긴 직후 캡처하면 합성 지연으로 UI가 남을 수 있으므로, 실제 캡처 결과로 검증해야 합니다. 커서 포함 여부도 명시적으로 끄는 후보를 검증합니다.

## 권한·프라이버시·배포

화면 기록 권한만을 기본 필요 권한으로 검토합니다. 전역 단축키 구현 때문에 접근성·입력 모니터링 권한이 필요한지는 선택 API에 따라 확인하고 필요한 경우에만 안내합니다. 자동 붙여 넣기가 없으므로 이를 이유로 접근성 권한을 요청하지 않습니다.

캡처는 메모리에서 처리하며 파일 자동 저장·네트워크 전송을 하지 않습니다. 로그에는 오류 코드·상태·소요 시간만 기록하고 화면 내용·클립보드 데이터·창 제목·앱 이름은 제외합니다. 샘플 및 버그 재현 자료에는 합성 테스트 화면만 사용합니다.

잠정 배포는 직접 배포용 서명 앱과 notarization, 최소 macOS 14입니다. SCScreenshotManager 후보 API 사용 가능 버전 및 동작을 확인한 뒤 확정합니다. 개인 개발용 실행과 사용자 배포 검증을 분리하고, 앱 식별자·서명 변경에 따른 권한 재요청, Gatekeeper, Apple Silicon/Intel 지원 범위를 검증합니다. App Store 배포는 별도 의사결정입니다.

## 미확정 결정

| ID | 잠정안 | 확정 근거 및 시점 |
| --- | --- | --- |
| D01 | macOS 14 이상, Swift/AppKit/SwiftUI | 단계 1에서 API availability, 개발 환경 및 지원 수요 확인 |
| D02 | ScreenCaptureKit/SCScreenshotManager | 단계 1에서 정확한 영역·오버레이 제외·권한 실패 실험 |
| D03 | ⌃⇧⌘5, 변경 가능한 전역 단축키 | 단계 1에서 등록 방식·권한·충돌 감지·설정 저장 검증 |
| D04 | 한 디스플레이 내부 선택 제안 | 단계 1에서 경계 횡단 요구와 혼합 배율 합성 필요 여부를 확인 후 확정 |
| D05 | 성공 시에만 clipboard 교체 | 단계 1에서 NSPasteboard 실패·복원·동시 변경 정책 확인 |
| D06 | 영역/모드의 세션 내 기억 | 단계 2 전에 앱 재시작 이후 저장 여부와 초기 영역 크기 결정 |
| D07 | 선택 중 재호출은 UI 활성화, 처리 중 무시 | 단계 2에서 UX 검토 및 상태 테스트로 확정 |
| D08 | Developer ID 서명 및 notarization 직접 배포 | 단계 6 전 인증서·배포 채널·지원 아키텍처 확정 |
| D09 | 메뉴 막대 상주 프로세스에서 단축키 감지 | 단계 1에서 종료 상태 실행 필요 여부 확인. 필요하면 launcher/로그인 시작 설계 |

## 공식 자료

구현 착수 시 아래 원문과 해당 SDK 헤더의 최신 내용·availability를 다시 확인하고 실험 결과를 기록합니다. 이 링크 목록만으로 구현 적합성이 검증된 것은 아닙니다.

- [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit)
- [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager)
- [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen)
- [CGPreflightScreenCaptureAccess](https://developer.apple.com/documentation/coregraphics/cgpreflightscreencaptureaccess())
- [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
