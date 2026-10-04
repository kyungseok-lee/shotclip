# ShotClip QA plan

[Trace](verification.md) · [Results](qa-results.md) · [Update operations](update-operations.md) · [한국어](#한국어)

Updated 2026-10-05. Agents run code review and fast automatic/static checks. **Capture GUI, Screen Recording grants, and actual paste are user-owned.** These procedures are planned checks, not performed results; VoiceOver/focus GUI verification is not run.

## Fast code and artifact checks

From the repository root:

```sh
swift test
swift scripts/test-release-manifest.swift
bash -n scripts/build-app.sh scripts/install-app.sh scripts/prepare-update.sh scripts/prepare-github-release.sh scripts/publish-github-release.sh
plutil -lint resources/Info.plist
git diff --check
bash scripts/build-app.sh
codesign --verify --deep --strict dist/ShotClip.app
```

Do not replace a running app or run signing/build changes from an uncontrolled parallel task. Record the actual test count/environment/commit when performed. Inspect sealed bundle identity/executable/version, en/ko resources, unchanged public key, canonical HTTPS URL, and required signed feed/update flags. An ad-hoc local signature check is not a Gatekeeper or notarization pass.

| Area | Cases and observable result |
| --- | --- |
| Geometry | Four drag directions, invalid/nonfinite rect, negative origins, display clamp, top-left conversion, outward rounding, 1x/2x |
| Coordinator | Denial/capture/encode/write error returns idle; selecting reentry activates once; processing ignores reentry; cancel/timeout rejects late results |
| Clipboard | PNG/TIFF ready before clear; unreadable/oversized snapshot aborts; guarded restore; external generation protected; rollback failure stays error |
| Shortcut / keyboard | Validate shortcut, conflict/restore; M mode mapping, Tab/Shift-Tab focus mapping, Return/Escape/arrows; mapping alone is not native-focus QA |
| Migration / language | Only valid shortcut/mode migrate; destination wins; malformed/second-run ignored; no consent/login/updater/key copy; English default and en/ko parity/fallback/persistence |
| Release | Explicit preview mode and reviewed commit; source/tag/version/manifest/hash agreement; tampered archive/feed rejection; safe archive layout; no Keychain access in publisher |

## User’s short acceptance check

1. Open `/Applications/ShotClip.app`. For a downloaded preview, verify the source and follow Apple’s [per-app first-launch flow](https://support.apple.com/en-us/102445) if needed.
2. Choose capture, request Screen Recording, allow **ShotClip**, return and Check Again; restart if access is still unavailable. Denial must preserve usable settings and the clipboard.
3. Move/resize Fixed Region, capture with Return/Capture, and paste in an image-capable app. Repeat in Drag Region, including a reverse drag.
4. Put nonsensitive synthetic content on the clipboard, cancel with Escape, and inspect that the prior content remains. Do not submit the content.
5. With another app active, check `⌃⇧⌘5`; change the shortcut and restart to check persistence. M switches mode; Tab/Shift-Tab reaches controls with visible focus.
6. Set 한국어 in General, restart, and inspect menu/settings/overlay/errors/labels; switch back to English. Compare minimum-size and light/dark layouts.
7. For a historical Sshot installation, install ShotClip manually once, check only selected preference migration, and grant fresh Screen Recording. Do not assume login registration or permission was migrated.

Report only version, case ID, mode, permission status, error code/message, expected/actual result, and reproduction steps. No screen images, app/window names, clipboard content, or passwords.

## Optional real-capture harness — user-owned

After granting access to the built product:

```sh
qa_output_dir=$(mktemp -d)
open -n -W -o "$qa_output_dir/self-test.json" dist/ShotClip.app --args --self-test
sed -n '1,200p' "$qa_output_dir/self-test.json"
```

Run through LaunchServices, not `Contents/MacOS/shotclip`, to avoid terminal responsibility/TCC confusion. The sibling `dist/shotclip-fixture.app` provides synthetic colored content; it is not installed with the product. The harness inspects real capture pixels/size/UI exclusion in memory, uses a unique named NSPasteboard, and prints safe metadata only. No images are saved. Permission absence reports SKIP; judge JSON PASS/FAIL/SKIP, not `open`’s exit code.

## Extended coverage and preview release

Separately record mixed-scale displays, negative-origin screen, screen disconnect/resize, sleep/wake, repeated sessions, denied/revoked permission, clipboard races/failures, VoiceOver, Full Keyboard Access, contrast/reduced transparency, macOS 14, Intel, and clean-account first launch. Missing environments remain unverified.

Verify Ed25519-signed archive **and feed**, uploaded bytes, source/tag consistency, and the public canonical feed for preview publication. Real old/new-version upgrading and post-update capture/settings/TCC need their own evidence; the legacy bundle change uses a one-time manual install. Developer ID/notarization checks belong to a separate future route and are not required for the authorized ad-hoc preview.

## 한국어

에이전트는 코드 리뷰·빠른 자동/정적 검증을 맡고 실제 캡처·권한·붙여 넣기는 사용자가 맡습니다. 위 명령과 절차는 계획이며 실행 결과가 아닙니다. VoiceOver/포커스 GUI도 미실행입니다.

짧은 체크는 ShotClip 실행 → 새 화면 기록 허용 → 고정/드래그 캡처·붙여 넣기 → Escape의 기존 내용 보존 → 단축키/M/Tab → 영어/한국어 재시작 적용 → 과거 앱의 수동 설치와 선택 설정 이전 순서입니다. 문제 공유에는 버전·오류·재현 순서만 필요하고 화면·클립보드 내용은 필요하지 않습니다.

harness는 합성 화면·고유 named pasteboard와 메타데이터만 사용합니다. SKIP은 PASS가 아닙니다. 실제 업그레이드·다중 화면·다른 OS/CPU 지원을 자동 테스트로 대신하지 않으며, 승인된 ad-hoc 프리뷰에는 기존 키로 archive/feed 서명과 원격 산출물 일치를 확인합니다.
