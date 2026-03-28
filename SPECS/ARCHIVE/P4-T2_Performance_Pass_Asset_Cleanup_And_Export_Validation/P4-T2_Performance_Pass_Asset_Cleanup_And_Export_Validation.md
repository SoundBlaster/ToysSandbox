# P4-T2 - Performance Pass, Asset Cleanup, And Export Validation

**Task ID:** P4-T2  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P1  
**Dependencies:** P3-T2, P3-T3, P4-T1  
**Status:** Planned

## Objective Summary

Stabilize the sandbox for MVP-scale play and prepare the project for reproducible desktop and Android exports. This task covers three linked outcomes: reduce avoidable runtime overhead so 25 active toys remains a supported operating envelope, remove or explicitly document stale placeholder assets that no longer belong on the main path, and add export configuration plus a written checklist that can be repeated on Windows, macOS, Linux, and Android.

The implementation should stay pragmatic. The current codebase is already lightweight, so the focus is on low-risk tuning with measurable guardrails: cap active toy count at the target object budget, trim per-instance work that scales poorly with object count, add a lightweight performance stats surface for manual profiling, and codify export prerequisites instead of relying on tribal knowledge. Any platform work that still depends on local SDK/signing setup must be documented clearly and called out in validation rather than hidden.

## Success Criteria And Acceptance Tests

### Success Criteria
- Sandbox behavior remains stable and readable with an enforced 25-toy active-object cap.
- Runtime code avoids unnecessary per-object work in the common case and exposes lightweight stats useful for desktop/Android profiling.
- Unused placeholder assets are removed or clearly listed for follow-up.
- Export presets and a reproducible checklist exist for Windows, macOS, Linux, and Android.
- Existing Flow quality gates pass after implementation.

### Acceptance Tests
1. Spawn or duplicate toys until the active count reaches 25; additional creation attempts are blocked with clear status feedback instead of degrading simulation.
2. Run the sandbox with 25 active toys and confirm the stats panel reports active count plus current FPS for profiling sessions.
3. Verify non-selected toys no longer keep optional presentation work enabled when it is not needed.
4. Confirm stale placeholder asset files are either deleted from the repo or explicitly called out in the export/performance checklist.
5. Verify `export_presets.cfg` exists and includes desktop plus Android presets with project-specific placeholders where local signing values are required.
6. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
7. Record results and any environment limitations in `SPECS/INPROGRESS/P4-T2_Validation_Report.md`.

## Test-First Plan

- Add the active-toy budget guard and stats surface first so performance-oriented behavior is explicit before tuning secondary details.
- Reduce per-instance overhead in `ToyInstance.gd` and texture lookup paths before touching export docs, then validate behavior with the existing sandbox flow.
- Add export presets and the release checklist after runtime changes are stable, then run Flow quality gates and write the validation report against the final tree.

## Hierarchical TODO Plan

### Phase 1 - Runtime Guardrails And Profiling Hooks
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Enforce active toy budget | `Sandbox.gd`, interaction flow, MVP object target | Hard cap at 25 live toys with player-facing status message | Spawns/duplicates stop cleanly at 25 |
| Expose lightweight runtime stats | Sandbox HUD and frame metrics | Visible FPS/object-count panel for manual profiling | Stats update during play without affecting interactions |

### Phase 2 - Per-Object Overhead Reduction And Asset Cleanup
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Trim avoidable instance work | `ToyInstance.gd`, `ToyCatalog.gd` | Lower per-toy processing/render overhead in steady state | No regression in toy visuals or interaction behavior |
| Remove stale placeholder assets | Repo asset tree and reference scan | Deleted unused files or explicit follow-up notes | No removed file is still referenced by scenes/scripts |

### Phase 3 - Export Readiness
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add baseline export presets | Godot project metadata and target platforms | `export_presets.cfg` for desktop + Android | Presets are present and structured for local completion |
| Document reproducible release checklist | PRD, current project layout, local toolchain assumptions | Export checklist covering Windows, macOS, Linux, Android | Validation report references the documented steps and blockers |

### Phase 4 - Validation And Reporting
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `.flow/params.yaml` commands | PASS outputs for tests/lint | Exit code 0 for both commands |
| Write validation report | Acceptance test outcomes and environment notes | `P4-T2_Validation_Report.md` | Every acceptance criterion mapped to evidence or limitation |

## Constraints And Toolchain Notes

- Preserve existing sandbox interaction verbs and current saved-state behavior.
- Keep performance changes deterministic and code-local; no external profiling dependencies.
- Export configuration should stay compatible with one shared Godot project and avoid platform-specific gameplay forks.
- Android signing identifiers, keystore paths, and SDK paths must remain placeholder/documented values, not hard-coded machine-specific secrets.
- Review subject name for this FLOW run will be `p4-t2-performance-pass-asset-cleanup-and-export-validation`.

## Notes

- If deeper optimization or device-specific export failures are found during review, capture them as follow-up tasks rather than expanding this task into a full platform porting effort.

---
**Archived:** 2026-03-28
**Verdict:** PARTIAL
