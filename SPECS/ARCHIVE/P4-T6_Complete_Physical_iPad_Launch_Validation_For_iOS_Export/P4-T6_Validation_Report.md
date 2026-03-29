# P4-T6 Validation Report

**Task:** P4-T6 - Complete Physical iPad Launch Validation For iOS Export  
**Date:** 2026-03-29  
**Verdict:** PARTIAL

## Deliverable Status

- [x] Confirmed the local iOS toolchain and export prerequisites.
- [x] Exported the Godot project to `build/ios/ToysSandbox.xcodeproj`.
- [x] Confirmed a physical iPad is connected and visible to Xcode/Core Device.
- [x] Ran the configured Flow quality gates.
- [ ] Installed and launched the app on the physical iPad. Xcode signing/provisioning is blocked locally.

## Evidence Summary

1. Toolchain and device discovery
   - `xcodebuild -version` -> `Xcode 26.3` (`Build version 17C529`)
   - `xcode-select -p` -> `/Applications/Xcode.app/Contents/Developer`
   - `xcrun --sdk iphoneos --show-sdk-path` -> `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.2.sdk`
   - `security find-identity -v -p codesigning` -> two valid Apple Development identities were available locally
   - `xcrun xctrace list devices` -> `iPad Egor Merkushev (26.2) - Connecting`
   - `xcrun devicectl list devices` -> `iPad Egor Merkushev` is `connected`, model `iPad mini (5th generation) (iPad11,1)`
2. Repo export path
   - `make export-ios-xcode GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot`
   - Result: `PASS`, generated `build/ios/ToysSandbox.xcodeproj`
   - `xcodebuild -list -project build/ios/ToysSandbox.xcodeproj` -> scheme `ToysSandbox`
3. Signing and launch attempts
   - `xcodebuild -project build/ios/ToysSandbox.xcodeproj -scheme ToysSandbox -configuration Debug -destination 'id=00008020-00123D610EF8003A' -derivedDataPath build/ios/DerivedData DEVELOPMENT_TEAM=R629M26C36 CODE_SIGN_STYLE=Automatic -allowProvisioningUpdates -allowProvisioningDeviceRegistration build`
     - Failed with `No Account for Team "R629M26C36"`
     - Failed with `No profiles for 'org.toyssandbox.game.ios' were found`
   - Retried with `DEVELOPMENT_TEAM=Y7D2JBHZU2`
     - Failed with the same account/profile errors
   - `~/Library/MobileDevice/Provisioning Profiles` was empty during validation
4. Simulator investigation
   - `xcodebuild -project build/ios/ToysSandbox.xcodeproj -scheme ToysSandbox -configuration Debug -destination 'platform=iOS Simulator,id=DB4E2D9A-01A7-4D78-8E0A-4C54972EC00B' -derivedDataPath build/ios/DerivedData-sim build`
     - Built the simulator target for `arm64`, but link failed with `Undefined symbols for architecture arm64: _main`
   - `lipo -info build/ios/ToysSandbox.xcframework/ios-arm64_x86_64-simulator/libgodot.a`
     - Reported `architecture: x86_64`
   - The booted iPhone Air simulator on this Apple Silicon host requires an arm64 simulator slice, so the exported Godot template cannot launch there as-is
5. Flow gates
   - `bash scripts/ci/flow_validate.sh tests` -> PASS
   - `bash scripts/ci/flow_validate.sh lint` -> PASS

## Acceptance Criteria Mapping

- **A physical iPad is connected, trusted, and selectable in Xcode during validation** -> Implemented; the iPad is connected and appears in both Xcode destination listings and Core Device output.
- **The generated `ToysSandbox-ios.xcodeproj` is signed with local development credentials without committing secrets** -> Not achieved; Xcode rejected both attempted local teams because no matching account/profile was available.
- **The app installs and launches successfully on the physical iPad** -> Not achieved; launch is blocked by signing/provisioning.
- **The validation report records device model, iOS version, signing mode, and observed launch outcome** -> Implemented here.

## Remaining Blocker

- The repo export path is correct, but the local Xcode signing environment is incomplete for physical-device deployment:
  - No Xcode account is configured for either attempted development team
  - No provisioning profile exists locally for `org.toyssandbox.game.ios`
  - Because the app cannot be signed, the physical iPad launch could not be completed
- Simulator launch on the Apple Silicon host is also blocked by the exported Godot iOS template shipping an x86_64-only simulator archive instead of an arm64 simulator slice.

## Notes

- The connected iPad is a real device, not a simulator, so this task is blocked by signing state rather than hardware visibility.
- The committed repo should keep the iOS preset placeholders unchanged; the required team/provisioning values are machine-local.
- Godot export and Flow validation both passed, so the remaining issue is isolated to local Apple signing configuration.
- The simulator issue is environment/template-specific and does not change the device-launch verdict, but it is useful context for anyone validating the export on Apple Silicon.
