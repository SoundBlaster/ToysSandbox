# Export Checklist

## Scope

This checklist covers the MVP export path for `Windows`, `macOS`, `Linux`, and `Android` from the shared Godot 4 project. It is intentionally pragmatic: the repo stores reproducible preset structure in `export_presets.cfg`, while machine-specific credentials and SDK paths stay local.

## Performance Validation Before Export

1. Launch the sandbox and spawn or duplicate toys until the live stats panel reads `Toys: 25/25`.
2. Let the toys settle, then interact with drag, fan, smash, resize, and reset.
3. Record FPS from the sandbox stats panel:
   - Desktop target: `60 FPS` with `25` active toys.
   - Android target: `30 FPS` with `25` active toys.
4. If FPS falls below target, capture the device/build details and treat it as a release blocker for `P4-T2`.

## Shared Prerequisites

1. Install Godot `4.6` plus matching export templates.
2. Confirm the project validates locally:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
3. Keep confidential export credentials out of git:
   - Android keystore passwords and aliases belong in local Godot export credentials.
   - Platform SDK paths belong in local editor/export settings.

## Desktop Export Flow

### Windows
1. Open `Project -> Export`.
2. Select `Windows Desktop`.
3. Confirm the export path resolves to `build/windows/ToysSandbox.exe`.
4. Export a debug build for smoke testing, then export a release build for packaging.
5. Run the exported build and verify menu -> sandbox -> 25-toy stress flow.

### macOS
1. Select `macOS`.
2. Confirm the export path resolves to `build/macos/ToysSandbox.zip`.
3. If notarization/signing is needed later, keep those values local and do not commit credentials.
4. Launch the packaged build and repeat the 25-toy stress flow on macOS reference hardware.

### Linux
1. Select `Linux/X11`.
2. Confirm the export path resolves to `build/linux/ToysSandbox.x86_64`.
3. Export and run on a Linux machine or CI runner with matching runtime libraries.
4. Repeat the menu -> sandbox -> 25-toy stress flow.

## Android Export Flow

1. Install Android SDK, build-tools, platform-tools, and an accepted JDK version for the active Godot release.
2. In Godot editor settings, configure Android SDK/JDK paths.
3. Open `Project -> Export` and select `Android`.
4. Fill local values for:
   - package unique name
   - keystore/debug signing settings
   - SDK version targets if needed by the active device fleet
5. Export to `build/android/ToysSandbox.apk`.
6. Install on the target tablet/phone and verify:
   - first-launch onboarding still works
   - audio/settings persistence still works
   - the sandbox maintains usable responsiveness at `25` toys

## Placeholder Asset Cleanup Status

- Removed stale root-level placeholder asset `ball.png`; the project now uses `icon.svg` plus the curated `assets/` tree.
- Keep generated `.import` metadata files because the current validation/export path depends on them for clean checkouts.

## Follow-Up Triggers

- If any platform requires project-level setting changes outside `export_presets.cfg`, capture that as a follow-up task with the exact platform and blocker.
- If mobile profiling shows the 25-toy budget is still unstable, record the device class and create a targeted optimization task instead of silently lowering the object cap.
