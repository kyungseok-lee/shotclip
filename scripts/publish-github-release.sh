#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# -ge 2 && $# -le 3 ]] || { printf '%s\n' 'Usage: bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY [--publish]' >&2; exit 1; }
version="$1"; directory="$2"; mode="${3:---draft}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && ( "$mode" == '--draft' || "$mode" == '--publish' ) ]] || exit 1
[[ -z "$(git status --porcelain)" ]] || { printf '%s\n' 'Commit reviewed changes before creating a release.' >&2; exit 1; }
tag="v$version"
commit="$(git rev-parse HEAD)"
[[ "$(git rev-parse "$tag^{commit}")" == "$commit" ]] || { printf '%s\n' 'Version tag must identify the current reviewed commit.' >&2; exit 1; }
remote_commit="$(git ls-remote origin "refs/tags/$tag^{}" | awk '{print $1}')"
if [[ -z "$remote_commit" ]]; then remote_commit="$(git ls-remote origin "refs/tags/$tag" | awk '{print $1}')"; fi
[[ "$remote_commit" == "$commit" ]] || { printf '%s\n' 'Push the exact reviewed version tag first.' >&2; exit 1; }
github_commit="$(gh api "repos/kyungseok-lee/sshot/commits/$tag" --jq .sha)"
[[ "$github_commit" == "$commit" ]] || { printf '%s\n' 'GitHub release repository tag differs from reviewed commit.' >&2; exit 1; }
archive="$directory/sshot-$version.zip"
feed="$directory/appcast.xml"
[[ -f "$archive" && -f "$feed" ]] || { printf '%s\n' 'Prepared archive and appcast.xml are required.' >&2; exit 1; }
public_key="$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' resources/Info.plist)"
signature="$(swift scripts/release-manifest.swift verify "$directory" "$commit" "$version" "$public_key")"
tools="$(pwd)/.build/artifacts/sparkle/Sparkle/bin"
account="${SSHOT_UPDATE_KEY_ACCOUNT:-sshot}"
[[ "$("$tools/generate_keys" --account "$account" -p)" == "$public_key" ]] || exit 1
"$tools/sign_update" --account "$account" --verify "$feed"
staging="$(mktemp -d)"
ditto -x -k "$archive" "$staging"
bundle="$staging/sshot.app"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$bundle/Contents/Info.plist")" == "$version" ]] || exit 1
[[ "$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$bundle/Contents/Info.plist")" == "$public_key" ]] || exit 1
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$bundle/Contents/Info.plist")" == 'dev.sshot.app' ]] || exit 1
[[ "$(/usr/libexec/PlistBuddy -c 'Print :SSHOTSourceCommit' "$bundle/Contents/Info.plist")" == "$commit" ]] || { printf '%s\n' 'Signed artifact source commit differs from reviewed tag.' >&2; exit 1; }
[[ "$(/usr/libexec/PlistBuddy -c 'Print :SUFeedURL' "$bundle/Contents/Info.plist")" == 'https://github.com/kyungseok-lee/sshot/releases/latest/download/appcast.xml' ]] || exit 1
build="$(plutil -extract build raw "$directory/release-manifest.json")"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$bundle/Contents/Info.plist")" == "$build" ]] || exit 1
codesign --verify --deep --strict "$bundle"
codesign -dv "$bundle" 2>&1 | grep -q '^Authority=Developer ID Application:' || { printf '%s\n' 'Public releases require an actual Developer ID Application signature.' >&2; exit 1; }
codesign -dv "$bundle" 2>&1 | grep -Eq '^TeamIdentifier=[A-Z0-9]{10}$' || { printf '%s\n' 'Developer ID TeamIdentifier is missing.' >&2; exit 1; }
: "${SSHOT_RELEASE_TEAM_ID:?Set the expected Developer ID signing team identifier}"
[[ "$SSHOT_RELEASE_TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || exit 1
codesign -dv "$bundle" 2>&1 | grep -Fxq "TeamIdentifier=$SSHOT_RELEASE_TEAM_ID" || { printf '%s\n' 'Release signing team differs from expected team.' >&2; exit 1; }
xcrun stapler validate "$bundle"
spctl --assess --type execute "$bundle"
expected="https://github.com/kyungseok-lee/sshot/releases/download/$tag/sshot-$version.zip"
grep -Fq "$expected" "$feed" && grep -q 'sparkle:edSignature=' "$feed" || { printf '%s\n' 'Appcast must reference the matching GitHub archive and EdDSA signature.' >&2; exit 1; }
(cd "$directory" && shasum -a 256 "sshot-$version.zip" appcast.xml > SHA256SUMS)
gh release create "$tag" "$archive" "$feed" "$directory/SHA256SUMS" "$directory/release-manifest.json" --repo kyungseok-lee/sshot --verify-tag --draft --title "sshot $version" --notes-from-tag
if [[ "$mode" == '--publish' ]]; then gh release edit "$tag" --repo kyungseok-lee/sshot --draft=false --latest; fi
