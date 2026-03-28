# P2-T4 Validation Report

**Task:** P2-T4 — Add Environmental Tools And Feedback  
**Date:** 2026-03-28  
**Verdict:** PASS

## Deliverable Status

- [x] Added `Fan` and `Smash` environmental tool controls to sandbox UI.
- [x] Added keyboard shortcuts for tools (`F` = Fan, `S` = Smash).
- [x] Implemented deterministic archetype-scaled responses for fan/smash impulses in `ToyInstance.gd`.
- [x] Added distinct visual reaction classes for fragile, soft/deformable, and rigid/heavy/metal behaviors.
- [x] Added baseline procedural audio feedback cues through `AudioService.gd` and wired action triggers from sandbox verbs.
- [x] Required quality gates pass.

## Validation Performed

1. Updated `scenes/game/Sandbox.tscn`:
   - Added `FanButton` and `SmashButton` to `ActionsRow`.
   - Updated in-scene hint text to include new shortcuts.
2. Updated `scripts/game/Sandbox.gd`:
   - Connected fan/smash buttons.
   - Added key handling for `F` and `S`.
   - Added `_apply_fan_to_active_toy()` and `_apply_smash_to_active_toy()` with active-toy safeguards.
   - Added centralized feedback tone triggers for spawn, duplicate, resize, reset, fan, smash, and drag release.
3. Updated `scripts/game/ToyInstance.gd`:
   - Added archetype coefficient maps for deterministic fan/smash force scaling.
   - Added `apply_fan_tool()` and `apply_smash_tool()` APIs.
   - Added feedback visuals with distinct handling:
     - Fragile: brighter flash and stronger smash response.
     - Soft/Deformable: softer flash + temporary squash stretch.
     - Heavy/Metal/Rigid-like: short warm flash + rigid label pulse.
4. Updated `scripts/autoload/AudioService.gd`:
   - Added procedural tone player using `AudioStreamGenerator`.
   - Added `play_feedback(event_name)` API with event-to-frequency mapping.

## Quality Gate Results

- `bash scripts/ci/flow_validate.sh tests` → **PASS**
- `bash scripts/ci/flow_validate.sh lint` → **PASS**

## Acceptance Criteria Mapping

- **Fan and smash trigger deterministic reactions by archetype** → Fan/smash impulses are scaled via fixed archetype maps (`FAN_FORCE_BY_ARCHETYPE`, `SMASH_FORCE_BY_ARCHETYPE`) and produce reproducible outcomes for identical inputs.
- **Each player action produces motion, sound, or visual feedback** → Core and tool actions now produce motion and/or visual effects, plus baseline procedural audio cues from `AudioService`.
- **Fragile and soft reactions are visibly distinct from rigid behavior** → Fragile, soft/deformable, and rigid/heavy/metal groups use separate visual response branches and different smash dynamics.

## Manual Test Protocol

1. Launch sandbox and spawn at least one of each: `vase` (fragile), `pillow` or `jelly_cube` (soft/deformable), `brick` or `pot` (rigid/heavy).
2. Select each toy and press `F` repeatedly; confirm fan displacement differs by archetype consistently across repeats.
3. Press `S` on each toy and verify reaction signatures:
   - Fragile: stronger spin/flash response.
   - Soft/deformable: squash-like visual recovery.
   - Rigid/heavy/metal: short rigid impact pulse with smaller deformation cues.
4. Verify tool buttons in UI produce same behavior as shortcuts.
5. Verify sandbox remains stable after mixed spawn/drag/duplicate/resize/reset + fan/smash sequences.

## Notes

- Validation harness reports a known Godot runtime warning (`ObjectDB instances leaked at exit`) while still returning pass status; this is existing behavior and not introduced by this task.
