# P4-T3 - Add iOS/iPad Export Pipeline And Device Validation

**Task ID:** P4-T3  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P2  
**Dependencies:** P4-T2  
**Status:** Planned

## Objective Summary

Add first-class iOS export support on top of the existing cross-platform Godot export setup so the project can be exported into an Xcode project and prepared for deployment to a physical iPad without forking gameplay code. The machine already has Xcode and the iPhoneOS SDK available, which means this task can focus on closing the repo-side gaps: versioned iOS export preset configuration, reproducible setup documentation, and validation evidence for the Godot-to-Xcode handoff.

The implementation should stay pragmatic and security-conscious. Apple team identifiers, provisioning profiles, and signing identities are machine-local secrets or account-specific values, so the repository should provide placeholders and documented setup paths rather than committed credentials. If a physical iPad is unavailable for final launch validation, the task should narrow the remaining blocker to that exact missing dependency instead of leaving the export path ambiguous.

## Success Criteria And Acceptance Tests

### Success Criteria
- `export_presets.cfg` includes a valid iOS preset with the required Godot application metadata fields and safe placeholder values where local credentials are needed.
- The repository documents reproducible iOS/iPad export setup steps, including Xcode, Team ID, bundle identifier, provisioning, and any Godot-specific export caveats.
- The local machine can export the project into an Xcode project structure, or any remaining exporter failure is tied to one precise missing prerequisite.
- Flow quality gates continue to pass after the export changes.
- Validation evidence records the exact environment status and whether physical-device launch was completed or blocked.

### Acceptance Tests
1. Add an iOS preset to `export_presets.cfg` with required fields for App Store Team ID, bundle identifier, versioning, targeted device family, and export mode.
2. Confirm the local machine has the Xcode path/SDK prerequisites Godot expects for iOS export.
3. Install or validate the required Godot export templates and attempt an iOS export from the command line or editor-compatible workflow.
4. If export succeeds, verify the generated `.xcodeproj` structure exists and document the expected next Xcode signing/deployment steps.
5. Document reproducible iOS/iPad setup and deployment steps in the repo, including how to fill local-only values safely.
6. If no physical iPad is connected or signing credentials are unavailable, capture that exact blocker in the validation report instead of claiming device completion.
7. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
8. Record all outcomes in `SPECS/INPROGRESS/P4-T3_Validation_Report.md`.

## Test-First Plan

- Validate local Apple toolchain and Godot export-template prerequisites before changing repo files.
- Add the iOS preset and documentation changes next so the repo reflects a reproducible configuration even before device-specific local secrets are filled in.
- Attempt a real export into an Xcode project using the configured preset and record the exact outcome.
- Re-run Flow quality gates after repo changes, then write the validation report from observed evidence.

## Hierarchical TODO Plan

### Phase 1 - Toolchain And Export Prerequisite Validation
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Check local Apple toolchain | `xcodebuild`, `xcode-select`, `xcrun` | Confirmed Xcode/iPhoneOS SDK status | Godot export will target the correct Xcode installation |
| Check Godot export-template state | Installed Godot app and template directory | Concrete template availability status | iOS export template blocker is either cleared or named precisely |

### Phase 2 - Repo-Level iOS Export Configuration
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add iOS export preset | Existing `export_presets.cfg`, Godot iOS export requirements | Versioned iOS preset with placeholders | Preset is present and parseable by Godot |
| Add setup checklist/docs | Current export docs and Apple/Godot requirements | Reproducible iOS/iPad export checklist | Local setup values are documented without committing secrets |

### Phase 3 - Export And Device Validation
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Attempt Xcode project export | Godot binary, export preset, templates | Generated iOS Xcode project or precise failure output | Export command demonstrates the real state |
| Validate physical-device readiness | Xcode signing state, connected device access if available | Launch evidence or exact missing dependency | Validation report does not overclaim hardware coverage |

### Phase 4 - Validation And Reporting
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `.flow/params.yaml` verify commands | PASS outputs for tests/lint | Exit code `0` for both commands |
| Write validation report | Export evidence, toolchain state, blockers | `P4-T3_Validation_Report.md` | Every acceptance criterion mapped to evidence |

## Constraints And Toolchain Notes

- Keep Apple account secrets, certificate material, provisioning UUIDs, and signing identities out of git.
- Preserve the current shared gameplay/export model; iOS support must not introduce gameplay forks.
- Prefer `export_project_only` for the repo-default iOS preset so the generated Xcode project can be signed locally per developer account.
- Treat physical iPad validation as evidence-based only: if no device is available, document that as the final blocker.
- Review subject name for this FLOW run will be `p4-t3-ios-ipad-export-validation`.

## Notes

- Godot’s stable iOS export docs require macOS, Xcode, export templates, and non-empty App Store Team ID plus bundle identifier for export.
- Apple Silicon Macs can run iOS apps natively, but this task still targets the workplan requirement of physical iPad deployment when the hardware is available.

---
**Archived:** 2026-03-28
**Verdict:** PARTIAL
