# Shot Clip technical validation

[Architecture](architecture.md) · [QA procedures](qa-plan.md) · [Executed evidence](qa-results.md#current-evidence--082-build-12)

## Current evidence and environment

0.8.2 (build 12) prepared/public/manually installed payload and bounded native runtime are verified in the current QA ledger. Same-payload cold restart after scoped cleanup passes without build caches. Earlier 0.8.1 cold-restart/update evidence remains historical. Recorded host: macOS 27.0.1, Xcode 27.0, Swift 6.4, arm64. macOS 14 is the deployment minimum; macOS 14/Intel/clean-account runtime, full accessibility, real current-version capture/paste/grants/native-save and a live invalid-feed expiry-time experiment are unrun. Current 0.8.2 checks and historical probes are distinguished by their exact source and inputs.

Official API/source consultation informs decisions; it is not runtime PASS. Preserve proposal, pinned source, executed logic/synthetic/native tests and unsupported environments as distinct evidence.

## Capture, clipboard and export APIs

| Primary source | Adopted implication / limit |
| --- | --- |
| [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager), [SCContentFilter](https://developer.apple.com/documentation/screencapturekit/sccontentfilter) | Capture one display region, exclude app UI/cursor; actual pixel/exclusion needs capture evidence |
| [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen) | Convert global points/display scale explicitly; do not infer active display from array order |
| [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard) | Pre-encode and guarded generation checks/rollback; no unconditional atomic replacement guarantee |
| [NSSavePanel](https://developer.apple.com/documentation/appkit/nssavepanel), [Data.write](https://developer.apple.com/documentation/foundation/data/write(to:options:)) | Native accepted destination only; atomic original PNG write; cancellation is not a save |
| [CoreText process font registration](https://developer.apple.com/documentation/coretext/ctfontmanagerregisterfontsforurl(_:_:_:)) | Bundle fonts/cascade locally; do not install fonts for the user |

## Settings typography sources

Apple DocC sources were checked by a separate specialist on 2026-10-06 KST; repository references were read first and `chub` was unavailable.

| Primary source | Implementation implication |
| --- | --- |
| [minimumLineHeight](https://developer.apple.com/documentation/appkit/nsparagraphstyle/minimumlineheight), [maximumLineHeight](https://developer.apple.com/documentation/appkit/nsparagraphstyle/maximumlineheight), [lineSpacing](https://developer.apple.com/documentation/appkit/nsparagraphstyle/linespacing) | A cap below fallback glyph ink can overlap lines; reserve common bilingual safe height |
| [preferredMaxLayoutWidth](https://developer.apple.com/documentation/appkit/nstextfield/preferredmaxlayoutwidth), [maximumNumberOfLines](https://developer.apple.com/documentation/appkit/nstextfield/maximumnumberoflines) | Measure complete text at actual assigned width; permit wrapping without a hidden line cap |
| [usedRect](https://developer.apple.com/documentation/appkit/nslayoutmanager/usedrect(for:)), [glyph boundingRect](https://developer.apple.com/documentation/appkit/nslayoutmanager/boundingrect(forglyphrange:in:)), [glyph location](https://developer.apple.com/documentation/appkit/nslayoutmanager/location(forglyphat:)) | Check layout/cell/full ink bounds and line baselines, including negative protrusion |
| [CTLine tight glyph bounds](https://developer.apple.com/documentation/coretext/ctlineboundsoptions/useglyphpathbounds), [CTLineGetBoundsWithOptions](https://developer.apple.com/documentation/coretext/ctlinegetboundswithoptions(_:_:)) | Tight path ink avoids variable-font face-box false collisions while retaining real adjacent-line checks |
| [NSStackView hugging](https://developer.apple.com/documentation/appkit/nsstackview/sethuggingpriority(_:for:)), [alignmentRectInsets](https://developer.apple.com/documentation/appkit/nsview/alignmentrectinsets) | Stacks lack intrinsic size; use stack hugging/constraints and native alignment/title ink rather than guessed control heights |

D17's 13/12/14/18 pt roles and nominal 20/18/22/28 pt lines are project choices raised when fallback ink requires it. Full paired geometry proves language invariance; independent non-clipping checks alone do not. The earlier combining-mark/emoji apparent collision was a QA face-box false positive, corrected to tight CoreText paths at TextKit baselines before accepted evidence.

## Signed feed and artifact sources

[Sparkle customization](https://sparkle-project.org/documentation/customization/) and the [pinned 2.10.0 appcast driver](https://github.com/sparkle-project/Sparkle/blob/eef1a539a373c1f1a320624b1130fc5de7b2e100/Sparkle/SUAppcastDriver.m#L136) establish that numeric zero disables signed-feed failure expiry. Current exact integer-zero configuration therefore prevents elapsed-time invalid-signature fallback while retaining later valid-feed retry. Both feed and archive authentication/pre-extraction checks stay enabled; source interpretation is distinct from a live time/network experiment.

Swift [SE-0274](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0274-magic-file.md) / [SE-0362](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0362-piecemeal-future-features.md) explain concise file IDs in Swift 5 mode; prefix-map help alone does not promise remapping runtime `#filePath`. [Swift driver options](https://github.com/swiftlang/swift-driver/blob/main/Sources/SwiftOptions/Options.swift) and local compiler help support metadata/RPATH flags. Apple's [install_name_tool source](https://github.com/apple-oss-distributions/cctools/blob/main/misc/install_name_tool.c) documents narrow RPATH deletion and signature invalidation, so removal precedes final signing.

Manual native resources eliminate the generated absolute SwiftPM accessor. Final scans, not flag assumptions, prove path purity across all regular files/symlinks/Mach-O code; UTF-16 alignments, case, own QA markers and escaping RPATH negatives are covered. The production/QA split is explicit, not inferred from DEBUG or ad-hoc signing. [Security review](../shotclip/qa-review-0.8.1.md) and [delivery review](../shotclip/release-review-0.8.1.md) cover separate frozen inputs.
