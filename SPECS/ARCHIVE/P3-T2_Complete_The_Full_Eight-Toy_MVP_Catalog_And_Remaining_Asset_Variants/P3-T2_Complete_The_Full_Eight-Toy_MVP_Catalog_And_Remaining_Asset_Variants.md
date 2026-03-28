# P3-T2 — Complete The Full Eight-Toy MVP Catalog And Remaining Asset Variants

**Task ID:** P3-T2  
**Phase:** Toy Catalog  
**Priority:** P1  
**Dependencies:** P3-T1, P2-T3  
**Status:** Planned

## Objective Summary

Complete the MVP toy roster by finishing Balloon, Jelly Cube, Pot, and Sticky Block with final shelf icon and world sprite assets, then wire these resources into the live catalog so all eight toys are production-consistent in the sandbox. Scope includes targeted archetype feedback tuning for the four newly completed toys so light, deformable, metallic, and sticky behavior remains visually legible during fan/smash interactions and mixed-object play sessions.

Implementation stays within the existing Godot 4 content pipeline and scene architecture: `scripts/autoload/ToyCatalog.gd` for authoritative toy definitions and texture paths, `scripts/game/ToyInstance.gd` for reaction feedback differentiation, and `assets/toys/icons` + `assets/toys/world` for final SVG variants. Existing input and interaction verbs (spawn, drag, duplicate, resize, reset, fan, smash) must remain unchanged behaviorally, with no regressions to current shelf selection or fallback rendering.

## Success Criteria And Acceptance Tests

### Success Criteria
- All eight MVP toys are available from the shelf with dedicated icon and world assets.
- Balloon, Jelly Cube, Pot, and Sticky Block each have consistent icon/world silhouette mapping.
- Air, deformable, metal, and sticky archetypes expose distinct visible feedback during fan/smash use.
- Sandbox remains stable with mixed-toy interactions at current target object density.

### Acceptance Tests
1. Open sandbox shelf and verify all eight toys display dedicated icons (no generated placeholder for any MVP toy).
2. Spawn Balloon, Jelly Cube, Pot, and Sticky Block; confirm each renders dedicated world sprite and matches shelf silhouette.
3. Apply fan and smash to each of the four new toys and verify at least two visible reaction signatures per toy.
4. Run mixed interaction smoke pass with at least 10 simultaneous objects from varied archetypes.
5. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
6. Record outcomes in `SPECS/INPROGRESS/P3-T2_Validation_Report.md`.

## Test-First Plan

- Add lightweight script-level reaction differentiation first in `ToyInstance.gd` for `air` and `sticky` archetypes (and refine `metal` if needed), then validate no breakage to existing branches.
- Wire explicit asset mappings in `ToyCatalog.gd` for the remaining four toys while preserving fallback behavior for truly missing resources.
- Add icon/world SVG files for Balloon, Jelly Cube, Pot, and Sticky Block with naming consistent with existing catalog conventions.
- Execute validation gates immediately after script/catalog updates, and re-run after asset integration.

## Hierarchical TODO Plan

### Phase 1 — Behavior Readability For Remaining Archetypes
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add air/sticky/metal feedback signatures | Existing `_apply_tool_feedback()` branches in `ToyInstance.gd` | Distinct visible responses for Balloon/Pot/Sticky Block interactions | Manual fan/smash checks |
| Preserve prior archetype behavior | Current bouncy/soft/heavy/fragile/deformable tuning | No regressions for first four toys | Quick mixed archetype smoke pass |

### Phase 2 — Asset Completion For Remaining Four Toys
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Create shelf icons | `assets/toys/icons/` style and palette conventions | 4 new icon SVG files | Shelf displays unique silhouettes |
| Create world sprites | `assets/toys/world/` style and proportions | 4 new world SVG files | Spawned toys render dedicated art |
| Map catalog paths | `ToyCatalog.gd` definitions for remaining toys | Non-empty icon/world texture paths | Resource loader resolves all 8 toys |

### Phase 3 — Validation And Documentation
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Execute quality gates | `scripts/ci/flow_validate.sh` tests + lint | Passing command output | Exit code 0 |
| Produce validation report | Test logs + manual checks | `P3-T2_Validation_Report.md` with verdict | Acceptance criteria mapped |

## Constraints And Toolchain Notes

- Keep all changes Godot 4 compatible and avoid introducing plugin/runtime dependencies.
- Maintain deterministic reaction behavior; avoid randomness for archetype feedback.
- Preserve existing file naming convention: `{toy_id}_icon.svg` and `{toy_id}_world.svg`.
- Avoid broad refactors in sandbox orchestration during this task; focus on catalog completion and archetype readability.

## Notes

- Follow-up visual polish and global style unification for backgrounds/VFX belongs to P3-T3.
- If any additional per-archetype tuning debt is found, record it as a REVIEW follow-up item after ARCHIVE.
