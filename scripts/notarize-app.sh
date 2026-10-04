#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
release_configuration
[[ "$SHOTCLIP_RELEASE_MODE" == developer-id ]] || release_fail 'Notarization is exclusive to the explicit Developer ID production path.'
release_reviewed_head >/dev/null
: "${SHOTCLIP_NOTARY_PROFILE:?Set SHOTCLIP_NOTARY_PROFILE to an existing notarytool Keychain profile}"
bash scripts/build-app.sh
bundle="$(pwd)/dist/$SHOTCLIP_APP_BUNDLE_NAME"
signature="$(codesign -dv "$bundle" 2>&1)"
[[ "$signature" == *'Authority=Developer ID Application:'* && "$signature" == *"TeamIdentifier=$SHOTCLIP_RELEASE_TEAM_ID"* ]] || release_fail 'App is not signed with the expected Developer ID identity/team.'
archive="$(pwd)/dist/shotclip-notarization.zip"
ditto -c -k --keepParent "$bundle" "$archive"
xcrun notarytool submit "$archive" --keychain-profile "$SHOTCLIP_NOTARY_PROFILE" --wait
xcrun stapler staple "$bundle"
xcrun stapler validate "$bundle"
codesign --verify --deep --strict "$bundle"
spctl --assess --type execute --verbose "$bundle"
ditto -c -k --keepParent "$bundle" "$(pwd)/dist/shotclip-release.zip"
