# Shot Clip

[한국어](README.ko.md)

![Shot Clip — Capture. Copy. Continue.](docs/shotclip/assets/shotclip-hero.png)

Capture part of your screen, then paste it wherever you need it. Shot Clip lives in the macOS menu bar and copies your selection straight to the clipboard.

**[Download Shot Clip 0.8.1 (ZIP)](https://github.com/kyungseok-lee/shotclip/releases/download/v0.8.1/shotclip-0.8.1.zip)** · [Latest release](https://github.com/kyungseok-lee/shotclip/releases/latest)

Requires **macOS 14 or later and Apple Silicon (arm64)**. The current preview is ad-hoc signed and **not notarized by Apple**.

## Install and allow capture

1. Unzip the download, move **Shot Clip.app** to **Applications**, and open it there.
2. If macOS blocks the first launch, check that you trust the download, then use **System Settings → Privacy & Security → Open Anyway** when offered after attempting to open it. See [Apple’s first-launch guidance](https://support.apple.com/en-us/102445).
3. If the menu shows **Enable Screen Recording…**, choose it, then **Allow Screen Recording**. Allow Shot Clip in macOS **Screen Recording** settings; some versions call it **Screen & System Audio Recording**. If capture commands are already available, you can skip the permission steps and start capturing.
4. Return to **Settings… → Access** and choose **Check Again**. If access is still unavailable, restart Shot Clip.

## Capture and paste

Open the Shot Clip menu and choose a mode:

- **Capture Area:** drag across the area you want, then release to capture and copy it.
- **Fixed Region:** move the selection or drag its handles, then press **Return** or **Capture**. It reuses the last selection during the current app session; the region resets after restarting.

Paste the copied image into an image-capable app with **⌘V**. In macOS Preview, **⌘N** creates an image from the clipboard.

The default shortcut **⌃⇧⌘5** (Control–Shift–Command–5) opens your last used capture mode. The first mode is Capture Area; your mode choice and custom shortcut are remembered. Keep Shot Clip running for the shortcut to work. In **Settings… → General**, click the button showing the current shortcut beside **Capture shortcut**, then press a new combination. Use Command or Control together with Shift or Option; Escape cancels recording.

| During selection | Action |
| --- | --- |
| Escape | Cancel without changing the clipboard |
| Return | Capture the selected region |
| M | Switch between Capture Area and Fixed Region |
| Arrow keys / Shift + arrows | Move by 1 / 10 points |
| Option + arrows | Resize from the upper-right corner |
| Tab / Shift + Tab | Move control focus forward / backward |

Each selection stays within one display.

## Preview or save

After a successful copy, a thumbnail appears briefly at the lower right. Click it to open the original capture. **Fit** and **100%** change the viewing scale; **Save…** exports the original as a PNG to a location you choose.

Dismissing the thumbnail, closing the preview, or canceling Save leaves the clipboard intact. You can still paste the copied image after the thumbnail disappears.

## Settings

Choose **Settings…** from the menu bar:

- **General:** change the capture shortcut, enable **Launch at login**, or choose **English / 한국어**. English is the default; language changes apply immediately and retain your place in settings.
- **Access:** check Screen Recording access, open macOS settings, or find restart and app-location recovery under **Troubleshooting…**.
- **Updates:** choose **Check for Updates…** or enable **Automatically check for updates**. Automatic checks start off on a fresh installation; your existing choice is retained. Installing an update requires confirmation.

## If something is not working

- **Capture commands are missing:** choose **Enable Screen Recording…** and allow the running copy of Shot Clip. Return to Access, choose Check Again, then restart if needed.
- **Access stopped working after an update:** the ad-hoc replacement may need permission again. In **Access → Troubleshooting… → Show in Finder**, confirm you are running the Applications copy, allow it in Screen Recording, and restart.
- **The shortcut does nothing:** make sure Shot Clip is running. In General, click the current shortcut button to record a different combination if another app uses it.

## Privacy

Shot Clip keeps its thumbnail and preview in memory. It does not automatically save captures, keep a disk history, or upload captured images. Capture files are created only when you choose Save. Canceling a selection preserves the existing clipboard; a successful copy replaces it with the image.

Only Screen Recording access is needed. Accessibility and Full Disk Access permissions are not required. Update checks contact GitHub to retrieve update information.

## Development

For building from source and the separate development QA app, see the [development guide](docs/shotclip/development-plan.md), [QA guide](docs/shotclip/qa-plan.md), and [documentation index](docs/shotclip/README.md).
