# Developing Shot Clip

[User guide](../user-guide.md) · [Documentation index](../README.md)

## Build from source

Use macOS with Xcode and its selected command-line tools, Swift and Python 3. The package declares Swift tools 5.9 and macOS 14 minimum runtime, and pins Sparkle 2.10.0. The public app targets Apple Silicon; package availability does not establish Intel support.

Run commands from the repository root. Quit every Shot Clip process before building or replacing its generated bundle. With release-related environment overrides unset:

```sh
bash scripts/build-app.sh
open 'dist/Shot Clip.app'
```

The build creates an ad-hoc signed production-flavor bundle in `dist/Shot Clip.app`, using `.build/production`. It neither installs nor publishes the app. Normal development launches share `dev.shotclip.app` preferences with the installed app and initialize ordinary updater/permission services. Use the isolated QA build for inert checks.

## Developer reference

| Document | Purpose |
| --- | --- |
| [Requirements](requirements.md) | Current feature scope and acceptance criteria |
| [Architecture](architecture.md) | Source map, capture lifecycle, clipboard/privacy and update boundaries |
| [Design system](design-system.md) | Native components, typography, layout, keyboard and localization rules |
| [Testing](testing.md) | Automated commands, isolated fixtures, manual acceptance and coverage limits |
| [Releasing](releasing.md) | Reviewed source/tag, signing, GitHub publication and installation |

## Working rules

Inspect Git status before starting and preserve unrelated user changes. Update the applicable current reference when behavior changes. Verify the change in a separate review pass and report executed checks, unrun coverage and actual commit/push status. Development diaries, dated review ledgers and per-release execution logs do not belong in maintained documentation.

Never log captured images, screen content, observed app/window names, clipboard contents or chosen export paths. Do not mutate the general clipboard or grant/reset Screen Recording permission merely to run an inert test. Keep release tags and the established Sparkle signing key intact.
