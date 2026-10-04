#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# == 1 && -d "$1" && ! -L "$1" ]] || { printf '%s\n' 'Usage: release-content.sh EXISTING_PREPARED_DIRECTORY' >&2; exit 1; }
source scripts/release-common.sh
release_configuration
architecture="$(lipo -archs dist/ShotClip.app/Contents/MacOS/shotclip)"
[[ "$architecture" == arm64 || "$architecture" == x86_64 || "$architecture" == 'x86_64 arm64' || "$architecture" == 'arm64 x86_64' ]] || release_fail 'Unexpected release executable architecture.'
if [[ "$SHOTCLIP_RELEASE_MODE" == ad-hoc ]]; then
    status='Ad-hoc signed; NOT notarized. No Apple Developer ID certificate is used.'
    korean='Ad-hoc 서명이며 공증되지 않았습니다. Apple Developer ID 인증서를 사용하지 않습니다.'
else
    status='Developer ID distribution; publishing requires successful notarization and Gatekeeper assessment.'
    korean='Developer ID 배포이며 게시 전에 공증과 Gatekeeper 검증을 통과해야 합니다.'
fi
cat > "$1/RELEASE-NOTES.md" <<EOF
# ShotClip $SHOTCLIP_VERSION (build $SHOTCLIP_BUILD_NUMBER)

ShotClip copies a selected screen region to the clipboard on macOS 14 or later.
English is the default language; Korean is also included.
Archive architecture: $architecture. Intel and macOS 14 runtime behavior are unverified.
Distribution: $status

## What's new

- A refreshed app icon pairs mint capture corners with an ivory clipboard and an original illustrated image.
- New synthetic brand artwork presents the capture-to-clipboard workflow in the English and Korean project documentation.
- The ShotClip bundle identity, preferences, signed-update trust and English/Korean support remain compatible with ShotClip 0.4.0.

The app name, executable and bundle identifier changed from the legacy app.
Quit the previous app before moving ShotClip.app to Applications.
Screen Recording permission may need to be granted again after migration or an ad-hoc update.
The legacy bundle identifier cannot migrate through Sparkle automatically; install ShotClip manually once.
Sparkle Ed25519 signatures authenticate updates; they do not grant macOS trust or permissions.
On first launch, follow macOS Privacy & Security guidance if Gatekeeper blocks the app.
Do not remove quarantine attributes or disable Gatekeeper.

## 한국어

ShotClip은 macOS 14 이상에서 선택 영역을 캡처하여 클립보드에 복사합니다.
영어가 기본이며 한국어를 함께 제공합니다.
아카이브 아키텍처: $architecture. Intel 및 macOS 14 실제 동작은 미검증입니다.
배포: $korean

### 변경 사항

- 민트색 캡처 모서리, 아이보리색 클립보드와 독자적인 이미지 일러스트를 결합한 새 앱 아이콘을 제공합니다.
- 실제 화면을 사용하지 않은 새 브랜드 이미지로 영어·한국어 프로젝트 문서에 캡처→클립보드 흐름을 표현합니다.
- ShotClip 0.4.0과 번들 식별자, 설정, 서명 업데이트 신뢰 및 영어·한국어 지원을 유지합니다.

앱 이름, 실행 파일 및 번들 식별자가 이전 앱에서 변경되었습니다.
이전 앱을 종료한 뒤 ShotClip.app을 응용 프로그램 폴더로 이동하세요.
이전 앱에서 전환하거나 ad-hoc 앱을 업데이트하면 화면 기록 권한을 다시 허용해야 할 수 있습니다.
이전 번들 식별자는 Sparkle로 자동 이전되지 않으므로 ShotClip을 한 번 수동으로 설치하세요.
Sparkle Ed25519 서명은 업데이트 출처를 검증하며 macOS 신뢰나 권한을 부여하지 않습니다.
최초 실행이 차단되면 macOS 개인정보 보호 및 보안 안내를 따르세요.
격리 속성을 제거하거나 Gatekeeper를 비활성화하지 마세요.
EOF
cp "$1/RELEASE-NOTES.md" "$1/README.txt"
