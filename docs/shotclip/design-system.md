# Shot Clip design system

[Product plan](product-plan.md) · [Development plan](development-plan.md) · [QA plan](qa-plan.md) · [한국어](#한국어)

Reviewed 2026-10-05 against Apple primary sources and the AppKit baseline. This contract does not prove rendered UI/accessibility. **2027 TREND PREDICTION is our hypothesis, not an Apple roadmap or verified future fact.** It justifies no scope/OS expansion; reassess in 2027 with observed guidance and usability evidence.

## Workflow evidence and approved 0.6 direction

The coordinator reviewed public product pages on 2026-10-05: [Shottr](https://shottr.cc/) emphasizes quick area capture, clipboard and keyboard nudges; [CleanShot X](https://cleanshot.com/) describes drag capture, quick copy and custom shortcuts; [ScreenFloat](https://eternalstorms.at/ScreenFloat/) provides explicit keyboard/menu capture and recapture; [Apple’s screenshot guide](https://support.apple.com/en-us/102646) describes crosshair drag/release, Escape and clipboard modifiers. These are website observations, not tests of third-party apps. Our inference is to prioritize capture intent, keyboard access and immediate copy; no third-party interface/artwork is copied and no feature expansion follows.

Use native [NSMenu](https://developer.apple.com/documentation/appkit/nsmenu), [NSStatusItem](https://developer.apple.com/documentation/appkit/nsstatusitem), [menus](https://developer.apple.com/design/human-interface-guidelines/menus) and [controls](https://developer.apple.com/design/human-interface-guidelines/controls) on macOS 14+. Keep semantic AppKit colors and restrained materials; do not require newer glass APIs. The visible name is **Shot Clip**, while stable identifiers, executable, repo, resource bundles and update trust remain unchanged.

| Surface | Approved 0.6 behavior |
| --- | --- |
| Menu | Capture Area (drag) first, Fixed Region second; configured native shortcut column only on the remembered mode; both capture intents available before permission; Settings, Check for Updates, Quit remain native menu items |
| Lifecycle | Show the first 0.5 setup once without a system permission prompt; later launches quiet; Finder reopen opens Settings; preserve existing valid shortcut/mode, fresh users default to drag |
| General | External Capture/App headings and grouped shortcut/mode/login/language rows; native switches/popup; English/Korean applies immediately and persists |
| Access | Screen Recording status and primary request row; System Settings/Check Again on separate recovery rows; restart/location/diagnostics in a leading disclosure |
| Updates | Version, automatic-check switch and manual-check rows under Software updates; busy/unconfigured states, concise preview footers; automatic checks default OFF |
| Selection | Compact floating toolbar, mode hint, crosshair and dimensions; drag begins with zero selection; M/Tab/Return/Escape and native focus contract retained |
| Brand | Original crop mark plus offset copy sheet; matching monochrome template menu glyph; no landscape/photo-editor metaphor or screenshot content |

Render inert synthetic UI previews in English/Korean, light/dark, default/minimum sizes and all panes using actual native views. Preview callbacks bypass preferences, hotkeys, updater, TCC, capture and clipboard; these checks prove layout only. Real capture/permissions/paste and VoiceOver remain separate user-owned evidence.

Carbon retains one physical global registration. Plain capture menu titles use native `keyEquivalent` / `keyEquivalentModifierMask` from saved physical key/current keyboard layout, only on the remembered-mode row. Settings uses the same presentation in system-font glyphs. Native equivalents dispatch app-local actions; both paths retain single-flight behavior and need dispatch-count checks. Keep Settings `⌘,` / Quit `⌘Q`. Unmapped codes use localized key-code help and an empty native equivalent; do not derive a key from a display label. Apple documents [keyEquivalent](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalent), [modifier masks](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalentmodifiermask) and [menu dispatch](https://developer.apple.com/documentation/appkit/nsmenu/performkeyequivalent(with:)).

## Reference-style native settings contract

The 0.6 blueprint adopts the supplied reference’s icon rail, external headings and aligned native controls using existing Shot Clip features. Image pixels are not point measurements; these values are project layout choices. Reconcile implementation and inert renders before acceptance. Cloud, window management, default-mode and Help/About features from references are excluded.

| Element | Layout and behavior |
| --- | --- |
| Window | Native resizable/closable window; default content 720×560 pt, minimum content 620×480 pt; derive minimum frame from content |
| Rail | 72 pt wide; three native 44×44 pt General/Access/Updates icon buttons, 22 pt symbols, 12 pt gaps; localized tooltip/label/selected value and native focus ring |
| Material | Semantic sidebar material/accent selection; opaque Reduce Transparency fallback; native traffic lights and system colors |
| Header/body | 56 pt header, 18 pt semibold title and separator; scroll body insets 28 pt horizontal, 22 pt top, 24 pt bottom; no product hero/segmented navigation |
| Sections/groups | 14 pt semibold external headings, 10 pt heading gap, 24 pt section gap; 8 pt radius, no shadow, semantic window fill and unmodified separator border |
| Rows | 16 pt horizontal/12 pt vertical insets, 13 pt labels/12 pt wrapping descriptions, inset hairlines; grow/scroll for long text |
| Controls | Real login/update `NSSwitch`, language `NSPopUpButton`, rounded action/recorder buttons with intrinsic size; shared system-font shortcut presentation |
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
| `type.body` / `type.caption` / `type.section` / `type.title` / `type.shortcut` | `NSFont` system `13` / `12` / semibold `14` / semibold `18` / medium `13` pt | Project defaults for hierarchy and shortcut glyphs |
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
| Menu bar | Capture Area, Fixed Region, Settings…, Check for Updates…, Quit Shot Clip; actual shortcut only on remembered mode; access status |
| General | Capture group: shortcut/two mode actions; App group: login switch/language popup; immediate-language caption |
| Capture intent without access | “Screen Recording access is needed to copy a selected region.” Dedicated pre-request explanation has one action opening the system request; do not imitate or pressure the system prompt |
| Permission recovery | “Access needs review.” Open Screen Recording Settings…, Check Again, Restart Shot Clip; expanded current-bundle/ad-hoc troubleshooting |
| Ready | “Ready to capture.” Do not infer grant history from Boolean preflight |
| Processing / completion / error | One operation; “Copied — paste with ⌘V” after commit; actionable error without screen/clipboard data |
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

English is the development/fallback language; persist explicit `en` or `ko`, defaulting to English on fresh install/legacy migration. Localize menu, settings, overlay, status/error/success, accessibility labels, and recorder together. Keep Shot Clip, APIs, paths, URLs, and key glyphs unchanged. macOS permission/security prompts follow OS language. Use validated `en.lproj` / `ko.lproj` resources and complete placeholder strings. Save the choice, replace explicit localization lookup and relabel visible app-owned views immediately. A supported custom Sparkle `SPUUserDriver` is planned for new/visible update dialogs, with live-relabel and synthetic callback evidence; do not edit framework bundles or caches. Preserve pane/disclosure/scroll/focus and capture/permission/update state. Remove language restart controls while retaining permission Restart. Inspect minimum-size and larger-text fixtures.

## 한국어

**2027 TREND PREDICTION**은 설계 가설이며 Apple 로드맵이나 확정 사실이 아닙니다. Apple HIG/AppKit/현지화 문서를 근거로 `labelColor`, `secondaryLabelColor`, `controlAccentColor` 등 native 토큰과 상태 문구/기호를 사용합니다. 설정은 일반/권한/업데이트, 긴 설명은 펼쳐 보기로 구성합니다. 캡처 시 권한 이유를 설명하고 명시적 요청·재확인·설정 이동·재시작을 제공합니다. 예측 때문에 OCR·저장·클라우드나 최소 OS를 확대하지 않습니다.

영어가 기본이고 **English / 한국어** 선택을 저장하여 앱 소유 문구를 즉시 갱신하고 다음 실행에도 유지합니다. 메뉴·오버레이·오류·접근성 설명까지 번역하고 지원되는 custom Sparkle driver의 새/열린 업데이트 창도 즉시 갱신하고 callback fixture로 검증할 계획입니다. macOS 시스템 창은 OS 언어 범위입니다. 페이지·펼침·스크롤·포커스·선택 영역·상태를 유지하고 권한 복구용 재시작은 남깁니다. Tab/Shift+Tab은 포커스 이동, Return은 확정, Escape는 취소, 방향키는 이동, Option+방향키는 크기 조절, `M`은 모드 전환입니다. 이 키보드 결정은 승인되었지만 VoiceOver/포커스 GUI 검증은 미실행입니다. GUI 캡처·권한 QA는 사용자 담당이고 이 문서는 통과 기록이 아닙니다.

0.6은 기존 이름/crop+copy 아이콘·캡처 우선 순서를 유지하고 72pt 아이콘 rail·외부 섹션 제목·native switch/popup/button·오른쪽 단축키 열을 사용합니다. 목표 content 크기는 기본 720×560pt/최소 620×480pt이며 실제 렌더와 대조합니다. 비교 제품의 공개 페이지를 참고한 자체 추론이며 실제 타사 앱 테스트나 디자인 복제가 아닙니다. 신규 사용자는 드래그를 기본으로 하고 기존 모드/단축키는 유지합니다. 10개 PNG 표현을 묶는 정적 ICNS이며 실제 캡처 데이터는 포함하지 않습니다. 합성 native 미리보기는 레이아웃 증거이고 권한·클립보드·실제 캡처 검증을 대신하지 않습니다.
