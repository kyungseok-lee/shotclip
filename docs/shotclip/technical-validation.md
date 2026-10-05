# Shot Clip technical validation

[Architecture](architecture.md) · [Design system](design-system.md) · [QA results](qa-results.md)

## 2026-10-05 0.7.0 candidate validation

The latest explicit request authorizes remaining verification, documentation, normal Git push, a new GitHub release and latest installation. Source `resources/Info.plist` targets **0.7.0 (build 9)**. The public and installed 0.6.0(8) app, source `e87e40e…`, remains the verified baseline until new publication and installation evidence is recorded. The earlier [UI approval](qa-review-ui-refresh.md) covers its exact 0.6 development inputs; the new version, documentation and release files require separate approval. Earlier no-deployment statements below describe the preceding request and are superseded for current work. Preserve the existing identity, keys, settings, automatic-update defaults, approved eight-item behavior and historical records.

Source metadata 0.7.0/build 9 was read by the writer; no candidate build/runtime/release check was performed in this lane. Official Apple/Google conclusions and all earlier dated experiments below remain intact. Prior approved 0.6-development evidence includes 36 tests,544 synthetic views, actual native Save 62 assertions and font/package proof, with the production error-alert/real capture/TCC/general paste/accessibility/platform/upgrade limits in [UI review](qa-review-ui-refresh.md). Fresh root candidate reports now pass 36 XCTest and four bundled 136-view matrices (544 total),1,236 updater/44 capture assertions per run; verifier temporary resource34/gate16/archive15+valid2/installer15/crypto25+valid regressions pass. Corrected actual Korean-dark native Save/error/recovery passes 70 assertions: real.OK, localized production catch/alert/acknowledgment, recovery real.OK and original pixels/private pasteboard. A UI-preview-only nil-default hook removes only a fresh empty synthetic destination after acceptance; writer/catch/exporter/native responses are unchanged. Copied QA unsigned executable/resource equality passes; prior OS-validation-blocked attempt is excluded. Candidate LaunchServices real-capture harness is SKIP for missing Screen Recording permission; current macOS27 arm64/Xcode27/Swift6.4 evidence does not establish actual capture/general paste/macOS14/Intel/clean-account acceptance. New-version final build/provenance and any host acceptance are recorded only from actual reports in [candidate QA](qa-results.md#2026-10-05-070-release-candidate).

Repository-hygiene steering adds a professional `.gitignore` update and thorough related source/release/build/installer inspection before push and publication. The executor froze only `.gitignore` and passed37 intended ignored paths/29 required visible paths/all78 tracked paths visible with `--no-index`; independent verification also passed43 ignored/33 visible cases. Only known transient OMC paths are ignored; shared SwiftPM schemes/configuration, `Package.resolved`, fonts/licenses and docs remain visible. Read-only related release/build/installer inspection reported no additional blocker; the final candidate/source verdict is recorded separately in `qa-review-0.7.0.md`. This preserves required source/resources/docs, locally retained ignored QA proof and existing user edits.

한국어: 최신 요청으로 남은 검증·문서·일반 push·새 GitHub 릴리스·최신 설치를 진행합니다. 소스는 0.7.0(build 9)이며 새 게시/설치 전까지 공개·설치 0.6.0(8)/`e87e40e`는 기존 기준입니다. 앞선 UI 독립 승인은 당시 동결 입력에만 적용하고 새 후보/자료 검토와 실제 결과를 구분합니다. 아래 과거 요청의 배포 제외 문구는 당시 기록이며 현재 요청으로 대체됩니다. 기존 식별자·설정·키·자동 확인 기본값과 여덟 구현·과거 증거를 보존합니다.

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

## 2026-10-05 0.6 final implementation and independent evidence

This supersedes the planned-driver wording in the dated documentation review below while preserving that earlier record. Source [APPROVE](qa-review-0.6.0.md) covers the frozen candidate subsequently committed/tagged at `e87e40e1fe5e962c4e2f1d9bc5b1d356711b417d`; final clean public six-file/feed, exact 171-entry installation and bounded normal-runtime evidence are separately recorded in current QA.

| Finding / method | Current conclusion and limit |
| --- | --- |
| Native window geometry | Ordinary titled/hidden-title/transparent-titlebar window, no `.fullSizeContentView`, provides 720×560 default and 620×480 minimum content. Earlier 84 pt collapse was reproduced and corrected; its internal AppKit cause is not asserted. Final fixtures assert root/frame/page/viewport/control and bitmap dimensions, not a manually resized raster. Reviewer observed full native frames separately |
| Live explicit localization | Lock-protected mutable `AppLocalization`, explicit en/ko sub-bundle lookup/English fallback and synchronous notification relabel retained controls/menus/overlay/driver. App-host defaults use standard defaults for its own identifier; inert fixtures only read persistent-domain snapshots. 159 app/57 Updates keys per language and live-core/state fixtures PASS |
| Native key equivalents | Saved physical key/current-layout translation, separate native key/modifier flags, shared menu factory and only the remembered-mode equivalent; stale saved labels ignored, unresolved keys omit native equivalent. Current-layout public menu dispatch/simulated second action PASS; alternate layouts/input-source changes/user overrides and Carbon delivery unrun |
| Sparkle public contract | Pinned 2.10.0 public headers, [SPUUpdater](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html), [SPUUserDriver](https://sparkle-project.org/documentation/api-reference/Protocols/SPUUserDriver.html) and [customization](https://sparkle-project.org/documentation/customization/) informed one updater/retained driver, 16 required callbacks + optional focus. Synthetic callback/state/language replies PASS; real new-version property mapping/download/install/relaunch and OS dialogs unrun; root separately observed an actual signed-feed manual no-update result and existing result-window live relabel. No framework patch/private API/language service reset |
| Resource/installer compatibility | Regular nonsymlink Localizable and Updates tables required for each language in new payloads; older backup rollback checks keep their earlier resource contract. Reviewer 34 resource/15 signed temporary installer/16 release gate cases PASS; no real rollback implied |

Primary Apple references read by implementation/review lanes: [contentView](https://developer.apple.com/documentation/appkit/nswindow/contentview), [contentLayoutGuide](https://developer.apple.com/documentation/appkit/nswindow/contentlayoutguide), [keyEquivalent](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalent), [modifier mask](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalentmodifiermask), [explicit localized lookup](https://developer.apple.com/documentation/foundation/bundle/localizedstring(forkey:value:table:)), [UserDefaults suite initialization](https://developer.apple.com/documentation/foundation/userdefaults/init(suitename:)). Links support the API/design choices, not complete runtime acceptance.

Environment/checks: macOS 27.0.1 (26A434), arm64, Xcode 27/Swift 6.4/macOS 27 SDK; declared minimum macOS14. Final authors ran 36 tests/no Swift warnings and four integrated 92-image fixtures; reviewer verified all 368 PNG integrity/digests and inspected representative/native windows/popups. Popup action selection was zero/unverified, and the reviewer disclosed an unintended installed-0.5 launch during name-based CUA fallback. Whole-GUI preference-free operation is not claimed. See [current QA](qa-results.md#2026-10-05-060-publication-installation-and-cleanup) and ignored author/reviewer reports for exact methods.

Reproduce after an authorized exclusive build lease using the commands in [QA plan](qa-plan.md); run bundled `--localization-self-test`, then `--ui-preview` for en/ko × light/dark with separate ignored output directories. These inert paths do not perform real capture/update/permission/clipboard work. This writer only inspected evidence; no build/SDK/runtime probe was rerun here.

한국어: 과거 driver 계획을 보존하되 현재는 public 단일 updater/16개 callback·즉시 현지화·일반 titled 창/정확한 geometry·native 단축키 구현과 독립 승인 증거로 대체합니다. 36 test·159+57 문자열·368 합성 export/resource34/installer15/gate16을 확인했지만 popup 선택·Carbon·대체 레이아웃·실제 캡처/권한/붙여 넣기·VoiceOver·macOS14/Intel·실제 업그레이드는 별도 미검증입니다. 이후 root는 실제 공개 바이트·171개 설치 항목·159+57 문자열과 동일 프로세스 언어 전환/수동 최신 확인/기존 결과 창 현지화를 확인했고 `.build/` 제거 후 재검증했습니다. macOS 창의 언어와 권한 재시작은 앱 현지화와 구분합니다.

## 2026-10-05 0.6 native-menu documentation review

This documentation lane inspected current native menu and explicit en/ko localization changes; implementation and independent verification continue in separate lanes. Apple pages initially returned JavaScript shells and the web Markdown fetch rejected the content type. A read-only HTTPS retrieval of the official `.md` pages supplied their actual content on 2026-10-05:

| Primary source | Documentation implication |
| --- | --- |
| [NSMenuItem.keyEquivalent](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalent) / [keyEquivalentModifierMask](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalentmodifiermask) | Native shortcuts use an unmodified key and a separate modifier mask. Derive them from the configured key/layout; keep text titles free of padded shortcut hints |
| [NSToolbar](https://developer.apple.com/documentation/appkit/nstoolbar) | Native window navigation can use toolbar items in the title-bar area; exact layout remains a project choice |
| [NSPopUpButton](https://developer.apple.com/documentation/appkit/nspopupbutton) | Native list selection fits the English / 한국어 control; menu tracking does not reflect arbitrary programmatic menu changes mid-track |

Reproduce by requesting the linked URL with `.md` appended and inspect the symbol title/discussion. Source inspection alone does not prove focus, native popup behavior, live language rendering or a real capture. The 0.6 plan uses explicit app-localization lookup plus refresh notifications and a supported custom Sparkle user driver for app-owned update dialogs; macOS-owned permission/security prompts remain OS-controlled. The user-driver implementation, synthetic callback fixtures and independent verdict must be recorded separately before completion claims. No app, preferences, TCC, clipboard, Keychain, Git or network mutations were made in this documentation lane.

한국어: Apple의 공식 Markdown 원문을 읽어 native 단축키의 key/modifier 분리, toolbar 및 언어 선택 popup 동작을 확인했습니다. 소스 확인은 실제 포커스·메뉴·언어·캡처 통과를 뜻하지 않습니다. 0.6은 앱 소유 언어의 즉시 갱신과 지원되는 Sparkle 사용자 driver를 계획하고 macOS 시스템 창은 OS 언어 범위로 구분합니다.

## 2026-10-05 documentation-source review

Method: inspected current Swift/AppKit sources and existing docs without operating capture GUI; consulted official Apple documentation through web retrieval and Apple's public DocC JSON endpoints (`developer.apple.com/tutorials/data/…`). JavaScript-only page shells were not treated as content evidence: the native design/accessibility/materials and package-localization JSON returned the document titles and content. No SDK probe, build, capture, permission grant, clipboard write, installation, or release was performed in this documentation lane.

| Primary source | Grounded decision |
| --- | --- |
| [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos) | Native windows/menu commands, appropriate density, keyboard workflows |
| [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) | Labels, perceivable states, system colors, contrast and alternate interaction |
| [NSColor](https://developer.apple.com/documentation/appkit/nscolor), [NSFont](https://developer.apple.com/documentation/appkit/nsfont) | Semantic roles and system fonts; project sizes are choices |
| [Materials](https://developer.apple.com/design/human-interface-guidelines/materials), [Reduce Transparency](https://developer.apple.com/documentation/appkit/nsworkspace/accessibilitydisplayshouldreducetransparency) | Restrained system materials, opaque readable help/control fallback |
| [Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy) | Request at capture intent; clear explicit request and later recovery |
| [Package localization](https://developer.apple.com/documentation/xcode/localizing-package-resources), [String catalogs](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) | English/ko resources, complete strings, deterministic fallback; verify actual packaging |
| [First launch](https://support.apple.com/en-us/102445), [Screen Recording settings](https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac) | Per-app approval and Screen Recording consent are distinct from Ed25519 integrity |

Reproduce: fetch the linked official pages; if the HIG page supplies only a JavaScript shell, fetch `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-macos.json` (and the corresponding topic path) and inspect `metadata.title` / `primaryContentSections`. Recheck availability in the installed SDK before implementing APIs. These readings support design decisions, not runtime passes. The **2027 TREND PREDICTION** column is an explicitly speculative project hypothesis.

한국어: Apple 원문과 실제 소스를 확인해 native 토큰·권한·키보드·현지화 방향을 정했습니다. JavaScript shell만 본 자료는 근거로 쓰지 않고 공개 DocC JSON 내용을 확인했습니다. API probe·앱 테스트는 재실행하지 않았고 2027 예측은 사실이 아닌 가설입니다.

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
