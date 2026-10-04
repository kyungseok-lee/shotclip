#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# == 1 && -d "$1" && ! -L "$1" ]] || { printf '%s\n' 'Usage: release-content.sh EXISTING_PREPARED_DIRECTORY' >&2; exit 1; }
source scripts/release-common.sh
release_configuration
architecture="$(lipo -archs "dist/$SHOTCLIP_APP_BUNDLE_NAME/Contents/MacOS/shotclip")"
[[ "$architecture" == arm64 || "$architecture" == x86_64 || "$architecture" == 'x86_64 arm64' || "$architecture" == 'arm64 x86_64' ]] || release_fail 'Unexpected release executable architecture.'
if [[ "$SHOTCLIP_RELEASE_MODE" == ad-hoc ]]; then
    status='Ad-hoc signed; NOT notarized. No Apple Developer ID certificate is used.'
    korean='Ad-hoc 서명이며 공증되지 않았습니다. Apple Developer ID 인증서를 사용하지 않습니다.'
else
    status='Developer ID distribution; publishing requires successful notarization and Gatekeeper assessment.'
    korean='Developer ID 배포이며 게시 전에 공증과 Gatekeeper 검증을 통과해야 합니다.'
fi
cat > "$1/RELEASE-NOTES.md" <<EOF
# Shot Clip $SHOTCLIP_VERSION (build $SHOTCLIP_BUILD_NUMBER)

Shot Clip copies a selected screen region to the clipboard on macOS 14 or later.
English is the default language; Korean is also included.
Archive architecture: $architecture. Intel and macOS 14 runtime behavior are unverified.
Distribution: $status

## What's new

- General, Access and Updates settings now use an icon sidebar, grouped rows and native switches and popup controls.
- English and Korean apply immediately to settings, menus, capture controls and app-owned update dialogs without restarting Shot Clip.
- Capture, Settings and Quit shortcuts share the native menu key-equivalent column. The configured shortcut follows the remembered capture mode and current keyboard layout.
- Existing capture behavior, preferences, bundle identifier and signed-update trust are retained; automatic checks remain opt-in.

Quit the previous app before moving Shot Clip.app to Applications.
The canonical folder changes from ShotClip.app to Shot Clip.app, while dev.shotclip.app and executable shotclip stay unchanged.
Install manually once to adopt that folder name; stock Sparkle may update the old host folder in place.
Historical Sshot used another bundle identifier and also requires manual installation.
Screen Recording permission may need to be granted again after an ad-hoc replacement; TCC is not reset.
Sparkle Ed25519 signatures authenticate updates; they do not grant macOS trust or permissions.
On first launch, follow macOS Privacy & Security guidance if Gatekeeper blocks the app.
Do not remove quarantine attributes or disable Gatekeeper.

## 한국어

Shot Clip은 macOS 14 이상에서 선택 영역을 캡처하여 클립보드에 복사합니다.
영어가 기본이며 한국어를 함께 제공합니다.
아카이브 아키텍처: $architecture. Intel 및 macOS 14 실제 동작은 미검증입니다.
배포: $korean

### 변경 사항

- 일반·권한·업데이트 설정에 아이콘 사이드바, 그룹 행, native 스위치와 팝업을 적용했습니다.
- 앱을 재시작하지 않고 영어·한국어가 설정, 메뉴, 캡처 제어 및 앱의 업데이트 안내에 바로 적용됩니다.
- 캡처·설정·종료 단축키를 native 메뉴 키 표시 열로 통일했습니다. 저장한 단축키는 마지막 캡처 모드와 현재 키보드 배열을 따릅니다.
- 기존 캡처 동작·설정·번들 식별자와 서명 업데이트 신뢰를 유지하며 자동 확인은 사용자가 선택하여 켭니다.

이전 앱을 종료한 뒤 Shot Clip.app을 응용 프로그램 폴더로 이동하세요.
폴더 이름은 ShotClip.app에서 Shot Clip.app으로 바뀌고 dev.shotclip.app과 실행 파일 shotclip은 유지합니다.
새 폴더 이름을 적용하려면 한 번 수동 설치하세요. 기본 Sparkle는 기존 폴더 위치에서 업데이트할 수 있습니다.
과거 Sshot은 다른 번들 식별자이므로 수동 설치가 필요합니다.
ad-hoc 교체 후 화면 기록 권한을 다시 허용해야 할 수 있으며 TCC는 초기화하지 않습니다.
Sparkle Ed25519 서명은 업데이트 출처를 검증하며 macOS 신뢰나 권한을 부여하지 않습니다.
최초 실행이 차단되면 macOS 개인정보 보호 및 보안 안내를 따르세요.
격리 속성을 제거하거나 Gatekeeper를 비활성화하지 마세요.
EOF
cp "$1/RELEASE-NOTES.md" "$1/README.txt"
