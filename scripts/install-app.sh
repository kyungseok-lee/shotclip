#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
source scripts/install-common.sh
# Fixed production destination; fixture tests invoke the helper with an explicit
# temporary root, never an environment override of a real installation.
install_verified_app "$(pwd)/dist/$SHOTCLIP_APP_BUNDLE_NAME" /Applications
