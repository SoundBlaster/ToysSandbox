# P3-T1 — Ship The First Four Toy Archetypes With Final Silhouettes

**Task ID:** P3-T1  
**Phase:** Toy Catalog  
**Priority:** P1  
**Dependencies:** P2-T2  
**Status:** Planned

## Objective Summary

Deliver a playtest-ready first toy set by finalizing Ball, Pillow, Brick, and Vase with distinct silhouettes, consistent icon/world art pairing, and readable reactions that communicate archetype behavior at a glance. The scope focuses on low-risk content and behavior updates in the existing Godot 4 pipeline: `ToyCatalog.gd` for toy asset mapping and archetype identity, `ToyInstance.gd` for visible feedback tuning, and lightweight assets for both shelf and in-world representation.

This task does not include final polish for the remaining four toys, advanced VFX systems, or export-level performance optimization. Instead, it establishes quality and consistency standards for toy readability that later catalog tasks can scale. All changes must preserve current sandbox interactions (spawn, drag, duplicate, resize, reset, fan, smash), maintain deterministic behavior per archetype, and pass existing Flow validation gates.

## Success Criteria And Acceptance Tests

### Success Criteria
- Ball, Pillow, Brick, and Vase each have unique, readable silhouettes in both shelf icon and world sprite form.
- Shelf and world visual assets are paired correctly for each of the four toys.
- Each toy presents at least two visible reactions through existing interactions/tools.
- Mixed interactions among the four toys remain stable and legible.

### Acceptance Tests
1. Select each of the four toys from the shelf and confirm icon identity matches in-world appearance.
2. Spawn each toy, apply fan and smash tools, and verify two visible reaction signatures per toy.
3. Spawn mixed sets (≥10 objects) of the first four toys; verify interactions remain readable and no script/runtime load failures occur.
4. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
5. Record outcomes in `SPECS/INPROGRESS/P3-T1_Validation_Report.md`.

## Test-First Plan

- Add/adjust behavior boundaries first: ensure toy feedback paths in `ToyInstance.gd` expose distinct bouncy/soft/heavy/fragile visual outcomes before asset wiring.
- Add deterministic toy-level visual mappings in `ToyCatalog.gd` next, then verify missing-asset fallback still works for non-target toys.
- Add first-four icon/world assets and wire them through catalog fields.
- Execute validation gates immediately after script changes and again after asset integration.

## Hierarchical TODO Plan

### Phase 1 — Reaction Readability Baseline
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Tune first-four reaction signatures | Existing archetype constants in `ToyInstance.gd` | Distinct visible bouncy/soft/heavy/fragile responses | Manual fan/smash checks per toy |
| Preserve interaction stability | Current drag/tool code paths | No regression in core verbs | Sandbox smoke pass with mixed toys |

### Phase 2 — Asset Pairing For First Four Toys
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add icon assets | `assets/` toy art folder | One icon per toy (4 total) | Shelf shows unique silhouettes |
| Add world assets | `assets/` toy art folder | One world sprite per toy (4 total) | Spawned toys render matching silhouettes |
| Wire catalog mappings | `ToyCatalog.gd` definitions | Stable icon/world paths for first four toys | No null-load for first four |

### Phase 3 — Validation And Reporting
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `flow_validate.sh` tests + lint modes | Passing validation output | Command exit code 0 |
| Write validation report | Manual + automated evidence | `P3-T1_Validation_Report.md` with verdict | Acceptance criteria mapped |

## Constraints And Toolchain Notes

- Maintain Godot 4 compatibility and current scene/script architecture.
- Keep asset integration lightweight and repository-friendly; no external plugin dependencies.
- Preserve deterministic archetype behavior and avoid randomization in reaction outcomes.
- Keep non-target toy entries functional through fallback icon/world behavior.

## Notes

- If first-four asset style patterns are validated, mirror this structure in P3-T2 for the remaining four toys.
- Update documentation pointers if toy art location conventions are changed.
