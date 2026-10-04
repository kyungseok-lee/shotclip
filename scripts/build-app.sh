#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
release_mode="${SHOTCLIP_RELEASE_MODE:-development}"
signing_identity="${SHOTCLIP_SIGN_IDENTITY:--}"
if [[ "$release_mode" != development ]]; then
    release_configuration
    release_reviewed_head >/dev/null
elif [[ "$signing_identity" != '-' ]]; then
    release_fail 'Use explicit developer-id release mode for Developer ID signing.'
fi
version="${SHOTCLIP_VERSION:-0.4.0}"
build_number="${SHOTCLIP_BUILD_NUMBER:-5}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && "$build_number" =~ ^[1-9][0-9]*$ ]] || release_fail 'Version must be N.N.N; build number must be a positive integer.'
if pgrep -x shotclip >/dev/null; then release_fail 'Quit ShotClip before rebuilding its app bundle.'; fi
swift build -c release
binary_dir="$(swift build -c release --show-bin-path)"
framework="$(pwd)/.build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
[[ -d "$framework" ]] || { printf '%s\n' 'Resolved Sparkle framework missing.' >&2; exit 1; }
mkdir -p dist
staging="$(mktemp -d "$(pwd)/dist/build.XXXXXX")"
bundle="$staging/ShotClip.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources" "$bundle/Contents/Frameworks"
cp "$binary_dir/shotclip" "$bundle/Contents/MacOS/shotclip"
cp resources/Info.plist "$bundle/Contents/Info.plist"
resource_bundle="$binary_dir/shotclip_shotclip.bundle"
release_resource_directory "$resource_bundle" >/dev/null || release_fail 'SwiftPM English/Korean resource bundle is missing or unsafe.'
# App localizer resolves this installed location before Bundle.module's build fallback.
ditto "$resource_bundle" "$bundle/Contents/Resources/shotclip_shotclip.bundle"
swift scripts/generate-app-icon.swift "$staging/AppIcon.iconset"
iconutil -c icns "$staging/AppIcon.iconset" -o "$bundle/Contents/Resources/AppIcon.icns"
ditto "$framework" "$bundle/Contents/Frameworks/Sparkle.framework"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :SHOTCLIPSourceCommit string $(git rev-parse HEAD)" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :SHOTCLIPReleaseMode string $release_mode" "$bundle/Contents/Info.plist"
swift scripts/configure-updates.swift "$bundle/Contents/Info.plist"
sign_options=(--force --sign "$signing_identity" --options runtime)
if [[ "$signing_identity" != "-" ]]; then sign_options+=(--timestamp); fi
embedded="$bundle/Contents/Frameworks/Sparkle.framework/Versions/B"
for component in "$embedded/XPCServices/Downloader.xpc" "$embedded/XPCServices/Installer.xpc" "$embedded/Updater.app" "$embedded/Autoupdate"; do
    if [[ -e "$component" ]]; then codesign "${sign_options[@]}" --preserve-metadata=entitlements "$component"; fi
done
codesign "${sign_options[@]}" "$bundle/Contents/Frameworks/Sparkle.framework"
if [[ "$signing_identity" == "-" ]]; then
    codesign "${sign_options[@]}" --entitlements resources/local-entitlements.plist "$bundle"
else
    codesign "${sign_options[@]}" "$bundle"
fi
codesign --verify --deep --strict "$bundle"
if pgrep -x shotclip >/dev/null; then release_fail 'ShotClip started during the build; refusing to replace a potentially running bundle.'; fi
[[ ! -L dist/ShotClip.app ]] || release_fail 'dist/ShotClip.app is a symlink; refusing replacement.'
if [[ -e dist/ShotClip.app ]]; then mv dist/ShotClip.app "$staging/previous-ShotClip.app"; fi
if ! mv "$bundle" dist/ShotClip.app; then
    if [[ -d "$staging/previous-ShotClip.app" && ! -e dist/ShotClip.app ]]; then mv "$staging/previous-ShotClip.app" dist/ShotClip.app; fi
    exit 1
fi
fixture="$staging/shotclip-fixture.app"
mkdir -p "$fixture/Contents/MacOS"
cp "$binary_dir/shotclip-fixture" "$fixture/Contents/MacOS/shotclip-fixture"
cp resources/Info.plist "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.shotclip.fixture' "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable shotclip-fixture' "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleName ShotClip Fixture' "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName ShotClip Fixture' "$fixture/Contents/Info.plist"
codesign --force --sign - "$fixture"
codesign --verify --deep --strict "$fixture"
if pgrep -x shotclip-fixture >/dev/null; then release_fail 'Quit shotclip-fixture before replacing the fixture bundle.'; fi
[[ ! -L dist/shotclip-fixture.app ]] || release_fail 'Fixture target is a symlink.'
if [[ -e dist/shotclip-fixture.app ]]; then mv dist/shotclip-fixture.app "$staging/previous-shotclip-fixture.app"; fi
mv "$fixture" dist/shotclip-fixture.app
printf '%s\n' "$(pwd)/dist/ShotClip.app"
