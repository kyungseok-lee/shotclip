#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source_app="$(pwd)/dist/sshot.app"
target="/Applications/sshot.app"
[[ -d "$source_app" && ! -L "$source_app" ]] || { printf '%s\n' 'Build dist/sshot.app first.' >&2; exit 1; }
codesign --verify --deep --strict "$source_app"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$source_app/Contents/Info.plist")" == 'dev.sshot.app' ]] || exit 1
[[ -w /Applications && ! -L "$target" ]] || { printf '%s\n' '/Applications is not writable or target is a symlink; install manually.' >&2; exit 1; }
if pgrep -x sshot >/dev/null; then printf '%s\n' 'Quit sshot before installation.' >&2; exit 1; fi
staging="$(mktemp -d /Applications/.sshot-install.XXXXXX)"
ditto "$source_app" "$staging/sshot.app"
codesign --verify --deep --strict "$staging/sshot.app"
if [[ -e "$target" ]]; then
    [[ -d "$target" && "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$target/Contents/Info.plist")" == 'dev.sshot.app' ]] || { printf '%s\n' 'Existing target is not the sshot app; refusing replacement.' >&2; exit 1; }
    mv "$target" "$staging/previous-sshot.app"
fi
if ! mv "$staging/sshot.app" "$target"; then
    if [[ -d "$staging/previous-sshot.app" && ! -e "$target" ]]; then mv "$staging/previous-sshot.app" "$target"; fi
    exit 1
fi
printf 'Installed %s\nPrevious version (if any): %s\n' "$target" "$staging/previous-sshot.app"
open "$target"
