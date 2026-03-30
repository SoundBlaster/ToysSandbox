# P5-T1 — Harden Pull Request Template And Validation Guidance

## Status
- Planned

## Context
The current pull request template is minimal and does not consistently capture implementation scope, validation evidence, or links to FLOW artifacts (`next.md`, task PRD, validation report). This task upgrades the template to improve review quality and release confidence while staying lightweight for small documentation-only changes.

## Deliverables
1. Updated `.github/PULL_REQUEST_TEMPLATE.md` with a clearer structure:
   - Summary
   - What Changed
   - Validation
   - FLOW Artifacts
   - Notes
2. Validation checklist with explicit automation and runtime/editor verification entries.
3. Artifact references section that encourages linking to the active task PRD and validation report.

## Dependencies
- P1-T4 (existing quality gate and FLOW scaffolding)

## Acceptance Criteria
- `.github/PULL_REQUEST_TEMPLATE.md` contains structured sections for summary, implementation details, validation evidence, and workflow artifact references.
- Validation checkboxes map to repository practices (automation + manual runtime/editor checks).
- Template remains concise and suitable for both code and docs changes.
- No stale placeholders or broken references are introduced.

## Implementation Plan
1. Review current template and repo workflow docs for consistent terminology.
2. Replace placeholder bullets with clear prompts and checklists.
3. Add a FLOW artifact section with optional links to:
   - `SPECS/INPROGRESS/next.md`
   - Active task PRD
   - Validation report
4. Run project quality gates (`verify.tests`, `verify.lint`) to validate no regressions.
5. Produce `SPECS/INPROGRESS/P5-T1_Validation_Report.md` with execution results and verdict.

## Risks And Mitigations
- Risk: Template becomes too verbose and discourages usage.
  - Mitigation: Keep sections short with optional details in `Notes`.
- Risk: Checklist drifts from real workflow commands.
  - Mitigation: Align wording to existing FLOW and `.flow/params.yaml` verification gates.
