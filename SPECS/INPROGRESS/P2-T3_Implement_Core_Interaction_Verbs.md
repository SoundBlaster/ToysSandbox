# P2-T3 — Implement Core Interaction Verbs

**Task ID:** P2-T3  
**Phase:** Core Sandbox  
**Priority:** P0  
**Dependencies:** P2-T1  
**Status:** Planned

## Objective Summary

Implement the first complete interaction loop for the sandbox: spawn, grab/drag, duplicate, resize, and reset. The behavior must remain simple, deterministic, and readable for both desktop and touch input. This task should build on the existing toy shelf + spawn pipeline without introducing separate interaction systems per platform.

Design intent is to keep `Sandbox.gd` as the orchestration layer and `ToyInstance.gd` as the per-object interaction state holder. `GameState.selected_toy_id` remains the source of truth for what gets spawned, while the active in-world toy is tracked transiently in the sandbox scene only.

## Success Criteria And Acceptance Tests

### Success Criteria
- Player can spawn and manipulate toys with two actions (select + interact).
- Grab/drag works with mouse and touch.
- Duplicate and resize target the active toy instance.
- Reset clears active spawned toys without breaking selection/shelf state.
- Interaction hints/status remain understandable during play.

### Acceptance Tests
1. Spawn at least three toys from shelf selection and confirm each appears with expected visuals.
2. Grab and drag toys with mouse; repeat with touch events.
3. Select a toy instance and duplicate it; verify copied toy keeps source definition.
4. Resize active toy larger/smaller and confirm collision + visual update together.
5. Trigger reset and verify all spawned toys are removed while shelf selection remains valid.
6. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
7. Record outcomes in `SPECS/INPROGRESS/P2-T3_Validation_Report.md`.

## Test-First Plan

- Add/extend script interfaces in `ToyInstance.gd` for selection highlighting and deterministic resize APIs first.
- Integrate sandbox interaction handlers around those APIs after interface is in place.
- Verify scene/script load safety through existing Flow validation gates before and after behavior wiring.
- Keep keyboard + button triggers for duplicate/resize/reset so touch and desktop can use the same verbs.

## Hierarchical TODO Plan

### Phase 1 — Interaction Surface And Active Selection

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add active toy tracking in sandbox | Existing spawn root and toy instances | `active_toy` reference, selection highlight updates | Active toy always visible in status text/highlight |
| Implement pick-under-pointer lookup | Physics world + pointer position | Deterministic toy selection for drag | Clicking/touching toy sets it active |

### Phase 2 — Core Verbs Wiring

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Implement grab + drag | Mouse/touch events, active toy APIs | Drag behavior with release handling | Object follows pointer while held |
| Implement duplicate + reset | Active toy + spawn root | New copy spawn path and full clear action | Duplicate produces clone; reset removes all |
| Implement resize controls | Active toy API + UI buttons/shortcuts | Grow/shrink actions with clamp | Toy size changes safely and remains sim-stable |

### Phase 3 — UX, Validation, And Documentation

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add in-scene controls and hints | `Sandbox.tscn` + `Sandbox.gd` | Buttons/labels for verbs | Controls visible and connected |
| Run quality gates | Flow validate scripts | Passing `tests` and `lint` modes | Validation output ends in pass |
| Write validation report | Run logs + acceptance checks | `P2-T3_Validation_Report.md` | Report maps checks to acceptance criteria |

## Constraints And Toolchain Notes

- Preserve Godot 4 compatibility and current autoload contracts.
- Avoid introducing plugin dependencies or external packages.
- Keep interaction logic readable for future onboarding/tutorial work.
- Reuse existing catalog + spawn flow instead of parallel object definitions.

## Notes

- If interaction complexity grows, consider splitting pointer handling into a dedicated helper script in a later task.
- Future persistence task (`P4-T1`) can optionally store last active toy metadata, but that is out of scope here.
