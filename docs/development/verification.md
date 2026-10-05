# Shot Clip verification and requirement trace

[Requirements](requirements.md#requirements) · [Development phases](development-plan.md#ordered-work-and-trace) · [Results](qa-results.md#current-evidence)

## Current evidence

0.8.1 (build 11) is published/installed, with immutable source A `3140c27629708eecca53ff820066356be7cf443d`. Existing recorded proof covers exact signed public/latest/installed bytes, a real newer-build Sparkle upgrade, normal cold restart and bounded native language/pane behavior. New release checks must be recorded separately; existing 0.8.1 evidence is not proof for a new artifact. Logic/synthetic/native/delivery evidence below is deliberately separate.

## Requirement trace

| Requirement | Phase / decision | Recorded proof / remaining scope |
| --- | --- | --- |
| R01 | P1–P2 / D03 | Shortcut validation/conflict/mapping and remembered native menu row; real Carbon/input-source/global interaction not newly tested |
| R02 | P2,P5 / D04,D06 | Clamp/move/resize/session fallback logic; current real handles/Return capture unrun |
| R03 | P2,P5 / D04 | Reverse/zero/invalid drag logic; current real mouse-release capture unrun |
| R04 | P1,P5 / D05 | Encode-before-clear and commit/error logic; real general clipboard image/paste unrun |
| R05 | P5 / D05 | No keystroke injection in source; destination paste is user-owned |
| R06 | P1–P2,P5,P8 / D08,D11,D12 | Permission gating/source/synthetic dispatch and normal permission-needed view; actual grant/deny/revoke cycle unrun |
| R07 | P1–P2,P5 / D04 | Negative origins/scale/rounding geometry; real mixed-display hardware unrun |
| R08 | P1,P5 / D02 | Filter/cursor configuration; current captured pixel/exclusion proof unrun |
| R09 | P1–P2,P5 / D05,D07 | Cancellation/timeout/late-result/rollback/external-change regressions; OS atomicity limits remain |
| R10 | P1–P2,P5 / D07 | Single-flight/session-token tests; full repeated real capture sessions unrun |
| R11 | P1,P5,P10 / D05,D15,D18 | Local storage/export/lifetime boundaries; production QA exclusion, retired argv and full path scanner negatives |
| R12 | P2,P5 / D09,D11 | Key/label/focus source and synthetic evidence; full VoiceOver/native focus/sleep/hardware scope unrun |
| R13 | P6–P7,P10 / D10,D14,D18 | Signed archive/feed, integer-zero failure expiry, tamper/policy fixtures and real valid-feed newer-build update; no live 20-day invalid-feed experiment |
| R14 | P2–P4,P8–P9 / D11–D13,D16–D17 | Square rail/icon, font provenance/shaping, full bilingual geometry/ink; normal native root/tree proof is narrower than fixture inventory |
| R15 | P4,P9 / D13,D17 | 173/57 en/ko keys, fallback/live transitions/persistence and preserved synthetic/native state; OS prompts separate |
| R16 | P3,P7 / D12 | Stable identity/key/settings, signed temporary migration/rollback and exact canonical installed payload; legacy grant remains separate |
| R17 | P6–P7 / D08,D14 | Explicit ad-hoc mode, reviewed source/tag/public equality and scoped cleanup; no notarization/Gatekeeper universal pass |
| R18 | P8 / D15 | Historical synthetic original/PNG/private clipboard/native-save evidence; current real capture/export/general paste unrun |

## Evidence rules

PASS requires execution in the named environment/input scope. Source approval is not runtime PASS; a synthetic view is not a desktop capture; a private named pasteboard is not normal general clipboard paste. SKIP is not PASS. Never imply normal language root/tree evidence proves all offscreen/hidden frames, or that numeric cleanup bytes equal measured freed disk space.

Record source/artifact hashes, commands and owner; keep authoring and independent approval separate. Do not record capture/screen/clipboard/observed app/window/export-path content. Follow [QA procedures](qa-plan.md) for future code changes.

## Documentation acceptance

The active documentation set is the two root READMEs, `docs/README.md`, `docs/user-guide.md` and `docs/development`. Check relative links/fragments, R01–R18/D01–D18/P0–P10 coverage, English prose outside the Korean README and source-backed usage/build commands. Preserve historical files in `docs/shotclip` byte-for-byte; their claims apply only to their dates and sources. Independent review and release verification are separate from writer checks.
