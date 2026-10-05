#!/bin/bash
# Read-only publishing-gate checks. Never builds, signs, contacts GitHub or installs.
set -euo pipefail
cd "$(dirname "$0")/.."
unset SHOTCLIP_BUILD_FLAVOR SHOTCLIP_RELEASE_MODE SHOTCLIP_ACKNOWLEDGE_AD_HOC SHOTCLIP_SIGN_IDENTITY SHOTCLIP_RELEASE_TEAM_ID SHOTCLIP_VERSION SHOTCLIP_BUILD_NUMBER SHOTCLIP_UPDATE_PUBLIC_KEY SHOTCLIP_UPDATE_FEED_URL SHOTCLIP_UPDATE_DOWNLOAD_URL_PREFIX SHOTCLIP_REVIEWED_COMMIT
current_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' resources/Info.plist)"
count=0
reject() {
    local expected="$1" output status
    shift
    set +e
    output="$(env "$@" bash scripts/publish-github-release.sh "$current_version" /nonexistent --check 2>&1)"
    status="$?"
    set -e
    [[ "$status" != 0 && "$output" == *"$expected"* ]] || { printf 'FAIL: expected rejection: %s\n%s\n' "$expected" "$output" >&2; exit 1; }
    count=$((count + 1))
}
reject 'Set SHOTCLIP_RELEASE_MODE'
reject 'SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES' SHOTCLIP_RELEASE_MODE=ad-hoc
reject 'SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=NO
reject 'requires SHOTCLIP_SIGN_IDENTITY=-' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES 'SHOTCLIP_SIGN_IDENTITY=Developer ID Application: synthetic'
reject 'requires an explicit Developer ID Application identity' SHOTCLIP_RELEASE_MODE=developer-id
reject 'requires SHOTCLIP_RELEASE_TEAM_ID' SHOTCLIP_RELEASE_MODE=developer-id 'SHOTCLIP_SIGN_IDENTITY=Developer ID Application: synthetic'
reject 'development builds cannot be published' SHOTCLIP_RELEASE_MODE=development
reject 'production build flavor' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES SHOTCLIP_BUILD_FLAVOR=qa
reject 'version/build must match reviewed' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES SHOTCLIP_VERSION=99.99.99
reject 'version/build must match reviewed' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES SHOTCLIP_BUILD_NUMBER=999
reject 'canonical HTTPS configuration' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES SHOTCLIP_UPDATE_PUBLIC_KEY=invalid
reject 'canonical HTTPS configuration' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES SHOTCLIP_UPDATE_FEED_URL=http://invalid.example/appcast.xml
reject 'matching HTTPS GitHub version directory' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES SHOTCLIP_UPDATE_DOWNLOAD_URL_PREFIX=https://invalid.example/
if [[ -n "$(git status --porcelain)" ]]; then
    reject 'Commit reviewed changes' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES
else
    reject 'SHOTCLIP_REVIEWED_COMMIT' SHOTCLIP_RELEASE_MODE=ad-hoc SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES
fi
# Exercise clean/review/tag gates in a subshell with a read-only synthetic git function.
# No actual git commit, tag, push, or repository edits occur.
synthetic_reject() {
    local scenario="$1" expected="$2" output status
    set +e
    output="$( {
        source scripts/release-common.sh
        SHOTCLIP_VERSION=0.4.0
        SHOTCLIP_REVIEWED_COMMIT=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        if [[ "$scenario" == review ]]; then SHOTCLIP_REVIEWED_COMMIT=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb; fi
        git() {
            if [[ "$1" == status ]]; then return 0; fi
            if [[ "$2" == HEAD ]]; then printf '%s\n' aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; return 0; fi
            if [[ "$scenario" == tag-missing ]]; then return 1; fi
            if [[ "$scenario" == tag-mismatch ]]; then
                printf '%s\n' bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
            else
                printf '%s\n' aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
            fi
        }
        release_reviewed_head
    } 2>&1)"
    status="$?"
    set -e
    [[ "$status" != 0 && "$output" == *"$expected"* ]] || { printf 'FAIL: %s\n%s\n' "$scenario" "$output" >&2; exit 1; }
    count=$((count + 1))
}
synthetic_reject review 'SHOTCLIP_REVIEWED_COMMIT'
synthetic_reject tag-missing 'local version tag'
synthetic_reject tag-mismatch 'local version tag'
printf 'PASS: %s read-only publishing/review/tag gate rejections; no remote or Keychain access\n' "$count"
