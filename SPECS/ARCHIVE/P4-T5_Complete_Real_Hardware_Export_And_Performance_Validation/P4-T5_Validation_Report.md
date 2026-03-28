# P4-T5 Validation Report

**Task:** P4-T5 - Complete Real Hardware Export And Performance Validation  
**Date:** 2026-03-29  
**Verdict:** PARTIAL

## Deliverable Status

- [x] Added reproducible export smoke helper: `scripts/ci/export_smoke_validate.sh`.
- [x] Updated `docs/export-checklist.md` with CLI-first smoke workflow and concrete blocker remediation guidance.
- [x] Executed Flow quality gates (`tests`, `lint`) successfully.
- [x] Executed desktop + Android export smoke attempts with captured logs and pass/fail outcomes.
- [ ] Captured measured FPS on real desktop and Android hardware at the `25`-toy budget.
- [ ] Produced installable Android APK in this environment.

## Implementation Evidence

1. `scripts/ci/export_smoke_validate.sh`
   - Added deterministic export validation command for `Windows Desktop`, `macOS`, `Linux/X11`, and `Android` presets.
   - Validates preset presence, runs headless import pass, performs `--export-debug`, and emits machine-readable `RESULT preset=...` lines.
   - Persists failure logs to `/tmp/toyssandbox-export-<preset>.log` for audit.
2. `docs/export-checklist.md`
   - Added explicit preflight command usage for full matrix and focused `macOS` + `Android` checks.
   - Added concrete remediation notes for observed blockers (bundle identifier, JDK/SDK/platform-tools/build-tools).

## Validation Performed

1. Flow quality gates:
   - `bash scripts/ci/flow_validate.sh tests` -> **PASS**
   - `bash scripts/ci/flow_validate.sh lint` -> **PASS**
2. Export smoke matrix:
   - `bash scripts/ci/export_smoke_validate.sh --all` -> **PARTIAL**
   - Results:
     - `Windows Desktop` -> **PASS** (export output created)
     - `Linux/X11` -> **PASS** (export output created)
     - `macOS` -> **FAIL** (configuration error)
     - `Android` -> **FAIL** (toolchain configuration error)
3. Failure log excerpts:
   - macOS (`/tmp/toyssandbox-export-macOS.log`): `Invalid bundle identifier: Identifier is missing.`
   - Android (`/tmp/toyssandbox-export-Android.log`): missing/invalid Java SDK path and missing Android `platform-tools`/`build-tools`.

## FPS Evidence Protocol (Pending Real Hardware Run)

Use the following schema when running the 25-toy measurement on target environments:

| Platform | Device/Hardware | Build Type | Toy Count | Avg FPS (30s) | Min FPS | Pass Target | Notes |
|----------|------------------|------------|-----------|---------------|---------|-------------|-------|
| Desktop | TODO | Debug/Release | 25 | TODO | TODO | >= 60 FPS | Pending run |
| Android | TODO | APK (device install) | 25 | TODO | TODO | >= 30 FPS | Pending run |

## Acceptance Criteria Mapping

- **Required Godot export templates are installed locally or in CI for target desktop platforms** -> **PARTIAL**; Windows/Linux export smoke passed, macOS blocked by preset configuration.
- **Android SDK/signing prerequisites are configured well enough to produce an installable APK** -> **NOT MET**; export currently blocked by missing JDK/SDK/editor configuration.
- **Desktop and Android validation captures measured FPS with `25` active toys** -> **NOT MET** in this environment; template provided but real-hardware measurements are pending.
- **Export smoke-test outcomes and performance measurements are documented in an archived validation report** -> **PARTIAL**; smoke outcomes documented, performance measurements pending.

## Remaining Blockers

1. macOS preset requires valid bundle identifier configuration before export can pass.
2. Android export requires local JDK + Android SDK path setup in Godot editor settings (with `platform-tools` and `build-tools`).
3. Real hardware measurement runs are still required to close the FPS acceptance targets.

## Notes

- Existing non-blocking Godot warning (`ObjectDB instances leaked at exit`) still appears during Flow validation and predates this task.
