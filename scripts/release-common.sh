#!/bin/bash
# Shared release gates. Sourcing this file never builds, signs, installs or publishes.
SHOTCLIP_REPOSITORY='kyungseok-lee/shotclip'
SHOTCLIP_CANONICAL_FEED='https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml'
SHOTCLIP_CANONICAL_KEY='gbN8bdU/ElNPW3vAeX0BCAv4qokA1biQeOUgXNEhdac='
SHOTCLIP_DISPLAY_NAME='Shot Clip'
SHOTCLIP_APP_BUNDLE_NAME='Shot Clip.app'

release_fail() { printf '%s\n' "$*" >&2; exit 1; }
plist_value() { /usr/libexec/PlistBuddy -c "Print :$2" "$1"; }

# SwiftPM emits either a native macOS bundle or a flat resource directory.
# Reject links in the bundle/table path rather than following them during copying.
release_resource_directory() {
    local bundle="$1" resource_dir language
    [[ -d "$bundle" && ! -L "$bundle" ]] || return 1
    if [[ -e "$bundle/Contents" || -L "$bundle/Contents" ]]; then
        [[ -d "$bundle/Contents" && ! -L "$bundle/Contents" ]] || return 1
        resource_dir="$bundle/Contents/Resources"
        [[ -d "$resource_dir" && ! -L "$resource_dir" ]] || return 1
    else
        resource_dir="$bundle"
    fi
    for language in en ko; do
        [[ -d "$resource_dir/$language.lproj" && ! -L "$resource_dir/$language.lproj" ]] || return 1
        [[ -f "$resource_dir/$language.lproj/Localizable.strings" && ! -L "$resource_dir/$language.lproj/Localizable.strings" ]] || return 1
    done
    printf '%s\n' "$resource_dir"
}

release_configuration() {
    : "${SHOTCLIP_RELEASE_MODE:?Set SHOTCLIP_RELEASE_MODE to ad-hoc or developer-id explicitly}"
    case "$SHOTCLIP_RELEASE_MODE" in
        ad-hoc)
            [[ "${SHOTCLIP_ACKNOWLEDGE_AD_HOC:-}" == YES ]] || release_fail 'Set SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES: this public release is ad-hoc signed, NOT notarized; Gatekeeper may block first launch and screen recording permission may need reauthorization.'
            [[ "${SHOTCLIP_SIGN_IDENTITY:--}" == '-' ]] || release_fail 'Ad-hoc mode requires SHOTCLIP_SIGN_IDENTITY=-.'
            export SHOTCLIP_SIGN_IDENTITY='-'
            ;;
        developer-id)
            [[ "${SHOTCLIP_SIGN_IDENTITY:-}" == 'Developer ID Application:'* ]] || release_fail 'Developer ID mode requires an explicit Developer ID Application identity.'
            [[ "${SHOTCLIP_RELEASE_TEAM_ID:-}" =~ ^[A-Z0-9]{10}$ ]] || release_fail 'Developer ID mode requires SHOTCLIP_RELEASE_TEAM_ID (10 uppercase alphanumeric characters).'
            ;;
        *) release_fail 'Release mode must be ad-hoc or developer-id; development builds cannot be published.' ;;
    esac
    export SHOTCLIP_VERSION="${SHOTCLIP_VERSION:-$(plist_value resources/Info.plist CFBundleShortVersionString)}"
    export SHOTCLIP_BUILD_NUMBER="${SHOTCLIP_BUILD_NUMBER:-$(plist_value resources/Info.plist CFBundleVersion)}"
    [[ "$SHOTCLIP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && "$SHOTCLIP_BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]] || release_fail 'Invalid release version or build number.'
    [[ "$(plist_value resources/Info.plist CFBundleShortVersionString)" == "$SHOTCLIP_VERSION" && "$(plist_value resources/Info.plist CFBundleVersion)" == "$SHOTCLIP_BUILD_NUMBER" ]] || release_fail 'Release version/build must match reviewed resources/Info.plist.'
    [[ "$(plist_value resources/Info.plist SUPublicEDKey)" == "$SHOTCLIP_CANONICAL_KEY" ]] || release_fail 'The established Sparkle public key must remain unchanged.'
    [[ "${SHOTCLIP_UPDATE_PUBLIC_KEY:-$SHOTCLIP_CANONICAL_KEY}" == "$SHOTCLIP_CANONICAL_KEY" && "${SHOTCLIP_UPDATE_FEED_URL:-$SHOTCLIP_CANONICAL_FEED}" == "$SHOTCLIP_CANONICAL_FEED" ]] || release_fail 'Release public key/feed must match the canonical HTTPS configuration.'
    export SHOTCLIP_UPDATE_PUBLIC_KEY="$SHOTCLIP_CANONICAL_KEY" SHOTCLIP_UPDATE_FEED_URL="$SHOTCLIP_CANONICAL_FEED"
    local prefix="https://github.com/$SHOTCLIP_REPOSITORY/releases/download/v$SHOTCLIP_VERSION/"
    [[ "${SHOTCLIP_UPDATE_DOWNLOAD_URL_PREFIX:-$prefix}" == "$prefix" ]] || release_fail 'Release download prefix must be the matching HTTPS GitHub version directory.'
    export SHOTCLIP_UPDATE_DOWNLOAD_URL_PREFIX="$prefix"
}

