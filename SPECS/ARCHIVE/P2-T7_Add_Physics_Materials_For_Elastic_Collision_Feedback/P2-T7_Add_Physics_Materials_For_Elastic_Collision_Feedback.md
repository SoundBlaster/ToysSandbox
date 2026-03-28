# P2-T7 - Add Physics Materials For Elastic Collision Feedback

**Task ID:** P2-T7  
**Phase:** Core Sandbox  
**Priority:** P1  
**Dependencies:** P2-T4  
**Status:** Planned

## Objective Summary

Introduce deterministic physics material tuning for both spawned toys and sandbox boundaries so collision feel better communicates archetype identity during throw and fan interactions. The current setup relies on default engine material behavior, which flattens collision differences between bouncy, heavy, and sticky toys. This task adds explicit per-archetype bounce/friction settings at toy spawn time and explicit boundary materials on floor and side walls.

Implementation should avoid scene duplication by keeping one reusable `ToyInstance.tscn` and assigning materials from toy definitions at runtime. The floor and walls must receive explicit materials in `Sandbox.tscn` so rebound behavior is not dependent on project defaults. Tuning should make Ball and other bouncy toys visibly rebound after impacts while heavy/sticky toys remain comparatively subdued under equivalent conditions.

## Success Criteria And Acceptance Tests

### Success Criteria
- Toys receive collision material settings by archetype without creating per-toy scene variants.
- Floor and wall colliders use explicit `PhysicsMaterial` resources.
- Bouncy toys visibly rebound more from floor and wall impacts than heavy/sticky toys.
- Quality gates pass using configured Flow commands.

### Acceptance Tests
1. Confirm archetype definitions expose collision material parameters used during toy configuration.
2. Confirm `ToyInstance` assigns a physics material override from the selected toy definition.
3. Confirm floor and both walls in `Sandbox.tscn` reference explicit `PhysicsMaterial` resources.
4. Run fan and throw interactions with Ball vs Brick/Sticky Block and verify rebound contrast.
5. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
6. Record tuning values and outcomes in `SPECS/INPROGRESS/P2-T7_Validation_Report.md`.

## Test-First Plan

- Extend toy data defaults with archetype physics material keys first so existing definitions inherit values without touching each toy entry.
- Update `ToyInstance.configure()` to apply `PhysicsMaterial` override from definition data before running sandbox validation.
- Add explicit floor and wall `PhysicsMaterial` resources in `Sandbox.tscn` and bind them to static bodies.
- Run Flow validation commands after each logical integration step and finish with a manual rebound comparison note.

## Hierarchical TODO Plan

### Phase 1 - Archetype Material Configuration
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add archetype material values | Existing `ARCHETYPE_DEFAULTS` in `ToyCatalog.gd` | `bounce` and `friction` values per archetype | Definitions expose material keys for all toy archetypes |
| Keep catalog compatibility | Current toy definitions | No per-toy schema breakage | Existing toy list/load behavior unchanged |

### Phase 2 - Runtime And Boundary Wiring
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Apply toy physics material override | Toy definition dictionary in `ToyInstance.gd` | Runtime material assignment per toy instance | Spawned toys show archetype-specific collision response |
| Configure world boundary materials | `Sandbox.tscn` floor/wall static bodies | Explicit `PhysicsMaterial` on floor and walls | Scene has no default-material boundary collider |

### Phase 3 - Validation And Reporting
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Execute quality gates | `flow_validate.sh` tests/lint | PASS command outputs | Exit code 0 for both commands |
| Document behavior and tuning | Manual comparison + command outputs | `P2-T7_Validation_Report.md` | Acceptance criteria mapped to evidence |

## Constraints And Toolchain Notes

- Keep Godot 4 compatibility and avoid introducing plugin dependencies.
- Preserve existing interaction controller behavior; this task is collision tuning, not input refactor.
- Prefer conservative tuning to avoid unstable jittering or extreme bounce loops.
- Do not require scene duplication for archetype differentiation.

## Notes

- If collision tuning reveals secondary gameplay balancing needs, capture them in REVIEW/FOLLOW-UP rather than broadening this task scope.

---
**Archived:** 2026-03-28
**Verdict:** PASS
