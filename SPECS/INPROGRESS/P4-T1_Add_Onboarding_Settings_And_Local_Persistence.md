# P4-T1 - Add Onboarding, Settings, And Local Persistence

**Task ID:** P4-T1  
**Phase:** UX, Persistence, And Release Readiness  
**Priority:** P1  
**Dependencies:** P2-T2  
**Status:** Planned

## Objective Summary

Implement the first MVP UX/persistence pass that makes the sandbox self-explanatory for first-time players and keeps player preferences between launches. The task includes three integrated outcomes: a lightweight onboarding overlay in the sandbox, a settings UI for audio and tutorial reset, and local persistence of audio values plus the last selected toy.

The onboarding experience must remain concise and non-blocking: short guidance for spawn, drag, and reset, dismissible manually, and automatically hidden after the user successfully performs the first spawn. Settings must be reachable from the main menu and include music volume, sound volume, and a tutorial reset action. Persistence must use local storage only, survive app restart, and recover safely from missing or malformed save data by restoring defaults.

## Success Criteria And Acceptance Tests

### Success Criteria
- First launch shows a short onboarding overlay in sandbox, then hides after first meaningful interaction or explicit dismiss.
- Main menu exposes settings with controls for music volume, sound volume, and tutorial reset.
- Selected toy and audio settings are persisted locally and restored on next launch.
- Existing Flow quality gates pass after implementation.

### Acceptance Tests
1. Launch app with no prior save and enter sandbox: onboarding overlay is visible with short instructions.
2. Spawn one toy or tap overlay close action: onboarding overlay hides and remains hidden in subsequent launches.
3. Open settings from main menu; change music/sound sliders; confirm values update active audio behavior.
4. Select a non-default toy, quit/relaunch app, and re-enter sandbox: selected toy remains restored.
5. Trigger "reset tutorial" in settings, enter sandbox again: onboarding appears again.
6. Remove or corrupt save file and relaunch: app falls back to defaults without crash.
7. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
8. Record results in `SPECS/INPROGRESS/P4-T1_Validation_Report.md`.

## Test-First Plan

- Add deterministic persistence API coverage first by hardening `SaveService` load/save defaults and schema sanitization before UI wiring.
- Introduce onboarding visibility state in `GameState` and wire startup load in `Boot.gd` before scene-level UX changes.
- Add settings panel and sandbox onboarding nodes/scripts after persistence surfaces are in place, then run iterative validation.
- Execute quality gates after major integration slices and again after final cleanup.

## Hierarchical TODO Plan

### Phase 1 - Persistence And Session State Foundations
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Expand save schema | Existing `SaveService.gd` defaults and save path | Read/write support for selected toy, tutorial dismissed flag, and audio settings | Missing/corrupt save falls back to defaults safely |
| Hydrate runtime state at boot | `Boot.gd`, `GameState.gd`, `AudioService.gd` | Loaded state applied on app startup | Launch restores prior settings and selected toy |

### Phase 2 - Settings UX
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add settings entry point | Main menu scene and script | `Settings` button and modal/panel flow | Settings UI opens/closes without breaking Play flow |
| Bind audio + tutorial controls | Save and audio services | Slider changes update audio and persist; reset tutorial clears dismissed flag | Relaunch reflects stored audio values; reset re-enables onboarding |

### Phase 3 - Onboarding Overlay In Sandbox
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add onboarding overlay UI | Sandbox scene and script | Lightweight overlay with spawn/drag/reset hints and dismiss control | Overlay visible only when tutorial is not dismissed |
| Complete dismiss logic | Interaction hooks in sandbox/spawn path | Auto-dismiss on first spawn plus manual dismiss persistence | Overlay does not reappear unless tutorial reset is used |

### Phase 4 - Validation And Documentation
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Run Flow quality gates | `flow_validate.sh` tests/lint | PASS command outputs | Exit code 0 for both commands |
| Write validation report | Acceptance checks + command outputs | `P4-T1_Validation_Report.md` evidence mapping | All acceptance criteria mapped to observed results |

## Constraints And Toolchain Notes

- Keep implementation compatible with current Godot 4 project structure and existing autoloads.
- Do not add network dependencies; all persistence remains local (`user://`).
- Keep onboarding text brief and child-friendly; avoid long instructional paragraphs.
- Preserve existing sandbox interaction behavior from prior tasks while adding onboarding visibility hooks.
- Ensure settings UX remains functional for both mouse and touch interactions.

## Notes

- If additional UX polish (animations, richer menu layout, sound asset balancing) is identified, capture it as follow-up work instead of expanding this task beyond MVP requirements.
