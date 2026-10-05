# Shot Clip technical validation

[Architecture](architecture.md) · [QA procedures](qa-plan.md) · [Executed evidence](qa-results.md#current-evidence) · [한국어](#한국어)

## Current evidence and environment

0.8.1 (build 11) source A, prepared/public/installed payload and cold restart are verified in the current QA ledger. Recorded host: macOS 27.0.1, Xcode 27.0, Swift 6.4, arm64. macOS 14 is the deployment minimum; macOS 14/Intel/clean-account runtime, full accessibility, real current-version capture/paste/grants/native-save and a live invalid-feed expiry-time experiment are unrun. This documentation-only request reuses evidence and performs no new technical test.

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

Manual native resources eliminate the generated absolute SwiftPM accessor. Final scans, not flag assumptions, prove path purity across all regular files/symlinks/Mach-O code; UTF-16 alignments, case, own QA markers and escaping RPATH negatives are covered. The production/QA split is explicit, not inferred from DEBUG or ad-hoc signing. [Security review](qa-review-0.8.1.md) and [delivery review](release-review-0.8.1.md) cover separate frozen inputs.

## 한국어

공식 문서·고정 버전 소스·SDK 확인과 실제 실행 결과는 다른 근거입니다. 현재 host는 macOS 27.0.1/Xcode 27/Swift 6.4 arm64이고 macOS 14/Intel·깨끗한 계정·전체 접근성·실캡처/일반 붙여 넣기·시간 경과 feed 실험은 미실행입니다. 이번 문서 변경은 기존 근거만 정리합니다.

한영 배치는 실제 너비/전체 잉크/줄 간 겹침을 검사하며 fallback보다 작은 줄 높이를 강제하지 않습니다. 서명 feed의 interval 0, 명시적 QA 분리, standalone 리소스와 전체 산출물 경로 검사가 D18을 뒷받침하고 compiler flag만으로 완료를 주장하지 않습니다.

<details>
<summary>Historical primary-source and probe evidence</summary>

The records below retain their original environment, source and unrun limits for immutable review links. Their dated “current/unreleased” wording is historical and is not the current work plan or product support statement.

## 2026-10-05 UNRELEASED UI refresh primary sources

Method: the document-specialist read the live Google Fonts browse/popularity controls and metadata, Google’s official font repository and license/metadata files, Apple’s screenshot guide/toolbar image, and Apple developer page/DocC JSON content on 2026-10-05. This is research/source evidence; no app build, capture, TCC, preferences, clipboard, installation or remote mutation was performed by this lane. The following current scope supersedes the earlier system-font/fixed-dialog/no-preview planning while keeping every dated record below unchanged.

| Official source | Finding / implementation implication |
| --- | --- |
| [Roboto Flex announcement](https://m3.material.io/blog/roboto-flex),2022-05-05; [Google Fonts metadata](https://fonts.google.com/metadata/fonts), checked 2026-10-05 | Roboto was identified as most popular download historically and remains in current top available popularity tier tied with Google Sans; current browse displays Google Sans first/Roboto second and blends ranking factors. Noto Sans KR leads Korean subset families. No sole current global#1 claim |
| [Roboto distribution](https://github.com/google/fonts/tree/main/ofl/roboto); [Noto Sans KR distribution](https://github.com/google/fonts/tree/main/ofl/notosanskr) | Unchanged variable TTFs and full SIL OFL1.1/copyright can be bundled. Metadata PostScript names: `Roboto-Regular`, `NotoSansKR-Thin`; explicitly apply matching `wght` axis |
| [Register fonts by URL](https://developer.apple.com/documentation/coretext/ctfontmanagerregisterfontsforurl(_:_:_:)); [process scope](https://developer.apple.com/documentation/coretext/ctfontmanagerscope/process); [cascade list](https://developer.apple.com/documentation/appkit/nsfontdescriptor/attributename/cascadelist); [variation](https://developer.apple.com/documentation/appkit/nsfontdescriptor/attributename/variation) | Font descriptor discovery after registration; process-only lifetime, explicit Korean cascade/weight rather than global installation |
| [NSMenu.font](https://developer.apple.com/documentation/appkit/nsmenu/font); [alignmentRectInsets](https://developer.apple.com/documentation/appkit/nsview/alignmentrectinsets) | App-owned menus/submenus can share the font; layout content rectangles can differ from physical frames, so inspect actual 44×44 pt rail geometry rather than assuming constraints prove it |
| [Apple screenshot article](https://support.apple.com/en-us/102646), published 2026-09-14; [screenshot user guide](https://support.apple.com/guide/mac-help/mh26782/mac) | Official toolbar image visually inspected: rounded panel, close, selected mode icons, group dividers, Capture. Floating thumbnail appears at lower-right for seconds, opens full image on click, and stays while hovered; Shot Clip keeps its clipboard-first/no-automatic-save behavior |
| [NSPanel](https://developer.apple.com/documentation/appkit/nspanel); [nonactivating panel](https://developer.apple.com/documentation/appkit/nswindow/stylemask-swift.struct/nonactivatingpanel); [visual effect](https://developer.apple.com/documentation/appkit/nsvisualeffectview) | Auxiliary passive thumbnail without activating the app; material chosen for HUD/panel role, not an incidental color |
| [NSSavePanel.allowedContentTypes](https://developer.apple.com/documentation/appkit/nssavepanel/allowedcontenttypes); [PNG](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype-swift.struct/png); [native save sheet](https://developer.apple.com/documentation/appkit/nssavepanel/beginsheetmodal(for:completionhandler:)) | macOS11+ `[.png]`/`public.png`, within minimum14; configure first, write original only following `.OK`, preserve clipboard on cancel/close/failure |

Reproduce by visiting the linked official browse page, selecting Most popular and reading About these results; inspect metadata fields and the official TTF/OFL/METADATA files. Read Apple’s toolbar image/guide and each developer symbol’s content/availability. Root’s current normal matrix passes 36 core tests and four 136-view runs (544 rendered views),1,236 updater/44 capture-preview assertions per run; independent font/hash/axes/cascade and 34 resource cases/eight visual samples passed. Sealed development-bundle signature/version/173+57 resources/five font-license-notice files/ten square icon representations passed for the final bundle; a separate 62-assertion Korean-dark actual native Save/cancel/pending-close/replacement/pixel/private-clipboard gate passed, with QA copied unsigned executable/all resources equal. Author/root evidence is complete; the independent verdict is recorded separately in `qa-review-ui-refresh.md` with bounded evidence in [current QA](qa-results.md#2026-10-05-unreleased-eight-item-ui-refresh).

Implementation findings: the former fixed 560×430 pt update surface left unnecessary space in simple results; content sizing now measures only visible text/progress/notes/actions. Example no-update fixtures are 420×131 pt EN/420×139 pt KO on a 2× host. For settings, `NSButton` alignment content can differ from physical frames, and native primary-face cell heights can differ from fallback glyph ink. Zero rail alignment insets plus actual 44×44 bounds and shared TextKit used/ink/cell-inset heights address both without relaxing validators. Current 44-per-run capture fixtures save synthetic PNGs and preserve a private named pasteboard; the native-sheet test initially failed on unsupported fixture `ok(nil)` and QA activation/event dispatch, then passed 62 assertions through real CUA Save-button acceptance in the unique-ID copied bundle. Only manual native QA enables regular activation/native event dispatch; production startup is unchanged. The default-button-cell acceptance route is unrun. No production error-alert path is claimed from direct `writePNG` failure.

한국어:2026-10-05에 공식 Google/Apple 내용을 읽고 Roboto의 과거 최다 다운로드·현재 상위 인기 그룹/Noto 한국어 순위, OFL·프로세스 폰트 등록·cascade/weight·native 메뉴 폰트·alignment rect·Apple toolbar/우측 하단 썸네일·PNG save sheet를 확인했습니다. 단독 현재1위나 앱 동작 통과를 주장하지 않으며 숫자 여백은 프로젝트 설계값입니다. 문서 작성자는 빌드/앱/권한/클립보드/설치/remote 변경을 하지 않았습니다.

## 2026-10-05 0.6 native-menu documentation review

This documentation lane inspected current native menu and explicit en/ko localization changes; implementation and independent verification continue in separate lanes. Apple pages initially returned JavaScript shells and the web Markdown fetch rejected the content type. A read-only HTTPS retrieval of the official `.md` pages supplied their actual content on 2026-10-05:

| Primary source | Documentation implication |
| --- | --- |
| [NSMenuItem.keyEquivalent](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalent) / [keyEquivalentModifierMask](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalentmodifiermask) | Native shortcuts use an unmodified key and a separate modifier mask. Derive them from the configured key/layout; keep text titles free of padded shortcut hints |
| [NSToolbar](https://developer.apple.com/documentation/appkit/nstoolbar) | Native window navigation can use toolbar items in the title-bar area; exact layout remains a project choice |
| [NSPopUpButton](https://developer.apple.com/documentation/appkit/nspopupbutton) | Native list selection fits the English / 한국어 control; menu tracking does not reflect arbitrary programmatic menu changes mid-track |

Reproduce by requesting the linked URL with `.md` appended and inspect the symbol title/discussion. Source inspection alone does not prove focus, native popup behavior, live language rendering or a real capture. The 0.6 plan uses explicit app-localization lookup plus refresh notifications and a supported custom Sparkle user driver for app-owned update dialogs; macOS-owned permission/security prompts remain OS-controlled. The user-driver implementation, synthetic callback fixtures and independent verdict must be recorded separately before completion claims. No app, preferences, TCC, clipboard, Keychain, Git or network mutations were made in this documentation lane.

한국어: Apple의 공식 Markdown 원문을 읽어 native 단축키의 key/modifier 분리, toolbar 및 언어 선택 popup 동작을 확인했습니다. 소스 확인은 실제 포커스·메뉴·언어·캡처 통과를 뜻하지 않습니다. 0.6은 앱 소유 언어의 즉시 갱신과 지원되는 Sparkle 사용자 driver를 계획하고 macOS 시스템 창은 OS 언어 범위로 구분합니다.

## Historical Sshot probes — retained as recorded

The following 2026-10-04 probes and legacy identity/TCC findings describe Sshot. Preserve their exact historical names and results. Later fixes and remote evidence are in [QA results](qa-results.md) and [handoff](handoff.md); a historical “in progress” statement is not the current ShotClip delivery decision.

## 2026-10-04: 단계 1

환경: macOS 27.0.1 (26A434), Xcode 27.0 (27A266a), Swift 6.4, Apple Silicon. 저장소는 문서 초기 커밋에서 시작했으며 후속 구현·QA·push 요청을 받았다.

| 항목 | 수행 및 증거 | 결과 |
| --- | --- | --- |
| 캡처 API | 설치 SDK 헤더 확인 및 `swift -e` 컴파일 probe: SCScreenshotManager.captureImage, SCContentFilter.pointPixelScale | macOS 14부터 제공. 실제 화면 픽셀 검사는 앱 harness에서 별도 수행 |
| 좌표 | SDK sourceRect 주석 확인 | display-local top-left point 단위. AppKit 전역 rect에서 x=rect.minX-screen.minX, y=screen.maxY-rect.maxY. 출력 크기는 pixel 단위 |
| UI 제외 | 자체 SCRunningApplication 제외 filter 및 showsCursor=false API 확인 | 컴파일 가능. 실제 UI 제외 통합 QA 필요 |
| 단축키 | Carbon RegisterEventHotKey에 kEventHotKeyExclusive로 ⌃⇧⌘5 등록·중복 등록·해제 | 최초 OSStatus 0, 중복 -9878. 기본 nonexclusive 옵션은 충돌 검출에 부적합 |
| 클립보드 | unique named NSPasteboard에 PNG+TIFF item 기록 | write true, item 1, type 2. clear와 write의 changeCount 관찰. 일반 clipboard 변경 없음 |
| 권한 | swift probe CGPreflightScreenCaptureAccess | false. CLI의 결과이며 제품 identity의 결과가 아님 |
| 배포 | security find-identity -v -p codesigning | 유효 identity 0. Developer ID 공증·배포 QA 미완료 |

## 구현 결정과 한계

- D01/D02: macOS 14 이상, SwiftPM + AppKit, ScreenCaptureKit의 still-image API 사용. 하위 OS의 실제 실행 검증은 별도 필요하다.
- D03: 기본 ⌃⇧⌘5, 사용자 변경 지원, exclusive 등록으로 충돌을 처리한다. 단축키 이벤트 전달은 실제 UI QA에서 확인한다.
- D04: 각 디스플레이에서 독립적인 영역 선택을 지원한다. 한 번의 선택은 시작 디스플레이 내부로 제한하고 UI에 안내한다. 혼합 배율 화면을 합치는 기능은 제공하지 않는다.
- D05: 이미지 인코딩을 먼저 완료하고, 모든 기존 pasteboard item/type의 eager snapshot을 확보한 경우만 교체한다. 읽기 불가·너무 큰 백업·snapshot 중 외부 변경은 교체 전 실패 처리한다. write 실패 시 own changeCount가 유지된 경우만 복원하며 외부 데이터는 덮어쓰지 않는다.
- NSPasteboard에는 atomic replace나 compare-and-swap가 없다. 시스템 pasteboard 장애·복원 실패·외부 프로세스와의 최종 경쟁까지 기존 데이터 보존을 무조건 보장할 수 없다. 이 한계를 성공으로 숨기지 않고 오류와 미검증 범위를 남긴다. 취소·권한 거부·캡처/인코딩 실패는 clipboard 쓰기 이전에 종료한다.
- D06: 영역은 실행 세션 안에서 재사용하고 모드와 단축키 설정은 저장한다. 화면 이미지는 저장하지 않는다.
- D07: 선택 중 재호출은 기존 UI를 활성화하고 처리 중 호출은 무시한다. 세션 토큰으로 취소·timeout 후 늦은 결과를 차단한다.
- D08: 로컬 ad-hoc 앱 번들을 우선 빌드한다. Developer ID·공증 인증정보가 없는 상태에서는 배포 완료로 선언하지 않는다.
- D09: 메뉴 막대 상주 앱에서 캡처 UI를 단축키로 연다. 처음 앱을 직접 실행한다. 로그인 시작은 명시적인 opt-in이며 종료한 프로세스의 cold launch는 제공하지 않는다. 이 동작은 사용자 가이드에 공개한다.

최종 구현 일치 여부와 실제 화면 캡처 결과는 QA 기록에서 검증한다. 위 probe만으로 단계 1의 실제 캡처 gate 또는 전체 QA 완료를 주장하지 않는다.

## 권한 재실행 이후 확인

사용자가 화면 기록을 허용하고 다시 실행한 뒤에도 실제 제품 self-test는 SKIP이었다. 직접 바이너리 실행뿐 아니라 LaunchServices `open -n -W ... --args --self-test`에서도 같은 결과를 확인했다.

제품에 한정한 macOS TCC 로그에서 `Failed to match existing code requirement for subject dev.sshot.app and service kTCCServiceScreenCapture`를 확인했다. 허용 항목의 이전 cdhash와 현재 ad-hoc 앱의 cdhash가 달랐다. 이는 CGPreflight 오검출을 추측할 상황이 아니라 저장된 코드 identity의 불일치다. 허용 스위치만 다시 켜도 기존 requirement가 갱신되지 않았다.

이전 sshot 권한 항목만 시스템 설정 UI에서 제거했으며 다른 앱 권한은 변경하지 않았다. 파일 선택 창의 자동 키보드 입력이 focus 제한으로 실패한 뒤 사용자가 현재 앱을 다시 허용했다. 이후 설정에서 sshot 허용을 확인했고 LaunchServices 실행은 preflight를 통과하여 실제 캡처까지 도달했다. 터미널 직접 실행은 iTerm이 responsible process로 판정되므로 제품 권한 gate의 증거로 사용하지 않는다. TCC DB 직접 수정이나 `tccutil reset`, 권한 판별 우회는 수행하지 않았다.

이후 self-test에서 `objc_release`/autorelease pool의 SIGSEGV를 확인했다. 테스트 overlay의 `isReleasedWhenClosed` 설정 누락을 수정 대상으로 확인하고 독립 검토를 진행 중이다. 실제 캡처 QA와 push는 계속 미완료다.

## 공식 근거

- [SCScreenshotManager](https://developer.apple.com/documentation/screencapturekit/scscreenshotmanager)
- [sourceRect](https://developer.apple.com/documentation/screencapturekit/scstreamconfiguration/sourcerect)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice)

실험은 별도 document-specialist가 수행했다. 실제 앱 테스트와 원격 반영은 별도 verifier가 검증한다.

</details>
