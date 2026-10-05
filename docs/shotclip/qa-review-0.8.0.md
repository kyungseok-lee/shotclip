# Independent QA review: 0.8.0 candidate

[Documentation](README.md) · [Current QA](qa-results.md#2026-10-06-080-language-invariant-settings) · [Handoff](handoff.md#2026-10-06-080-settings-handoff)

## 2026-10-06 verdict

**APPROVE the frozen 0.8.0 (build 10) source and candidate documentation for commit, a new version tag, ordinary main/tag push and clean release preparation. No candidate blocker remains.** This independent reviewer authored neither implementation nor release text. Normal installed-app acceptance, exact prepared artifacts, publication, installation and retirement require subsequent evidence and review.

The starting clean `main` is `13314bcdeb2e90edac1d1a70d99f9088c5d90ded`; public/installed 0.7.0(9) remains the delivery baseline. The inspected development bundle identifies that old HEAD as build provenance. It is a development candidate from the frozen working sources, not the subsequently committed release artifact.

## Reviewed behavior and evidence

Settings use the existing process-local Roboto/Noto Sans KR faces and weights, 13/12/14/18 pt roles, nominal 20/18/22/28 pt lines, a shared 160 pt action lane, 720×580 pt default and 620×480 pt minimum. Explicit read-only bilingual localization snapshots reserve complete text at the assigned width. CoreText typographic and tight glyph-path bounds raise a common line height for taller fallback/combining/emoji ink. Language refresh retains native views and interaction state. Capture, updater, clipboard, identity, preferences and signing policy retain their existing boundaries; the shared wrapping-label behavior outside settings remains adaptive.

The source review covered all five frozen implementation/metadata files, localization/state call sites, the preview guard and related build/release text. Native button titles fit their actual title rectangles, full document text retains 12 pt row padding, and the default viewport contains the normal collapsed pages. Larger state content remains scrollable. The updater's supported ready/busy/unconfigured/integer-error alternatives and Access signing/recovery alternatives are represented. Dynamic paths use the same underlying value for both translations; supplied paired diagnostic variants reserve their common maximum.

| Independently checked evidence | Result |
| --- | --- |
| Fresh `swift test` | 36 tests, zero failures; `dist/layout-0.8-qa/independent-swift-test.log` |
| Sealed development bundle | Deep/strict signature; 0.8.0(10), development provenance; 173 app + 57 update keys in each language; all five font/license/notice files byte-identical to source |
| Fresh en/light and ko/dark inert runs | Both terminal exit 0, 176 listed views each; 200 paired cases total, 25 states × four sizes; 139 app-owned structural views per case, 55,600 en↔ko frame comparisons |
| Full geometry | Exact object/parent/frame/bounds/alignment/hidden-state equality, including hidden and offscreen inventory; focus/pane/disclosure/control/scroll state, full glyph/layout/cell bounds, tight ink containment, adjacent-line noncollision and padding PASS |
| Invalid geometry | Five guard types reject truncated status, stale wrapping width, missing padding, overlapping line ink and structural frame drift; no non-JSON stderr or constraint diagnostics |
| Render integrity and visual review | 354 PNG CRCs, including two unlisted synthetic originals; six exact final samples inspected: paired General/light, blocked Access/light, paired minimum long-status/dark with stacked marks/emoji, and expanded-long-path top/light |
| Source/docs inputs | All 20 author-input hashes match; 89 repository inputs recorded; 22 Markdown documents checked, 265 relative links/105 fragments valid; twelve prior non-review bodies and eight historical review reports preserved; release-script logic unchanged; shell/whitespace checks PASS |

The four sealed author runs separately pass 704 listed views/400 paired cases and 416 deliberately invalid executions, supported by `dist/layout-0.8-author/summary.json` and final sibling reports. These counts are not added to the independent rerun counts. The root's resource34/gate16/archive15+valid2/temporary-installer15/crypto25+valid2 reports have the bounded scopes described in current QA.

Sizes are 720×580, 620×480, 670×520 and 820×620 pt. Language-only transitions preserve scroll origins without assistance. Actual resizing may clamp an origin; resize-back fixtures explicitly restore those origins before comparing the returned layout. This restoration is a fixture action, not a production scroll-preservation claim. Offscreen long-path text is checked numerically; the minimum visible PNG does not establish a visual inspection of every offscreen path line.

The initial apparent mixed-glyph collision came from conservative variable-font `NSLayoutManager.boundingRect` boxes. The reviewer reproduced that observation in `independent-textkit-probe.log`. Corrected QA uses tight CoreText paths at actual TextKit fragment origins/baselines, retaining full layout/cell/glyph checks. Apple's [glyph-path option](https://developer.apple.com/documentation/coretext/ctlineboundsoptions/useglyphpathbounds), [line-bounds coordinates](https://developer.apple.com/documentation/coretext/ctlinegetboundswithoptions(_:_:)) and [glyph-location coordinates](https://developer.apple.com/documentation/appkit/nslayoutmanager/location(forglyphat:)) were read on 2026-10-06 KST. The compressed-line negative case confirms that actual adjacent ink overlap is rejected.

## Frozen inputs and remaining gates

Sorted relative path NUL SHA-256 hex NUL fingerprints, excluding this self-referential review:

| Input set | Count | SHA-256 |
| --- | --- | --- |
| Author changes | 20 | `57160dfa4e49f5657d3ffc7f65b442c5b46e15a28eef139ef61fe7d723329ffa` |
| Repository inputs | 89 | `633f979694b673fcd357a2fe646d07bd4d589623512bd7d21dbdde2ac254dab7` |

Exact per-file hashes and independent checks are in ignored `dist/layout-0.8-qa/independent-candidate-inputs.json`, `independent-inert-summary.json`, `independent-package-proof.json` and the two independent run folders/logs. The writer's exact 15-input fingerprint is `fe359465add5887c3b5998f759c6ac3b38454efd5381e62b43add483202e0859`; the five source hashes remain equal to `source-frozen.json`.

The independent exact old-version deletion scope is conditionally approved **only after latest public and canonical installation approval**: 49 owned paths, comprising 38 older apps, eight older archives and three known prior build caches; 11,457 regular files/1,030,102,202 bytes. Root app identifiers, versions, executable hashes, archive CRC/single app root with owned AppleDouble, exact boundaries/counts and non-overlap were rechecked. The plan excludes current proof/latest app/root Git/signing key and does not empty general Trash. `independent-old-deletion-plan-review.json` records plan SHA-256 `b2c7a55cc0b040766b4bd47e9194eb1e38131bb200f087d73ff087dba36431b2`; no deletion is passed by this review.

The reviewer ran only inert previews/localization diagnostics and standalone font/AppKit probes, with synthetic pixels and private named pasteboards. No normal app startup, production preference writes, TCC/general clipboard/key access, installation, Git mutation or remote mutation was performed. Root preference digests prove measured state equality rather than absence of all possible writes. Actual capture/general paste/permission grants, full accessibility, Carbon/alternate input layouts, macOS14/Intel and clean-account/hardware coverage remain unverified. They are separate from this settings-change approval.

한국어: 동결된 0.8.0(10) 소스와 후보 문서를 커밋·새 태그·일반 main/tag push·배포 준비용으로 별도 승인합니다. 작성자와 분리된 조사/검증 맥락에서 실제 36 tests와 두 inert matrix를 재현해 200개 조합·55,600 프레임 비교·전체 잉크/여백·다섯 negative guard를 확인했습니다. 정상 설치 앱·정확한 서명 공개 파일·최신 설치·구버전 삭제·최종 push는 후속 근거로 별도 검토합니다. 실제 resize-back 스크롤 복원은 fixture 동작이며 언어 전환 보존은 자동입니다. 과거 버전 49개 경로 삭제 범위는 최신 공개/설치 승인 뒤에만 유효하고 일반 휴지통·Git 이력/태그·기존 키·현재 증거는 보존합니다.
