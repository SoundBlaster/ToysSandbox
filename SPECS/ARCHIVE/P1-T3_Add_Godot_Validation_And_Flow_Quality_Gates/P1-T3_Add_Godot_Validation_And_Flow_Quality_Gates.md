# P1-T3 — Add Godot Validation And Flow Quality Gates

## Objective

Replace the placeholder Flow verification commands with real, repo-local validation entrypoints that use the Godot editor binary in headless mode. The goal is to give EXECUTE a stable command surface for source-level validation now, while documenting the local and CI prerequisites needed to run those checks on a machine that has Godot installed.

## Success Criteria

- `.flow/params.yaml` points `verify.tests` and `verify.lint` at executable commands instead of placeholder `printf` stubs.
- The repo contains a documented validation command or script that runs Godot headlessly from the project root.
- The validation path covers the current scaffold and can fail on missing resources or parse errors before later tasks add more runtime behavior.
- Local and CI usage are documented, including the expected Godot binary location or `GODOT_BIN` override.

## Acceptance Tests

1. Inspect `.flow/params.yaml` and confirm both `verify.tests` and `verify.lint` point to real commands.
2. Inspect the validation script(s) and confirm they resolve a Godot editor binary, run from the repo root, and exit non-zero on failure.
3. Confirm the documentation explains how to run the checks locally and in CI.
4. Run the configured Flow verify commands and record whether Godot is available in the current environment.

## Test-First Plan

Before changing the verification commands, define the expected interface for the validation harness:

- The runner must accept a mode argument so tests and lint can share one implementation.
- The runner must fail clearly when no Godot editor binary is available.
- The runner must load the project from the repository root and validate the current scenes and scripts without relying on editor-only interaction.
- The docs must describe the same command surface used by Flow so future tasks can reuse it.

## Execution Plan

### Phase 1 — Validation Contract

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Define command interface | Workplan + `.flow/params.yaml` placeholders | A small validation contract with `tests` and `lint` modes | Review the planned modes against the current project shape |
| Define binary discovery rules | macOS workspace + CI expectations | `GODOT_BIN` override and fallback discovery path | Confirm the documented binary search order is deterministic |

### Phase 2 — Headless Harness

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Create a shell entrypoint | Validation contract | Repo-local executable script for Flow | Confirm the script resolves the repo root and invokes Godot headlessly |
| Create a GDScript check runner | Current scenes/scripts | Headless validation script that loads project resources | Confirm the script fails on missing resources or parse errors |

### Phase 3 — Flow Wiring And Docs

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Update Flow params | Validation harness | Real `verify.tests` and `verify.lint` commands | Inspect `.flow/params.yaml` for non-placeholder commands |
| Document local/CI usage | Runner behavior | Short validation guide for developers and CI | Confirm the doc includes setup notes and exact commands |
| Validate end to end | Final command surface | Validation report and commit-ready state | Run the configured Flow checks and record results |

## Decisions And Constraints

- Keep the validation surface small and repo-local so Flow does not depend on globally installed package managers or task runners.
- Prefer one reusable runner with a mode argument over two unrelated scripts so both quality gates stay aligned.
- Use Godot headless execution rather than editor UI steps because the current environment and CI both need non-interactive validation.
- Treat this task as source-level and configuration-level validation; deeper runtime playtesting remains a later task.

## Verification Steps

- Run the updated `verify.tests` and `verify.lint` commands from `.flow/params.yaml`.
- Confirm the commands resolve a Godot editor binary through the documented lookup rules.
- Record the outcome in `SPECS/INPROGRESS/P1-T3_Validation_Report.md`.
- If Godot is unavailable, document the exact missing prerequisite rather than marking the task failed for the repo itself.

## Notes

- Update any project docs that point contributors to Flow quality gates so they use the new command surface.
- Keep the validation script compatible with macOS path conventions and CI environments that provide `GODOT_BIN`.
- Preserve the existing `project.godot` structure; this task should not change scene ownership or gameplay scripts.

---
**Archived:** 2026-03-28
**Verdict:** PASS
