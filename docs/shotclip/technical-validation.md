# ShotClip technical validation

[Architecture](architecture.md) · [Design system](design-system.md) · [QA results](qa-results.md)

## 2026-10-05 documentation-source review

Method: inspected current Swift/AppKit sources and existing docs without operating capture GUI; consulted official Apple documentation through web retrieval and Apple's public DocC JSON endpoints (`developer.apple.com/tutorials/data/…`). JavaScript-only page shells were not treated as content evidence: the native design/accessibility/materials and package-localization JSON returned the document titles and content. No SDK probe, build, capture, permission grant, clipboard write, installation, or release was performed in this documentation lane.

| Primary source | Grounded decision |
| --- | --- |
| [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos) | Native windows/menu commands, appropriate density, keyboard workflows |
| [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) | Labels, perceivable states, system colors, contrast and alternate interaction |
| [NSColor](https://developer.apple.com/documentation/appkit/nscolor), [NSFont](https://developer.apple.com/documentation/appkit/nsfont) | Semantic roles and system fonts; project sizes are choices |
| [Materials](https://developer.apple.com/design/human-interface-guidelines/materials), [Reduce Transparency](https://developer.apple.com/documentation/appkit/nsworkspace/accessibilitydisplayshouldreducetransparency) | Restrained system materials, opaque readable help/control fallback |
| [Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy) | Request at capture intent; clear explicit request and later recovery |
| [Package localization](https://developer.apple.com/documentation/xcode/localizing-package-resources), [String catalogs](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) | English/ko resources, complete strings, deterministic fallback; verify actual packaging |
| [First launch](https://support.apple.com/en-us/102445), [Screen Recording settings](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac) | Per-app approval and Screen Recording consent are distinct from Ed25519 integrity |

Reproduce: fetch the linked official pages; if the HIG page supplies only a JavaScript shell, fetch `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-macos.json` (and the corresponding topic path) and inspect `metadata.title` / `primaryContentSections`. Recheck availability in the installed SDK before implementing APIs. These readings support design decisions, not runtime passes. The **2027 TREND PREDICTION** column is an explicitly speculative project hypothesis.

한국어: Apple 원문과 실제 소스를 확인해 native 토큰·권한·키보드·현지화 방향을 정했습니다. JavaScript shell만 본 자료는 근거로 쓰지 않고 공개 DocC JSON 내용을 확인했습니다. API probe·앱 테스트는 재실행하지 않았고 2027 예측은 사실이 아닌 가설입니다.

## Historical Sshot probes — retained as recorded

The following 2026-10-04 probes and legacy identity/TCC findings describe Sshot. Preserve their exact historical names and results. Later fixes and remote evidence are in [QA results](qa-results.md) and [handoff](handoff.md); a historical “in progress” statement is not the current ShotClip delivery decision.

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

## 권한 재실행 이후 확인

사용자가 화면 기록을 허용하고 다시 실행한 뒤에도 실제 제품 self-test는 SKIP이었다. 직접 바이너리 실행뿐 아니라 LaunchServices `open -n -W ... --args --self-test`에서도 같은 결과를 확인했다.

제품에 한정한 macOS TCC 로그에서 `Failed to match existing code requirement for subject dev.sshot.app and service kTCCServiceScreenCapture`를 확인했다. 허용 항목의 이전 cdhash와 현재 ad-hoc 앱의 cdhash가 달랐다. 이는 CGPreflight 오검출을 추측할 상황이 아니라 저장된 코드 identity의 불일치다. 허용 스위치만 다시 켜도 기존 requirement가 갱신되지 않았다.

이전 sshot 권한 항목만 시스템 설정 UI에서 제거했으며 다른 앱 권한은 변경하지 않았다. 파일 선택 창의 자동 키보드 입력이 focus 제한으로 실패한 뒤 사용자가 현재 앱을 다시 허용했다. 이후 설정에서 sshot 허용을 확인했고 LaunchServices 실행은 preflight를 통과하여 실제 캡처까지 도달했다. 터미널 직접 실행은 iTerm이 responsible process로 판정되므로 제품 권한 gate의 증거로 사용하지 않는다. TCC DB 직접 수정이나 `tccutil reset`, 권한 판별 우회는 수행하지 않았다.

이후 self-test에서 `objc_release`/autorelease pool의 SIGSEGV를 확인했다. 테스트 overlay의 `isReleasedWhenClosed` 설정 누락을 수정 대상으로 확인하고 독립 검토를 진행 중이다. 실제 캡처 QA와 push는 계속 미완료다.

## 공식 근거

- [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager)
- [sourceRect](https://developer.apple.com/documentation/screencapturekit/scstreamconfiguration/sourcerect)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice)

실험은 별도 document-specialist가 수행했다. 실제 앱 테스트와 원격 반영은 별도 verifier가 검증한다.
