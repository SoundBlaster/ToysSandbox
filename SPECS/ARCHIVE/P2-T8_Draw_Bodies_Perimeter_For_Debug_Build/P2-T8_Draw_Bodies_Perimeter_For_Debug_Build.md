# P2-T8 — Draw Bodies Perimeter For Debug Build

## Objective Summary

Add a debug-only visual overlay for spawned toy bodies so collision shapes and interaction bounds are immediately visible during development. The overlay must be automatically disabled in non-debug/export builds and must not change selection, drag, tool reactions, or physics simulation behavior.

## Scope And Deliverables

- Debug-only perimeter visualization for toy collision/body shapes.
- Integration point in runtime scripts/scenes where spawned toys can toggle perimeter rendering.
- Automated/manual validation proving no gameplay behavior regressions.
- Validation report file: `SPECS/INPROGRESS/P2-T8_Validation_Report.md`.

## Acceptance Criteria And Acceptance Tests

1. Body perimeter overlays are visible in debug runs for spawned toy instances.
   - **Test:** Run sandbox in debug, spawn multiple toy archetypes, verify each toy draws a readable perimeter.
2. Overlay rendering is disabled in non-debug/export gameplay builds.
   - **Test:** Gate drawing with debug build/runtime check and verify overlay path does not execute outside debug.
3. Overlay does not alter physics behavior, selection, or drag interactions.
   - **Test:** Execute spawn/select/drag/duplicate/resize/reset/fan/smash flows with and without overlay enabled; behavior must match.
4. Visual style remains readable over existing toy sprites and fallback polygons.
   - **Test:** Confirm stroke color/width/contrast remains legible across light/dark backgrounds and toy skins.

## Test-First Plan

Before implementation changes:

- Add or extend validation script checks/manual checklist to include debug-overlay expectations.
- Define deterministic manual test protocol in validation report template:
  - spawn three distinct toy archetypes,
  - drag and throw one toy,
  - run fan/smash actions,
  - confirm perimeter visibility and no behavior change.
- If project test harness supports scene/runtime assertions, add guard checks for debug gate behavior.

## Implementation Plan (Hierarchical TODO)

### Phase 1 — Runtime Hook And Debug Gate
- **Inputs:** Existing toy instance render pipeline (`scripts/game/ToyInstance.gd` and related scene nodes).
- **Outputs:** A debug-gated perimeter drawing path (`OS.is_debug_build()` / runtime debug condition) with no export impact.
- **Verification:** Local sandbox run confirms perimeter appears only under debug conditions.

### Phase 2 — Perimeter Rendering Style And Shape Mapping
- **Inputs:** Collision shapes and toy visual dimensions for all archetypes.
- **Outputs:** Readable outline style (color, alpha, width, z-order) mapped to active body shape.
- **Verification:** Visual pass for all toy types over both sandbox/menu backgrounds.

### Phase 3 — Regression And Quality Gates
- **Inputs:** Existing interaction flows and CI validation commands from `.flow/params.yaml`.
- **Outputs:** Passing tests/lint plus written validation report with PASS/PARTIAL/FAIL verdict and evidence.
- **Verification:** `bash scripts/ci/flow_validate.sh tests` and `bash scripts/ci/flow_validate.sh lint` complete successfully.

## Decision Points And Constraints

- Keep implementation localized to toy rendering scripts to avoid interaction-controller coupling.
- Prefer engine-native `_draw()` and `queue_redraw()` over additional scene complexity unless existing architecture already has debug visuals.
- Use build/runtime gate that is deterministic across desktop/mobile debug sessions.
- Avoid adding plugin dependencies for debug rendering.

## Risks And Mitigations

- **Risk:** Overlay sits behind sprite or UI.  
  **Mitigation:** Control draw order and color contrast explicitly.
- **Risk:** Shape mismatch for non-rectangular toys.  
  **Mitigation:** Draw from active collision shape geometry rather than texture bounds.
- **Risk:** Performance overhead with many toys in debug.  
  **Mitigation:** Keep draw logic lightweight and debug-gated only.

## Notes

After completion, update:

- `SPECS/Workplan.md` (mark `P2-T8` complete).
- `SPECS/ARCHIVE/INDEX.md` via ARCHIVE step.
- Any troubleshooting doc if overlay usage should be discoverable for future physics debugging.

---
**Archived:** 2026-03-29
**Verdict:** PARTIAL
