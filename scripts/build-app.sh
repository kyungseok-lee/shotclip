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
version="${SHOTCLIP_VERSION:-0.8.1}"
build_number="${SHOTCLIP_BUILD_NUMBER:-11}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && "$build_number" =~ ^[1-9][0-9]*$ ]] || release_fail 'Version must be N.N.N; build number must be a positive integer.'
if pgrep -x shotclip >/dev/null; then release_fail 'Quit Shot Clip before rebuilding its app bundle.'; fi
build_flavor="${SHOTCLIP_BUILD_FLAVOR:-production}"
case "$build_flavor" in
    production) output_root="$(pwd)/dist"; bundle_name="$SHOTCLIP_APP_BUNDLE_NAME" ;;
    qa)
        [[ "$release_mode" == development ]] || release_fail 'QA builds cannot be published.'
        output_root="$(pwd)/dist/qa"; bundle_name='Shot Clip QA.app'
        ;;
    *) release_fail 'Build flavor must be production or qa.' ;;
esac
scratch="$(pwd)/.build/$build_flavor"
# Swift compiler source documents prefix maps for debug/coverage/index paths.
# ConciseMagicFile also prevents Swift 5 assertion defaults embedding #filePath.
# The final byte/Mach-O scan verifies the result rather than trusting flags.
build_flags=(--scratch-path "$scratch" -c release --product shotclip
    --disable-local-rpath -debug-info-format none
    -Xswiftc -gnone -Xswiftc -no-toolchain-stdlib-rpath -Xswiftc -enable-upcoming-feature -Xswiftc ConciseMagicFile
    -Xswiftc -file-prefix-map -Xswiftc "$(pwd)=."
    -Xswiftc -debug-prefix-map -Xswiftc "$(pwd)=."
    -Xswiftc -file-compilation-dir -Xswiftc .
    -Xcc "-ffile-prefix-map=$(pwd)=." -Xcc "-fdebug-prefix-map=$(pwd)=.")
if [[ "$build_flavor" == qa ]]; then build_flags+=(-Xswiftc -DSHOTCLIP_QA); fi
swift build "${build_flags[@]}"
binary_dir="$(swift build "${build_flags[@]}" --show-bin-path)"
framework="$scratch/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
[[ -d "$framework" ]] || { printf '%s\n' 'Resolved Sparkle framework missing.' >&2; exit 1; }
mkdir -p "$output_root"
staging="$(mktemp -d "$output_root/build.XXXXXX")"
bundle="$staging/$bundle_name"
output_app="$output_root/$bundle_name"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources" "$bundle/Contents/Frameworks"
cp "$binary_dir/shotclip" "$bundle/Contents/MacOS/shotclip"
python3 scripts/remove-toolchain-rpaths.py "$bundle/Contents/MacOS/shotclip"
cp resources/Info.plist "$bundle/Contents/Info.plist"
resource_bundle="$bundle/Contents/Resources/shotclip_shotclip.bundle"
mkdir -p "$resource_bundle/Contents/Resources"
release_resource_directory Sources/shotclip/Resources >/dev/null || release_fail 'English/Korean source resources are missing or unsafe.'
ditto Sources/shotclip/Resources "$resource_bundle/Contents/Resources"
cat > "$resource_bundle/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.shotclip.resources</string>
<key>CFBundleName</key><string>Shot Clip Resources</string>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST
release_resource_directory "$resource_bundle" >/dev/null || release_fail 'Packaged English/Korean resources are missing or unsafe.'
swift scripts/generate-app-icon.swift "$staging/AppIcon.iconset"
iconutil -c icns "$staging/AppIcon.iconset" -o "$bundle/Contents/Resources/AppIcon.icns"
ditto "$framework" "$bundle/Contents/Frameworks/Sparkle.framework"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :SHOTCLIPSourceCommit string $(git rev-parse HEAD)" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :SHOTCLIPReleaseMode string $release_mode" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :SHOTCLIPBuildFlavor string $build_flavor" "$bundle/Contents/Info.plist"
if [[ "$build_flavor" == qa ]]; then
    /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.shotclip.qa' "$bundle/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleName Shot Clip QA' "$bundle/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Shot Clip QA' "$bundle/Contents/Info.plist"
fi
swift scripts/configure-updates.swift "$bundle/Contents/Info.plist"
if [[ "$build_flavor" == production ]]; then
    python3 scripts/verify-app-security.py "$bundle" || release_fail 'Production app security gates failed.'
fi
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
if pgrep -x shotclip >/dev/null; then release_fail 'Shot Clip started during the build; refusing to replace a potentially running bundle.'; fi
[[ ! -L "$output_app" ]] || release_fail 'Output app is a symlink; refusing replacement.'
if [[ -e "$output_app" ]]; then mv "$output_app" "$staging/previous-$bundle_name"; fi
if ! mv "$bundle" "$output_app"; then
    if [[ -d "$staging/previous-$bundle_name" && ! -e "$output_app" ]]; then mv "$staging/previous-$bundle_name" "$output_app"; fi
    exit 1
fi
if [[ "$build_flavor" == qa ]]; then
    swift build --scratch-path "$scratch" -c release --product shotclip-fixture --disable-local-rpath -debug-info-format none -Xswiftc -gnone -Xswiftc -no-toolchain-stdlib-rpath -Xswiftc -enable-upcoming-feature -Xswiftc ConciseMagicFile
    fixture="$staging/shotclip-fixture.app"
    mkdir -p "$fixture/Contents/MacOS"
    cp "$binary_dir/shotclip-fixture" "$fixture/Contents/MacOS/shotclip-fixture"
    cp resources/Info.plist "$fixture/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.shotclip.fixture' "$fixture/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable shotclip-fixture' "$fixture/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleName Shot Clip Fixture' "$fixture/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Shot Clip Fixture' "$fixture/Contents/Info.plist"
    codesign --force --sign - "$fixture"
    codesign --verify --deep --strict "$fixture"
    if pgrep -x shotclip-fixture >/dev/null; then release_fail 'Quit shotclip-fixture before replacing the fixture bundle.'; fi
    [[ ! -L "$output_root/shotclip-fixture.app" ]] || release_fail 'Fixture target is a symlink.'
    if [[ -e "$output_root/shotclip-fixture.app" ]]; then mv "$output_root/shotclip-fixture.app" "$staging/previous-shotclip-fixture.app"; fi
    mv "$fixture" "$output_root/shotclip-fixture.app"
fi
# Only after the selected generated bundles pass verification and replacement succeeds.
# Failed builds retain their private staging folder for recovery.
[[ "$staging" == "$output_root/build."* && -d "$staging" && ! -L "$staging" ]] || release_fail 'Unexpected build staging directory.'
rm -rf -- "$staging"
printf '%s\n' "$output_app"
