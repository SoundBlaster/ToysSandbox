# iOS And iPad Export Checklist

## Scope

This checklist covers the Godot-to-Xcode export path for deploying `ToysSandbox` to a physical iPad from the shared project without gameplay forks. The repository stores the reusable preset structure in `export_presets.cfg`, while Apple account, signing, and provisioning details remain local to each developer machine.

## Repo-Managed Defaults

- Export preset: `iOS`
- Export path: `build/ios/ToysSandbox`
- Default bundle identifier placeholder: `org.toyssandbox.game.ios`
- Default Team ID placeholder: `TEAMID1234`
- Repo default export mode: `export_project_only=true`

Replace the Team ID and bundle identifier locally in Godot before device deployment. Do not commit personal Team IDs, provisioning UUIDs, or certificate material.

## Required Local Prerequisites

1. macOS with Xcode installed and selected via `xcode-select`.
2. Matching Godot export templates for the installed Godot version.
3. An Apple Developer team capable of signing development builds.
4. A unique bundle identifier for the local signing account.
5. A physical iPad connected, trusted, and visible to Xcode for final validation.
6. If you want simulator validation on Apple Silicon, confirm the exported Godot iOS template actually contains an `arm64` simulator slice. A folder name like `ios-arm64_x86_64-simulator` is not enough by itself.

## Toolchain Smoke Checks

Run these before exporting:

```bash
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-path
security find-identity -v -p codesigning
xcrun xctrace list devices
```

Expected results:
- `xcodebuild` reports the active Xcode version.
- `xcrun --sdk iphoneos` resolves an iPhoneOS SDK path.
- `security find-identity` lists at least one Apple Development identity.
- `xctrace` shows the target iPad as online before final deployment.

## Godot Export Setup

1. Install Godot `4.6.x` export templates that match the local editor build.
2. Open `Project -> Export` and select the `iOS` preset.
3. Fill local-only values:
   - `Application > App Store Team ID`
   - `Application > Bundle Identifier`
   - Optional manual provisioning profile fields if automatic signing is not used
4. Keep `Export Project Only` enabled for the repo default flow so Xcode owns final signing and deployment.
5. Export to `build/ios/ToysSandbox`.

## Xcode Deployment Flow

1. Open the generated `build/ios/ToysSandbox.xcodeproj` in Xcode.
2. Under `Signing & Capabilities`, choose the correct Apple team.
3. Confirm the bundle identifier matches a valid development identifier for the selected team.
4. Select the connected iPad as the run target.
5. Build and run from Xcode.
6. Verify:
   - app launches successfully on the iPad
   - onboarding/menu/sandbox path still works
   - no gameplay fork or platform-specific logic is required for core interactions

## Validation Notes To Capture

Record these in the Flow validation report:

- Exact Godot version and whether export templates were installed
- Xcode version and iPhoneOS SDK path
- Which signing identity/team was used
- Whether the iPad was online, trusted, and selected in Xcode
- Whether the export produced an `.xcodeproj`
- Whether the app launched on the physical iPad, or the exact blocking step if not

## Follow-Up Triggers

- If export fails before `.xcodeproj` generation, capture the exact Godot/template blocker.
- If Xcode opens the project but signing fails, record the team/provisioning mismatch and keep credentials out of git.
- If the iPad is offline or unavailable, treat physical-device launch as the remaining blocker rather than marking the task complete.
- If simulator launch fails on Apple Silicon with `Undefined symbols for architecture arm64: _main`, inspect the simulator slice inside the exported `libgodot.a` before changing app code.
