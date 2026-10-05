# Shot Clip 0.8.1 candidate independent review

Date: 2026-10-06 KST. Reviewer: separate document-specialist/verifier lane; this reviewer did not author the implementation, tests or candidate release text.

**APPROVE the frozen 0.8.1 (build 11) candidate source, verification inputs and candidate documents within the evidence below.** No concrete blocking finding remains in that scope. This permits the coordinator's authorized source commit, new tag, ordinary push and clean preparation. It does not approve future prepared/public files, installation, retirement or final delivery documents; each requires its own exact evidence.

## Exact reviewed inputs

- Starting main: `f6113b96600224fe0304689286bb368bd9a9ad7b`. The tested app is an uncommitted development candidate, not eventual source A or public provenance.
- `dist/security-0.8.1-author/candidate-source-fingerprints.json` binds 44 build/source and 18 verification inputs. Independent SHA256 fingerprint of their 62-path union: `7b29a2fd0f2b27e1c4184118fbab82595def32c35013f2ab4b4854ffbae61e8a`.
- Fourteen current documents and release-content text: `10c541876e80fc0cac5175ef63778240f10a7200f21519e501ec39b296146869`. Fingerprints concatenate sorted relative path, NUL, SHA256 hex, NUL. This review is excluded from that author fingerprint.
- Sealed production executable: `f10ccbf7380145d93bc3a44af515c08c4dd0d7d1971f4a408c839caa688e2215`. Separate QA executable: `ed29cca583fa4b3b70a95374ac3497691e630e2558f368a854c7948acbfe04c5`. Both hashes and all 62 inputs remained equal after independent reruns.

## Findings closed in the candidate

| Finding | Independent conclusion |
| --- | --- |
| S01 / R13 | Configuration writes `SUSignedFeedFailureExpirationInterval` as integer 0. Both required signature switches remain true. The actual release gate rejects missing, nonzero, negative, Boolean, string and floating-point expiry values. Pinned Sparkle reads this bundle key; zero prevents recovery after a signing failure, while its valid-signature branch remains eligible. This establishes policy semantics with source interpretation and artifact/negative fixtures, not a live 20-day/network experiment. Archive authentication was already enforced; earlier unsigned-code execution is not established. |
| S02 / R11 | Explicit `SHOTCLIP_QA` guards remove development routes, capture test helper dispatch and diagnostic/save/layout hooks from production. Thirteen retired names, including plain/equals and combined forms, exit 64 before resource/preferences/application initialization. Production is the default; release configuration rejects QA flavor. QA has a separate app/ID/scratch tree and refuses normal startup. Standard Sparkle installer helpers remain bundled. |
| S03 / R11 | Native resource packaging removes the generated absolute resource-accessor fallback. Concise file identifiers, prefix maps and no-debug settings reduce compiler metadata; only verified active-toolchain stdlib RPATHs are removed before signing. Artifact inspection, rather than flags alone, establishes zero prohibited personal/known-checkout/build paths and app-owned QA markers. Public relative module/file identifiers are permitted. |

Review corrections were addressed before freeze: UTF-16 odd alignment, terminal/mixed-case personal roots, bare loader tokens, token-relative RPATH containment, controlled malformed/non-dictionary plist failure, remaining synthetic permission initializer and complete retired-argument coverage. Code review found no change to normal capture/save completion, native controls or existing font/resource bytes from the conditional QA removal.

