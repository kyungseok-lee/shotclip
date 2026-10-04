#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
[[ $# -ge 2 && $# -le 3 ]] || release_fail 'Usage: bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY [--check|--draft|--publish]'
version="$1"; directory="$2"; action="${3:---draft}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && ( "$action" == '--check' || "$action" == '--draft' || "$action" == '--publish' ) ]] || release_fail 'Invalid version or publication action.'
release_configuration
[[ "$version" == "$SHOTCLIP_VERSION" ]] || release_fail 'Requested version differs from reviewed release configuration.'
commit="$(release_reviewed_head)"
tag="v$version"
[[ -d "$directory" && ! -L "$directory" ]] || release_fail 'Prepared directory is missing or a symlink.'
directory="$(cd "$directory" && pwd -P)"
staging="$(mktemp -d)"
snapshot="$staging/verified-assets"
mkdir "$snapshot"
# Upload the exact snapshot that passes verification, even if the preparation directory changes.
for asset in "shotclip-$version.zip" appcast.xml SHA256SUMS release-manifest.json RELEASE-NOTES.md README.txt; do
    [[ -f "$directory/$asset" && ! -L "$directory/$asset" ]] || release_fail 'Prepared assets must be regular files without symlinks.'
    cp "$directory/$asset" "$snapshot/$asset"
done
directory="$snapshot"
archive="$directory/shotclip-$version.zip"
feed="$directory/appcast.xml"
# Public-key-only archive, feed, manifest and checksum verification; no Keychain prompts.
swift scripts/release-manifest.swift verify "$directory" "$commit" "$version" "$SHOTCLIP_CANONICAL_KEY" >/dev/null
python3 scripts/verify-release-archive.py "$archive"
mkdir "$staging/extracted"
ditto -x -k "$archive" "$staging/extracted"
release_verify_bundle "$staging/extracted/$SHOTCLIP_APP_BUNDLE_NAME" "$commit"
remote_commit="$(git ls-remote origin "refs/tags/$tag^{}" | awk '{print $1}')"
if [[ -z "$remote_commit" ]]; then remote_commit="$(git ls-remote origin "refs/tags/$tag" | awk '{print $1}')"; fi
[[ "$remote_commit" == "$commit" ]] || release_fail 'Push the exact reviewed version tag first.'
github_commit="$(gh api "repos/$SHOTCLIP_REPOSITORY/commits/$tag" --jq .sha)"
[[ "$github_commit" == "$commit" ]] || release_fail 'GitHub release repository tag differs from reviewed commit.'
[[ "$(release_reviewed_head)" == "$commit" ]] || release_fail 'Reviewed source changed during publication validation.'
if [[ "$action" == '--check' ]]; then
    printf 'PASS: %s release gates; no release created, uploaded or published.\n' "$SHOTCLIP_RELEASE_MODE"
    exit 0
fi
if [[ "$SHOTCLIP_RELEASE_MODE" == ad-hoc ]]; then
    title="Shot Clip $version (ad-hoc preview; NOT notarized)"
else
    title="Shot Clip $version (Developer ID; notarized)"
fi
gh release create "$tag" "$archive" "$feed" "$directory/SHA256SUMS" "$directory/release-manifest.json" "$directory/RELEASE-NOTES.md" "$directory/README.txt" --repo "$SHOTCLIP_REPOSITORY" --verify-tag --draft --title "$title" --notes-file "$directory/RELEASE-NOTES.md"
# Confirm uploaded bytes before any transition out of draft. Do not overwrite assets.
downloaded="$staging/uploaded"
mkdir "$downloaded"
gh release download "$tag" --repo "$SHOTCLIP_REPOSITORY" --dir "$downloaded"
for asset in "shotclip-$version.zip" appcast.xml SHA256SUMS release-manifest.json RELEASE-NOTES.md README.txt; do
    cmp "$directory/$asset" "$downloaded/$asset" || release_fail 'Uploaded asset differs from verified local release; release remains draft.'
done
swift scripts/release-manifest.swift verify "$downloaded" "$commit" "$version" "$SHOTCLIP_CANONICAL_KEY" >/dev/null
[[ "$(release_reviewed_head)" == "$commit" ]] || release_fail 'Reviewed source changed after upload; release remains draft.'
if [[ "$action" == '--publish' ]]; then
    [[ "$(gh api "repos/$SHOTCLIP_REPOSITORY/commits/$tag" --jq .sha)" == "$commit" ]] || release_fail 'Remote tag changed after upload; release remains draft.'
    gh release edit "$tag" --repo "$SHOTCLIP_REPOSITORY" --draft=false --latest
    curl --fail --location --proto '=https' --proto-redir '=https' --max-time 60 "$SHOTCLIP_CANONICAL_FEED" --output "$staging/public-appcast.xml"
    cmp "$feed" "$staging/public-appcast.xml" || release_fail 'Release was published but canonical latest feed differs; investigate without replacing assets.'
fi
printf 'Release action completed: %s (%s).\n' "$action" "$SHOTCLIP_RELEASE_MODE"
