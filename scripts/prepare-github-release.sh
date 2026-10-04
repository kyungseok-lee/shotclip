#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Both public modes must be selected explicitly; neither is an implicit fallback.
source scripts/release-common.sh
release_configuration
bash scripts/prepare-update.sh
printf '%s\n' 'No publication performed. Review the prepared artifacts; use publish-github-release.sh --check before creating a draft.'
