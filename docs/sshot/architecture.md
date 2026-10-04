# 설계와 결정 대장

## 후보 구조

Swift 기반 메뉴 막대 앱을 구현했습니다. SwiftPM으로 빌드하고 AppKit으로 메뉴·설정·오버레이와 NSPasteboard를 처리합니다. 화면 캡처는 macOS 14 이상의 ScreenCaptureKit still-image API를 사용합니다. 실제 구현 결정과 probe 증거는 [기술 기록](technical-validation.md), 실행 검증 범위는 [QA 기록](qa-results.md)을 따릅니다.

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
| UpdateService | Sparkle 초기화, HTTPS feed/공개키 구성 검증, 업데이트 메뉴 상태 |

## 상태 및 실패 처리

구현은 `idle → selecting → processing → idle` 상태를 사용합니다. 진입 전 권한을 확인하고 processing에서 캡처·인코딩·클립보드 commit을 순서대로 수행합니다. 취소·권한 실패·캡처 실패는 쓰기 전에 종료합니다. 세션 ID로 이전 비동기 결과를 차단하며 Task를 취소합니다. 선택 중 재호출은 기존 UI를 활성화하고 처리 중 재호출은 무시합니다. 12초 timeout, 화면 구성 변경, 잠자기 진입은 세션을 종료합니다. OS API 자체의 즉각적인 중단까지 보장하지는 않습니다.

이미지 획득과 PNG/TIFF 생성에 성공한 뒤 클립보드를 변경합니다. `clearContents` 이후 `writeObjects` 실패의 원자성은 보장된다고 가정하지 않습니다. 기존 타입별 데이터 snapshot과 오류 복원 정책을 D05로 채택했고, 오류 주입 테스트로 복원과 외부 변경 보호를 검증했습니다. 실제 앱 간 붙여 넣기는 권한 허용 후 별도 검증합니다. 실패를 성공 알림으로 바꾸지 않습니다.

지연 제공되는 pasteboard 타입은 완전한 백업이 불가능할 수 있습니다. 모든 타입을 eager snapshot으로 확보하고 64MiB·128 item·item당 64 type 제한을 적용합니다. 백업 실패와 세대 변경은 교체 전에 중단하며, 교체/복원 전후 changeCount를 확인합니다. 원자적 교체 API가 없으므로 시스템 장애·복원 실패·최종 경쟁 상황의 무조건 보존은 보장할 수 없습니다. 복원 실패는 별도 오류로 표시하고 [QA 기록](qa-results.md)에 한계를 공개합니다.

전역 단축키는 실행 중인 메뉴 막대 프로세스가 등록합니다. 첫 직접 실행이 필요하며 앱 종료 후 키 감지는 불가능합니다. 로그인 자동 시작은 opt-in이고 별도 cold-launch launcher는 구현하지 않습니다.

## 화면과 오버레이

디스플레이 식별자·전역 logical point rect·배율을 별도로 관리합니다. 화면 배열의 첫 항목을 주 화면이나 현재 화면으로 가정하지 않습니다. AppKit과 캡처 API의 좌표 방향·원점 차이를 명시적으로 변환하고, 음수 원점과 역방향 드래그를 정규화한 뒤 디스플레이 경계로 제한합니다. 픽셀 경계의 반올림 정책을 결정하고 순수 함수로 검증합니다.

시작한 디스플레이 내부 선택만 허용하고 경계를 제한·안내합니다. 다른 디스플레이에서도 새 선택을 시작할 수 있습니다. 화면 구성 변경은 진행 중인 세션을 취소하고 다음 호출에서 다시 구성합니다.

ScreenCaptureKit content filter에서 자체 프로세스를 제외하고 showsCursor=false로 설정합니다. 일반 캡처에서는 오버레이를 숨기며, harness에서는 magenta 오버레이를 보이게 한 상태로 필터 제외 여부를 검사합니다. 실제 결과는 권한 허용 후 검증해야 합니다.

## 권한·프라이버시·배포

제품 사용에는 화면 기록 권한이 필요하며 접근성·전체 디스크 접근 권한은 요구하지 않습니다. 앱 실행 여부와 화면 기록 권한을 별도로 표시하고, 활성화 시 현재 권한을 재확인합니다. 현재 실행 앱의 경로를 보여주고 해당 앱을 Finder에서 표시하여 여러 빌드의 권한 혼동을 줄입니다.

개발 ad-hoc 서명은 코드 교체 시 cdhash 기반 identity가 달라져 재허용이 필요할 수 있습니다. 배포는 고정 앱 식별자와 동일 Developer ID identity, `/Applications/sshot.app` 경로를 유지합니다. 이는 반복 재허용을 줄이는 운영안이며 OS의 추가 요청이 절대 없다는 보장은 아닙니다.

