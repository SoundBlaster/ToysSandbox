# P2-T6 — Extract Interaction Controller From Sandbox Orchestration

**Task ID:** P2-T6  
**Phase:** Core Sandbox  
**Priority:** P1  
**Dependencies:** P2-T3, P2-T5  
**Status:** Planned

## Objective Summary

Extract pointer/drag/action orchestration out of `scripts/game/Sandbox.gd` into a dedicated interaction controller module so the sandbox scene script focuses on scene wiring, shelf state, and catalog presentation. The extracted module must preserve existing gameplay behavior for spawn, drag, duplicate, resize, reset, fan, and smash across both mouse and touch event paths.

The target architecture keeps `Sandbox.gd` responsible for world-specific helpers (pick, spawn, clamp, half-extents, active-toy selection visuals), while a new `SandboxInteractionController.gd` owns state transitions and verb dispatch. Integration should use explicit dependency injection (callables + node refs) so controller logic remains testable and independent from scene-tree lookups.

## Success Criteria And Acceptance Tests

### Success Criteria
- `Sandbox.gd` no longer directly owns full pointer/drag lifecycle state machine.
- A dedicated interaction controller encapsulates pointer down/move/up transitions and action verb dispatch.
- Existing spawn/drag/duplicate/resize/reset/fan/smash behavior remains functionally equivalent for mouse and touch input.
- Flow quality gates pass using configured project commands.

### Acceptance Tests
1. Verify `Sandbox.gd` delegates `_unhandled_input()` to the controller and no longer implements the drag lifecycle handlers directly.
2. Verify controller retains one authoritative drag pointer policy and pending-drag threshold behavior.
3. Verify action buttons and keyboard shortcuts still call duplicate/resize/reset/fan/smash via controller logic.
4. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
5. Record outcomes in `SPECS/INPROGRESS/P2-T6_Validation_Report.md`.

## Test-First Plan

- Introduce `scripts/game/SandboxInteractionController.gd` with drag state and verb methods copied/migrated from `Sandbox.gd` first, preserving constants and ordering semantics.
- Integrate controller into `Sandbox.gd` through explicit setup and callable hooks (`get/set_active_toy`, spawn, pick, coordinate transforms, clamping).
- Remove duplicated orchestration methods from `Sandbox.gd` only after integration compiles.
- Run Flow quality gates and then perform focused manual behavior checks via existing sandbox interaction path.

## Hierarchical TODO Plan

### Phase 1 — Create Dedicated Controller
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add controller script with drag state machine | Current drag lifecycle methods in `Sandbox.gd` | `SandboxInteractionController.gd` with pointer and verb handling | Script loads and methods map to previous behavior |
| Preserve drag release physics logic | Existing throw thresholds and damping constants | Equivalent release velocity and clamping computation | No logic regressions in code comparison |

### Phase 2 — Integrate Into Sandbox
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Wire controller setup in `_ready()` | Sandbox node references + helper methods | Controller receives explicit dependencies | Runtime setup succeeds without null access |
| Delegate input and button actions | `_unhandled_input()` and button callbacks | Sandbox routes actions through controller | Existing controls remain functional |
| Trim orchestration from Sandbox | Legacy pointer/action methods | Reduced sandbox ownership surface | `Sandbox.gd` no longer hosts full lifecycle logic |

### Phase 3 — Validate And Document
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Execute Flow quality gates | `flow_validate.sh` tests/lint | PASS/FAIL outputs captured | Exit code 0 for both gates |
| Produce validation report | Command results + manual checks | `P2-T6_Validation_Report.md` | Acceptance criteria explicitly mapped |

## Constraints And Toolchain Notes

- Keep the refactor behavior-preserving: no new gameplay features, no tuning changes.
- Maintain Godot 4 compatibility and current scene resource paths.
- Preserve current status-label messaging for existing player actions where practical.
- Avoid broad UI/layout edits; this task is architecture-focused.

## Notes

- Any discovered behavior drift should be fixed within this task before ARCHIVE.
- Additional extraction of shelf/catalog concerns is out of scope and can be tracked separately if needed.
