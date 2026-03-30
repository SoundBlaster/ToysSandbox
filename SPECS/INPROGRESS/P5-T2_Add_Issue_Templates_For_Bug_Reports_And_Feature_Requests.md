# P5-T2 — Add Issue Templates For Bug Reports And Feature Requests

## Status
- Planned

## Context
The repository currently has a pull request template but no structured issue intake flow. As a result, bug and feature requests can arrive without reproducible details, environment context, or clear acceptance targets. This task adds concise GitHub issue forms aligned with the project's FLOW-driven validation and documentation practices.

## Deliverables
1. New bug report form at `.github/ISSUE_TEMPLATE/bug_report.yml` that captures:
   - summary and impact
   - reproducible steps
   - expected vs actual behavior
   - environment details
   - validation evidence
2. New feature request form at `.github/ISSUE_TEMPLATE/feature_request.yml` that captures:
   - user problem
   - proposed solution
   - alternatives considered
   - acceptance criteria
   - validation plan
3. Issue template configuration at `.github/ISSUE_TEMPLATE/config.yml` with concise guidance and discussion redirection.

## Dependencies
- P5-T1 (pull request template and FLOW artifact guidance)

## Acceptance Criteria
- `.github/ISSUE_TEMPLATE/bug_report.yml` exists with required fields for reproduction steps, expected behavior, and environment details.
- `.github/ISSUE_TEMPLATE/feature_request.yml` exists with required fields for user problem, proposed change, and acceptance criteria.
- `.github/ISSUE_TEMPLATE/config.yml` guides users toward discussions while keeping the issue intake experience concise.
- Template wording references repository artifacts and validation practices without stale links.

## Implementation Plan
1. Inspect existing `.github/` artifacts to align tone and field naming.
2. Add bug report and feature request YAML forms with required fields and sensible defaults.
3. Add issue template config to disable blank issues and provide discussion/guide links.
4. Run project quality gates (`verify.tests`, `verify.lint`) to confirm repository automation remains green.
5. Produce `SPECS/INPROGRESS/P5-T2_Validation_Report.md` with command outputs and verdict.

## Risks And Mitigations
- Risk: Forms become too long and discourage issue reporting.
  - Mitigation: Keep required fields minimal and use optional details where possible.
- Risk: Guidance drifts from FLOW practices.
  - Mitigation: Reuse naming and artifact references already used in `P5-T1` template updates.
