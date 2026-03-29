# P2-T10 — Add Top-Right Collapse/Expand Menu Button

## Objective Summary

Add a compact top-right control on the in-game menu panel that toggles between collapsed and expanded states. Collapsing should reduce visual obstruction over the sandbox while preserving all gameplay interactions; expanding should restore the full menu instantly with prior selection/tool context intact.

## Scope And Deliverables

- Add a top-right collapse/expand button anchored to the menu panel.
- Implement a persistent runtime menu visibility state for the current sandbox session.
- Preserve interaction behavior while collapsed (spawn/select/drag/tools still usable).
- Preserve context when re-expanding (selected toy, active tool labels, button state).
- Validation report file: `SPECS/INPROGRESS/P2-T10_Validation_Report.md`.

## Acceptance Criteria And Acceptance Tests

1. A clearly visible collapse/expand button exists at the menu panel’s top-right corner.
   - **Test:** Launch sandbox; verify button placement and icon/label clarity.
2. Collapsing reduces UI obstruction while preserving core sandbox interactions.
   - **Test:** Collapse menu, then spawn/select/drag and run fan/smash actions successfully.
3. Expanding restores the full menu state and controls without losing selection context.
   - **Test:** Select toy, collapse menu, expand menu, verify selected toy label and shelf selection remain synchronized.
4. Behavior works consistently for mouse and touch input paths.
   - **Test:** Execute collapse/expand via click and touch press simulation.

## Test-First Plan

Before implementation changes:
- Extend or add tests for menu toggle state transitions and context retention.
- Verify no regressions in existing interaction/controller tests.
- Define manual protocol for click and touch checks if automated UI assertions are unavailable in current harness.

## Implementation Plan (Hierarchical TODO)

### Phase 1 — UI Structure And Node Wiring
- **Inputs:** `scenes/game/Sandbox.tscn`, existing menu panel hierarchy.
- **Outputs:** New top-right collapse/expand button node(s) and script references.
- **Verification:** Scene loads; button appears in expected top-right location.

### Phase 2 — Toggle Behavior And State Management
- **Inputs:** `scripts/game/Sandbox.gd` UI state and labels.
- **Outputs:** `_set_menu_collapsed(bool)` state handler, button label/icon updates, hide/show menu content logic.
- **Verification:** Collapsed menu minimizes footprint; expanded menu restores controls and labels.

### Phase 3 — Interaction Safety And Validation
- **Inputs:** `scripts/game/SandboxInteractionController.gd`, CI quality gates.
- **Outputs:** Confirm no interference with pointer handling; produce validation report with evidence and verdict.
- **Verification:** `bash scripts/ci/flow_validate.sh tests` and `bash scripts/ci/flow_validate.sh lint` pass.

## Decision Points And Constraints

- Keep toggle implementation localized to sandbox UI orchestration (`Sandbox.gd`) to avoid unnecessary interaction-controller coupling.
- Use non-destructive visibility toggling rather than rebuilding UI nodes.
- Ensure collapsed affordance remains discoverable and touch-friendly.

## Risks And Mitigations

- **Risk:** Collapsed state hides essential feedback entirely.  
  **Mitigation:** Keep a compact header/handle with clear expand affordance visible at all times.
- **Risk:** Toggle overlaps onboarding/stats overlays at smaller resolutions.  
  **Mitigation:** Anchor and margin tuning with quick visual pass.
- **Risk:** Input capture on hidden controls blocks sandbox interactions.  
  **Mitigation:** Disable/hide only content containers while leaving non-blocking mouse filters.

## Notes

After completion, update:
- `SPECS/Workplan.md` (mark `P2-T10` complete).
- `SPECS/ARCHIVE/INDEX.md` during ARCHIVE step.
- Any sandbox usage docs if the new control should be referenced for QA/playtests.

---
**Archived:** 2026-03-29
**Verdict:** PARTIAL
