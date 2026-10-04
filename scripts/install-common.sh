#!/bin/bash
# Source-only transaction. The production caller uses the literal /Applications;
# fixture tests pass a temporary root directly, never an environment override.
install_quit_check() {
    if pgrep -x shotclip >/dev/null || pgrep -x sshot >/dev/null; then
        release_fail 'Quit Shot Clip and the legacy app before installation; running apps are never replaced.'
    fi
}

install_verify_app() {
    local path="$1" identifier="$2" executable="$3" display_name="${4:-}" plist="$1/Contents/Info.plist"
    [[ -d "$path" && ! -L "$path" && -d "$path/Contents" && ! -L "$path/Contents" && -f "$plist" && ! -L "$plist" ]] || release_fail 'App path or metadata is missing or a symlink; refusing replacement.'
    [[ "$(plist_value "$plist" CFBundleIdentifier)" == "$identifier" && "$(plist_value "$plist" CFBundleExecutable)" == "$executable" ]] || release_fail 'App identifier/executable does not match the expected migration source.'
    if [[ -n "$display_name" ]]; then
        [[ "$(plist_value "$plist" CFBundleName)" == "$display_name" && "$(plist_value "$plist" CFBundleDisplayName)" == "$display_name" ]] || release_fail 'New app display name does not match Shot Clip.'
    fi
    [[ -d "$path/Contents/MacOS" && ! -L "$path/Contents/MacOS" && -f "$path/Contents/MacOS/$executable" && ! -L "$path/Contents/MacOS/$executable" ]] || release_fail 'App executable is missing or a symlink.'
    codesign --verify --deep --strict "$path"
}

install_move() {
    [[ ! -e "$2" && ! -L "$2" ]] || release_fail 'Installation destination appeared unexpectedly; preserving recoverable artifacts.'
    mv "$1" "$2"
}

install_verified_app() (
    set -euo pipefail
    # State belongs to this isolated subshell. Bash EXIT traps run after function
    # locals unwind, so rollback state must remain available until that trap ends.
    source_app="$1"
    applications_dir="$2"
    [[ "$applications_dir" == /* && -d "$applications_dir" && -w "$applications_dir" && ! -L "$applications_dir" ]] || release_fail 'Applications directory must be writable and must not be a symlink; install manually.'
    target="$applications_dir/$SHOTCLIP_APP_BUNDLE_NAME"
    previous="$applications_dir/ShotClip.app"
    legacy="$applications_dir/sshot.app"
    install_quit_check
    install_verify_app "$source_app" dev.shotclip.app shotclip "$SHOTCLIP_DISPLAY_NAME"
    for path in "$target" "$previous" "$legacy"; do
        [[ ! -L "$path" ]] || release_fail 'Installed app paths must not be symlinks; refusing replacement.'
    done
    if [[ -e "$target" ]]; then install_verify_app "$target" dev.shotclip.app shotclip; fi
    if [[ -e "$previous" ]]; then install_verify_app "$previous" dev.shotclip.app shotclip; fi
    if [[ -e "$legacy" ]]; then install_verify_app "$legacy" dev.sshot.app sshot; fi
    staging="$(mktemp -d "$applications_dir/.shotclip-install.XXXXXX")"
    printf 'Recoverable installation staging and backups: %s\n' "$staging"
    target_backed=false; previous_backed=false; legacy_backed=false; installed=false
    rollback() {
        local status="$?"
        trap - EXIT INT TERM
        if [[ "$status" != 0 ]]; then
            if pgrep -x shotclip >/dev/null || pgrep -x sshot >/dev/null; then
                printf 'An app started during installation; quit it and recover backups manually from %s\n' "$staging" >&2
                exit "$status"
            fi
            if [[ "$installed" == true && -d "$target" && ! -e "$staging/failed-$SHOTCLIP_APP_BUNDLE_NAME" ]]; then
                mv "$target" "$staging/failed-$SHOTCLIP_APP_BUNDLE_NAME" || true
            fi
            if [[ "$target_backed" == true && ! -e "$target" && ! -L "$target" ]]; then
                mv "$staging/previous-$SHOTCLIP_APP_BUNDLE_NAME" "$target" || true
            fi
            if [[ "$previous_backed" == true && ! -e "$previous" && ! -L "$previous" ]]; then
                mv "$staging/previous-ShotClip.app" "$previous" || true
            fi
            if [[ "$legacy_backed" == true && ! -e "$legacy" && ! -L "$legacy" ]]; then
                mv "$staging/previous-sshot.app" "$legacy" || true
            fi
            printf 'Installation failed; rollback attempted. Recoverable artifacts are in %s\n' "$staging" >&2
        fi
        exit "$status"
    }
    trap rollback EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    ditto "$source_app" "$staging/$SHOTCLIP_APP_BUNDLE_NAME"
    install_verify_app "$staging/$SHOTCLIP_APP_BUNDLE_NAME" dev.shotclip.app shotclip "$SHOTCLIP_DISPLAY_NAME"
    install_quit_check
    if [[ -e "$target" ]]; then
        install_verify_app "$target" dev.shotclip.app shotclip
        install_move "$target" "$staging/previous-$SHOTCLIP_APP_BUNDLE_NAME"
        target_backed=true
    fi
    install_quit_check
    install_move "$staging/$SHOTCLIP_APP_BUNDLE_NAME" "$target"
    installed=true
    install_verify_app "$target" dev.shotclip.app shotclip "$SHOTCLIP_DISPLAY_NAME"
    # Keep prior unspaced/historical installations until the new canonical app
    # has passed verification. Later moves remain recoverable on failure.
    install_quit_check
    if [[ -e "$previous" ]]; then
        install_verify_app "$previous" dev.shotclip.app shotclip
        install_move "$previous" "$staging/previous-ShotClip.app"
        previous_backed=true
    fi
    install_quit_check
    if [[ -e "$legacy" ]]; then
        install_verify_app "$legacy" dev.sshot.app sshot
        install_move "$legacy" "$staging/previous-sshot.app"
        legacy_backed=true
    fi
    install_verify_app "$target" dev.shotclip.app shotclip "$SHOTCLIP_DISPLAY_NAME"
    printf 'Installed %s\nRecoverable backups are in %s\n' "$target" "$staging"
    printf '%s\n' 'Open Shot Clip manually. The bundle identity and settings are unchanged; ad-hoc replacement may need Screen Recording access again. Gatekeeper/quarantine settings were not changed.'
)
