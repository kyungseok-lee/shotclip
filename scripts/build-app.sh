#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
binary_dir="$(swift build -c release --show-bin-path)"
bundle="$(pwd)/dist/sshot.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources"
cp "$binary_dir/sshot" "$bundle/Contents/MacOS/sshot"
cp resources/Info.plist "$bundle/Contents/Info.plist"
signing_identity="${SSHOT_SIGN_IDENTITY:--}"
if [[ "$signing_identity" == "-" ]]; then
    codesign --force --sign - --options runtime "$bundle"
else
    codesign --force --sign "$signing_identity" --options runtime --timestamp "$bundle"
fi
codesign --verify --strict "$bundle"
fixture="$(pwd)/dist/sshot-fixture.app"
mkdir -p "$fixture/Contents/MacOS"
cp "$binary_dir/sshot-fixture" "$fixture/Contents/MacOS/sshot-fixture"
cp resources/Info.plist "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.sshot.fixture' "$fixture/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable sshot-fixture' "$fixture/Contents/Info.plist"
codesign --force --sign - "$fixture"
printf '%s\n' "$bundle"
