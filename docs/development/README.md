# Developing Shot Clip

[App user guide](../user-guide.md) · [Documentation index](../README.md)

## Start here

Read the [handoff](handoff.md) for the current task and actual delivery state, then use the [build and development plan](development-plan.md#build-from-source). Run commands from the repository root. Normal development builds share product preferences; the separate QA app is intended for inert checks.

## Product and design

- [Product plan](product-plan.md): audience, scope and supported behavior.
- [Requirements](requirements.md): R01–R18 and acceptance criteria.
- [Architecture](architecture.md): components, safety boundaries and D01–D18 decisions.
- [Design system](design-system.md): native presentation, typography and language geometry.
- [Technical validation](technical-validation.md): official API sources, recorded environment and limits.

## Implement and verify

- [Development plan](development-plan.md): build recipe and ordered P0–P10 trace.
- [QA procedures](qa-plan.md): fast regressions, isolated UI/security checks and user-owned real capture acceptance.
- [QA results](qa-results.md): executed evidence, current work and unrun coverage.
- [Requirement trace](verification.md): requirement → phase/decision → proof and remaining scope.

## Deliver

[Release operations](update-operations.md) covers reviewed source/tag preparation, signing, GitHub publication, download verification and installation. Ad-hoc previews and Developer ID/notarized releases are distinct routes. Never export or replace the established signing key.

Dated ledgers and independent reviews are preserved in the [frozen archive](../archive.md). Current guides are English; app localization remains English/Korean.
