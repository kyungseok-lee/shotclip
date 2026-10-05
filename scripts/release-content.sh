#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# == 1 && -d "$1" && ! -L "$1" ]] || { printf '%s\n' 'Usage: release-content.sh EXISTING_PREPARED_DIRECTORY' >&2; exit 1; }
source scripts/release-common.sh
release_configuration
architecture="$(lipo -archs "dist/$SHOTCLIP_APP_BUNDLE_NAME/Contents/MacOS/shotclip")"
[[ "$architecture" == arm64 || "$architecture" == x86_64 || "$architecture" == 'x86_64 arm64' || "$architecture" == 'arm64 x86_64' ]] || release_fail 'Unexpected release executable architecture.'
if [[ "$SHOTCLIP_RELEASE_MODE" == ad-hoc ]]; then
    status='Ad-hoc signed; NOT notarized. No Apple Developer ID certificate is used.'
else
    status='Developer ID distribution; publishing requires successful notarization and Gatekeeper assessment.'
fi
cat > "$1/RELEASE-NOTES.md" <<EOF
# Shot Clip $SHOTCLIP_VERSION (build $SHOTCLIP_BUILD_NUMBER)

Shot Clip copies a selected screen region to the clipboard on macOS 14 or later.
English is the default language; Korean is also included.
Archive architecture: $architecture. Intel and macOS 14 runtime behavior are unverified.
Distribution: $status

## What's new

- Reorganized documentation into a concise installation README, a dedicated app usage guide and a development reference section.
- English is the primary documentation language; the root Korean README provides the Korean installation and usage summary.
- Development requirements, architecture, design, testing and release operations are linked separately from everyday app instructions.
- App behavior is unchanged from 0.8.1. Capture, clipboard handling, in-memory preview, explicit PNG saving, preferences and signed-update protections remain unchanged.

The canonical Shot Clip.app installation can use Sparkle to update from 0.8.1 to this release.
For manual installation, quit the previous app before moving Shot Clip.app to Applications.
Only historical ShotClip.app or Sshot installations need the earlier folder/identity migration guidance:
install manually once to adopt Shot Clip.app; stock Sparkle may retain an older host folder.
Historical Sshot used another bundle identifier and requires manual installation and a fresh permission grant.
Screen Recording permission may need to be granted again after an ad-hoc replacement; TCC is not reset.
Sparkle Ed25519 signatures authenticate updates; they do not grant macOS trust or permissions.
Ad-hoc Sparkle compatibility retains the disclosed library-validation exception.
On first launch, follow macOS Privacy & Security guidance if Gatekeeper blocks the app.
Do not remove quarantine attributes or disable Gatekeeper.

EOF
cp "$1/RELEASE-NOTES.md" "$1/README.txt"
