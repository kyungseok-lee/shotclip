# Shot Clip design system

[Product plan](product-plan.md) · [Development plan](development-plan.md) · [QA plan](qa-plan.md) · [한국어](#한국어)

## 2026-10-05 0.7.0 design-system candidate

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

Carry the existing token/component contracts into 0.7: Roboto/Noto Sans KR and full OFL notices, complete multiline metrics/padding, physical 44×44 rail/highlights, unchanged square app artwork, measured updater and Apple-reference HUD, success-only thumbnail/original/native PNG. R14/R15/R18 and D11/D13/D15/D16 retain the exact definitions below. Inspect the new-version bundle and normal runtime separately from prior fixture renders; complete accessibility/OS/hardware coverage remains a separate gate.

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

Vendor license integrity: keep both full upstream OFL files byte-for-byte, including their line21 trailing spaces. A two-exact-path `.gitattributes` `whitespace=-blank-at-eol` rule covers only Roboto-OFL.txt and NotoSansKR-OFL.txt; staged whitespace check passes while authored trailing-space and license EOF checks still reject defects. This repository rule changes no font/app runtime behavior; independent staged verification is separate.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

## 2026-10-05 UNRELEASED design-system refresh

The current contract extends the approved 0.6 presentation with the eight requested improvements. It supersedes earlier active wording about permission-menu availability, system-only type, fixed updater sizes and success notices; dated evidence remains unchanged. Public/installed 0.6.0(8) is still source `e87e40e…`; this development candidate is unreleased. Four 136-view language/appearance fixtures, final sealed development-bundle checks and a 62-assertion native PNG save gate passed; author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md`.

### Shared foundations and reusable components

`Sources/shotclip/DesignTokens.swift` owns app typography, semantic surfaces and state colors, spacing, control/rail/window/update/toolbar/thumbnail metrics and wrapping-label/card primitives. Shared `WrappingLabel` measures actual attributed TextKit line and glyph ink extents plus native cell drawing insets at the assigned width, so Korean or shortcut fallback glyphs cannot inherit an underestimated primary-face height. `SettingsWindow.swift`, `LocalizedUpdateDriver.swift`, `Overlay.swift` and `CapturePreview.swift` consume these values. Change the role token first, then inspect every consumer in both languages/appearances; avoid ad hoc fixed label heights or per-screen font substitutions. macOS-owned dialogs and the native menu key-equivalent column retain system rendering.

| Role | Current project value / rule |
| --- | --- |
| Body / caption / section / title / shortcut | Roboto 13 / 12 / semibold 14 / semibold 18 / medium 13 pt; Noto Sans KR cascade at matching weight; system fallback when bundled fonts cannot resolve |
| Tight / inline / group / section / inset | 4 / 8 / 12 / 16 / 20 pt; settings body 28 pt and section 24 pt; panel 24 pt |
| Settings row / card | 16 pt horizontal, minimum 12 pt above/below complete multiline content, 8 pt radius; nested wrapping labels receive actual available width |
| Settings rail | 72 pt rail, three true 44×44 pt buttons, 12 pt gaps, 10 pt selected-highlight radius; constrain the stack height so icons cannot stretch into tall tiles |
| Update notices / notes | 420 / 520 pt base width; measured text/action heights,24 pt insets,12 pt vertical gaps;188 pt notes viewport; no empty fixed-height result area |
| Capture toolbar | 62 pt compact HUD,13 pt corners,8 pt inset,44 pt close/mode controls,46 pt mode width; centered24 pt above screen bottom; localized tooltips and visible selected state |
| Thumbnail / original | Base 220×152 pt thumbnail,24 pt display-edge inset,12 pt internal padding; clamp to visible frame, proportionally fit original; preview has Fit/100% and explicit PNG save |

These dimensions are project choices, not measurements mandated by Apple. Validate complete text cell/glyph bounds and assigned width, including more than two lines, against rows/cards/separators/footer/document bounds; allow scroll rather than clip. Preserve the prior unreleased settings-polish fixes and meaningful permission/update/ad-hoc help. Layout/source assertions do not establish VoiceOver or complete native focus acceptance.

### Font provenance

Roboto is a free Google Fonts face with an official historical [most-popular-download statement](https://m3.material.io/blog/roboto-flex) dated 2022-05-05. On 2026-10-05, [Google Fonts metadata](https://fonts.google.com/metadata/fonts) places Roboto in the top available popularity tier, tied with Google Sans; the [Most popular browse view](https://fonts.google.com/?sort=popularity) displays Google Sans first/Roboto second and explains a ranking that blends several factors. Do not claim a unique current global number-one font. Noto Sans KR leads Korean-supporting families in that metadata.

Bundled provenance and actual retrieved binary hashes are recorded in [the font resource notice](../../Sources/shotclip/Resources/Fonts/README.txt).

Bundle unchanged [Roboto](https://github.com/google/fonts/tree/main/ofl/roboto) and [Noto Sans KR](https://github.com/google/fonts/tree/main/ofl/notosanskr) binaries and each full SIL OFL1.1 license/copyright. [CoreText URL registration](https://developer.apple.com/documentation/coretext/ctfontmanagerregisterfontsforurl(_:_:_:)) with [process scope](https://developer.apple.com/documentation/coretext/ctfontmanagerscope/process) never installs fonts globally. Central font descriptors explicitly apply the `wght` variation and Korean [cascade](https://developer.apple.com/documentation/appkit/nsfontdescriptor/attributename/cascadelist); Noto’s variable base PostScript name is `NotoSansKR-Thin`, so verify actual400/500/600 weights. App-owned menus can use documented [NSMenu.font](https://developer.apple.com/documentation/appkit/nsmenu/font). Packaging/glyph rendering require separate proof.

### Capture presentation

Use the [Apple screenshot toolbar and floating-thumbnail guide](https://support.apple.com/guide/mac-help/mh26782/mac), checked 2026-10-05, as a visual reference: one rounded material panel; circular close; related icon mode toggles with selected tile; group separators; primary Capture. Shot Clip exposes only its two supported capture modes. [`NSVisualEffectView`](https://developer.apple.com/documentation/appkit/nsvisualeffectview) with `.hudWindow`/behind-window material follows the panel role; keep semantic colors, contrast and Reduce Transparency handling.

Remove the old upper-right success notification. After successful clipboard commit, show a nonactivating lower-right thumbnail on the capture screen, with proportionally fitted synthetic/original image, explicit close and localized accessible open action. Timeout dismisses it after 8 seconds; hover pauses dismissal. Clicking opens the original image; Fit changes presentation only and 100% uses the backing scale so one image pixel maps to a display pixel. Save PNG uses [`NSSavePanel`](https://developer.apple.com/documentation/appkit/nssavepanel) only after deliberate user action. No automatic save/history occurs; closing or cancelling never clears/replaces the clipboard. Announce completion accessibly without restoring a success notice.

The screenshots supplied for item5 show the settings rail’s stretched icon tile. Fix its 44×44 pt button/highlight geometry. Existing app artwork already has a 1024×1024 canvas and 832×832 rounded square tile; preserve the crop/copy design and audit all ten ICNS representations. This request does not require newly generated icon artwork.

한국어: 중앙 `DesignTokens.swift`에서 Roboto/Noto Sans KR·의미 색상·여백·크기·모서리·여러 줄 primitive를 관리합니다. 세 rail 버튼/선택 배경은 실제44×44pt로 고정하고 기존 정사각형 앱 아이콘은 보존·검사합니다. 업데이트 결과는420pt 기본 폭과 내용 높이, 노트 창은520pt 기준으로 계산합니다. 두 줄을 넘는 실제 문구의 너비·전체 높이·12pt 위아래 여백을 확인합니다. Apple 참고 HUD는 닫기/두 모드/캡처를 묶고 성공 뒤 우측 하단 썸네일을 표시합니다. 클릭하면 원본/Fit/100%/PNG 저장을 제공하며8초 timeout·닫기·저장 취소에도 클립보드는 유지합니다. 폰트는 OFL을 포함해 프로세스에만 등록하고 현재 단독 인기1위라고 주장하지 않습니다.

## 2026-10-05 UNRELEASED settings polish

Screenshot feedback prompted a local settings refinement: remove the immediate-language-apply footer, repeated update-verification footer and configured-ready manual-check subtitle. Preserve capture instructions, permission/recovery help, busy/unconfigured/error statuses and the ad-hoc/Screen Recording warning. Meaningful state help remains accessible; ready controls need no repeated security explanation.

Wrapping labels receive their assigned width, update intrinsic height when that width changes and fill their nested columns. Composite native controls hug their contents; headings occupy the section width. Rows and footers reserve at least 12 pt above/below complete multiline labels, while scrollable content may extend beyond the viewport. Public AppKit alignment rectangles distinguish native control ornamentation from content; full text-field bounds remain checked.

The author matrix passed English/Korean × light/dark × 720×560/620×480 pt with ready, access-needed, troubleshooting, login-approval, busy, unconfigured, error and targeted long-status fixtures. Full text, nested widths, headings, padding and card/separator/footer bounds are checked; [QA](qa-results.md#2026-10-05-unreleased-settings-polish) records counts and limits. This is unreleased author evidence awaiting independent review. Published/installed 0.6.0(8), source `e87e40e…`, remains the baseline; new deployment follows the explicit trigger in [AGENTS](../../AGENTS.md#최신-배포-요청-규칙).

한국어: 아직 배포하지 않은 설정 개선입니다. 즉시 적용·반복 서명 안내와 준비 상태 설명은 줄이고 실제 상태·캡처·권한·ad-hoc 경고는 유지합니다. 중첩 문구의 실제 너비에 맞춰 높이를 계산하고 전체 여러 줄 문구 위아래 12pt 이상 여백을 확인합니다. 영어/한국어·밝음/어두움·기본/최소 크기 합성 검증은 작성자 근거이며 독립 검토와 명시적인 최신 배포 요청은 별도입니다.

Reviewed 2026-10-05 against Apple primary sources and the AppKit baseline. This contract does not prove rendered UI/accessibility. **2027 TREND PREDICTION is our hypothesis, not an Apple roadmap or verified future fact.** It justifies no scope/OS expansion; reassess in 2027 with observed guidance and usability evidence.

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

## Reference-style native settings contract

The 0.6 blueprint adopts the supplied reference’s icon rail, external headings and aligned native controls using existing Shot Clip features. Image pixels are not point measurements; these values are project layout choices. Reconcile implementation and inert renders before acceptance. Cloud, window management, default-mode and Help/About features from references are excluded.

| Element | Layout and behavior |
| --- | --- |
| Window | Ordinary titled native resizable/closable window with hidden title and transparent title bar; no full-size content view; default content 720×560 pt, minimum 620×480 pt; derive minimum frame from content |
| Rail | 72 pt wide; three explicitly constrained 44×44 pt General/Access/Updates icon buttons and square selected highlights, 22 pt symbols, 12 pt gaps; localized tooltip/label/selected value and native focus ring |
| Material | Semantic sidebar material/accent selection; opaque Reduce Transparency fallback; native traffic lights and system colors |
| Header/body | 56 pt header, 18 pt semibold title and separator; scroll body insets 28 pt horizontal, 22 pt top, 24 pt bottom; no product hero/segmented navigation |
| Sections/groups | 14 pt semibold external headings, 10 pt heading gap, 24 pt section gap; 8 pt radius, no shadow, semantic window fill and unmodified separator border |
| Rows | 16 pt horizontal/12 pt vertical insets, 13 pt labels/12 pt wrapping descriptions, inset hairlines; grow/scroll for long text |
| Controls | Real login/update `NSSwitch`, language `NSPopUpButton`, rounded action/recorder buttons with intrinsic size; shared Roboto/Noto Sans KR shortcut presentation |
| State | Retain pane, disclosure, scroll/focus, mode/region, permission/login/update state and pending work during language refresh; permission Restart remains |

General has Capture and App groups; Access has Screen Recording status/recovery; Updates shows actual version and existing controls. Access details stay locally selectable and are never logged. Test repeated en→ko→en, both appearances/sizes, ready/unavailable access, login approval, busy/unconfigured updates and larger-text fixtures. Native popup/focus/VoiceOver are separate acceptance evidence.

## Native foundations and predictions

| Area | Verified current guidance / baseline | Shot Clip decision | 2027 TREND PREDICTION |
| --- | --- | --- | --- |
| Structure | Apple describes resizable windows, menu commands, keyboard workflows, and comfortable density. [macOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos) | Menu bar entry; one settings window with General, Access, Updates; disclosure for diagnostics | Small utilities may favor fewer surfaces and faster task return; speculative |
| Color | Semantic colors describe roles and adapt to appearance. [NSColor](https://developer.apple.com/documentation/appkit/nscolor) | System label/background/accent colors; state words and symbols alongside color | Semantic adaptation may remain more durable than fixed palettes; speculative |
| Materials | Apple assigns materials by role and recommends restrained glass effects. [Materials HIG](https://developer.apple.com/design/human-interface-guidelines/materials) | Standard AppKit chrome; readable help over capture content; no custom glass dependency | Restrained translucency may outlast decorative layering; speculative |
| Accessibility | Apple calls for perceivable states, contrast, labels, and adaptable interaction. [Accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility) | Visible focus, VoiceOver labels, no color-only status, reduced-motion/transparency handling | Keyboard/assistive control may become expected utility quality signals; speculative |
| Permission | Apple recommends requests in the context of the protected feature. [Privacy HIG](https://developer.apple.com/design/human-interface-guidelines/privacy) | Explain at capture intent; explicit request; recovery details when needed | Permission explanations may become more concise and transparent; speculative |
| Localization | Apple supports localized package resources and string catalogs. [Package resources](https://developer.apple.com/documentation/xcode/localizing-package-resources), [String catalogs](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) | English default, explicit English / 한국어, complete strings and fallback | Language choices may become easier to find without larger settings surfaces; speculative |

## Semantic tokens

| Token | Native mapping / value | Use |
| --- | --- | --- |
| `text.primary` / `text.secondary` / `text.disabled` | `NSColor.labelColor` / `.secondaryLabelColor` / `.disabledControlTextColor` | Body, explanation, disabled controls with nearby reason |
| `surface.window` / `surface.control` | `NSColor.windowBackgroundColor` / `.controlBackgroundColor` | Window and control content |
| `action.accent` | `NSColor.controlAccentColor` | System emphasis; honor the person’s accent preference |
| `border.separator` / `focus.ring` | `NSColor.separatorColor` / native focus ring (`.keyboardFocusIndicatorColor` for custom drawing) | Grouping and keyboard focus |
| `state.ready` / `state.attention` / `state.error` | `.systemGreen` / `.systemOrange` / `.systemRed` plus icon and words | Ready, access needed, operation failure |
| `type.body` / `type.caption` / `type.section` / `type.title` / `type.shortcut` | bundled Roboto with Noto Sans KR cascade `13` / `12` / semibold `14` / semibold `18` / medium `13` pt | Project defaults for hierarchy and shortcut glyphs |
| `space.inline` / `space.group` / `space.section` / `space.inset` | `8` / `12` / `16` / `20` pt | Shared baseline; reference settings use local 24 pt section gaps / 28 pt body insets; wrap rather than truncate |
| `selection.outline` / `selection.handle` | Contrasting light/dark outline pair; visible `8` pt handle, at least `24` pt hit region | Selection over arbitrary screen content |
| `selection.scrim` | Baseline black at `35%`; high-visibility fallback subject to QA | Context outside selection; no universal contrast claim |

AppKit resolves semantic colors for the active appearance; do not persist resolved colors. Honor [Reduce Transparency](https://developer.apple.com/documentation/appkit/nsworkspace/accessibilitydisplayshouldreducetransparency) with opaque help/control surfaces without obscuring selection. Keep feedback brief/nonblocking and suppress decorative motion for Reduce Motion; essential state remains available afterward. Verify light/dark/Increase Contrast over synthetic bright, dark, patterned screens; tokens alone do not prove accessibility.

## Icon and brand artwork

The 0.5 icon uses a clear crop mark and offset copy sheet to represent region-to-clipboard. It replaces the 0.4.1 landscape/photo-card metaphor. The icon contains no text or screenshots; its template menu glyph shares the core silhouette. Inspect 16/32 px and the 1024 px render rather than assuming large artwork scales well. [Apple’s app icon guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons), checked 2026-10-05, informs the simple illustrated concept.

`scripts/generate-app-icon.swift` is the deterministic AppKit source of the ten 1×/2× PNG representations used to create `AppIcon.icns`. This macOS 14+ packaging path uses flattened static artwork. It does not claim Icon Composer layers or system-adaptive Liquid Glass icon effects described in current Apple guidance. Rendered icon/packaging checks and native appearance/accessibility QA are separate evidence.

The project hero is [PNG](assets/shotclip-hero.png), with an editable [SVG](assets/shotclip-hero.svg); the [1024 px icon preview](assets/shotclip-icon.png) and [icon SVG](assets/shotclip-icon.svg) share the app artwork. The hero’s “Capture. Copy. Continue.” message and capture→clipboard motif illustrate the existing workflow. Both READMEs provide localized alternative text. All artwork is original synthetic graphics, without captured screens, app/window information or clipboard contents; no additional product feature is implied.

From the repository root, regenerate the iconset and all four brand assets:

```sh
swift scripts/generate-app-icon.swift 'dist/visual-qa/Shot Clip.iconset' --brand-assets docs/shotclip/assets
```

## Components and progressive permissions

| Component / state | Behavior and copy |
| --- | --- |
| Menu bar | Ready: Capture Area, Fixed Region; unavailable: Enable Screen Recording… / 화면 기록 허용… leading to Access; Settings…, Check for Updates…, Quit Shot Clip; shortcut only on remembered mode |
| General | Capture group: shortcut/two mode actions; App group: login switch/language popup; redundant ready-state captions omitted |
| Capture intent without access | “Screen Recording access is needed to copy a selected region.” Dedicated pre-request explanation has one action opening the system request; do not imitate or pressure the system prompt |
| Permission recovery | “Access needs review.” Open Screen Recording Settings…, Check Again, Restart Shot Clip; expanded current-bundle/ad-hoc troubleshooting |
| Ready | “Ready to capture.” Do not infer grant history from Boolean preflight |
| Processing / completion / error | One operation; no upper-right success notice; lower-right thumbnail only after clipboard commit; actionable error without screen/clipboard data |
| Original preview / save | Click thumbnail for same original image, Fit/100% and Save PNG; native save sheet only; close/cancel/failure preserve clipboard; no automatic storage/history |
| Updates | Version, manual check, automatic checks OFF by default, signed-update explanation; preview limitations in help/release notes |

No automatic launch-time system permission prompt. Denial is supported; capture intent opens explicit setup and settings, language, and quit remain usable. Show the current app path in recovery details only, not logs. The unchanged 0.4.x identity needs no new defaults migration, but ad-hoc replacement may need a fresh Screen Recording grant. Do not reset TCC or promise consent survives replacement.

## Keyboard and accessibility contract

| Action | Key / behavior |
| --- | --- |
| Open last mode | Configurable global `⌃⇧⌘5`; conflict is visible and previous shortcut restored on failure |
| Confirm / cancel | Return or keypad Enter confirms a valid selection; Escape cancels without writing |
| Move / resize | Arrows move `1` pt; Shift+Arrows `10` pt; Option+Arrows resize upper-right corner; Option+Shift uses `10` pt |
| Focus | Tab / Shift+Tab traverses controls with visible focus; Space activates focused native button |
| Switch mode | `M`, documented in both languages; mode selection also available from the menu/settings |

The historical overlay intercepts Tab to switch modes; the coordinator accepted `M` and native Tab focus on 2026-10-05. Give the selection view a localized role/label and accessible bounds/value, native Capture/Cancel controls, meaningful mode/status labels, and sensible focus return. Fixed Region must remain operable without dragging. VoiceOver and focus GUI checks are **not run**; normal product use requires no Accessibility permission.

## Localization contract

English is the development/fallback language; persist explicit `en` or `ko`, defaulting to English on fresh install/legacy migration. Localize menu, settings, overlay, status/error/success, accessibility labels, and recorder together. Keep Shot Clip, APIs, paths, URLs, and key glyphs unchanged. macOS permission/security prompts follow OS language. Use validated `en.lproj` / `ko.lproj` resources and complete placeholder strings. Save the choice, replace explicit localization lookup and relabel visible app-owned views immediately. The supported public Sparkle `SPUUserDriver` relabels new/visible update dialogs through the same synchronous notification, preserving callback/progress/window/control/focus and unchanged note selection/scroll. Its ordinary native window sizes to measured heading/summary/detail, visible progress/notes and action rows: 420 pt base notice width, 520 pt notes width, 24 pt insets/12 pt gaps and 188 pt notes viewport. Widen for localized action rows; recompute full multiline heights on state/language changes instead of retaining the former fixed 560×430 pt surface. All 16 required callbacks and optional focus have inert fixtures; real updater networking/installation and OS dialogs remain separate. Do not edit framework bundles or use private APIs or language-triggered updater resets. Preserve pane/disclosure/scroll/focus and capture/permission/update state. Remove language restart controls while retaining permission Restart. Inspect minimum-size and larger-text fixtures.

## 한국어

**2027 TREND PREDICTION**은 설계 가설이며 Apple 로드맵이나 확정 사실이 아닙니다. Apple HIG/AppKit/현지화 문서를 근거로 `labelColor`, `secondaryLabelColor`, `controlAccentColor` 등 native 토큰과 상태 문구/기호를 사용합니다. 설정은 일반/권한/업데이트, 긴 설명은 펼쳐 보기로 구성합니다. 캡처 시 권한 이유를 설명하고 명시적 요청·재확인·설정 이동·재시작을 제공합니다. 예측 때문에 OCR·자동 저장·클라우드나 최소 OS를 확대하지 않습니다. 사용자 선택 PNG 저장은 이번 명시적 요청으로 별도 추가합니다.

영어가 기본이고 **English / 한국어** 선택을 저장하여 앱 소유 문구를 즉시 갱신하고 다음 실행에도 유지합니다. 메뉴·오버레이·오류·접근성 설명까지 번역하고 지원되는 public Sparkle driver의 새/열린 업데이트 창도 즉시 갱신하며 16개 필수 callback·선택적 focus·상태/노트 선택·스크롤 보존 fixture를 통과했습니다. 단일 updater를 유지하고 프레임워크 수정·private API·언어 변경에 따른 updater 재생성을 하지 않습니다. macOS 시스템 창은 OS 언어 범위입니다. 페이지·펼침·스크롤·포커스·선택 영역·상태를 유지하고 권한 복구용 재시작은 남깁니다. Tab/Shift+Tab은 포커스 이동, Return은 확정, Escape는 취소, 방향키는 이동, Option+방향키는 크기 조절, `M`은 모드 전환입니다. 이 키보드 결정은 승인되었지만 VoiceOver/포커스 GUI 검증은 미실행입니다. GUI 캡처·권한 QA는 사용자 담당이고 이 문서는 통과 기록이 아닙니다.

0.6은 기존 이름/crop+copy 아이콘·캡처 우선 순서를 유지하고 72pt 아이콘 rail·외부 섹션 제목·native switch/popup/button·오른쪽 단축키 열을 사용합니다. 일반 titled 창의 제목은 숨기고 full-size content view를 사용하지 않습니다. 실제 content 크기는 기본 720×560pt/최소 620×480pt이며 최종 368개 합성 export의 무결성/geometry와 별도 native 관찰을 확인했습니다. popup 선택·VoiceOver·실제 캡처 통과와는 구분합니다. 비교 제품의 공개 페이지를 참고한 자체 추론이며 실제 타사 앱 테스트나 디자인 복제가 아닙니다. 신규 사용자는 드래그를 기본으로 하고 기존 모드/단축키는 유지합니다. 10개 PNG 표현을 묶는 정적 ICNS이며 실제 캡처 데이터는 포함하지 않습니다. 합성 native 미리보기는 레이아웃 증거이고 권한·클립보드·실제 캡처 검증을 대신하지 않습니다.
