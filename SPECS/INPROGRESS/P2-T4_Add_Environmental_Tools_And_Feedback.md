# P2-T4 — Add Environmental Tools And Feedback

**Task ID:** P2-T4  
**Phase:** Core Sandbox  
**Priority:** P1  
**Dependencies:** P2-T2, P2-T3  
**Status:** Planned

## Objective Summary

Implement two environmental interaction tools (fan and smash) and baseline feedback layers (sound cues + simple visual responses) so the sandbox feels expressive rather than purely mechanical. The feature must plug into the existing interaction loop in `Sandbox.gd` and `ToyInstance.gd` without regressing current verbs: spawn, drag, duplicate, resize, reset.

Tool behavior must be deterministic by toy archetype from `ToyCatalog.gd`. At minimum: fan should impart directional force with archetype-scaled response; smash should trigger impulse and distinct reactive treatment for fragile vs soft vs rigid toys. Feedback should remain lightweight and placeholder-friendly: no external dependencies, no heavy VFX systems, and no requirement for final art/audio assets.

## Success Criteria And Acceptance Tests

### Success Criteria
- Fan and smash actions are available in sandbox controls and callable by input shortcuts.
- Tool outcomes are deterministic and vary by archetype in obvious, readable ways.
- Each core interaction (spawn/drag/duplicate/resize/reset/fan/smash) emits at least one sound or visual response.
- Fragile and soft reactions are visibly distinct from rigid behavior.

### Acceptance Tests
1. Spawn one toy per archetype group and apply fan; response strength/damping is predictably different.
2. Apply smash to fragile, soft, and heavy toys; fragile shows break-like reaction, soft shows squash-like reaction, heavy shows rigid impact behavior.
3. Verify UI includes tool controls and status text updates for active tool use.
4. Execute quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
5. Document evidence and outcomes in `SPECS/INPROGRESS/P2-T4_Validation_Report.md`.

## Test-First Plan

- First add small, testable method boundaries in `ToyInstance.gd` (`apply_fan_impulse()`, `apply_smash_impulse()`, reaction-state visuals) and wire deterministic coefficients from archetype hooks before UI wiring.
- Add minimal tool dispatch in `Sandbox.gd` with explicit target selection rules (active toy first, pointer-picked fallback) and status updates.
- Add optional placeholder audio trigger points in `AudioService.gd` with no-op-safe playback calls.
- Run validation gates after each major phase to ensure scene/script load safety.

## Hierarchical TODO Plan

### Phase 1 — Tool Data And Toy Reactions

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Define reaction coefficients by archetype | `ToyCatalog` archetype/reaction hooks | Deterministic force/response maps | Same toy + same input yields same behavior |
| Add fan and smash APIs to toy instances | `ToyInstance.gd` rigid body state | Reusable methods for impulse + visuals | Methods callable from sandbox without side effects |

### Phase 2 — Sandbox Controls And Dispatch

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add tool buttons + shortcuts | `Sandbox.tscn`, `Sandbox.gd` | `Fan` and `Smash` actions | UI buttons trigger corresponding methods |
| Implement target resolution and action feedback | Active toy/pointer pick logic | Stable tool targeting and status text | Actions never crash with no selected toy |

### Phase 3 — Audio/Visual Feedback And Validation

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add baseline feedback cues | `AudioService.gd`, toy visuals | Distinct feedback per interaction class | Fragile/soft/rigid differences are visible/audible |
| Run quality gates + write report | Flow validation commands + manual checks | Passing gates and validation report | Acceptance criteria explicitly mapped |

## Constraints And Toolchain Notes

- Maintain Godot 4 compatibility and current project structure.
- Keep placeholder implementation lightweight; final polish belongs to later catalog/polish phases.
- Preserve current interaction verbs and performance characteristics.
- Avoid introducing plugin or package dependencies.

## Notes

- Update docs if controls/hotkeys change (`docs/` and any in-scene hint text).
- If reaction tuning grows complex, split constants into a follow-up config/helper task.
