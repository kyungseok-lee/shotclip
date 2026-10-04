# sshot

macOS에서 원하는 화면 영역을 캡처한 뒤 이미지를 즉시 클립보드에 넣는 메뉴 막대 앱입니다. 사용자는 다른 앱에서 `⌘V`로 캡처 이미지를 붙여 넣을 수 있습니다.

현재 버전은 로컬 개발용 MVP입니다. 구현과 자동 회귀 테스트가 있으며 실제 화면 QA는 [QA 기록](docs/sshot/qa-results.md)에 범위별로 표시합니다. Developer ID 서명·공증 배포는 아직 완료되지 않았습니다.

## 빌드 및 실행

macOS 14 이상과 macOS SDK를 포함한 Xcode, Swift 5.9 이상이 필요합니다. 외부 패키지 의존성은 없습니다. 현재 검증 환경은 macOS 27.0.1 / Xcode 27.0 / Apple Silicon입니다.

```sh
git clone https://github.com/kyungseok-lee/sshot.git
cd sshot
swift test
bash scripts/build-app.sh
open dist/sshot.app
```

`dist/sshot.app`은 기본적으로 ad-hoc 서명된 로컬 실행 앱입니다. 빌드 중에는 실행 중인 sshot을 먼저 종료하세요. 바이너리를 교체하면 실행 프로세스나 화면 기록 권한에 영향을 줄 수 있습니다. `.build/`와 `dist/`는 Git에 포함하지 않습니다.

## 목표 사용 흐름

1. 설정 가능한 전역 단축키로 캡처 UI를 엽니다.
2. 고정 사각형 마스크를 조정해 캡처하거나, 드래그로 영역을 즉시 선택합니다.
3. 캡처가 성공하면 이미지가 클립보드에 들어갑니다.
4. 원하는 앱으로 돌아가 `⌘V`로 붙여 넣습니다.

macOS 기본 캡처의 썸네일에서 별도로 복사하는 단계를 없애는 것이 핵심입니다. 자동 붙여 넣기나 다른 앱에 키 입력을 보내는 기능은 MVP 범위에 포함하지 않습니다.

