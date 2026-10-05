# Releasing Shot Clip

[Developer guide](README.md) · [Testing](testing.md)

## User updates and first launch

**Check for Updates** performs a manual check. Fresh automatic checks default OFF; an existing ON/OFF choice is preserved. Automatic download/install is disabled. Both feed and archive authenticate against the established Ed25519 key; integer-zero signed-feed failure expiry prevents elapsed-time acceptance of an invalid signature, while later valid feeds remain eligible.

The public app is arm64 ad-hoc signed, not Apple-notarized. Verify the release/source before using Apple's [per-app first-launch flow](https://support.apple.com/en-us/102445). Do not globally disable Gatekeeper or reset TCC. Ad-hoc replacement can require Screen Recording reapproval; Access contains request/settings/recheck/restart recovery. Developer ID/notarization is a separate future route, not a claim about this release.

## Prepare, check, draft, publish

For an explicitly authorized release, first update requirements/design, implement and verify, obtain independent approval, commit the reviewed new version/build and create/push a new immutable tag. Never repoint an existing version. Preparation requires clean reviewed HEAD and a matching version tag; it is not appropriate for a documentation-only commit.

Resolve the exact dependency into the production scratch directory, then select public mode explicitly:

```sh
swift package --scratch-path .build/production resolve
export SHOTCLIP_RELEASE_MODE=ad-hoc
export SHOTCLIP_ACKNOWLEDGE_AD_HOC=YES
export SHOTCLIP_REVIEWED_COMMIT="$(git rev-parse HEAD)"
bash scripts/prepare-github-release.sh
```

The script prints the newly prepared `dist/update-VERSION.*` directory. Use that exact directory and reviewed version for `--check`, then obtain exact-artifact approval before publication:

```sh
bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY --check
bash scripts/publish-github-release.sh VERSION PREPARED_DIRECTORY --publish
```

`VERSION` and `PREPARED_DIRECTORY` are placeholders, not runnable literal arguments. The publisher snapshots verified bytes, checks archive/feed/manifest/checksums, safe extraction, complete production bundle gates and remote tag identity. `--check` creates no release. As a separate alternative, use `--draft` instead of `--publish` to create a draft. Both options create a new release; do not run this script with `--publish` after creating the draft. An existing draft must be published through a separately verified GitHub release-edit flow. Preparation signs using the existing key; publisher verification is public-key-only.

Prepared assets are `shotclip-VERSION.zip`, `appcast.xml`, `SHA256SUMS`, `release-manifest.json`, `RELEASE-NOTES.md` and `README.txt`. They belong to that release, not an accumulated README changelog. Download all six after publication, compare exact approved bytes and canonical latest feed, then verify actual latest installation. Only afterward clean precisely authorized obsolete/generated outputs, preserving source/history/tags/key, preferences, unrelated files and compact evidence.

## Production bundle gates

Only production flavor may publish. Verify identity/version/build/source commit, explicit signing mode, canonical HTTPS feed/key, signed-feed/archive/pre-extraction policy and integer-zero expiry, native self-contained en/ko resources, translation-key parity, fonts/licenses/icon, deep/strict signature and safe payload paths. Complete scanner checks regular bytes, symlink targets and all Mach-O debug/RPATHs, rejecting private-home/checkout/build metadata and app-owned QA types/hooks. Standard Sparkle updater helpers remain; development capture-test helpers do not ship.

Swift Build toolchain RPATH removal occurs only for verified active-toolchain library paths before signing; unknown absolute paths fail closed. Preserve `/usr/lib/swift` and safe bundle-relative lookup. Current ad-hoc Sparkle library-validation exception is disclosed; local validation does not convert it into Developer ID/notarization evidence.

## Trust and migration limits

Keep the established Ed25519 public key and private Keychain account `sshot`; lookup/sign only, no export/rotation/regeneration. A display/repository rename does not authorize changing trust. Historical `dev.sshot.app` migration copies only missing valid shortcut/mode values, not language, permission, login, updater state or keys.

The canonical spaced folder is `/Applications/Shot Clip.app`. Legacy folder/identity transition uses a verified manual installation; stock Sparkle can update its old host location and is not promised to rename it. [install-app](../../scripts/install-app.sh) stages/verifies before replacement and supports guarded backups/rollback. Test real updater installation separately from manual installation. Neither proves every legacy identity, account, OS or permission scenario.
