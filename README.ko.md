# Shot Clip

[English](README.md)

![Shot Clip의 crop+copy 아이콘과 Capture. Copy. Continue. 문구](docs/shotclip/assets/shotclip-hero.png)

화면 영역을 선택하면 이미지를 바로 클립보드에 복사하는 작은 macOS 메뉴 막대 앱입니다. **영역 캡처** 또는 **고정 영역**으로 캡처한 뒤 다른 앱에서 `⌘V`로 붙여 넣습니다.

**개발 후보: Shot Clip 0.8.0(build 10).** 같은 창 크기·상태에서 영어/한국어를 바꿔도 창·탐색·행·폼 컨트롤·읽던 위치를 유지하고 Roboto/Noto Sans KR의 글자 크기·행간을 조정합니다. 긴 진단은 실제 상태 변경이나 resize 뒤 두 언어 공통 높이로 커질 수 있습니다. 새 검증·배포 상태는 [현재 QA](docs/shotclip/qa-results.md#2026-10-06-080-language-invariant-settings)에 기록하며 아직 새 공개/설치 완료를 주장하지 않습니다.

현재 공개·설치 기준은 **0.7.0(build 9)**, 검토한 소스 [`53bd5d2`](https://github.com/kyungseok-lee/shotclip/commit/53bd5d2ad05375be7a6296da4534815260a38d98)입니다: [릴리스](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.7.0) / [ZIP](https://github.com/kyungseok-lee/shotclip/releases/download/v0.7.0/shotclip-0.7.0.zip). **Apple Silicon(arm64) 전용 ad-hoc·미공증** 배포입니다. 새0.8 공개·설치 검증 뒤 과거 공개 릴리스와 소유가 확인된 로컬 구버전을 삭제하며 Git 이력/태그는 보존합니다. 과거 다운로드 링크는 그 뒤 사용할 수 없을 수 있습니다.

화면 기록 권한이 없으면 **화면 기록 허용…**을 제공하며 준비된 뒤 캡처 메뉴를 표시합니다. 복사 성공 후 우측 하단 썸네일을 누르면 원본을 Fit/100%로 보고 **저장…**으로 선택한 위치에 PNG를 내보냅니다. 썸네일 해제·창 닫기·저장 취소는 클립보드를 유지하며 자동 캡처 저장/이력은 만들지 않습니다.

후보36 tests·704 합성 뷰/400 언어 불변성 case와 별도36 tests/두 matrix 재현을 확인했고 실제 정상 native 전환·배포는 구분합니다. [현재 후보 검증](docs/shotclip/qa-results.md#2026-10-06-080-language-invariant-settings)과 [과거0.7 배포 판정](docs/shotclip/release-review-0.7.0.md)을 구분합니다. 검증 host의 화면 기록 권한이 없어 실제 캡처/붙여 넣기는 permission-SKIP입니다. 전체 접근성·macOS14/Intel·깨끗한 계정 최초 실행은 미검증이며 이전 자동 전역 단축키 시도는 Carbon 동작이나 제품 결함을 확정하지 못했습니다.

## 빌드와 실행

macOS 14 이상, macOS SDK가 포함된 Xcode, Swift 5.9 이상이 필요합니다. macOS 27.0.1 / Xcode 27.0 / Apple Silicon에서 빌드·설치·로컬 정상 시작을 확인했습니다. macOS 14 실행은 미검증이며 공개 ZIP에는 Intel 바이너리가 없습니다.

```sh
git clone https://github.com/kyungseok-lee/shotclip.git
cd shotclip
swift test
bash scripts/build-app.sh
bash scripts/install-app.sh
open '/Applications/Shot Clip.app'
```

ZIP의 `Shot Clip.app`을 `/Applications/Shot Clip.app`에 설치합니다. 소스 설치기는 새 앱을 staging/검증하고 해당 경로에 설치·검증한 뒤 기존 `ShotClip.app`/`sshot.app`을 복구 가능한 백업으로 옮깁니다. 설치 전에 모든 실행 복사본을 종료하세요. 수동 폴더 전환은 로컬에서 검증했으며 기본 Sparkle는 기존 공백 없는 경로를 유지할 수 있습니다. 개발 산출물은 `dist/Shot Clip.app`이고 `.build/`와 `dist/`는 Git에서 제외합니다.

## 캡처와 언어

1. Shot Clip을 실행합니다. 화면 기록 권한이 없으면 **화면 기록 허용…**을 선택하고 준비된 경우 **영역 캡처** 또는 **고정 영역**, 변경 가능한 단축키 `⌃⇧⌘5`로 마지막 모드를 엽니다. 신규 기본은 영역 캡처이며 기존 유효한 모드/단축키는 유지합니다.
2. 캡처할 때 **화면 기록** 권한을 허용합니다. 앱으로 돌아와 다시 확인하고 필요하면 재시작합니다.
3. 고정 영역을 이동·조절한 뒤 Return 또는 캡처를 누릅니다. 드래그 영역은 유효한 선택을 놓으면 캡처합니다.
4. 이미지 입력을 지원하는 앱에서 `⌘V`를 누릅니다. Preview는 `⌘N`으로 클립보드 이미지를 엽니다.

Escape는 취소, 방향키는 이동, Shift는 큰 이동, Option+방향키는 오른쪽 위 모서리 크기 조절입니다. `M`은 모드 전환, Tab/Shift-Tab은 포커스 이동입니다. 기본 언어는 영어입니다. 일반 설정의 **English / 한국어** 선택이 메뉴·설정·선택 도구·앱 메시지·앱 소유 업데이트 창에 즉시 적용되고 다음 실행에도 유지됩니다. macOS 소유 권한/보안 창은 OS 언어를 따릅니다. 화면 기록 권한 변경 후 필요한 재시작은 언어 전환과 별개입니다.

선택은 한 화면 안으로 제한됩니다. 고정 영역은 현재 실행 세션에서만 기억하며 모드와 단축키는 저장합니다. 앱이 실행 중이어야 전역 단축키가 작동하고 로그인 시작은 선택 사항입니다. 접근성·전체 디스크 접근 권한은 필요하지 않습니다.

0.5.0 표시/경로 변경은 `dev.shotclip.app` 식별자와 기존 설정을 유지합니다. 과거 Sshot은 다른 ID여서 새 허용이 필요하고 ad-hoc 교체 후에도 재허용이 필요할 수 있습니다. 수동 폴더 전환 후 `/Applications/Shot Clip.app`에서 실행하세요. 복구 안내는 현재 위치를 표시하며 TCC를 초기화하지 않습니다. [Apple 권한 안내](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac)를 참고하세요.

## 개발자 프리뷰와 업데이트

ad-hoc 프리뷰는 최초 실행이 차단될 수 있습니다. 출처를 확인한 후 가능한 경우 Apple의 앱별 **개인정보 보호 및 보안 → 확인 없이 열기** 절차를 따르세요. Gatekeeper 전체를 끄지 않습니다. Ed25519 서명은 feed/archive 무결성을 검증하며 Apple 공증이나 화면 기록 허용을 대신하지 않습니다. [Apple 최초 실행 안내](https://support.apple.com/en-us/102445), [업데이트 운영](docs/shotclip/update-operations.md)을 참고하세요.

Sparkle 자동 확인은 선택 사항이며 **기본 OFF**입니다. [공개 서명 feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml)와 0.7.0 ZIP을 2026-10-05에 검증했습니다. 기존 Ed25519 키와 Keychain 계정 `sshot`은 유지합니다. 기본 Sparkle는 기존 `ShotClip.app` 위치에서 교체할 수 있으므로 새 `Shot Clip.app` 이름은 Shot Clip 수동 설치로 적용합니다. 과거 Sshot도 수동 설치하고 단축키/모드만 이전하며 권한·로그인 등록은 이전하지 않습니다. 이 host에서 수동 확인으로 시작한 동일 ID 0.6→0.7 Sparkle 업그레이드는 통과했으며 다른 버전/플랫폼은 별도 검증입니다.

## 개인정보와 검증

캡처·인코딩은 메모리에서 처리합니다. 클라우드·캡처 기록·자동 저장·OCR 기능은 추가하지 않으며 이미지·화면·앱/창 정보·클립보드 내용을 로그로 남기지 않습니다. 취소·거부·캡처/인코딩 실패는 클립보드를 변경하지 않습니다. 쓰기 복구에는 OS 원자성 한계가 있어 오류를 표시합니다. **저장…** 창을 승인했을 때만 원본을 선택한 위치에 저장하고 닫기·취소는 클립보드를 유지합니다.

빠른 검증과 사용자 담당 캡처 절차는 [QA 계획](docs/shotclip/qa-plan.md)에 있습니다. 이 문서 작업은 실제 캡처·권한·붙여 넣기 통과를 주장하지 않습니다. harness는 합성 화면과 고유 named pasteboard를 쓰고 SKIP은 PASS가 아닙니다.

[제품 계획](docs/shotclip/product-plan.md), [개발 계획](docs/shotclip/development-plan.md), [디자인 시스템](docs/shotclip/design-system.md), [인수인계](docs/shotclip/handoff.md), [문서 안내](docs/shotclip/README.md)를 순서대로 읽으세요.
