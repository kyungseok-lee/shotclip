#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
source_app="$(pwd)/dist/ShotClip.app"
target='/Applications/ShotClip.app'
# INTENTIONAL LEGACY MIGRATION: preserve only the verified prior app at this exact path.
legacy='/Applications/sshot.app'
quit_check() {
    if pgrep -x shotclip >/dev/null || pgrep -x sshot >/dev/null; then
        release_fail 'Quit ShotClip and the legacy app before installation; running apps are never replaced.'
    fi
}
verify_app() {
    local path="$1" identifier="$2" executable="$3"
    [[ -d "$path" && ! -L "$path" ]] || release_fail 'App path is not a regular app directory; refusing replacement.'
    [[ "$(plist_value "$path/Contents/Info.plist" CFBundleIdentifier)" == "$identifier" && "$(plist_value "$path/Contents/Info.plist" CFBundleExecutable)" == "$executable" ]] || release_fail 'App identifier/executable does not match the expected migration source.'
    [[ -f "$path/Contents/MacOS/$executable" && ! -L "$path/Contents/MacOS/$executable" ]] || release_fail 'App executable is missing or a symlink.'
    codesign --verify --deep --strict "$path"
}
quit_check
verify_app "$source_app" dev.shotclip.app shotclip
[[ -w /Applications && ! -L /Applications && ! -L "$target" && ! -L "$legacy" ]] || release_fail '/Applications must be writable and app paths must not be symlinks; install manually.'
if [[ -e "$target" ]]; then verify_app "$target" dev.shotclip.app shotclip; fi
if [[ -e "$legacy" ]]; then verify_app "$legacy" dev.sshot.app sshot; fi
staging="$(mktemp -d /Applications/.shotclip-install.XXXXXX)"
printf 'Recoverable installation staging and backups: %s\n' "$staging"
target_backed=false; legacy_backed=false; installed=false
rollback() {
    local status="$?"
    trap - EXIT INT TERM
    if [[ "$status" != 0 ]]; then
        # Do not move an app launched during installation. Keep all backups recoverable.
        if pgrep -x shotclip >/dev/null || pgrep -x sshot >/dev/null; then
            printf 'An app started during installation; quit it and recover backups manually from %s\n' "$staging" >&2
            exit "$status"
        fi
        if [[ "$installed" == true && -d "$target" && ! -e "$staging/failed-ShotClip.app" ]]; then
            mv "$target" "$staging/failed-ShotClip.app" || true
        fi
        if [[ "$target_backed" == true && ! -e "$target" && ! -L "$target" ]]; then
            mv "$staging/previous-ShotClip.app" "$target" || true
        fi
        if [[ "$legacy_backed" == true && ! -e "$legacy" && ! -L "$legacy" ]]; then
            mv "$staging/previous-sshot.app" "$legacy" || true
        fi
        printf 'Installation failed; rollback attempted. All remaining recoverable artifacts are in %s\n' "$staging" >&2
    fi
    exit "$status"
}
trap rollback EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
ditto "$source_app" "$staging/ShotClip.app"
verify_app "$staging/ShotClip.app" dev.shotclip.app shotclip
quit_check
if [[ -e "$target" ]]; then
    verify_app "$target" dev.shotclip.app shotclip
    mv "$target" "$staging/previous-ShotClip.app"
    target_backed=true
fi
quit_check
if [[ -e "$legacy" ]]; then
    verify_app "$legacy" dev.sshot.app sshot
    mv "$legacy" "$staging/previous-sshot.app"
    legacy_backed=true
fi
quit_check
mv "$staging/ShotClip.app" "$target"
installed=true
verify_app "$target" dev.shotclip.app shotclip
printf 'Installed %s\nBackups (if present): %s/previous-ShotClip.app and %s/previous-sshot.app\n' "$target" "$staging" "$staging"
printf '%s\n' 'Open ShotClip manually. The new bundle identity needs Screen Recording access; ad-hoc replacements may need it again. Gatekeeper/quarantine settings were not changed.'
