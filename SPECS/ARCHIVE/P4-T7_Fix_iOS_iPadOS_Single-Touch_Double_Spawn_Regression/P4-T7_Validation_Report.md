# P4-T7 Validation Report

**Task:** P4-T7 - Fix iOS/iPadOS Single-Touch Double Spawn Regression  
**Date:** 2026-03-29  
**Verdict:** PARTIAL

## Deliverable Status

- [x] Replaced the mobile input deduplication heuristic with explicit active-touch tracking in `SandboxInteractionController.gd`.
- [x] Mobile mouse suppression now treats an active touch sequence as authoritative and also suppresses synthesized mouse events for a short tail after touch release.
- [x] Desktop mouse input behavior remains unchanged because the suppression path still exits early when `OS.has_feature("mobile")` is false.
- [x] Configured Flow quality gates passed locally.
- [ ] Verified the fix on physical iOS/iPadOS hardware. This environment does not provide a reproducible device tap test.

## Implementation Evidence

1. `scripts/game/SandboxInteractionController.gd`
   - Removed the position-distance heuristic that tried to match synthesized mouse events back to the last touch coordinate.
   - Added `_active_touch_ids` so any in-flight mobile touch sequence blocks redundant mouse press/motion handling.
   - Split touch bookkeeping into `_register_touch_press()` and `_register_touch_release()` so the controller can keep suppression active through the full touch lifecycle.
   - Kept a short post-release suppression window (`EMULATED_MOUSE_SUPPRESS_MS`) so synthesized mouse-up/click follow-ons immediately after a touch still cannot reach `_handle_pointer_pressed()`.
2. Event-path reasoning
   - Before the fix, both `InputEventScreenTouch` and `InputEventMouseButton` could call `_handle_pointer_pressed()`, and empty-space presses spawn immediately there.
   - After the fix, touch remains the only authoritative source during a mobile tap sequence; redundant mouse events are ignored regardless of minor coordinate drift.

## Validation Performed

1. Source-level regression review:
   - Confirmed mobile `InputEventScreenTouch` continues to drive select/spawn/drag behavior directly.
   - Confirmed `InputEventMouseButton` and `InputEventMouseMotion` are now rejected on mobile while any touch is active, and for the short suppression window immediately afterward.
   - Confirmed non-mobile platforms bypass the suppression path entirely.
2. Flow quality gates:
   - `bash scripts/ci/flow_validate.sh tests` -> **PASS**
   - `bash scripts/ci/flow_validate.sh lint` -> **PASS**

## Acceptance Criteria Mapping

- **A single tap on empty sandbox space creates exactly one toy on physical iPhone/iPad hardware** -> Source-level fix implemented, but physical-device confirmation remains **unverified** in this environment.
- **Touch selection and drag of existing toys still work after the fix** -> Preserved at source level because touch events still run through the same pointer press/drag/release handlers; only redundant mobile mouse events are filtered.
- **Desktop mouse spawn behavior remains unchanged** -> Achieved; `_should_ignore_emulated_mouse()` returns `false` outside mobile builds.
- **Validation documents the exact event path before the fix and the guarded path after the fix** -> Achieved in this report and the task PRD.

## Remaining Blocker

- Physical iOS/iPadOS verification is still required to fully close the task. The local environment can validate Godot resources and logic, but it cannot prove the exact tap/event ordering on a connected Apple mobile device.

## Notes

- Godot validation still emits the pre-existing non-blocking `ObjectDB instances leaked at exit` warning after successful runs.
