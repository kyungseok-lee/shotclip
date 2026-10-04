# Sshot

macOS에서 원하는 화면 영역을 캡처한 뒤 이미지를 즉시 클립보드에 넣는 메뉴 막대 앱입니다. 사용자는 다른 앱에서 `⌘V`로 캡처 이미지를 붙여 넣을 수 있습니다.

현재 버전은 로컬 개발용 MVP입니다. 구현과 자동 회귀 테스트가 있으며 실제 화면 QA는 [QA 기록](docs/sshot/qa-results.md)에 범위별로 표시합니다. Developer ID 서명·공증 배포는 아직 완료되지 않았습니다.

로컬 개발 archive는 `dist/sshot-0.3.0.zip`입니다. 압축 무결성은 확인했지만 production 서명·업데이트 feed가 없는 자료이므로 공개 배포본으로 취급하지 않습니다.

사용자로부터 이전 버전의 기본 동작이 잘 된다는 정성 확인을 받았습니다. 현재 설치 버전은 표시 이름·아이콘·native 설정 창을 정돈한 0.3.0(build 4)입니다. 로컬 빌드·서명과 설정 화면을 확인했고 실제 캡처 테스트는 사용자가 맡습니다. 실행 파일·앱 식별자·설치 경로는 기존 값을 유지합니다.

## 빌드 및 실행

macOS 14 이상과 macOS SDK를 포함한 Xcode, Swift 5.9 이상이 필요합니다. 업데이트 기능에는 Sparkle을 사용합니다. 현재 검증 환경은 macOS 27.0.1 / Xcode 27.0 / Apple Silicon입니다.

```sh
git clone https://github.com/kyungseok-lee/sshot.git
cd sshot
swift test
bash scripts/build-app.sh
bash scripts/install-app.sh
```

설치 스크립트는 실행 중인 sshot이 있으면 중단하고 새 번들의 서명을 검증한 뒤 `/Applications/sshot.app`에 설치·실행합니다. 기존 앱은 `/Applications/.sshot-install.…/previous-sshot.app`에 보관하며 정확한 경로를 출력합니다. 필요하면 앱 종료 후 해당 백업을 복원할 수 있습니다. 설치된 앱 실행은 `open /Applications/sshot.app`입니다.

`dist/sshot.app`은 기본적으로 ad-hoc 서명된 로컬 실행 앱입니다. 빌드 중에는 실행 중인 sshot을 먼저 종료하세요. 바이너리를 교체하면 실행 프로세스나 화면 기록 권한에 영향을 줄 수 있습니다. `.build/`와 `dist/`는 Git에 포함하지 않습니다.

평상시에는 `/Applications/sshot.app` 한 경로에서 실행하세요. 개발 빌드의 ad-hoc 서명은 코드 변경에 따라 권한 식별이 달라질 수 있습니다. 동일한 Developer ID·앱 식별자로 서명한 배포본은 이 문제를 줄이지만 macOS가 다시 권한을 요청하지 않는다고 보장하지는 않습니다.

## 목표 사용 흐름

1. 설정 가능한 전역 단축키로 캡처 UI를 엽니다.
2. 고정 사각형 마스크를 조정해 캡처하거나, 드래그로 영역을 즉시 선택합니다.
3. 캡처가 성공하면 이미지가 클립보드에 들어갑니다.
4. 원하는 앱으로 돌아가 `⌘V`로 붙여 넣습니다.

macOS 기본 캡처의 썸네일에서 별도로 복사하는 단계를 없애는 것이 핵심입니다. 자동 붙여 넣기나 다른 앱에 키 입력을 보내는 기능은 MVP 범위에 포함하지 않습니다.