Official sources were retrieved on 2026-10-06 KST: [Sparkle customization](https://sparkle-project.org/documentation/customization/), [pinned 2.10.0 appcast driver](https://github.com/sparkle-project/Sparkle/blob/eef1a539a373c1f1a320624b1130fc5de7b2e100/Sparkle/SUAppcastDriver.m#L136), [Swift concise file identifiers](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0274-magic-file.md), [SwiftPM resource accessor source](https://github.com/swiftlang/swift-package-manager/blob/main/Sources/Build/BuildDescription/SwiftModuleBuildDescription.swift), and [Apple install_name_tool source](https://github.com/apple-oss-distributions/cctools/blob/main/misc/install_name_tool.c). Prefix maps are not a general runtime-literal sanitizer; actual final bytes remain the release gate.

## Fresh independent evidence

Ignored records and sanitized logs are under `dist/security-0.8.1-qa`, prefixed `independent-`.

| Reproduction | Result / bounds |
| --- | --- |
| Actual security/release fixtures | Six accepts and 71 rejects; temporary signing stubs only. Private UTF-8/UTF-16LE/BE contamination at both alignments, policy types, resources/links, QA payload/names and actual compiled Mach-O/RPATH fixtures reject as expected. |
| Production retired arguments | 27 copied-app cases; exit 64, helper canary not executed, no QA output, application-domain digests equal. No normal application route was launched. |
| Separate portable QA | Installed localization succeeds outside checkout; three normal-route attempts reject; removing its resource bundle exits 78 without external fallback. No self-test/capture route was run. |
| Production payload | Scanner: 99 regular files, nine symlinks, six Mach-O files, zero prohibited categories. Separate raw encoded-prefix/file/link inventory also has zero hits. Deep/strict signature passes; all nine localized/font/license/notice resource files equal source; en/ko each contain 173 app and 57 update keys. |
| Core/resource/release gates | Fresh execution of the finalized core test binary with `swift test --scratch-path .build/tests --skip-build`: 36 tests, zero failures. Resource 34 and publishing 17 cases pass. This is a fresh core run, not an independently rebuilt test binary. |
| Inert layout | `review-en-light` and `review-ko-dark`: 352 declared renders, 200 paired cases, 139 structural views per case, four sizes and five negative guard kinds, zero stderr. Exact frame/full-ink/padding/window/focus/scroll checks pass; all 354 PNGs pass chunk CRC. Representative English General and Korean dark minimum long-status/combining-mark renders are readable. |
| Documents | Exact 15-input fingerprint; 323 relative links including images and 152 fragments across 25 existing Markdown files pass. Fourteen baseline bodies and ten prior reviews remain intact; release script logic outside its text heredoc is unchanged. Syntax and whitespace checks pass. |

The independent matrix-summary postprocessor initially assumed a dictionary instead of the actual list report. It was corrected and the existing successful run outputs/PNGs were checked; this was not a product-run failure. The author's earlier transient-copy matrix wrapper warning is separately disclosed in `portability-iteration.json`; final sealed runs have no stderr.

## Normal candidate evidence and remaining gates

The reviewer inspected root's fresh native states and final screenshot directly: PID 87456/window 6951, General ko→en→ko, 720×608 native root, 25 untruncated elements and exact restored Korean tree; three panes, version/build and existing automatic checks ON were read. The tested executable's pre/post hash equals the frozen production hash above. Stored final-after digests and independent read-only defaults export equal all ten baseline keys. State equality does not prove no writes. Full 139-view geometry belongs to the inert matrices, not native AX evidence.

The existing ad-hoc/arm64/not-notarized/library-validation exception remains a disclosed distribution constraint. Real capture/paste, capture self-test, native save dialogs, permission grants/resets, general clipboard operations, complete accessibility, macOS 14/Intel/clean-account and live invalid-feed clock sequences were not tested here. Existing update keys were not exported or regenerated. New source/tag/remote equality, exact prepared signatures/archive/feed, public redownload, canonical latest installation/runtime and owned cleanup remain pending coordinator gates; this report makes no delivery PASS claim.

한국어: 독립 작성 맥락에서 동결 0.8.1(11) 소스/검증 입력·15개 후보 문서를 승인합니다. 실제 보안 6 수용/71 거부·27 production 인자·36 core 실행·34 resource·17 release gate·별도 QA 352 render/200 case와 전체 artifact/서명/문서를 새로 확인했습니다. 정상 General 전환은 root의 정확한 실행 파일/25 AX/720×608과 설정 열 개 digest 범위이며 전체 139 view 불변성은 합성 matrix 근거입니다. 소스 commit/tag/push와 준비는 진행할 수 있지만 새 공개/설치/정리·실제 캡처/권한/붙여 넣기·별도환경은 이 승인으로 통과 처리하지 않습니다.
