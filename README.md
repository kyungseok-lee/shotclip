# Shot Clip

[한국어](README.ko.md)

![Shot Clip — Capture. Copy. Continue.](docs/shotclip/assets/shotclip-hero.png)

Capture part of your screen, copy it immediately, then paste wherever you need it. Shot Clip is a macOS menu bar app with two selection modes and an optional original-image preview and PNG export.

**[Download the latest release](https://github.com/kyungseok-lee/shotclip/releases/latest)**

Requires **macOS 14 or later and Apple Silicon (arm64)**. The public preview is ad-hoc signed and **not notarized by Apple**. macOS may block first launch, and an update may require Screen Recording permission again.

## Get started

1. Download the ZIP, unzip it, move **Shot Clip.app** to **Applications**, and open it there. If blocked, follow [Apple’s first-launch guidance](https://support.apple.com/en-us/102445).
2. Choose **Enable Screen Recording…** when shown, allow Shot Clip in macOS settings, then use **Settings… → Access → Check Again**. Restart if necessary.
3. Choose **Capture Area**, drag and release, then paste with **⌘V** in an image-capable app. In Preview, use **⌘N**.

The default shortcut **⌃⇧⌘5** opens your last capture mode while Shot Clip is running. **Fixed Region** lets you move/resize a selection and confirm with Return. Escape cancels without changing the clipboard. After copying, click the thumbnail to preview or save the original PNG.

## Privacy and settings

Captures and previews stay in memory; files are created only when you choose **Save…**. There is no automatic capture history or image upload. Only Screen Recording access is required. Update checks retrieve information from GitHub.

Settings contains **General** (shortcut, login start, English/Korean), **Access** (permission and recovery), and **Updates** (manual and optional automatic checks). English is the default. Automatic checks are off for a fresh installation; existing choices are retained.

## Documentation

- [App user guide](docs/user-guide.md): installation, capture controls, preview/save, settings and troubleshooting.
- [Developer guide](docs/development/README.md): build, architecture, requirements, QA and release operations.
- [Documentation index](docs/README.md): current guides and frozen historical evidence.

Korean documentation is maintained in [README.ko.md](README.ko.md). Detailed user and developer guides are maintained in English.