release_reviewed_head() {
    [[ -z "$(git status --porcelain)" ]] || release_fail 'Commit reviewed changes before preparing or publishing a release.'
    local commit
    commit="$(git rev-parse HEAD)"
    [[ "${SHOTCLIP_REVIEWED_COMMIT:-}" == "$commit" ]] || release_fail 'Set SHOTCLIP_REVIEWED_COMMIT to the full independently reviewed HEAD.'
    [[ "$(git rev-parse --verify "refs/tags/v$SHOTCLIP_VERSION^{commit}")" == "$commit" ]] || release_fail 'The local version tag must identify the exact reviewed HEAD.'
    printf '%s\n' "$commit"
}

release_verify_bundle() {
    local bundle="$1" commit="$2" plist="$1/Contents/Info.plist" signature resource_bundle
    [[ -d "$bundle" && ! -L "$bundle" ]] || release_fail 'Release app bundle is missing or a symlink.'
    [[ "$(plist_value "$plist" CFBundleIdentifier)" == dev.shotclip.app && "$(plist_value "$plist" CFBundleExecutable)" == shotclip && "$(plist_value "$plist" CFBundleName)" == "$SHOTCLIP_DISPLAY_NAME" && "$(plist_value "$plist" CFBundleDisplayName)" == "$SHOTCLIP_DISPLAY_NAME" ]] || release_fail 'App name, identifier or executable differs from Shot Clip metadata.'
    [[ -f "$bundle/Contents/MacOS/shotclip" && ! -L "$bundle/Contents/MacOS/shotclip" ]] || release_fail 'Shot Clip executable is missing or a symlink.'
    [[ "$(plist_value "$plist" CFBundleShortVersionString)" == "$SHOTCLIP_VERSION" && "$(plist_value "$plist" CFBundleVersion)" == "$SHOTCLIP_BUILD_NUMBER" && "$(plist_value "$plist" SHOTCLIPSourceCommit)" == "$commit" ]] || release_fail 'Artifact version, build or source commit differs from reviewed release.'
    [[ "$(plist_value "$plist" SHOTCLIPReleaseMode)" == "$SHOTCLIP_RELEASE_MODE" ]] || release_fail 'Artifact release mode differs from the explicitly selected mode.'
    [[ "$(plist_value "$plist" SUFeedURL)" == "$SHOTCLIP_CANONICAL_FEED" && "$(plist_value "$plist" SUPublicEDKey)" == "$SHOTCLIP_CANONICAL_KEY" && "$(plist_value "$plist" SUVerifyUpdateBeforeExtraction)" == true && "$(plist_value "$plist" SURequireSignedFeed)" == true ]] || release_fail 'Artifact HTTPS feed, Ed25519 key or signed-update policy is invalid.'
    [[ "$(plist_value "$plist" LSMinimumSystemVersion)" == 14.0 && "$(plist_value "$plist" CFBundleDevelopmentRegion)" == en ]] || release_fail 'Shot Clip requires macOS 14+ and English development localization.'
    [[ -d "$bundle/Contents" && ! -L "$bundle/Contents" && -d "$bundle/Contents/Resources" && ! -L "$bundle/Contents/Resources" ]] || release_fail 'App resource directory is missing or a symlink.'
    resource_bundle="$bundle/Contents/Resources/shotclip_shotclip.bundle"
    release_resource_directory "$resource_bundle" >/dev/null || release_fail 'English/Korean SwiftPM localization bundle is missing or unsafe.'
    codesign --verify --deep --strict "$bundle"
    signature="$(codesign -dv "$bundle" 2>&1)"
    if [[ "$SHOTCLIP_RELEASE_MODE" == ad-hoc ]]; then
        [[ "$signature" == *'Signature=adhoc'* && "$signature" != *'Authority='* && "$signature" == *'TeamIdentifier=not set'* ]] || release_fail 'Public ad-hoc mode must contain an actual ad-hoc signature without a signing authority/team.'
    else
        [[ "$signature" == *'Authority=Developer ID Application:'* && "$signature" == *"TeamIdentifier=$SHOTCLIP_RELEASE_TEAM_ID"* ]] || release_fail 'Developer ID signature or expected team does not match.'
        xcrun stapler validate "$bundle"
        spctl --assess --type execute "$bundle"
    fi
}
