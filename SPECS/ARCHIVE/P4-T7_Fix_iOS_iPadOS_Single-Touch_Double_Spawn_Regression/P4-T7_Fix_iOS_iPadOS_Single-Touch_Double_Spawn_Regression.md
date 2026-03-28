# P4-T7 - Fix iOS/iPadOS Single-Touch Double Spawn Regression

**Task ID:** P4-T7  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P1  
**Dependencies:** P2-T6, P4-T3  
**Status:** Planned

## Objective Summary

Remove the iOS/iPadOS regression where one physical tap on empty sandbox space can create two toys. The fix must preserve the shared interaction-controller architecture from `P2-T6` while making the mobile input path deterministic: one physical pointer press should map to one spawn decision, even if Godot emits both touch and emulated mouse events on Apple mobile devices.

The preferred direction is to make touch authoritative on mobile and treat synthesized mouse events as secondary compatibility input rather than letting both event classes reach the spawn path. The sandbox scene should keep owning world/shelf state, while `SandboxInteractionController.gd` remains the single place where pointer events are normalized into spawn, select, drag, and release behavior.

## Success Criteria And Acceptance Tests

### Success Criteria
- A single tap on empty sandbox space produces exactly one spawned toy on iOS/iPadOS.
- Tapping an existing toy still selects it, and dragging still begins after the current threshold.
- Desktop mouse spawn and drag behavior remain unchanged.
- The controller logic clearly documents or encodes why duplicate mobile events no longer result in duplicate spawns.

### Acceptance Tests
1. On mobile hardware or a reproducible event trace, verify one empty-space tap causes one spawn call and not two.
2. Verify tapping an existing toy does not spawn a new toy and still arms drag-selection behavior.
3. Verify dragging an existing toy still works for touch input after the guard changes.
4. Verify desktop left-click spawn still works and is not blocked by the mobile-specific guard path.
5. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
6. Record outcomes and any environment limits in `SPECS/INPROGRESS/P4-T7_Validation_Report.md`.

## Test-First Plan

- Inspect the current controller entry points and identify where both `InputEventScreenTouch` and `InputEventMouseButton` can reach `_handle_pointer_pressed()`.
- Add a small, explicit regression guard around mobile touch/mouse normalization before altering spawn behavior broadly.
- Reuse the existing Godot validation harness for syntax/resource coverage and pair it with targeted manual reasoning about the duplicated event path, because the current repo does not include a simulator-level automated input test harness.

## Hierarchical TODO Plan

### Phase 1 - Confirm And Tighten Input Ownership
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Audit mobile pointer normalization | `SandboxInteractionController.gd`, current touch suppression heuristic | Precise understanding of why a single touch can call spawn twice | Code path mapped in validation report |
| Make one event source authoritative on mobile | Controller `handle_input()` branches | Deterministic mobile press handling that ignores redundant emulated mouse presses | Empty-space touch no longer duplicates spawn |

### Phase 2 - Preserve Interaction Semantics
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Keep toy selection and drag intact | `_handle_pointer_pressed`, `_handle_pointer_dragged`, `_handle_pointer_released` | Existing touch drag lifecycle still works | Touch select/drag manual checks stay green |
| Leave desktop behavior unchanged | Mouse event branch, non-mobile guard | No regression for desktop click/drag flow | Desktop reasoning plus validation remains green |

### Phase 3 - Validate And Document
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `.flow/params.yaml` verify commands | Passing tests/lint or documented blockers | Commands exit successfully |
| Write validation report | Code diff, acceptance checks, environment notes | `P4-T7_Validation_Report.md` | Acceptance criteria mapped to evidence |

## Constraints And Toolchain Notes

- Keep the fix inside the interaction-controller boundary unless a sandbox callback contract truly needs to change.
- Prefer an explicit mobile event-policy fix over widening the current time/distance heuristic.
- Do not introduce desktop regressions for mouse spawn, selection, or drag.
- Physical iOS/iPadOS confirmation may still require later device validation outside this local environment; if so, document that limitation explicitly rather than guessing.
- Review subject name for this FLOW run will be `p4-t7-ios-single-touch-double-spawn`.

## Notes

- If Godot’s iOS event emission pattern requires a broader platform-specific policy later, capture that as a follow-up only if it is not necessary to close this bug.

---
**Archived:** 2026-03-29
**Verdict:** PARTIAL
