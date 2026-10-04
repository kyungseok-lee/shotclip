# ShotClip design system

[Product plan](product-plan.md) · [Development plan](development-plan.md) · [QA plan](qa-plan.md) · [한국어](#한국어)

Reviewed 2026-10-05 against Apple primary sources and the AppKit baseline. This contract does not prove rendered UI/accessibility. **2027 TREND PREDICTION is our hypothesis, not an Apple roadmap or verified future fact.** It justifies no scope/OS expansion; reassess in 2027 with observed guidance and usability evidence.

## Native foundations and predictions

| Area | Verified current guidance / baseline | ShotClip decision | 2027 TREND PREDICTION |
| --- | --- | --- | --- |
| Structure | Apple describes resizable windows, menu commands, keyboard workflows, and comfortable density. [macOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos) | Menu bar entry; one settings window with General, Permissions, Updates; disclosure for diagnostics | Small utilities may favor fewer surfaces and faster task return; speculative |
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
| `type.body` / `type.caption` / `type.section` / `type.title` / `type.shortcut` | `NSFont` system `13` / `12` / semibold `17` / `24` pt; monospaced `14` pt | Project defaults for hierarchy and shortcut glyphs |
| `space.inline` / `space.group` / `space.section` / `space.inset` | `8` / `12` / `20` / `24` pt | Wrap/adapt rather than truncate actions |
| `selection.outline` / `selection.handle` | Contrasting light/dark outline pair; visible `8` pt handle, at least `24` pt hit region | Selection over arbitrary screen content |
| `selection.scrim` | Baseline black at `35%`; high-visibility fallback subject to QA | Context outside selection; no universal contrast claim |

AppKit resolves semantic colors for the active appearance; do not persist resolved colors. Honor [Reduce Transparency](https://developer.apple.com/documentation/appkit/nsworkspace/accessibilitydisplayshouldreducetransparency) with opaque help/control surfaces without obscuring selection. Keep feedback brief/nonblocking and suppress decorative motion for Reduce Motion; essential state remains available afterward. Verify light/dark/Increase Contrast over synthetic bright, dark, patterned screens; tokens alone do not prove accessibility.

## Icon and brand artwork

The 0.4.1 visual refresh uses a centered ivory clipboard/photo card, mint region-selection corners and an original abstract landscape on a deep cobalt tile. The icon contains no text or screenshots. A clear silhouette and restrained shapes should remain recognizable at 16/32 px; inspect the actual small renders rather than assuming the 1024 px design scales well. [Apple’s app icon guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons), checked 2026-10-05, informs the simple illustrated concept and emphasis on small-size recognition.

`scripts/generate-app-icon.swift` is the deterministic AppKit source of the ten 1×/2× PNG representations used to create `AppIcon.icns`. This macOS 14+ packaging path uses flattened static artwork. It does not claim Icon Composer layers or system-adaptive Liquid Glass icon effects described in current Apple guidance. Rendered icon/packaging checks and native appearance/accessibility QA are separate evidence.

The project hero is [PNG](assets/shotclip-hero.png), with an editable [SVG](assets/shotclip-hero.svg); the [1024 px icon preview](assets/shotclip-icon.png) and [icon SVG](assets/shotclip-icon.svg) share the app artwork. The hero’s “Capture. Copy. Continue.” message and capture→clipboard motif illustrate the existing workflow. Both READMEs provide localized alternative text. All artwork is original synthetic graphics, without captured screens, app/window information or clipboard contents; no additional product feature is implied.

From the repository root, regenerate the iconset and all four brand assets:

```sh
swift scripts/generate-app-icon.swift dist/visual-qa/ShotClip.iconset --brand-assets docs/shotclip/assets
```

## Components and progressive permissions

| Component / state | Behavior and copy |
| --- | --- |
| Menu bar | Fixed Region, Drag Region, Settings…, Check for Updates…, Quit ShotClip; shortcut and access status |
| General | Capture choices, shortcut, Language: English / 한국어, opt-in login start; short usage hint |
| Capture intent without access | “Screen Recording access is needed to copy a selected region.” Dedicated pre-request explanation has one action opening the system request; do not imitate or pressure the system prompt |
| Permission recovery | “Access needs review.” Open Screen Recording Settings…, Check Again, Restart ShotClip; expanded current-bundle/ad-hoc troubleshooting |
| Ready | “Ready to capture.” Do not infer grant history from Boolean preflight |
| Processing / completion / error | One operation; “Copied — paste with ⌘V” after commit; actionable error without screen/clipboard data |
| Updates | Version, manual check, automatic checks OFF by default, signed-update explanation; preview limitations in help/release notes |

No automatic launch-time permission prompt. Denial is supported; settings, language, and quit remain usable. Show the current app path in recovery details only, not logs. The new identity needs its own grant; do not reset TCC or promise consent survives ad-hoc replacement.

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

English is the development/fallback language; persist explicit `en` or `ko`, defaulting to English on fresh install/legacy migration. Localize menu, settings, overlay, status/error/success, accessibility labels, and recorder together. Keep ShotClip, APIs, paths, URLs, and key glyphs unchanged. System Settings/Sparkle-owned language behavior is separate. Use validated `en.lproj` / `ko.lproj` package resources and complete placeholder strings, not concatenated fragments. Save the choice and explicitly request restart to apply; check both languages at minimum size and text enlargement without clipping primary actions.

## 한국어

**2027 TREND PREDICTION**은 설계 가설이며 Apple 로드맵이나 확정 사실이 아닙니다. Apple HIG/AppKit/현지화 문서를 근거로 `labelColor`, `secondaryLabelColor`, `controlAccentColor` 등 native 토큰과 상태 문구/기호를 사용합니다. 설정은 일반/권한/업데이트, 긴 설명은 펼쳐 보기로 구성합니다. 캡처 시 권한 이유를 설명하고 명시적 요청·재확인·설정 이동·재시작을 제공합니다. 예측 때문에 OCR·저장·클라우드나 최소 OS를 확대하지 않습니다.

영어가 기본이고 **English / 한국어** 선택을 저장한 뒤 재시작하여 적용합니다. 메뉴·오버레이·오류·접근성 설명까지 번역하고 시스템 및 Sparkle 창의 언어는 별도로 확인합니다. Tab/Shift+Tab은 포커스 이동, Return은 확정, Escape는 취소, 방향키는 이동, Option+방향키는 크기 조절, `M`은 모드 전환입니다. 이 키보드 결정은 승인되었지만 VoiceOver/포커스 GUI 검증은 미실행입니다. GUI 캡처·권한 QA는 사용자 담당이고 이 문서는 통과 기록이 아닙니다.

0.4.1 아이콘은 코발트색 바탕 위에 민트색 영역 모서리와 아이보리 클립보드·추상 풍경을 결합합니다. 글자·실제 화면은 넣지 않고 16/32 px 실물을 확인합니다. 현재 빌드는 10개 PNG 표현을 ICNS로 묶는 macOS 14 이상용 정적 이미지이며 Icon Composer/Liquid Glass의 동적 효과를 구현했다고 주장하지 않습니다. 영어·한국어 README의 브랜드 이미지에는 각 언어의 대체 설명을 제공하며 캡처·창·클립보드 데이터는 포함하지 않습니다.
