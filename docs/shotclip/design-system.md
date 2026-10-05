# Shot Clip design system

[Usage](../../README.md) · [Requirements](requirements.md) · [Architecture decisions](architecture.md#decision-register) · [한국어](#한국어)

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

<a id="2026-10-06-language-invariant-settings-design"></a>
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

The [hero PNG](assets/shotclip-hero.png)/[SVG](assets/shotclip-hero.svg) and [icon PNG](assets/shotclip-icon.png)/[SVG](assets/shotclip-icon.svg) are synthetic artwork. Both READMEs provide localized alternative text. From the repository root, an authorized artwork change can regenerate them with `swift scripts/generate-app-icon.swift 'dist/visual-qa/Shot Clip.iconset' --brand-assets docs/shotclip/assets`; this documentation refresh does not run that command.

<a id="2026-10-06-d18-security-and-qa-boundaries"></a>
## Security and QA boundaries

R11/R13 → D18 → P10 keeps UI review separate from product capture. Public builds contain no QA dispatch/hooks; `SHOTCLIP_QA` exists only in the explicit isolated development flavor. Integer-zero signed-feed failure expiry prevents elapsed-time acceptance of invalid signatures; later valid feeds remain eligible. Bundled fonts/localization remain self-contained, with no source/build resource fallback or prohibited developer-path metadata. Developer details belong in [QA procedures](qa-plan.md), not the product flow.

## 한국어

캡처 경로는 선택 → 복사 → 붙여 넣기이며 권한이 없을 때는 Access로 안내합니다. native 색/컨트롤, 44×44pt rail과 읽기 쉬운 Roboto/Noto Sans KR를 사용합니다. 기본 720×580/최소 620×480pt와 160pt 공통 폼 폭에서 두 언어의 전체 배치·잉크·포커스·스크롤을 유지하고 긴 문구는 감추거나 축소하지 않습니다.

Return/Escape, 화살표/Option 크기 조절, Tab 포커스와 M 전환을 제공하고 앱 문구는 언어 선택 즉시 바뀝니다. 원본 보기/PNG 저장은 복사 이후 선택 사항입니다. 실제 접근성 전체 검증은 별도이며 production QA 실행 경로·개발자 경로는 배포물에 포함하지 않습니다.

<details>
<summary>Historical font provenance evidence</summary>

The following source/licensing record was reviewed with the earlier UI refresh. It is retained for the immutable review link, not a pending refresh or release note.

### Font provenance

Roboto is a free Google Fonts face with an official historical [most-popular-download statement](https://m3.material.io/blog/roboto-flex) dated 2022-05-05. On 2026-10-05, [Google Fonts metadata](https://fonts.google.com/metadata/fonts) places Roboto in the top available popularity tier, tied with Google Sans; the [Most popular browse view](https://fonts.google.com/?sort=popularity) displays Google Sans first/Roboto second and explains a ranking that blends several factors. Do not claim a unique current global number-one font. Noto Sans KR leads Korean-supporting families in that metadata.

Bundled provenance and actual retrieved binary hashes are recorded in [the font resource notice](../../Sources/shotclip/Resources/Fonts/README.txt).

Bundle unchanged [Roboto](https://github.com/google/fonts/tree/main/ofl/roboto) and [Noto Sans KR](https://github.com/google/fonts/tree/main/ofl/notosanskr) binaries and each full SIL OFL1.1 license/copyright. [CoreText URL registration](https://developer.apple.com/documentation/coretext/ctfontmanagerregisterfontsforurl(_:_:_:)) with [process scope](https://developer.apple.com/documentation/coretext/ctfontmanagerscope/process) never installs fonts globally. Central font descriptors explicitly apply the `wght` variation and Korean [cascade](https://developer.apple.com/documentation/appkit/nsfontdescriptor/attributename/cascadelist); Noto’s variable base PostScript name is `NotoSansKR-Thin`, so verify actual400/500/600 weights. App-owned menus can use documented [NSMenu.font](https://developer.apple.com/documentation/appkit/nsmenu/font). Packaging/glyph rendering require separate proof.

</details>

<details>
<summary>Historical evidence referenced by retained QA records</summary>

These original dated records preserve their actual scope; their old current/candidate/pending wording does not describe the installed app or this documentation-only task.

## 2026-10-05 UNRELEASED design-system refresh

The current contract extends the approved 0.6 presentation with the eight requested improvements. It supersedes earlier active wording about permission-menu availability, system-only type, fixed updater sizes and success notices; dated evidence remains unchanged. Public/installed 0.6.0(8) is still source `e87e40e…`; this development candidate is unreleased. Four 136-view language/appearance fixtures, final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`.

## Workflow evidence and approved 0.6 direction

The coordinator reviewed public product pages on 2026-10-05: [Shottr](https://shottr.cc/) emphasizes quick area capture, clipboard and keyboard nudges; [CleanShot X](https://cleanshot.com/) describes drag capture, quick copy and custom shortcuts; [ScreenFloat](https://eternalstorms.at/ScreenFloat/) provides explicit keyboard/menu capture and recapture; [Apple’s screenshot guide](https://support.apple.com/en-us/102646) describes crosshair drag/release, Escape and clipboard modifiers. These are website observations, not tests of third-party apps. Our inference is to prioritize capture intent, keyboard access and immediate copy; no third-party interface/artwork is copied and no feature expansion follows.

Use native [NSMenu](https://developer.apple.com/documentation/appkit/nsmenu), [NSStatusItem](https://developer.apple.com/documentation/appkit/nsstatusitem), [menus](https://developer.apple.com/design/human-interface-guidelines/menus) and [controls](https://developer.apple.com/design/human-interface-guidelines/controls) on macOS 14+. Keep semantic AppKit colors and restrained materials; do not require newer glass APIs. The visible name is **Shot Clip**, while stable identifiers, executable, repo, resource bundles and update trust remain unchanged.

| Surface | Approved 0.6 behavior |
| --- | --- |
| Menu | Capture Area (drag) first, Fixed Region second; configured native shortcut column only on the remembered mode; when access is unavailable, omit both capture commands and show explicit Access; Settings, Check for Updates, Quit remain native menu items |
| Lifecycle | Show the first 0.5 setup once without a system permission prompt; later launches quiet; Finder reopen opens Settings; preserve existing valid shortcut/mode, fresh users default to drag |
| General | External Capture/App headings and grouped shortcut/mode/login/language rows; native switches/popup; English/Korean applies immediately and persists |
| Access | Screen Recording status and primary request row; System Settings/Check Again on separate recovery rows; restart/location/diagnostics in a leading disclosure |
| Updates | Version, automatic-check switch and manual-check rows under Software updates; busy/unconfigured states, concise preview footers; automatic checks default OFF |
| Selection | Compact Apple-reference rounded HUD with close, supported icon mode controls, group dividers and Capture; crosshair and dimensions; drag begins with zero selection; M/Tab/Return/Escape and native focus contract retained |
| Brand | Preserve the existing square-canvas/square-tile crop mark plus offset copy sheet; matching monochrome template menu glyph; no landscape/photo-editor metaphor or screenshot content |

Render inert synthetic UI previews in English/Korean, light/dark, default/minimum sizes and all panes using actual native views. Layout callbacks bypass preferences, hotkeys, updater, TCC, real capture and the general clipboard; the integrated capture-preview fixture uses synthetic pixels and a private named pasteboard. Layout renders prove presentation only. Real capture/permissions/paste and VoiceOver remain separate user-owned evidence.

Carbon retains one physical global registration. Plain capture menu titles use native `keyEquivalent` / `keyEquivalentModifierMask` from saved physical key/current keyboard layout, only on the remembered-mode row. Settings uses the same presentation with shared app typography; native key-equivalent rendering remains AppKit-owned. Native equivalents dispatch app-local actions; both paths retain single-flight behavior and need dispatch-count checks. Keep Settings `⌘,` / Quit `⌘Q`. Unmapped codes use localized key-code help and an empty native equivalent; do not derive a key from a display label. Apple documents [keyEquivalent](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalent), [modifier masks](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalentmodifiermask) and [menu dispatch](https://developer.apple.com/documentation/appkit/nsmenu/performkeyequivalent(with:)).

</details>
