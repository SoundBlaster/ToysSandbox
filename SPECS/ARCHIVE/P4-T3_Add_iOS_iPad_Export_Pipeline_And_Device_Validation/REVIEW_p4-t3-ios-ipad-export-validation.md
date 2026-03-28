## REVIEW REPORT — P4-T3 iOS/iPad Export Validation

**Scope:** origin/main..HEAD  
**Files:** 7

### Summary Verdict
- [ ] Approve
- [ ] Approve with comments
- [x] Request changes
- [ ] Block

### Critical Issues
- [High] `P4-T3` now has a working repo-level iOS export path, matching templates, and a successful Xcode build, but the workplan acceptance still requires a launch on a physical iPad. The current machine evidence shows the known iPad device is `unavailable`, so the final acceptance proof remains open and should be tracked explicitly rather than implied by the successful export/build steps.

### Secondary Issues
- None beyond the outstanding hardware validation gap.

### Architectural Notes
- Adding `rendering/textures/vram_compression/import_etc2_astc=true` was the key repo-level fix for Godot’s Apple Embedded export path. Without it, the exporter fails with a generic configuration error that does not explain the root cause in CLI mode.
- The iOS preset is correctly scoped toward `export_project_only`, which keeps signing and provisioning local to Xcode instead of hard-coding machine-specific values into the repo.
- Adding non-empty privacy usage descriptions to the exported plist path improves the generated project quality and removes avoidable Xcode warnings.

### Tests
- `bash scripts/ci/flow_validate.sh tests` — pass
- `bash scripts/ci/flow_validate.sh lint` — pass
- Godot CLI export to `/tmp/ToysSandbox-ios` — pass
- Xcode generic iOS device build with `CODE_SIGNING_ALLOWED=NO` — pass
- Physical iPad deployment — not performed because the iPad device is offline/unavailable

### Next Steps
- Add a follow-up task to complete signed launch validation on a connected physical iPad and capture the final device evidence.
- Keep `P4-T3` archived as `PARTIAL` until that hardware validation is completed.
