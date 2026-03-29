# ToysSandbox

Godot 4 toybox sandbox prototype with a documentation-driven workflow under [`SPECS/`](/Users/egor/Development/GitHub/ToysSandbox/SPECS).

## Generate iOS Xcode Project

Use the short command to export the existing Godot `iOS` preset to `/private/tmp/ToysSandbox` and open the generated Xcode project:

```bash
make ios
```

Manual export command:

```bash
make export-ios-xcode
```

By default this writes:

- [build/ios/ToysSandbox.xcodeproj](/Users/egor/Development/GitHub/ToysSandbox/build/ios/ToysSandbox.xcodeproj)

Optional overrides:

```bash
make export-ios-xcode GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot
make export-ios-xcode IOS_EXPORT_PATH=build/ios/MyCustomToysSandbox
```

Prerequisites:

- Godot `4.6.x` with matching export templates installed
- Local `iOS` export preset values filled in for Team ID and bundle identifier
- macOS/Xcode toolchain available for signing and device deployment

After export, open the generated `.xcodeproj` in Xcode and complete signing there. For the full setup and deployment checklist, see [docs/ios-ipad-export-checklist.md](/Users/egor/Development/GitHub/ToysSandbox/docs/ios-ipad-export-checklist.md).

## Interaction Tuning

Double-click/double-tap delete thresholds are centralized in [scripts/game/Sandbox.gd](/Users/egor/Development/GitHub/ToysSandbox/scripts/game/Sandbox.gd) via `INTERACTION_TUNING`.

- `delete_double_tap_window_ms`: `320`
- `delete_double_tap_max_distance`: `28.0`

These values are injected into `SandboxInteractionController.setup(...)` and default to the same numbers if tuning data is omitted or invalid.
