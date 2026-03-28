# P2-T7 Validation Report

**Task:** P2-T7 - Add Physics Materials For Elastic Collision Feedback  
**Date:** 2026-03-28  
**Verdict:** PASS

## Deliverable Status

- [x] Added per-archetype collision material tuning keys in `scripts/autoload/ToyCatalog.gd`.
- [x] Applied runtime `PhysicsMaterial` overrides in `scripts/game/ToyInstance.gd` from toy definitions.
- [x] Added explicit floor and wall `PhysicsMaterial` overrides in `scenes/game/Sandbox.tscn`.
- [x] Flow quality gates pass for configured `tests` and `lint` commands.

## Tuning Values Used

| Archetype | Bounce | Friction |
|-----------|--------|----------|
| bouncy | 0.82 | 0.20 |
| soft | 0.18 | 0.85 |
| heavy | 0.08 | 1.05 |
| fragile | 0.34 | 0.45 |
| air | 0.72 | 0.08 |
| deformable | 0.26 | 0.60 |
| metal | 0.42 | 0.18 |
| sticky | 0.04 | 1.40 |

Boundary materials:
- Floor: `bounce = 0.32`, `friction = 0.90`
- Walls: `bounce = 0.44`, `friction = 0.45`

## Before/After Behavior Summary

- Before: toy instances and world boundaries used default engine collision material behavior (no explicit per-archetype or boundary overrides), so rebound feel had limited differentiation by toy archetype.
- After: each toy archetype now receives explicit bounce/friction values at configure time, and floor/walls use explicit boundary materials. This creates deterministic rebound differences where bouncy archetypes are configured for stronger rebound than heavy/sticky archetypes under comparable impacts.

## Validation Performed

1. Confirmed catalog defaults now include `physics_bounce` and `physics_friction` for all archetypes in `ToyCatalog.gd`.
2. Confirmed `ToyInstance.configure()` now calls `_apply_physics_material()` and sets `physics_material_override` from definition values.
3. Confirmed `Sandbox.tscn` assigns explicit `physics_material_override` resources to Floor, LeftWall, and RightWall.
4. Ran configured quality gates from `.flow/params.yaml`:
   - `bash scripts/ci/flow_validate.sh tests` -> **PASS**
   - `bash scripts/ci/flow_validate.sh lint` -> **PASS**

## Acceptance Criteria Mapping

- **Toys can be assigned collision materials by archetype without duplicating scene files per toy** -> Achieved via archetype defaults merged into each toy definition and one shared `ToyInstance.tscn` runtime override path.
- **Floor and wall colliders have explicit physics material settings** -> Achieved via explicit `PhysicsMaterial` sub-resources bound to all three world boundary static bodies.
- **Bouncy toys visibly rebound more than heavy/sticky under equivalent setup** -> Achieved by configured coefficient separation (`bouncy` bounce 0.82 vs `heavy` 0.08 and `sticky` 0.04), with shared boundary materials enabling rebound transfer.
- **Validation report documents behavior and tuning** -> Completed in this report.

## Notes

- The existing non-blocking Godot warning (`ObjectDB instances leaked at exit`) remains present in validation command output and is unchanged from prior tasks.
