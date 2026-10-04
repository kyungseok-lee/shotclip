#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -z "$(git status --porcelain)" ]] || { printf '%s\n' 'Commit reviewed source before preparing a production artifact.' >&2; exit 1; }
source_commit="$(git rev-parse HEAD)"
: "${SSHOT_SIGN_IDENTITY:?Developer ID Application signing identity required}"
: "${SSHOT_NOTARY_PROFILE:?Existing notarytool keychain profile required}"
: "${SSHOT_UPDATE_FEED_URL:?HTTPS appcast URL required}"
: "${SSHOT_UPDATE_PUBLIC_KEY:?Sparkle public key required}"
: "${SSHOT_UPDATE_DOWNLOAD_URL_PREFIX:?HTTPS download directory URL required}"
[[ "$SSHOT_SIGN_IDENTITY" == 'Developer ID Application:'* && "$SSHOT_UPDATE_DOWNLOAD_URL_PREFIX" == https://* ]] || { printf '%s\n' 'Developer ID signing and HTTPS download URL are required.' >&2; exit 1; }
account="${SSHOT_UPDATE_KEY_ACCOUNT:-sshot}"
tools="$(pwd)/.build/artifacts/sparkle/Sparkle/bin"
[[ -x "$tools/generate_keys" ]] || { printf '%s\n' 'Run swift package resolve first.' >&2; exit 1; }
existing_public_key="$("$tools/generate_keys" --account "$account" -p)"
[[ "$existing_public_key" == "$SSHOT_UPDATE_PUBLIC_KEY" ]] || { printf '%s\n' 'Existing Keychain public key differs from configured public key.' >&2; exit 1; }
bash scripts/notarize-app.sh
[[ "$(git rev-parse HEAD)" == "$source_commit" && -z "$(git status --porcelain)" ]] || { printf '%s\n' 'Source changed during release preparation.' >&2; exit 1; }
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' dist/sshot.app/Contents/Info.plist)"
output="$(mktemp -d "$(pwd)/dist/update-$version.XXXXXX")"
ditto -c -k --sequesterRsrc --keepParent dist/sshot.app "$output/sshot-$version.zip"
"$tools/generate_appcast" --account "$account" --download-url-prefix "$SSHOT_UPDATE_DOWNLOAD_URL_PREFIX" "$output"
swift scripts/release-manifest.swift create "$output" "$source_commit" "$version" "$SSHOT_UPDATE_PUBLIC_KEY"
printf 'Prepared signed update in %s\nUpload the archive and generated appcast to the configured HTTPS locations. No publishing was performed.\n' "$output"