macOS도 Control을 추가한 캡처 단축키나 캡처 저장 위치 설정으로 클립보드 복사를 지원합니다([Apple 안내](https://support.apple.com/guide/mac-help/take-a-screenshot-mh26782/mac)). sshot은 고정 영역 재사용과 두 선택 모드를 제공하고, 성공한 캡처를 항상 즉시 복사하는 일관된 흐름을 목표로 합니다.

첫 실행의 안내 창에서 화면 기록 권한을 요청한 뒤 시스템 설정에서 sshot을 허용하세요. 시스템에서 요청하면 앱을 다시 실행합니다. 권한 거부 상태에서는 캡처하지 않습니다. 접근성 권한은 제품 사용에 요구하지 않습니다.

기본 단축키는 `⌃⇧⌘5`입니다. 안내 창의 ‘단축키 변경’으로 바꿀 수 있으며 이미 등록된 키는 오류를 안내합니다. 마지막 선택 모드를 단축키로 다시 엽니다. 앱을 처음 직접 실행해야 하고, 종료하면 단축키도 작동하지 않습니다. 로그인 자동 시작은 사용자가 설정에서 켤 수 있으며 서명·설치 환경에 따라 시스템 승인이 필요합니다.

고정 영역에서는 사각형 내부를 드래그해 이동하고 8개 핸들로 크기를 조절합니다. 캡처 버튼 또는 Enter로 확정합니다. 방향키로 이동, Shift+방향키로 크게 이동, Option+방향키로 오른쪽 위 모서리를 조절합니다. 즉시 드래그 모드에서는 선택 후 마우스를 놓으면 캡처합니다. Escape 또는 취소 버튼으로 취소하고 Tab으로 모드를 전환합니다.

선택을 시작한 화면 내부에서 캡처합니다. 각 모니터를 독립적으로 선택할 수 있지만 여러 화면을 하나로 합치지는 않습니다. 화면 구성 변경과 잠자기 진입 시 진행 중인 캡처를 취소합니다. 고정 영역은 같은 실행 세션에서 재사용하며, 모드·단축키만 설정으로 저장합니다.

성공하면 복사 완료 안내가 표시됩니다. 이미지 붙여 넣기를 지원하는 앱에서 직접 `⌘V`를 누르세요. Preview는 `⌘N`으로 클립보드 이미지를 새 문서로 열 수 있습니다. 일반 텍스트 입력란은 이미지 붙여 넣기를 지원하지 않을 수 있습니다.

## 검증과 배포

```sh
swift test
bash scripts/build-app.sh
dist/sshot.app/Contents/MacOS/sshot --self-test
```

`--self-test`는 별도 fixture 앱의 합성 색상 화면을 실제 캡처하고, 자체 UI 제외·픽셀 크기·PNG/TIFF 디코딩을 검사합니다. 일반 클립보드 대신 unique named pasteboard를 사용합니다. 결과는 메타데이터 JSON이며 PASS는 exit 0, FAIL은 1, 권한 부족 SKIP은 77입니다. SKIP은 통과가 아닙니다. 실제 이미지를 파일·로그로 남기지 않습니다.

개발용 ad-hoc 앱은 다른 컴퓨터의 Gatekeeper 배포 검증을 통과한 앱이 아닙니다. Developer ID Application 인증서와 기존 notarytool keychain profile이 준비되면 다음 명령으로 서명·공증·staple·Gatekeeper 검사를 수행합니다. 인증정보를 저장소에 넣지 마세요.

```sh
SSHOT_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
SSHOT_NOTARY_PROFILE='your-existing-profile' \
bash scripts/notarize-app.sh
```

산출물은 `dist/sshot-release.zip`입니다. 이 명령은 현재 인증서가 없어 실행 검증하지 않았습니다. 앱 종료 후 앱 번들을 삭제하면 제거되며, 로그인 시작을 켰다면 먼저 앱에서 꺼주세요.

취소·권한 거부·캡처/인코딩 실패는 클립보드를 변경하지 않습니다. 교체 전 기존 데이터를 백업할 수 없으면 복사를 중단합니다. NSPasteboard에는 원자적 교체 기능이 없어 시스템 쓰기·복원 장애의 무조건적인 데이터 보존은 보장하지 않습니다. 복원 실패는 별도 오류로 안내합니다.

## 문서 읽는 순서

- [에이전트 공통 규약](AGENTS.md)
- [개발 문서 안내](docs/sshot/README.md)
- [요구사항과 수용 기준](docs/sshot/requirements.md)
- [설계와 결정 대장](docs/sshot/architecture.md)
- [단계별 개발 순서](docs/sshot/development-plan.md)
- [검증 계획과 요구사항 추적](docs/sshot/verification.md)
- [현재 상태와 작업 인수인계](docs/sshot/handoff.md)
- [기술 검증 기록](docs/sshot/technical-validation.md)
- [QA 실행 기록](docs/sshot/qa-results.md)

## 다른 환경에서 이어가기

저장소를 clone한 뒤 위 문서와 인수인계 상태를 읽으세요. 문서 작성에는 Git과 텍스트 편집기만 필요합니다. 실제 앱 구현 및 화면 캡처 검증에는 macOS와 Xcode가 필요합니다. [개발 순서](docs/sshot/development-plan.md)의 남은 gate와 실제 QA 증거를 기준으로 작업을 이어갑니다.

이 저장소에는 캡처 이미지나 개인정보를 넣지 않습니다. 기여자는 변경 범위와 검증 결과를 인수인계 문서에 기록하고, 검증되지 않은 실행 가능성이나 지원 범위를 주장하지 않습니다.