macOS도 Control을 추가한 캡처 단축키나 캡처 저장 위치 설정으로 클립보드 복사를 지원합니다([Apple 안내](https://support.apple.com/guide/mac-help/take-a-screenshot-mh26782/mac)). sshot은 고정 영역 재사용과 두 선택 모드를 제공하고, 성공한 캡처를 항상 즉시 복사하는 일관된 흐름을 목표로 합니다.

첫 실행의 안내 창에서 화면 기록 권한을 요청한 뒤 시스템 설정에서 sshot을 허용하세요. 시스템에서 요청하면 앱을 다시 실행합니다. 권한 거부 상태에서는 캡처하지 않습니다. 접근성 권한은 제품 사용에 요구하지 않습니다.

앱은 켜져 있는데 캡처가 안 되면 권한 안내에서 현재 상태를 다시 확인하세요. 앱 실행과 캡처 권한은 별개입니다. 안내에 표시된 실행 앱 경로를 확인하고 Finder에서 해당 앱을 연 뒤, 권한 요청 → 시스템 설정의 화면 기록 허용 → 다시 확인 순서로 진행합니다. 필요하면 sshot을 종료하고 같은 경로에서 재실행하세요. 설정 스위치가 켜져 있어도 다른 빌드의 허용일 수 있습니다. 접근성·전체 디스크 접근 권한은 필요하지 않으며 TCC 초기화를 자동 실행하지 않습니다.

기본 단축키는 `⌃⇧⌘5`입니다. 안내 창의 ‘단축키 변경’으로 바꿀 수 있으며 이미 등록된 키는 오류를 안내합니다. 마지막 선택 모드를 단축키로 다시 엽니다. 앱을 처음 직접 실행해야 하고, 종료하면 단축키도 작동하지 않습니다. 로그인 자동 시작은 사용자가 설정에서 켤 수 있으며 서명·설치 환경에 따라 시스템 승인이 필요합니다.

고정 영역에서는 사각형 내부를 드래그해 이동하고 8개 핸들로 크기를 조절합니다. 캡처 버튼 또는 Enter로 확정합니다. 방향키로 이동, Shift+방향키로 크게 이동, Option+방향키로 오른쪽 위 모서리를 조절합니다. 즉시 드래그 모드에서는 선택 후 마우스를 놓으면 캡처합니다. Escape 또는 취소 버튼으로 취소하고 Tab으로 모드를 전환합니다.

선택을 시작한 화면 내부에서 캡처합니다. 각 모니터를 독립적으로 선택할 수 있지만 여러 화면을 하나로 합치지는 않습니다. 화면 구성 변경과 잠자기 진입 시 진행 중인 캡처를 취소합니다. 고정 영역은 같은 실행 세션에서 재사용하며, 모드·단축키만 설정으로 저장합니다.

성공하면 복사 완료 안내가 표시됩니다. 이미지 붙여 넣기를 지원하는 앱에서 직접 `⌘V`를 누르세요. Preview는 `⌘N`으로 클립보드 이미지를 새 문서로 열 수 있습니다. 일반 텍스트 입력란은 이미지 붙여 넣기를 지원하지 않을 수 있습니다.

## 검증과 배포

```sh
swift test
bash scripts/build-app.sh
qa_output_dir=$(mktemp -d)
open -n -W -o "$qa_output_dir/self-test.json" dist/sshot.app --args --self-test
sed -n '1,200p' "$qa_output_dir/self-test.json"
```

`--self-test`는 별도 fixture 앱의 합성 색상 화면을 실제 캡처하고, 자체 UI 제외·픽셀 크기·PNG/TIFF 디코딩을 검사합니다. 일반 클립보드 대신 unique named pasteboard를 사용합니다. 결과는 메타데이터 JSON의 PASS/FAIL/SKIP으로 판단하며 SKIP은 통과가 아닙니다. `open` 종료 코드 0은 harness PASS를 뜻하지 않습니다. 실제 이미지를 파일·로그로 남기지 않습니다.

이 명령은 `dist/sshot.app` 옆의 `dist/sshot-fixture.app`을 사용하는 개발용 harness입니다. fixture는 일반 사용에 필요한 앱이 아니며 `/Applications` 제품 설치에 함께 복사하지 않습니다. 설치된 앱에 `--self-test`만 실행하면 fixture 위치가 맞지 않을 수 있으므로 위 개발용 경로로 실행하세요. 번들 내부 binary를 터미널에서 직접 실행하면 화면 기록 권한이 터미널에 귀속될 수 있어 LaunchServices의 `open`으로 실행합니다.

## 업데이트

Sparkle 2.10.0 기반 업데이트를 제공합니다. 자동 확인은 기본적으로 꺼져 있고 설정의 ‘자동으로 업데이트 확인’으로 켤 수 있습니다. 설치 전에는 확인 창이 표시됩니다. 현재 0.3.0(build 4)은 GitHub feed URL과 실제 공개키를 포함하며 로컬 설치·설정 UI를 확인했습니다. 실제 업그레이드는 공개 appcast/archive와 Developer ID 서명·공증 배포가 준비되어야 합니다. 공개 release asset과 실제 버전 업그레이드 성공은 아직 없습니다. 캡처 이미지는 업데이트 서버로 전송하지 않습니다.

기본 feed와 공개키는 resources/Info.plist에 있습니다. 변경할 경우 `SSHOT_UPDATE_FEED_URL`(인증정보 없는 HTTPS), `SSHOT_UPDATE_PUBLIC_KEY`(32-byte base64 공개키)를 함께 빌드 환경에 넣습니다. 버전은 `SSHOT_VERSION`, 증가하는 빌드 번호는 `SSHOT_BUILD_NUMBER`로 지정합니다(기본 0.3.0 / 4). 일부 설정만 있거나 잘못된 URL·키이면 빌드를 중단합니다. 서명된 feed도 요구합니다.

기존 Keychain 서명 키가 준비된 환경에서 다음 명령은 서명·공증 후 `dist/update-버전.…`에 archive와 appcast를 준비합니다. 게시나 키 생성은 수행하지 않습니다. 생성된 파일을 설정한 HTTPS 위치에 게시하는 작업과 실제 업데이트 QA는 별도입니다.

```sh
SSHOT_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
SSHOT_NOTARY_PROFILE='your-existing-profile' \
SSHOT_UPDATE_FEED_URL='https://github.com/kyungseok-lee/sshot/releases/latest/download/appcast.xml' \
SSHOT_UPDATE_PUBLIC_KEY='your-base64-public-key' \
SSHOT_UPDATE_DOWNLOAD_URL_PREFIX='https://github.com/kyungseok-lee/sshot/releases/download/v0.3.0/' \
SSHOT_UPDATE_KEY_ACCOUNT='sshot' \
bash scripts/prepare-update.sh
```

GitHub Releases를 공개 배포 저장소로 사용하므로 별도 서버나 GitHub Pages는 필요하지 않습니다. 위 feed는 가장 최근 공개 release의 `appcast.xml`, archive는 버전별 tag의 파일을 가리킵니다. 실제 release asset이 게시되기 전에는 URL이 동작한다고 주장하지 않습니다. 키 예시는 실제 값이 아니며 개인 키·인증정보를 저장소에 넣지 마세요. 로컬 ad-hoc 번들은 Sparkle framework를 로드하기 위해 개발용 library-validation 예외를 적용하며 Developer ID 배포본에는 해당 예외를 넣지 않습니다.

Ed25519 키는 업데이트 archive의 진위를 검증하는 키입니다. macOS 앱의 Developer ID 서명·공증을 대신하거나 화면 기록 권한 문제를 해결하지 않습니다. 개인 키는 Keychain에 두고 공개키만 앱에 포함합니다. 공개 release에는 production 서명·공증·QA를 통과한 artifact만 게시합니다. GitHub 배포 운영 절차는 [업데이트 운영](docs/sshot/update-operations.md)을 따릅니다.

GitHub용 준비는 `bash scripts/prepare-github-release.sh`, 게시 준비는 `bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY`입니다. publisher는 검증한 원격 tag와 production artifact를 요구하며 기본 draft로 만듭니다. `--publish`는 검증을 통과한 release를 명시적으로 공개할 때만 사용합니다.

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
