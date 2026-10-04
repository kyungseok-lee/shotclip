#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
binary_dir="$(swift build -c release --show-bin-path)"
framework="$(pwd)/.build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
[[ -d "$framework" ]] || { printf '%s\n' 'Resolved Sparkle framework missing.' >&2; exit 1; }
mkdir -p dist
staging="$(mktemp -d "$(pwd)/dist/build.XXXXXX")"
bundle="$staging/sshot.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources" "$bundle/Contents/Frameworks"
cp "$binary_dir/sshot" "$bundle/Contents/MacOS/sshot"
cp resources/Info.plist "$bundle/Contents/Info.plist"
ditto "$framework" "$bundle/Contents/Frameworks/Sparkle.framework"
version="${SSHOT_VERSION:-0.2.1}"
build_number="${SSHOT_BUILD_NUMBER:-3}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && "$build_number" =~ ^[0-9]+$ ]] || { printf '%s\n' 'Version must be N.N.N; build number must be an integer.' >&2; exit 1; }
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :SSHOTSourceCommit string $(git rev-parse HEAD)" "$bundle/Contents/Info.plist"
swift scripts/configure-updates.swift "$bundle/Contents/Info.plist"
signing_identity="${SSHOT_SIGN_IDENTITY:--}"
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
if [[ -e dist/sshot.app ]]; then mv dist/sshot.app "$staging/previous-sshot.app"; fi
mv "$bundle" dist/sshot.app
fixture="$(pwd)/dist/sshot-fixture.app"
mkdir -p "$fixture/Contents/MacOS"
cp "$binary_dir/sshot-fixture" "$fixture/Contents/MacOS/sshot-fixture"
cp resources/Info.plist "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.sshot.fixture' "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable sshot-fixture' "$fixture/Contents/Info.plist"
codesign --force --sign - "$fixture"
printf '%s\n' "$(pwd)/dist/sshot.app"
