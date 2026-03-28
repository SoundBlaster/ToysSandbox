# P4-T4 - Add Toy Styles/Skins With Settings Selection

**Task ID:** P4-T4  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P1  
**Dependencies:** P3-T2, P4-T1  
**Status:** Planned

## Objective Summary

Add a lightweight skin system for the MVP toy catalog so players can switch the visual style of all toys from Settings and keep that preference between launches. The task should reuse the existing toy catalog, shelf UI, sandbox spawn flow, and local save path rather than introducing a separate asset pipeline or scene fork.

The implementation target is a small set of curated style presets that remap toy colors and presentation accents while preserving each toy’s silhouette, icon readability, and behavior. Skin changes must apply consistently in three places: the Settings UI preview/control, shelf icons in the sandbox, and spawned toy visuals in the world. The selected skin must persist locally and restore on boot alongside the existing audio/tutorial/toy selection settings.

## Success Criteria And Acceptance Tests

### Success Criteria
- Settings includes a visible toy skin/style selector with at least three distinct preset options.
- Switching the active skin updates toy presentation consistently for shelf icons and in-world spawned toys.
- The chosen skin persists across relaunches and restores before the player enters menu or sandbox flows.
- Existing toy behavior, interaction verbs, and Flow quality gates remain intact.

### Acceptance Tests
1. Open Settings from the main menu and verify the toy skin/style control exposes at least three readable presets.
2. Change the selected skin and confirm the settings status/preview reflects the new choice immediately.
3. Enter the sandbox after changing skins and verify shelf icons use the active style rather than the default palette.
4. Spawn at least two different toys and confirm their world visuals use the active skin while keeping toy identity readable.
5. Return to Settings, choose another skin, relaunch the app, and confirm the selected style is restored automatically.
6. Verify invalid or missing persisted skin values fall back safely to the default skin without breaking toy visuals.
7. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
8. Record outcomes in `SPECS/INPROGRESS/P4-T4_Validation_Report.md`.

## Test-First Plan

- Expand persisted state and runtime state first so the selected skin becomes a stable cross-scene value before UI wiring.
- Add a skin preset layer in `ToyCatalog.gd` that can derive per-toy presentation overrides without duplicating the toy behavior definitions.
- Wire the Settings selector and sandbox shelf refresh logic next so style changes become visible in menu and gameplay.
- Re-run validation after integration and document fallback behavior plus any manual visual verification steps.

## Hierarchical TODO Plan

### Phase 1 - Persisted Skin State And Catalog Skin Presets
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Extend save/runtime state | `SaveService.gd`, `GameState.gd`, boot load path | Persisted `selected_skin_id` with default/fallback handling | Invalid values restore to default safely |
| Define reusable skin presets | `ToyCatalog.gd`, existing toy definitions/colors | Small preset catalog that remaps toy colors/presentation | Every toy resolves a usable styled definition |

### Phase 2 - Settings Selector And Live UX
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add skin selector to Settings | `MainMenu.tscn`, `MainMenu.gd` | Option control and status text for toy skin selection | User can cycle/select skins without breaking other settings |
| Keep settings UI in sync | Save state + runtime state | Selected skin shown correctly on open/reopen | Restored state matches persisted value |

### Phase 3 - Sandbox Shelf And World Application
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Style shelf presentation | `Sandbox.gd`, toy icon resolution | Active skin updates icons/readability in toy shelf | Shelf refresh reflects current skin |
| Style world toy visuals | `ToyInstance.gd`, toy definitions | Spawned toys tint/texture presentation with active skin | Spawned toys visually match selected skin |

### Phase 4 - Validation And Reporting
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `.flow/params.yaml` verify commands | PASS outputs for tests/lint | Exit code 0 for both commands |
| Write validation report | Acceptance results and visual/manual checks | `P4-T4_Validation_Report.md` | Acceptance criteria mapped to evidence |

## Constraints And Toolchain Notes

- Preserve current toy silhouettes, physics values, and interaction behavior; this task changes presentation, not gameplay tuning.
- Prefer code-defined skin presets over duplicated scene files or a new external asset dependency.
- Skin presentation must remain readable for the existing child-friendly UI and placeholder/export pipeline.
- Fallback behavior must be deterministic: unknown skin IDs revert to the default style automatically.
- Review subject name for this FLOW run will be `p4-t4-toy-skins-settings`.

## Notes

- If a future art pass needs fully bespoke textures per skin, capture that as follow-up work. This task only needs a robust MVP skin-selection system on top of the current assets.

---
**Archived:** 2026-03-28
**Verdict:** PASS
