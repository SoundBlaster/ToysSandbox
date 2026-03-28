## REVIEW REPORT — P4-T2 Performance Pass, Asset Cleanup, And Export Validation

**Scope:** origin/main..HEAD  
**Files:** 14

### Summary Verdict
- [ ] Approve
- [ ] Approve with comments
- [x] Request changes
- [ ] Block

### Critical Issues
- [High] `P4-T2` is a release-readiness task whose acceptance criteria require proven desktop/Android export behavior and measured FPS at `25` active toys, but the branch only adds guardrails, docs, and a preset smoke probe. The validation report explicitly records those requirements as unverified because export templates and target hardware were unavailable. That is honest, but it also means the task’s core acceptance remains open and should be tracked as follow-up work rather than treated as fully done.

### Secondary Issues
- None beyond the acceptance-proof gap above.

### Architectural Notes
- The runtime changes are directionally correct: the sandbox now exposes object-count/FPS telemetry, enforces the object budget, avoids repeated texture lookup, and skips per-instance physics processing when runtime forces are not needed.
- Versioning `export_presets.cfg` is the right repo-level move; leaving it ignored would have made export configuration non-reproducible.

### Tests
- `bash scripts/ci/flow_validate.sh tests` — pass
- `bash scripts/ci/flow_validate.sh lint` — pass
- Export smoke probe recognized the `Windows Desktop` preset but failed because local export templates were not installed.
- No real-hardware desktop/Android FPS capture was performed in this environment.

### Next Steps
- Add a follow-up task to complete real desktop/Android export validation with installed templates, SDK/signing setup, and recorded FPS measurements at `25` active toys.
- Keep the current task archived as `PARTIAL`; do not reinterpret it as a full pass without the missing evidence.
