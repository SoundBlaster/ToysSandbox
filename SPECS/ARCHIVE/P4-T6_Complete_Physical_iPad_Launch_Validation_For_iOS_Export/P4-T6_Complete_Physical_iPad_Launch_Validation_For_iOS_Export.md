# P4-T6 - Complete Physical iPad Launch Validation For iOS Export

**Task ID:** P4-T6  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P2  
**Dependencies:** P4-T3  
**Status:** Planned

## Objective Summary

Close the remaining acceptance gap from `P4-T3` by proving the exported iOS build can be launched on a connected physical iPad with local signing enabled, then capturing exact device evidence in a validation report. The repo already contains the reusable iOS export preset, export checklist, and Xcode handoff guidance, so this task should focus on environment verification and device-launch evidence rather than revisiting export configuration.

The work must stay evidence-based. If the connected iPad is missing, untrusted, or unavailable in Xcode, that blocker should be recorded precisely instead of being hidden behind a successful export/build result. Local signing credentials must remain machine-local and out of git.

## Success Criteria And Acceptance Tests

### Success Criteria
- A physical iPad is connected, trusted, and selectable in Xcode during validation.
- The generated `ToysSandbox-ios.xcodeproj` signs with local development credentials without committing secrets.
- The app installs and launches successfully on the physical iPad.
- The validation report records device model, iOS version, signing mode, and observed launch outcome.

### Acceptance Tests
1. Run the configured Flow quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
2. Confirm local iOS export prerequisites from `docs/ios-ipad-export-checklist.md`:
   - Xcode selected with `xcode-select`
   - iPhoneOS SDK available
   - export templates installed for the current Godot version
3. Export the project to the repo-default iOS Xcode project path.
4. Open or validate the generated Xcode project with the local signing team and connected iPad selected.
5. Build and launch on the physical iPad, or capture the exact blocking prerequisite if launch cannot be completed.
6. Record all evidence in `SPECS/INPROGRESS/P4-T6_Validation_Report.md`.

## Test-First Plan

- Verify the local toolchain and connected-device visibility before making any repo changes.
- Attempt the iOS export and Xcode launch path using the documented checklist, capturing command output and device state as evidence.
- Only after the device outcome is known, write the validation report with a verdict and precise blocker description.
- Re-run the configured Flow gates at the end so the report reflects the current branch state.

## Hierarchical TODO Plan

### Phase 1 - Preflight And Device Discovery
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Check Xcode and iPhoneOS SDK | `xcodebuild`, `xcode-select`, `xcrun` | Confirmed local iOS toolchain state | Commands resolve to the expected Xcode installation |
| Check export template availability | Godot editor version and template install path | Clear template status for iOS export | Template presence or blocker is recorded explicitly |
| Check physical iPad visibility | Xcode device list / connected device tooling | Trusted iPad or a precise availability blocker | Validation can name the exact device or missing dependency |

### Phase 2 - Export And Signing Validation
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Export the project to Xcode | Godot binary, iOS preset, templates | `ToysSandbox-ios.xcodeproj` and export artifacts | Export completes without undocumented warnings |
| Configure local signing in Xcode | Generated Xcode project, local Apple dev account | Signed run target for the connected iPad | Xcode shows the iPad as the run destination |

### Phase 3 - Physical Launch And Evidence Capture
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Build and launch on device | Xcode project, signing state, connected iPad | Successful install/launch or exact failure point | The report captures device model, iOS version, signing mode, and outcome |
| Write validation report | Command output, launch evidence, blocker notes | `P4-T6_Validation_Report.md` | Each acceptance criterion is mapped to evidence |

### Phase 4 - Final Validation Pass
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `.flow/params.yaml` verify commands | PASS outputs for tests and lint | Exit code `0` for both commands |
| Summarize verdict | Validation evidence | Final report verdict (`PASS`/`PARTIAL`/`FAIL`) | Verdict matches observed device evidence |

## Constraints And Toolchain Notes

- Keep Apple account secrets, certificate material, provisioning UUIDs, and signing identities out of git.
- Use the repo-default iOS export path and checklist already documented in `docs/ios-ipad-export-checklist.md` and `README.md`.
- Treat `ToysSandbox-ios.xcodeproj` as the artifact to validate, but do not claim completion without a physical iPad launch.
- Review subject name for this FLOW run will be `p4-t6-physical-ipad-launch-validation`.

## Notes

- If the iPad is unavailable or untrusted, the validation report should explicitly say so and stop short of claiming launch completion.
- If export succeeds but Xcode signing fails, capture the exact local signing mismatch rather than changing repo-level iOS configuration.

---
**Archived:** 2026-03-29
**Verdict:** PARTIAL
