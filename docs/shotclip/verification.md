# Shot Clip verification and requirement trace

[Requirements](requirements.md) · [Development plan](development-plan.md) · [QA plan](qa-plan.md) · [Results](qa-results.md) · [한국어](#한국어)

Plans do not establish passes. Automatic tests cover deterministic geometry/state/failure paths; user-owned GUI tests cover real capture, permissions, paste, focus, and rendering.

| Requirement | Phase / decision | Automatic or review evidence | User-owned / release evidence |
| --- | --- | --- | --- |
| R01 | P1–P2 / D03 | Shortcut validation, conflict/restore, repeated entry | Other app active; change/restart; real overlay |
| R02 | P2,P5 / D04,D06 | Clamp/move/resize and default region | Handles, Return/Capture, repeat region |
| R03 | P2,P5 / D04 | Four drag directions, zero/invalid rect | Valid release captures; reverse drag/cancel |
| R04 | P1,P5 / D05 | Encode-before-clear, write result/error | Immediate general clipboard image |
| R05 | P5 / D05 | No key injection source review | Image-capable app ⌘V; Preview ⌘N |
| R06 | P1–P2,P5 / D08,D12 | Preflight gating, unavailable/recovery presentation | Fresh grant, deny/revoke, recheck/restart |
| R07 | P1–P2,P5 / D04 | Negative origins, scales, rounding, bounds | Real mixed-scale screens and changes |
| R08 | P1,P5 / D02 | Filter and cursor configuration review | Synthetic capture has no overlay/buttons/cursor |
| R09 | P1–P2,P5 / D05,D07 | Cancel/timeout/late result, rollback/external-change tests | UI cancel/failure preserves existing clipboard; OS limits disclosed |
| R10 | P1–P2,P5 / D07 | Single flight and stale result tests | Repeated shortcut/capture sessions |
| R11 | P1,P5 / D05 | Storage/network/log paths and buffer lifetime review | Metadata-only successful-capture diagnostics; no sensitive output |
| R12 | P2,P5 / D09,D11 | Key mapping and accessible-label/focus source review | M, native Tab/Shift-Tab, VoiceOver, error/sleep/display recovery |
| R13 | P6–P7 / D10,D14 | URL/key fail closed; signed feed/archive/manifest; tamper rejection | Uploaded bytes/canonical feed; actual version upgrade |
| R14 | P2–P4 / D11–D13 | Shot Clip plist/crop-copy icon, capture-first shared menu, quiet lifecycle; inert native previews | Native popup/focus/accessibility separately tested; both languages/minimum sizes/appearances |
| R15 | P4 / D13 | English default, key parity, fallback, saved choice, bundled resources | Restart applies all app-owned UI; Korean layout/labels |
| R16 | P3,P7 / D12 | Unchanged ID/executable/settings/key; spaced app root; signed temp migration/wrong-ID/three-path rollback fixtures | Canonical manual-folder migration and exact installed payload; historical Sshot grant separate; actual update unrun |
| R17 | P6–P7 / D08,D14 | Explicit ad-hoc mode, clean reviewed source/tag/artifact, signatures | Preview notes, downloaded artifact, per-app first launch; no notarization claim |

## Evidence rules

Record date, commit, environment (macOS/Xcode/CPU), case ID, method, expected/actual result, PASS/FAIL/SKIP, requirement, and remaining defect/limit. Hardware capture records can include display geometry/scale; never include captures, screen content, observed app names/window titles, or clipboard contents. Use synthetic content, inspect images in memory, and keep only safe metadata.

`swift test`, build success, and code review do not prove GUI acceptance. A harness SKIP (including permission absence) is not PASS; `open` returning zero does not prove harness PASS. Latest-host compilation does not prove macOS 14 or Intel support. Cryptographic archive/feed verification does not prove Gatekeeper acceptance, TCC consent, or a completed upgrade.

An independent verifier reviews final changes in a separate context. Keep document checks and runtime checks separate. Code push is verified by local HEAD/remote commit equality; binary release requires its own artifact/tag/upload verification. Capture QA is user-owned and is not a fabricated prerequisite for code push or the authorized preview; disclose missing runtime coverage.

## Document checks

Confirm R01–R17 appear in requirements and verification; phases/decisions map them in development/architecture. Check Markdown relative files/fragments and whitespace, current source paths, Shot Clip naming, bilingual entry points, and explicit prediction labels. Historical audit entries may keep legacy names only under an archive disclaimer. See [handoff](handoff.md) for this worker’s actual checks.

## 한국어

R01–R17을 단계·설계 결정·자동 검증·사용자/배포 검증에 연결합니다. 자동 테스트는 순수 로직과 오류 경로를 검증하고 실제 캡처·권한·붙여 넣기·포커스·VoiceOver·레이아웃은 사용자 담당입니다. 빌드/문서 확인이나 SKIP을 앱 동작 PASS로 바꾸지 않습니다.

결과는 날짜·commit·환경·case·예상/실제·상태·요구사항·남은 한계만 기록합니다. 이미지·화면·앱/창 이름·클립보드 내용은 저장하지 않습니다. 작성과 독립 검토를 분리하고 코드 push·공개 바이너리·실제 업데이트 증거를 각각 확인합니다.
