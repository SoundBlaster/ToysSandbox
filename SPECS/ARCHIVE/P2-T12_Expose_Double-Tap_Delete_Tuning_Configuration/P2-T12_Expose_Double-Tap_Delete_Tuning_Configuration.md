# P2-T12 — Expose Double-Tap Delete Tuning Configuration

## Objective Summary
`P2-T11` delivered working double-click/double-tap delete interactions, but the timing and spatial thresholds are currently hard-coded inside `SandboxInteractionController.gd`. This task externalizes those thresholds into one shared configuration surface so future UX tuning does not require code edits in interaction logic.

The implementation must preserve current behavior at default values while allowing controlled overrides. The preferred path is to define project settings keys under a stable namespace and load values once during interaction controller setup. This keeps tuning centralized, avoids gameplay behavior drift, and maintains clean separation between orchestration (`Sandbox.gd`) and interaction internals (`SandboxInteractionController.gd`).

## Success Criteria
- Controller no longer depends on hard-coded delete-tap thresholds for runtime decisions.
- Default values match current behavior (`320 ms` window, `28 px` max distance).
- Tuning values are resolved from one shared config path with robust fallback and bounds checks.
- Existing interaction semantics remain unchanged when no override is set.
- Validation commands from `.flow/params.yaml` pass:
  - `bash scripts/ci/flow_validate.sh tests`
  - `bash scripts/ci/flow_validate.sh lint`

## Acceptance Tests
1. Fresh run with no explicit custom project settings: double-click/double-tap delete works as before.
2. Project setting override for delete window and distance is read and applied on controller setup.
3. Invalid or non-positive override values safely fall back to defaults.
4. No regressions in selection, drag start, and toy spawn on pointer press/release paths.

## Test-First Plan
- Add a validation-focused checklist in this PRD and validation report before implementation.
- Implement smallest change set that introduces configurable thresholds plus fallback guards.
- Run tests/lint quality gates after changes; if regressions appear, roll back and narrow scope.

## Hierarchical TODO Plan

### Phase A — Configuration Design
- **Inputs:** `P2-T11` review note, existing controller constants, project settings conventions.
- **Outputs:** Config key names and fallback policy.
- **Verification:** Keys are namespaced and defaults equal legacy constants.

### Phase B — Implementation
- **Inputs:** `Sandbox.gd`, `SandboxInteractionController.gd`.
- **Outputs:** Controller setup receives resolved tuning values; delete detection consumes configurable fields.
- **Verification:** Static review confirms no behavior changes outside threshold source.

### Phase C — Validation & Documentation
- **Inputs:** `.flow/params.yaml` quality gates, docs update target.
- **Outputs:** Validation report and short tuning doc section.
- **Verification:** Both quality-gate commands pass; docs identify key names and defaults.

## Decision Points & Constraints
- Keep API changes minimal and backward compatible.
- Validate values defensively (`max(value, minimum)`) to avoid disabling delete accidentally.
- Avoid introducing new autoload dependencies for this small tuning surface.

## Notes (Docs To Update On Completion)
- Update `README.md` with a short “Interaction tuning” note listing project setting keys and defaults.
- Add validation outcome summary in `SPECS/INPROGRESS/P2-T12_Validation_Report.md`.
