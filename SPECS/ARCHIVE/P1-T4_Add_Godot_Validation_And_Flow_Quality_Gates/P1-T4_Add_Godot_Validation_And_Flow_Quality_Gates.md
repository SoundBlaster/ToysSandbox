# P1-T4 — Add Godot Validation And Flow Quality Gates

**Task ID:** P1-T4  
**Phase:** Foundation  
**Priority:** P1  
**Dependencies:** P1-T1, P1-T3  
**Status:** Planned

## Objective Summary

Establish a real, reproducible local validation path for the Godot 4 project and wire it into Flow quality gates. This task replaces legacy placeholder assumptions with explicit project checks for headless Godot execution, script/scene baseline integrity, and documentation for local and CI use.

Primary deliverables:
- A documented and executable validation command path.
- Verified `verify.*` commands in `.flow/params.yaml` that point to real checks.
- Updated developer docs describing prerequisites and expected outcomes.

## Success Criteria

1. Running the configured quality commands from `.flow/params.yaml` produces deterministic pass/fail behavior on this repository.
2. The validation flow can be executed by a contributor with only documented prerequisites.
3. Local and CI usage instructions are captured in project docs with exact command names and troubleshooting guidance.

## Acceptance Tests

- `bash scripts/ci/flow_validate.sh tests` exits `0` on a valid repo state.
- `bash scripts/ci/flow_validate.sh lint` exits `0` on a valid repo state.
- Any unsupported mode (example: `bash scripts/ci/flow_validate.sh unknown`) exits non-zero with a help message.
- Documentation references the same commands configured in `.flow/params.yaml`.

## Test-First Plan

Before implementation changes:
1. Run current validation commands to establish baseline behavior and capture output.
2. Add/adjust command-level assertions in shell script behavior first (argument validation, mode routing, error messages).
3. Re-run failing checks until expected failure/pass behavior matches acceptance tests.

This task is shell-and-doc focused; “tests first” is interpreted as validating command contracts and failure modes before broad doc updates.

## Execution Plan (Hierarchical TODO)

### Phase 1 — Baseline Audit And Contract Definition

| Subtask | Inputs | Outputs | Verification |
|---|---|---|---|
| 1.1 Inspect existing CI script and validation scene/script | `scripts/ci/flow_validate.sh`, `scenes/ci/FlowValidation.tscn`, `scripts/ci/flow_validation.gd` | Current-state behavior map (modes, prerequisites, edge cases) | Manual command run captures expected/actual behavior |
| 1.2 Confirm Flow params alignment | `.flow/params.yaml` | Required command contract list for `verify.tests` and `verify.lint` | Params point to non-placeholder script invocations |
| 1.3 Identify gaps for local/CI reproducibility | Existing docs under `docs/` and `SPECS/` | Gap checklist for missing prerequisites and usage steps | Checklist covers install assumptions, headless mode, exit codes |

### Phase 2 — Implement Validation Gate Improvements

| Subtask | Inputs | Outputs | Verification |
|---|---|---|---|
| 2.1 Harden `flow_validate.sh` mode handling | Baseline contract + acceptance tests | Deterministic mode parser with clear errors and non-zero exits on invalid input | `tests`, `lint`, and invalid mode behavior match acceptance tests |
| 2.2 Ensure Godot validation execution path is explicit | CI scene/script + shell wrapper | Stable command invoking Godot headless validation entry point | Script exits propagate command failure correctly |
| 2.3 Align Flow params with final command path | `.flow/params.yaml` | Finalized `verify.tests` and `verify.lint` values | Running commands from params succeeds |

### Phase 3 — Documentation And Validation Report

| Subtask | Inputs | Outputs | Verification |
|---|---|---|---|
| 3.1 Update validation docs for local and CI | `docs/godot-validation.md`, related specs docs as needed | Clear prerequisites and run instructions | Fresh environment user can follow docs without hidden assumptions |
| 3.2 Execute full quality gate pass | Script and docs updates | Evidence of command outputs and final status | Both configured gates pass |
| 3.3 Create task validation report | Run results + acceptance checklist | `SPECS/INPROGRESS/P1-T4_Validation_Report.md` with PASS/PARTIAL/FAIL verdict | Report includes gate outputs and criteria mapping |

## Functional Requirements

- Validation script supports at least `tests` and `lint` modes and rejects unknown modes.
- Script must return non-zero on failures to integrate cleanly with CI.
- `.flow/params.yaml` verify commands must reference maintained project scripts, not placeholders.

## Non-Functional Requirements

- **Reliability:** deterministic behavior across repeated runs.
- **Maintainability:** commands are centralized through `scripts/ci/flow_validate.sh`.
- **Usability:** docs provide one-command examples for local developers.

## Constraints And Decision Points

- Godot executable path may differ by platform; docs must state how to provide/resolve the binary.
- Validation should avoid interactive UI requirements; headless-friendly execution is required.
- Keep implementation minimal and avoid introducing unrelated build tooling.

## Risks And Mitigations

- **Risk:** contributor environment lacks Godot binary.  
  **Mitigation:** document fallback env var/path configuration and failure message.
- **Risk:** script changes accidentally mask failing validations.  
  **Mitigation:** enforce strict shell error handling and explicit exit checks.

## Notes (Post-Completion Updates)

After EXECUTE completes:
- Update `SPECS/Workplan.md` to mark P1-T4 complete during ARCHIVE.
- Ensure archive index/log entries include task verdict and date.
- Preserve docs consistency between `docs/godot-validation.md` and `.flow/params.yaml` commands.

---
**Archived:** 2026-03-28
**Verdict:** PASS
