# Shot Clip design system

[Usage](../../README.md) · [Requirements](requirements.md) · [Architecture decisions](architecture.md#decision-register)

## Native foundations

Keep the capture path short and explicit. Ready menus show Capture Area first and Fixed Region second; unavailable menus lead to Access instead of unusable actions. General, Access and Updates use native controls, semantic colors and a 44×44 pt icon rail. Success uses a lower-right thumbnail after clipboard commit; recovery uses clear words plus status/icon, with long diagnostics collapsed.

## Semantic tokens

| Role | Value / native mapping |
| --- | --- |
| Primary / secondary / disabled text | `labelColor` / `secondaryLabelColor` / `disabledControlTextColor` |
| Window / control surface | `windowBackgroundColor` / `controlBackgroundColor` |
| Accent / separator / focus | System accent / separator / native focus ring |
| Ready / attention / error | System green/orange/red plus words and icon |
| Body / caption / section / title / shortcut | Roboto/Noto Sans KR: 13 / 12 / 14 semibold / 18 semibold / 13 medium pt |
| Inline / group / section / inset | 8 / 12 / 16 / 20 pt; settings use 24 pt section gaps/28 pt body inset |
| Selection | Contrasting outline, visible 8 pt handles with at least 24 pt hit regions, 35% black scrim baseline |

Use semantic colors in the active appearance; do not persist resolved colors. Reduce Transparency gets opaque help/control surfaces. Tokens and labels are intended accessibility support, not proof of universal contrast, VoiceOver or all focus behavior.

## Settings geometry and typography

R14/R15 → D17 → P9 fixes default content at 720×580 pt, minimum 620×480 pt and a common 160 pt action/shortcut/popup/version lane. Body/caption/section/title nominal line reservations are 20/18/22/28 pt. Per-label common bilingual reservations can rise to contain resolved fallback glyph ink; never cap a line below its real ink. Keep at least 12 pt vertical row padding.

At the same state/size, en→ko→en preserves window, rail/header, headings, rows/cards, labels/control composites, separators/footer, document extent, focus and scroll. Measure supported alternatives at actual width, including permission location and dynamic states. Long arbitrary diagnostics may expand the common reservation after state changes/resize. Small windows can scroll; text must not clip, collide or shrink to fit. The [fixture proof](qa-results.md#current-evidence) covers full structural frames and tight per-line glyph paths.

## Components and permissions

| Component | Behavior |
| --- | --- |
| Menu | Native remembered-mode shortcut column; Settings `⌘,`, Quit `⌘Q`; explicit Access when unavailable |
| General | Capture/shortcut actions and app login/language controls; omit redundant ready-state guidance |
| Access | Effective status, explicit request/settings/recheck/restart recovery and collapsed troubleshooting |
| Selection toolbar | Compact native cancel/mode/capture controls, dimensions and visible keyboard focus |
| Original preview | Nonactivating thumbnail; same original Fit/100%; Save… opens a native PNG export sheet; dismiss/timeout/replacement releases memory |
| Update dialogs | Content-sized native public driver, retained callbacks/state, bounded plain-text notes/HTTPS links |

Do not prompt for system permission at launch or imply Boolean preflight proves grant history. Denial keeps settings/language/quit usable. macOS prompts follow OS language; app relabeling and permission-related restart are separate.

## Keyboard and localization

| Action | Key / behavior |
| --- | --- |
| Open last mode | Configurable global `⌃⇧⌘5` while running |
| Capture / cancel | Return/keypad Enter for a valid Fixed Region; Escape cancels |
| Move / resize | Arrows 1 pt; Shift 10 pt; Option resizes upper-right; Option+Shift 10 pt |
| Focus / mode | Tab/Shift-Tab traverses native controls; `M` switches mode |
| Original save | Native **Save…** button or `⌘S` in original preview exports PNG |

English is the default/fallback; explicit `en`/`ko` persists and updates app-owned UI immediately without rebuilding services or losing state. Keep Shot Clip/API identifiers unchanged. Korean and shortcut glyphs use the bundled cascade/system fallback. Actual full accessibility/input-source/alternate hardware checks remain bounded in QA.

## Icon and brand artwork

The original crop mark with offset copy sheet represents region-to-clipboard and matches the template menu glyph. It contains no captured screen or text. [Icon source](../../scripts/generate-app-icon.swift) creates ten PNG representations for static 16–1024 px ICNS packaging. This does not claim Icon Composer layers or adaptive system effects.

The [hero PNG](../shotclip/assets/shotclip-hero.png)/[SVG](../shotclip/assets/shotclip-hero.svg) and [icon PNG](../shotclip/assets/shotclip-icon.png)/[SVG](../shotclip/assets/shotclip-icon.svg) are synthetic artwork. Both READMEs provide localized alternative text. From the repository root, an authorized artwork change can regenerate them with `swift scripts/generate-app-icon.swift 'dist/visual-qa/Shot Clip.iconset' --brand-assets docs/shotclip/assets`. Artwork was not regenerated for this reorganization.

## Security and QA boundaries

R11/R13 → D18 → P10 keeps UI review separate from product capture. Public builds contain no QA dispatch/hooks; `SHOTCLIP_QA` exists only in the explicit isolated development flavor. Integer-zero signed-feed failure expiry prevents elapsed-time acceptance of invalid signatures; later valid feeds remain eligible. Bundled fonts/localization remain self-contained, with no source/build resource fallback or prohibited developer-path metadata. Developer details belong in [QA procedures](qa-plan.md), not the product flow.
