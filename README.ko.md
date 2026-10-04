# ShotClip

[English](README.md)

![ShotClip: 코발트색 바탕의 민트 캡처 모서리·아이보리 클립보드 아이콘과 Capture. Copy. Continue. 문구](docs/shotclip/assets/shotclip-hero.png)

화면 영역을 선택하면 이미지를 바로 클립보드에 복사하는 작은 macOS 메뉴 막대 앱입니다. **고정 영역** 또는 **드래그 영역**으로 캡처한 뒤 다른 앱에서 `⌘V`로 붙여 넣습니다.

**0.4.1(build 6) 시각 개선 버전을 준비 중**입니다. 캡처와 클립보드를 표현하는 새 아이콘과 독자적인 브랜드 이미지를 제공합니다. 이미지는 실제 화면을 포함하지 않은 합성 일러스트이며 게시·설치 결과는 검증 후 기록합니다.

**ShotClip 0.4.0(build 5)**를 **Apple Silicon(arm64) 전용** GitHub 개발자 프리뷰로 공개했습니다. **Ad-hoc 서명이며 공증되지 않았습니다.** [ZIP 다운로드](https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/shotclip-0.4.0.zip), [v0.4.0 릴리스](https://github.com/kyungseok-lee/shotclip/releases/tag/v0.4.0)를 이용하세요. 2026-10-05 KST에 독립 검토된 구현 소스 [`ab57fca`](https://github.com/kyungseok-lee/shotclip/commit/ab57fcace589f2c786ba183778d1b1bb4e77fe87)에서 게시했습니다.

공개 산출물/feed와 로컬 설치·정상 시작을 검증했습니다. 실제 캡처·권한·붙여 넣기·언어/접근성 화면·자동 업데이트는 미검증이며 [QA 기록](docs/shotclip/qa-results.md)에 범위를 구분했습니다.

## 빌드와 실행

macOS 14 이상, macOS SDK가 포함된 Xcode, Swift 5.9 이상이 필요합니다. macOS 27.0.1 / Xcode 27.0 / Apple Silicon에서 빌드·설치·로컬 정상 시작을 확인했습니다. macOS 14 실행은 미검증이며 공개 ZIP에는 Intel 바이너리가 없습니다.

```sh
git clone https://github.com/kyungseok-lee/shotclip.git
cd shotclip
swift test
bash scripts/build-app.sh
bash scripts/install-app.sh
open /Applications/ShotClip.app
```

다운로드한 ZIP을 풀고 `ShotClip.app`을 `/Applications`에 넣으세요. 설치 전에 ShotClip과 과거 Sshot을 종료합니다. 위 소스 설치 스크립트는 새 번들을 검증하고 기존 설치를 백업하여 위치를 출력합니다. 개발 산출물은 `dist/ShotClip.app`이고 `.build/`와 `dist/`는 Git에서 제외합니다.

## 캡처와 언어

1. ShotClip을 실행하고 메뉴 막대 또는 변경 가능한 기본 단축키 `⌃⇧⌘5`로 마지막 선택 모드를 엽니다.
2. 캡처할 때 **화면 기록** 권한을 허용합니다. 앱으로 돌아와 다시 확인하고 필요하면 재시작합니다.
3. 고정 영역을 이동·조절한 뒤 Return 또는 캡처를 누릅니다. 드래그 영역은 유효한 선택을 놓으면 캡처합니다.
4. 이미지 입력을 지원하는 앱에서 `⌘V`를 누릅니다. Preview는 `⌘N`으로 클립보드 이미지를 엽니다.

Escape는 취소, 방향키는 이동, Shift는 큰 이동, Option+방향키는 오른쪽 위 모서리 크기 조절입니다. `M`은 모드 전환, Tab/Shift-Tab은 포커스 이동입니다. 기본 언어는 영어이고 일반 설정에서 **English / 한국어**를 선택한 뒤 재시작하여 적용합니다.

선택은 한 화면 안으로 제한됩니다. 고정 영역은 현재 실행 세션에서만 기억하며 모드와 단축키는 저장합니다. 앱이 실행 중이어야 전역 단축키가 작동하고 로그인 시작은 선택 사항입니다. 접근성·전체 디스크 접근 권한은 필요하지 않습니다.

새 `dev.shotclip.app` 식별자는 과거 Sshot의 허용과 별개로 화면 기록을 다시 허용해야 합니다. `/Applications/ShotClip.app`에서 실행하세요. ad-hoc 교체 후에도 재허용이 필요할 수 있으며 복구 안내에 현재 위치를 표시합니다. TCC를 자동 초기화하지 않습니다. [Apple 권한 안내](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac)를 참고하세요.

## 개발자 프리뷰와 업데이트

ad-hoc 프리뷰는 최초 실행이 차단될 수 있습니다. 출처를 확인한 후 가능한 경우 Apple의 앱별 **개인정보 보호 및 보안 → 확인 없이 열기** 절차를 따르세요. Gatekeeper 전체를 끄지 않습니다. Ed25519 서명은 feed/archive 무결성을 검증하며 Apple 공증이나 화면 기록 허용을 대신하지 않습니다. [Apple 최초 실행 안내](https://support.apple.com/en-us/102445), [업데이트 운영](docs/shotclip/update-operations.md)을 참고하세요.

Sparkle 자동 확인은 선택 사항이며 **기본 OFF**입니다. [공개 서명 feed](https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml)와 릴리스 ZIP을 2026-10-05에 검증했습니다. 기존 Ed25519 키와 Keychain 계정 `sshot`을 교체·내보내기·재생성 없이 유지합니다. 과거 Sshot에서 ShotClip은 한 번 수동 설치하고 단축키/모드만 이전하며 권한·로그인 등록은 이전하지 않습니다. 같은 ShotClip 식별자의 더 높은 build로 실제 자동 업그레이드하는 종단간 테스트는 미실행입니다.

## 개인정보와 검증

캡처·인코딩은 메모리에서 처리합니다. 클라우드·캡처 기록·저장·OCR 기능은 추가하지 않으며 이미지·화면·앱/창 정보·클립보드 내용을 로그로 남기지 않습니다. 취소·거부·캡처/인코딩 실패는 클립보드를 변경하지 않습니다. 쓰기 복구에는 OS 원자성 한계가 있어 오류를 표시합니다.

빠른 검증과 사용자 담당 캡처 절차는 [QA 계획](docs/shotclip/qa-plan.md)에 있습니다. 이 문서 작업은 실제 캡처·권한·붙여 넣기 통과를 주장하지 않습니다. harness는 합성 화면과 고유 named pasteboard를 쓰고 SKIP은 PASS가 아닙니다.

[제품 계획](docs/shotclip/product-plan.md), [개발 계획](docs/shotclip/development-plan.md), [디자인 시스템](docs/shotclip/design-system.md), [인수인계](docs/shotclip/handoff.md), [문서 안내](docs/shotclip/README.md)를 순서대로 읽으세요.
