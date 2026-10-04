#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${SSHOT_NOTARY_PROFILE:?Set SSHOT_NOTARY_PROFILE to an existing notarytool keychain profile}"
: "${SSHOT_SIGN_IDENTITY:?Set SSHOT_SIGN_IDENTITY to a Developer ID Application identity}"
if [[ "$SSHOT_SIGN_IDENTITY" == "-" ]]; then
    printf '%s\n' 'Developer ID signing is required for notarization.' >&2
    exit 1
fi
bash scripts/build-app.sh
bundle="$(pwd)/dist/sshot.app"
archive="$(pwd)/dist/sshot-notarization.zip"
ditto -c -k --keepParent "$bundle" "$archive"
xcrun notarytool submit "$archive" --keychain-profile "$SSHOT_NOTARY_PROFILE" --wait
xcrun stapler staple "$bundle"
xcrun stapler validate "$bundle"
codesign --verify --deep --strict "$bundle"
spctl --assess --type execute --verbose "$bundle"
ditto -c -k --keepParent "$bundle" "$(pwd)/dist/sshot-release.zip"
