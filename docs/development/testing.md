# Testing Shot Clip

[Usage](../../README.md) · [Developer guide](README.md) · [Requirements](requirements.md)

## Production and isolated QA builds

These are reproducible procedures, not a record of completed runs. Run from the repository root. Quit every Shot Clip process before either bundle build; build-app refuses replacement while the executable is running.

```sh
# Production code flavor; local development signing, no publication.
bash scripts/build-app.sh
python3 scripts/verify-app-security.py 'dist/Shot Clip.app'
python3 scripts/test-production-qa-arguments.py 'dist/Shot Clip.app'

# Explicit development-only QA flavor, distinct bundle/identity/scratch.
SHOTCLIP_BUILD_FLAVOR=qa bash scripts/build-app.sh
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --localization-self-test
python3 scripts/test-qa-build.py 'dist/qa/Shot Clip QA.app'
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --ui-preview dist/ui-qa/en-light --language en --appearance light
'dist/qa/Shot Clip QA.app/Contents/MacOS/shotclip' --ui-preview dist/ui-qa/ko-dark --language ko --appearance dark
```

Production defaults to `.build/production` / `dist/Shot Clip.app` / `dev.shotclip.app`. Isolated QA uses `.build/qa` / `dist/qa/Shot Clip QA.app` / `dev.shotclip.qa` and the explicit `SHOTCLIP_QA` define. QA has no normal startup route; production rejects retired QA arguments before preferences/AppDelegate/updater/permission work. A normal production-flavor development launch shares product preferences, so use QA for inert checks. Published artifacts never contain the QA helper or hooks.

## Fast code and artifact checks

```sh
swift test
python3 scripts/test-app-security.py
bash scripts/test-resource-bundle.sh
bash scripts/test-release-gates.sh
python3 scripts/test-release-archive.py
python3 scripts/test-install-migration.py
swift scripts/test-release-manifest.swift
codesign --verify --deep --strict 'dist/Shot Clip.app'
```

Record exact inputs, environment, commands and counts when performed. Synthetic signing fixtures use ephemeral keys, not the user's Keychain key. Installer tests use temporary roots, not the canonical app. Local ad-hoc signature validation is not Apple notarization or universal first-launch acceptance.

## Inert layout and state acceptance

Repeat en/ko × light/dark at 720×580, 620×480, 670×520 and 820×620 pt. Cover General/Access/Updates, ready/blocked, collapsed/expanded diagnostics, login approval, busy/error/unconfigured update states, long paths/status/shortcut fallback glyphs and resize→switch→resize-back.

Compare all 139 app-owned structural views, including nested labels/control composites, offscreen/hidden structures, separators/footer and document extent, with exact same-state/size en→ko→en frames. Verify full text/cell/tight glyph ink, adjacent-line nonoverlap, at least 12 pt vertical padding, native button title ink, preserved pane/focus/scroll/state and unchanged preferences. Resizing may clamp scroll; fixture restoration after resize is disclosed separately from unassisted language-transition preservation.

Prove guards are active with truncated status, stale wrapping width, missing padding, overlapping line ink and deliberate structural-frame drift. Inspect representative renders as well as machine reports. The renderer draws synthetic product views with inert callbacks; it starts no capture/hotkey/updater/TCC, takes no desktop screenshot and touches no general clipboard. Capture-preview fixtures use a private named pasteboard and synthetic PNGs only. A drawn menu is not native popup or Carbon event evidence.

## Security acceptance

Security checks verify exact integer-zero feed-failure expiry and both signature switches, later valid signed-feed eligibility, production flavor/no QA dispatch, complete artifact path purity and standalone resources. Negative fixtures cover missing/wrong-type policy, QA flavor/types/hooks/files, case-insensitive UTF-8/UTF-16 paths/both alignments, symlink and unsafe/escaping RPATH cases. Whole scanner includes all regular files, symlink targets and Mach-O debug/RPATH data; report categories/counts without matched private paths. Pinned Sparkle source/configuration is not a live 20-day failure experiment.

## User’s short acceptance check

1. Launch the verified app, handle any per-app macOS first-launch block, then inspect General/Access/Updates and version.
2. Use Access to grant Screen Recording only if desired; check denial, Check Again and restart recovery without bypassing TCC.
3. With nonsensitive content, try both capture modes, reverse drag, Return/Capture and Escape. Paste normally into an image-capable app and confirm capture UI/cursor exclusion.
4. Click the thumbnail, inspect original Fit/100%, save a deliberate PNG, cancel another save and verify clipboard retention. Starting a new capture closes the old preview.
5. Check the running-process shortcut from another app, conflict/recovery, M, arrows/Option resize and Tab/Shift-Tab focus.
6. Switch English↔Korean without restarting; inspect retained pane/state/region, small windows and both appearances. Restart once to verify the saved language. OS dialogs follow OS language.

Report only version, case ID, mode/permission state, safe error code, expected/actual result and steps. Do not submit capture/screen/clipboard/observed app/window/export-path content. These checks remain user-owned unless a specific recorded run proves them.

## Optional real-capture harness — user-owned

Only the isolated development QA flavor provides `--self-test`, with its sibling `dist/qa/shotclip-fixture.app`. A person must explicitly choose real capture and grant access to the QA identity. Launch through LaunchServices to keep permission responsibility clear; run this separately from inert testing:

```sh
qa_output_dir=$(mktemp -d)
open -n -W -o "$qa_output_dir/self-test.json" 'dist/qa/Shot Clip QA.app' --args --self-test
```

Inspect the harness JSON PASS/FAIL/SKIP, not `open`'s status. It compares synthetic screen colors/pixels in memory and uses a unique named pasteboard; missing access is SKIP, never PASS. Do not run this route on the published app, which rejects it.

## Extended coverage

Clean-account first launch, macOS 14/other OS versions, Intel, mixed-scale/multiple displays, keyboard input sources, VoiceOver/full focus and normal capture/paste/save require distinct runs. Developer ID/notarization is a separate route. Public delivery needs exact source/tag/artifact/download/feed/install equality and scoped cleanup, as described in [operations](releasing.md).
