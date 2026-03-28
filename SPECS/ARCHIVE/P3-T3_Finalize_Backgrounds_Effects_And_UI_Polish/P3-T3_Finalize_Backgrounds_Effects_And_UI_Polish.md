# P3-T3 — Finalize Backgrounds, Effects, And UI Polish

**Task ID:** P3-T3  
**Phase:** Toy Catalog  
**Priority:** P2  
**Dependencies:** P2-T4, P3-T2  
**Status:** Planned

## Objective Summary

Unify the non-toy visual layer so the sandbox and menus read as one cohesive product rather than engine-default UI plus isolated toy art. Scope covers three linked areas: (1) dedicated background art for menu and sandbox, (2) consistent HUD/tool panel and button styling, and (3) explicit per-reaction effect visuals for fragment, crack, squash, and pop states.

Implementation should preserve all existing interaction behavior and toy physics from prior phases. This task focuses on visual readability and presentation only: scene layout, style resources, and lightweight runtime effect rendering. Existing toy icons/world sprites remain the source of truth for toy identity; this pass improves surrounding context and reaction feedback clarity.

## Success Criteria And Acceptance Tests

### Success Criteria
- Menu and sandbox both use dedicated background assets with shared palette direction.
- HUD panels and action buttons use consistent styling and clear state/readability.
- Fragment, crack, squash, and pop effects are visually distinct during gameplay interactions.
- Main play path no longer relies on placeholder/default-looking UI treatment.
- Visuals remain readable for tablet-scale layouts and 128x128 icon preview contexts.

### Acceptance Tests
1. Open `MainMenu` and `Sandbox`; verify both scenes render dedicated themed backgrounds.
2. Verify info panel, shelf panel, onboarding panel, and action buttons use consistent visual language (corner radius, border, contrast, spacing).
3. Trigger fan/smash interactions across toys and confirm distinct effect signatures:
   - Fragile smash -> crack + fragment burst
   - Soft/deformable reaction -> squash pulse
   - Air reaction -> pop pulse
4. Confirm selected toy preview renders cleanly at `128x128` and remains legible.
5. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
6. Record outcomes in `SPECS/INPROGRESS/P3-T3_Validation_Report.md`.

## Test-First Plan

- Add/adjust scene nodes and script hooks for backgrounds and style resources in isolation, then run `tests` validation to ensure resources load and scenes instantiate.
- Add effect overlay/particle nodes and script-level effect dispatch logic in `ToyInstance` before tuning visual values.
- Validate effect paths by archetype mapping in code review and manual run protocol, then run `lint` validation.
- Re-run both quality gates after final cleanup.

## Hierarchical TODO Plan

### Phase 1 — Background And UI Art Direction
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add dedicated backgrounds | New SVG assets for menu/sandbox | `TextureRect` scene integration in menu/sandbox | Scenes load and display themed backgrounds |
| Improve panel/button readability | Existing HUD/menu nodes | Unified style overrides for key panels and action buttons | Visual consistency and contrast check |

### Phase 2 — Reaction Effects Pass
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add effect textures | New SVG effect assets (`fragment`, `crack`, `squash`, `pop`) | Runtime-loadable effect textures | Asset load sanity via validation |
| Wire effect dispatch in toy runtime | `ToyInstance.gd` tool feedback branches | Distinct effect playback by reaction type/archetype | Manual fan/smash protocol across toy set |

### Phase 3 — Tablet/Preview Readability + Validation
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Set 128x128 preview readability baseline | `SelectedPreview` node + icon flow | Larger preview size and stable layout | Selected icon remains readable in sandbox UI |
| Execute quality gates + document results | Flow validation scripts and manual checks | `P3-T3_Validation_Report.md` | Both commands pass and criteria mapped |

## Constraints And Toolchain Notes

- Maintain Godot 4 compatibility and current autoload assumptions.
- Do not alter core interaction mechanics (spawn/drag/duplicate/resize/reset/fan/smash).
- Keep additional runtime effect logic lightweight (short tweens, no heavy systems).
- Keep asset naming and folder organization explicit for future art swaps.

## Notes

- If this pass surfaces deeper UX/navigation concerns, capture them as follow-up work instead of broadening scope here.
- Performance/export cleanup remains under `P4-T2` and is out of scope for this task.

---
**Archived:** 2026-03-28
**Verdict:** PASS
