# P4-T2 Validation Report

**Task:** P4-T2 - Performance Pass, Asset Cleanup, And Export Validation  
**Date:** 2026-03-28  
**Verdict:** PARTIAL

## Deliverable Status

- [x] Added a sandbox stats panel with live FPS and active toy count reporting.
- [x] Enforced a 25-toy active object cap for spawn and duplicate flows.
- [x] Reduced avoidable runtime overhead by caching toy textures and disabling per-instance physics processing unless runtime forces are needed.
- [x] Removed stale root-level placeholder asset `ball.png`.
- [x] Added export readiness artifacts: `export_presets.cfg` and `docs/export-checklist.md`.
- [x] Flow quality gates pass for configured `tests` and `lint` commands.
- [ ] Full export execution and measured desktop/Android FPS validation were not completed in this environment.

## Implementation Evidence

1. `scenes/game/Sandbox.tscn` + `scripts/game/Sandbox.gd`
   - Added a `StatsLabel` to display live FPS and toy count.
   - Added a `MAX_ACTIVE_TOYS` budget of `25` and blocked new spawns once the limit is reached.
2. `scripts/game/SandboxInteractionController.gd`
   - Applied the same 25-toy guard to duplication so the cap is consistent across creation paths.
3. `scripts/autoload/ToyCatalog.gd`
   - Added icon/world texture caching to avoid repeated resource loads for the same toy definitions.
4. `scripts/game/ToyInstance.gd`
   - Disabled `_physics_process` unless a toy actually needs buoyancy/upright correction runtime forces.
5. `docs/export-checklist.md`
   - Documented reproducible export prerequisites and smoke-check steps for Windows, macOS, Linux, and Android.
6. `export_presets.cfg`
   - Added baseline presets for Windows Desktop, macOS, Linux/X11, and Android.
7. `.gitignore`
   - Stopped ignoring `export_presets.cfg` so export configuration is versioned with the project.

## Validation Performed

1. Ran configured Flow quality gates from `.flow/params.yaml`:
   - `bash scripts/ci/flow_validate.sh tests` -> **PASS**
   - `bash scripts/ci/flow_validate.sh lint` -> **PASS**
2. Ran an export preset smoke probe:
   - `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug "Windows Desktop" /tmp/ToysSandbox-smoke.exe`
   - Result: **Preset recognized**, export blocked because local Windows export templates are not installed.

## Manual Verification Protocol

1. Launch the sandbox locally in Godot.
2. Spawn and duplicate toys until the stats panel reads `Toys: 25/25`.
3. Confirm the next spawn/duplicate attempt is blocked with a clear status message.
4. Interact with drag, fan, smash, resize, and reset while monitoring FPS from the stats panel.
5. Record desktop FPS against the `60 FPS @ 25 toys` target.
6. Export/install the Android build once SDK/signing/templates are configured, then repeat the 25-toy validation on device for the `30 FPS` target.

## Acceptance Criteria Mapping

- **Desktop build holds 60 FPS with 25 active objects on reference hardware** -> Runtime stats panel and 25-toy cap are implemented, but measured desktop FPS remains **unverified** in this environment.
- **Android build holds 30 FPS with 25 active objects on target hardware class** -> Export checklist and Android preset exist, but device validation remains **unverified** in this environment.
- **Unused placeholder art and textures are removed or clearly marked for follow-up** -> Removed stale placeholder file `ball.png` and documented retained generated import metadata in the checklist.
- **Export checklist for Windows, macOS, Linux, and Android is documented and reproducible** -> Implemented in `docs/export-checklist.md` with matching preset paths in `export_presets.cfg`.

## Notes

- The existing Godot validation warning (`ObjectDB instances leaked at exit`) remains unchanged and predates this task.
- This task is archived as `PARTIAL` because export-template installation and hardware/device profiling are environment-dependent and were not fully executable here.