업데이트는 Sparkle을 사용합니다. 빌드 시 HTTPS appcast URL과 Ed25519 공개키를 주입하며 미설정·비HTTPS 구성은 비활성화합니다. 개인 서명 키는 저장소·앱 번들에 넣지 않습니다. 앱 번들의 Developer ID 서명·공증과 업데이트 archive의 Sparkle 서명을 각각 검증합니다. 실제 HTTPS 호스팅·feed·키·이전 버전에서의 업그레이드 성공은 미검증입니다. 업데이트 통신에 캡처/클립보드 내용을 포함하지 않습니다.

캡처는 메모리에서 처리하며 파일 자동 저장·네트워크 전송을 하지 않습니다. 로그에는 오류 코드·상태·소요 시간만 기록하고 화면 내용·클립보드 데이터·창 제목·앱 이름은 제외합니다. 샘플 및 버그 재현 자료에는 합성 테스트 화면만 사용합니다.

잠정 배포는 직접 배포용 서명 앱과 notarization, 최소 macOS 14입니다. SCScreenshotManager 후보 API 사용 가능 버전 및 동작을 확인한 뒤 확정합니다. 개인 개발용 실행과 사용자 배포 검증을 분리하고, 앱 식별자·서명 변경에 따른 권한 재요청, Gatekeeper, Apple Silicon/Intel 지원 범위를 검증합니다. App Store 배포는 별도 의사결정입니다.

## 결정 상태

구현에 채택한 결정이며 실제 QA 통과와 구분합니다. D08의 서명·공증 배포와 현재 환경 밖의 실행 검증은 아직 완료되지 않았습니다.

| ID | 잠정안 | 확정 근거 및 시점 |
| --- | --- | --- |
| D01 | macOS 14 이상, Swift/AppKit | SDK availability와 현재 host 컴파일 확인. macOS 14/Intel 실행은 미검증 |
| D02 | ScreenCaptureKit/SCScreenshotManager | 구현·컴파일 완료, 실제 픽셀/오버레이 QA는 권한 대기 |
| D03 | ⌃⇧⌘5, 변경 가능한 exclusive 전역 단축키 | 등록/중복 probe 및 Finder에서 실제 이벤트 전달·설정 변경 확인 |
| D04 | 각 모니터 독립 캡처, 한 선택은 한 화면 | 경계 제한 안내 포함. 여러 화면 합성 없음. 실제 혼합 배율 harness 준비 |
| D05 | 사전 인코딩·snapshot, 오류 rollback·외부 변경 보존 | 오류 주입 단위 테스트 통과. 플랫폼 잔여 한계 공개 |
| D06 | 영역 세션 기억, 모드/단축키 UserDefaults 저장 | 초기 400×300 point 영역, 화면 경계 보정. 이미지 저장 없음 |
| D07 | 선택 중 UI 활성화, 처리 중 무시 | 제품에서 사용하는 coordinator의 취소/timeout/늦은 결과 테스트 통과 |
| D08 | 로컬 ad-hoc 앱 + Developer ID 공증 준비 | 로컬 서명 검사 통과. 유효 인증서 0으로 공증·배포 QA 차단 |
| D09 | 메뉴 막대 상주, opt-in 로그인 시작 | 첫 직접 실행 필요. 종료 상태 cold launch 없음. 로그인 등록 실제 실행은 미검증 |
| D10 | Sparkle, GitHub Releases HTTPS appcast·Ed25519 서명 업데이트 | 별도 서버 없이 latest/download/appcast.xml과 tag별 archive 사용. 공개키 포함 및 publisher 작업 중. production 인증서·공증·실제 게시/업그레이드 QA 미완료 |
| D11 | Sshot 표시명·독자 macOS 아이콘·native AppKit 설정 | 0.3.0(build 4) 구현·독립 검토·로컬 설치/설정 확인. stable identity 및 저장 설정 유지. 실제 resize와 캡처는 미검증/사용자 인수 |

## 공식 자료

구현 착수 시 아래 원문과 해당 SDK 헤더의 최신 내용·availability를 다시 확인하고 실험 결과를 기록합니다. 이 링크 목록만으로 구현 적합성이 검증된 것은 아닙니다.

- [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit)
- [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager)
- [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen)
- [CGPreflightScreenCaptureAccess](https://developer.apple.com/documentation/coregraphics/cgpreflightscreencaptureaccess())
- [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
- [Apple HIG: Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos): native 설정 창·정보 밀도·크기 조절·메뉴/키보드 설계 참고. 링크 자체는 UI 실행 검증 증거가 아닙니다.
