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

- Capture Area and Fixed Region appear when Screen Recording is ready; unavailable access offers an explicit Enable Screen Recording action.
- Roboto and Noto Sans KR provide consistent English/Korean typography, complete multiline spacing and square settings navigation highlights. Existing square app artwork is preserved.
- Update dialogs size to their visible content while retaining progress, replies and live English/Korean text.
- The compact capture toolbar follows Apple's screenshot layout with close, capture modes and Capture.
- After a successful copy, a lower-right thumbnail opens the original at Fit or 100%. Save exports the original PNG only to a destination you choose; cancel, close and dismissal preserve the clipboard.
- No automatic capture storage, capture history or upload is added. Both complete font licenses are included.
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

- 화면 기록이 준비된 경우 영역 캡처·고정 영역을 표시하고, 권한이 없으면 명시적인 화면 기록 허용 동작을 제공합니다.
- Roboto와 Noto Sans KR로 영어·한국어 글꼴과 여러 줄 여백을 통일하고 설정 버튼/선택 표시를 정사각형으로 맞췄습니다. 기존 정사각형 앱 아이콘은 보존했습니다.
- 업데이트 창은 표시 내용에 맞춰 크기를 조절하며 진행률·응답과 즉시 영어/한국어 전환을 유지합니다.
- Apple 스크린샷 구성을 참고한 작은 캡처 도구막대에 닫기·캡처 모드·캡처 동작을 배치했습니다.
- 복사 성공 뒤 우측 하단 썸네일을 클릭하면 원본을 Fit 또는100%로 봅니다. 저장은 사용자가 선택한 위치에 원본 PNG만 내보내며 취소·닫기·썸네일 해제는 클립보드를 유지합니다.
- 자동 캡처 저장·이력·업로드는 추가하지 않았고 두 글꼴의 전체 라이선스를 포함합니다.
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
