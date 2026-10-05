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

- Invalidly signed update feeds remain rejected without an elapsed-time recovery fallback. A later valid signed feed remains eligible; Ed25519 archive authentication and the existing update key stay intact.
- The production app excludes development QA routes, the capture test helper, self-test and UI-preview code and rejects retired QA arguments before application startup. Synthetic QA remains available only in a separate development build.
- Production packaging removes private developer-home and absolute source/build paths and checks the complete app, bundled code/resources, symlinks and Mach-O paths before signing/preparation.
- English/Korean settings retain the same window, navigation, rows, form-control geometry and reading position at the same size/state, with readable Roboto/Noto Sans KR and complete bilingual text reservations. State changes or resize can expand the shared layout for long diagnostics.
- Existing capture menus, native controls, post-copy thumbnail/original preview and explicit PNG saving remain. No automatic capture storage, history or upload is added; both complete font licenses are included.
- Existing preferences, dev.shotclip.app identity and signed-update trust are retained. Automatic checks remain opt-in; an existing enabled preference is preserved.

The current canonical Shot Clip.app installation can update from 0.8.0 to this release through Sparkle.
For manual installation, quit the previous app before moving Shot Clip.app to Applications.
Only historical ShotClip.app or Sshot installations need the earlier folder/identity migration guidance:
install manually once to adopt Shot Clip.app; stock Sparkle may retain an older host folder.
Historical Sshot used another bundle identifier and requires manual installation and a fresh permission grant.
Screen Recording permission may need to be granted again after an ad-hoc replacement; TCC is not reset.
Sparkle Ed25519 signatures authenticate updates; they do not grant macOS trust or permissions.
Ad-hoc Sparkle compatibility retains the disclosed library-validation exception.
On first launch, follow macOS Privacy & Security guidance if Gatekeeper blocks the app.
Do not remove quarantine attributes or disable Gatekeeper.

## 한국어

Shot Clip은 macOS 14 이상에서 선택 영역을 캡처하여 클립보드에 복사합니다.
영어가 기본이며 한국어를 함께 제공합니다.
아카이브 아키텍처: $architecture. Intel 및 macOS 14 실제 동작은 미검증입니다.
배포: $korean

### 변경 사항

- 잘못 서명된 update feed는 시간이 지나도 수용하지 않습니다. 이후 유효하게 서명된 feed는 허용하며 Ed25519 archive 인증과 기존 업데이트 키를 유지합니다.
- 공개 앱에서 개발 QA 경로·capture test helper·self-test·UI-preview 코드를 제외하고 과거 QA 인자를 정상 시작 전에 거부합니다. 합성 QA는 별도 개발 빌드에만 남깁니다.
- production 패키징에서 비공개 개발자 홈과 절대 소스/빌드 경로를 제거하고 서명/준비 전에 앱 전체·번들 코드/자료·symlink·Mach-O 경로를 검사합니다.
- 같은 크기/상태의 한영 설정 창·탐색·행·폼 컨트롤·읽던 위치, Roboto/Noto Sans KR의 읽기 쉬운 크기와 전체 두 언어 높이 예약을 유지합니다. 긴 진단의 공통 배치는 상태 변경/resize 때 커질 수 있습니다.
- 기존 캡처 메뉴·native 컨트롤·복사 후 썸네일/원본 보기·명시적 PNG 저장을 유지합니다. 자동 캡처 저장·이력·업로드는 추가하지 않으며 두 글꼴의 전체 라이선스를 포함합니다.
- 기존 설정·dev.shotclip.app 식별자·서명 업데이트 신뢰를 유지합니다. 자동 확인은 선택 사항이고 기존에 켠 설정은 보존합니다.

현재 정식 Shot Clip.app 설치는 Sparkle로 0.8.0에서 이 버전으로 업데이트할 수 있습니다.
수동 설치라면 이전 앱을 종료한 뒤 Shot Clip.app을 응용 프로그램 폴더로 이동하세요.
과거 ShotClip.app 또는 Sshot 설치에만 기존 폴더/식별자 전환 안내가 적용됩니다.
Shot Clip.app 폴더 이름을 적용하려면 한 번 수동 설치하며 기본 Sparkle는 과거 host 폴더를 유지할 수 있습니다.
과거 Sshot은 다른 번들 식별자여서 수동 설치와 새 권한 허용이 필요합니다.
ad-hoc 교체 후 화면 기록 권한을 다시 허용해야 할 수 있으며 TCC는 초기화하지 않습니다.
Sparkle Ed25519 서명은 업데이트 출처를 검증하며 macOS 신뢰나 권한을 부여하지 않습니다.
Ad-hoc Sparkle 호환성은 기존에 공개한 library-validation 예외를 유지합니다.
최초 실행이 차단되면 macOS 개인정보 보호 및 보안 안내를 따르세요.
격리 속성을 제거하거나 Gatekeeper를 비활성화하지 마세요.
EOF
cp "$1/RELEASE-NOTES.md" "$1/README.txt"
