# P4-T5 - Complete Real Hardware Export And Performance Validation

**Task ID:** P4-T5  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P1  
**Dependencies:** P4-T2  
**Status:** Planned

## Objective Summary

Close the remaining acceptance gap from `P4-T2` by turning export/performance validation into a reproducible evidence workflow, then executing as much of that workflow as possible in the current environment. The final artifact must prove what is completed now (templates/toolchains, export smoke outcomes, local FPS evidence) and clearly isolate what still requires external hardware access.

This task should avoid speculative claims. Any platform result must be backed by concrete command output or direct run evidence. For unavailable environments (for example, Android physical device testing), the report should list exact prerequisites and a copy-paste protocol so another operator can produce the missing evidence without re-planning.

## Success Criteria And Acceptance Tests

### Success Criteria
- Export-template and toolchain checks are executable and documented for desktop and Android paths.
- Desktop and Android export smoke outcomes are recorded with pass/fail evidence for current environment.
- FPS measurement protocol at `25` toys is standardized and includes required capture fields.
- `SPECS/INPROGRESS/P4-T5_Validation_Report.md` maps each acceptance criterion to concrete evidence or an explicit blocker.

### Acceptance Tests
1. Run configured Flow quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
2. Run export-environment preflight checks and confirm template/toolchain status for desktop and Android.
3. Attempt desktop export smoke command(s) with available presets and record outcomes.
4. Attempt Android export smoke command with current local SDK/signing/toolchain configuration and record outcomes.
5. Capture or template FPS evidence at 25 toys for desktop and Android in one consistent table format.
6. Produce validation report with verdict (`PASS`/`PARTIAL`/`FAIL`) based on objective evidence.

## Test-First Plan

- Define a machine-readable validation helper before editing docs so evidence collection is repeatable across runs.
- Run the helper in this environment first to surface blockers early (missing templates, SDK, signing values, device access).
- Update export documentation only after results are known, so the checklist reflects tested commands and observed failure modes.

## Hierarchical TODO Plan

### Phase 1 - Validation Harness And Evidence Schema
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add export/perf validation helper | `export_presets.cfg`, existing CI scripts | Script that checks Godot binary, templates, presets, and optional export attempts | Script runs non-interactively and emits explicit pass/fail lines |
| Define evidence schema | P4-T2 report + current acceptance criteria | Reusable report sections/tables for FPS and export outcomes | Validation report fields are complete and consistent |

### Phase 2 - Execute Local Validation Attempts
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `.flow/params.yaml` verify commands | Fresh `tests`/`lint` outcomes | Both commands exit successfully |
| Run desktop + Android smoke attempts | Validation helper + local toolchains | Recorded export/template/toolchain results | Command outputs captured in validation report |

### Phase 3 - Document And Close Task
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Update export checklist with tested flow | `docs/export-checklist.md`, observed results | Checklist aligned to real commands and blocker handling | No ambiguous or untested instruction remains |
| Write P4-T5 validation report | Command outputs, manual evidence template | `P4-T5_Validation_Report.md` with final verdict | Each workplan acceptance criterion is mapped |

## Constraints And Toolchain Notes

- Avoid committing secrets: Android signing credentials and SDK/JDK local paths stay outside git.
- Prefer deterministic CLI validation (`--headless --export-debug`) before editor-only flows.
- If physical hardware FPS data cannot be captured here, mark criterion as blocked with an explicit follow-up handoff checklist.
- Review subject name for this FLOW run is assumed as `p4-t5-real-hardware-export-and-performance-validation`.

## Notes

- If local export templates are still missing, include exact installation guidance tied to observed Godot version.
- If Android export is blocked by SDK/signing prerequisites, include precise missing keys/paths and expected command to retry.
