#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
release_configuration
source_commit="$(release_reviewed_head)"
if [[ "$SHOTCLIP_RELEASE_MODE" == developer-id ]]; then
    : "${SHOTCLIP_NOTARY_PROFILE:?Existing notarytool Keychain profile is required for Developer ID mode}"
fi
tools="$(pwd)/.build/production/artifacts/sparkle/Sparkle/bin"
[[ -x "$tools/generate_keys" && -x "$tools/generate_appcast" ]] || release_fail 'Resolve Sparkle 2.10.0 with swift package --scratch-path .build/production resolve first.'
# INTENTIONAL LEGACY COMPATIBILITY: existing private key is stored under sshot.
# Lookup-only -p must never be omitted. Do not export, rotate, delete or recreate it.
account="${SHOTCLIP_UPDATE_KEY_ACCOUNT:-sshot}"
existing_public_key="$("$tools/generate_keys" --account "$account" -p)"
[[ "$existing_public_key" == "$SHOTCLIP_CANONICAL_KEY" ]] || release_fail 'Existing Keychain key differs from established public key; stop without changing it.'
if [[ "$SHOTCLIP_RELEASE_MODE" == ad-hoc ]]; then
    bash scripts/build-app.sh
else
    bash scripts/notarize-app.sh
fi
[[ "$(release_reviewed_head)" == "$source_commit" ]] || release_fail 'Reviewed source changed during preparation.'
release_verify_bundle "dist/$SHOTCLIP_APP_BUNDLE_NAME" "$source_commit"
output="$(mktemp -d "$(pwd)/dist/update-$SHOTCLIP_VERSION.XXXXXX")"
ditto -c -k --sequesterRsrc --keepParent "dist/$SHOTCLIP_APP_BUNDLE_NAME" "$output/shotclip-$SHOTCLIP_VERSION.zip"
bash scripts/release-content.sh "$output"
"$tools/generate_appcast" --account "$account" --download-url-prefix "$SHOTCLIP_UPDATE_DOWNLOAD_URL_PREFIX" "$output"
swift scripts/release-manifest.swift create "$output" "$source_commit" "$SHOTCLIP_VERSION" "$SHOTCLIP_CANONICAL_KEY"
(cd "$output" && shasum -a 256 "shotclip-$SHOTCLIP_VERSION.zip" appcast.xml release-manifest.json RELEASE-NOTES.md README.txt > SHA256SUMS)
swift scripts/release-manifest.swift verify "$output" "$source_commit" "$SHOTCLIP_VERSION" "$SHOTCLIP_CANONICAL_KEY" >/dev/null
[[ "$(release_reviewed_head)" == "$source_commit" ]] || release_fail 'Reviewed source changed during preparation.'
printf 'Prepared %s release in %s\nNo publishing was performed.\n' "$SHOTCLIP_RELEASE_MODE" "$output"
