# P2-T11 — Delete Toys With Double Click Or Double Tap

## Objective Summary

Allow players to remove an existing spawned toy by double clicking (desktop) or double tapping (touch) directly on that toy while preserving current single click/tap behavior for selection and drag start.

## Dependencies

- P2-T6 — Extract Interaction Controller From Sandbox Orchestration
- P2-T9 — Select Spawned Toys By Clicking In-World Instances

## Scope And Deliverables

- Add interaction-controller logic to detect rapid repeated tap/click on the same toy instance.
- Delete only the targeted toy instance without affecting other spawned toys.
- Preserve single click/tap behavior used for selection and drag initiation.
- Keep sandbox flow stable after deletion (selection handling, spawn count/stats, further interactions).
- Validation report: `SPECS/INPROGRESS/P2-T11_Validation_Report.md`.

## Acceptance Criteria And Acceptance Tests

1. Double clicking a spawned toy deletes that toy immediately.
   - **Test:** Spawn multiple toys, double click one toy, verify only that toy is removed.
2. Double tapping a spawned toy on touch input deletes that toy immediately.
   - **Test:** On touch runtime (or touch simulation), double tap one toy and verify deletion.
3. Single click/tap behavior for selection and drag start remains unchanged.
   - **Test:** Single press selects, drag threshold still required before drag begins, release without drag does not delete.
4. Deleting a toy this way does not break active selection state, sandbox stats, or subsequent spawn/interaction flow.
   - **Test:** Delete a toy, then spawn/select/drag/duplicate/resize and confirm expected behavior.

## Test-First Plan

- Add validation-first behavioral checks in controller logic pathways before finalizing implementation.
- Re-run existing quality gates to catch regressions in scene/script loading and lint validation.
- Execute focused manual protocol for click and touch interaction confirmation.

## Implementation Plan (Hierarchical TODO)

### Phase 1 — Interaction Detection Design
- Add state for last tap/click timing, location, and toy identity.
- Evaluate second rapid tap/click against configurable thresholds.

### Phase 2 — Toy Deletion Behavior
- Add internal helper to safely delete a specific toy instance.
- Ensure drag/pending-drag state is cleared safely when the deleted toy is involved.

### Phase 3 — Stability And Validation
- Keep status messaging and active selection transitions coherent after deletion.
- Run project quality gates (`tests`, `lint`) and record outcomes in the validation report.

## Risks And Mitigations

- **Risk:** Double-tap detection could trigger during normal selection taps.
  - **Mitigation:** Require both tight time and world-position thresholds on the same toy instance.
- **Risk:** Deleting a toy while in pending drag state leaves stale pointers.
  - **Mitigation:** Centralize deletion cleanup through one helper that clears drag/pending state as needed.
- **Risk:** Mobile emulated mouse events interfere with touch behavior.
  - **Mitigation:** Keep existing mobile emulated mouse suppression path intact and layer double-tap logic on top.
