#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export SSHOT_VERSION="${SSHOT_VERSION:-0.3.0}"
export SSHOT_BUILD_NUMBER="${SSHOT_BUILD_NUMBER:-4}"
[[ "$SSHOT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 1
export SSHOT_UPDATE_FEED_URL='https://github.com/kyungseok-lee/sshot/releases/latest/download/appcast.xml'
export SSHOT_UPDATE_PUBLIC_KEY="${SSHOT_UPDATE_PUBLIC_KEY:-$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' resources/Info.plist)}"
export SSHOT_UPDATE_DOWNLOAD_URL_PREFIX="https://github.com/kyungseok-lee/sshot/releases/download/v$SSHOT_VERSION/"
bash scripts/prepare-update.sh
printf '%s\n' 'Use publish-github-release.sh with the prepared directory after QA, commit, push, and pushing the matching version tag.'
