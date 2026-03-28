# P4-T3 Validation Report

**Task:** P4-T3 - Add iOS/iPad Export Pipeline And Device Validation  
**Date:** 2026-03-28  
**Verdict:** PARTIAL

## Deliverable Status

- [x] Added a versioned `iOS` preset to `export_presets.cfg` with placeholder Team ID and bundle identifier fields.
- [x] Added reproducible iOS/iPad setup and deployment documentation in `docs/ios-ipad-export-checklist.md`.
- [x] Enabled project-level ETC2/ASTC texture import support required by Godot’s Apple Embedded exporter.
- [x] Installed matching Godot `4.6.1.stable` export templates locally and verified iOS template discovery.
- [x] Exported the project successfully to an Xcode project via Godot CLI.
- [x] Built the generated Xcode project successfully for a generic iOS device with code signing disabled.
- [ ] Launched the app on a physical iPad. The known iPad device is currently offline, so final device validation remains blocked.

## Implementation Evidence

1. `export_presets.cfg`
   - Added an `iOS` preset targeting `build/ios/ToysSandbox`.
   - Configured `application/app_store_team_id`, `application/bundle_identifier`, `application/export_project_only`, `application/targeted_device_family`, `application/min_ios_version`, and version metadata.
   - Added `application/additional_plist_content` entries so the generated Info.plist includes non-empty camera, microphone, and photo-library usage descriptions.
2. `project.godot`
   - Added `rendering/textures/vram_compression/import_etc2_astc=true`.
   - This is required by Godot’s Apple Embedded export validation path for iOS/mobile texture formats.
3. `docs/ios-ipad-export-checklist.md`
   - Documented local prerequisites, Godot export flow, Xcode signing/deployment steps, and the exact evidence to capture for physical-device validation.

## Validation Performed

1. Confirmed local Apple toolchain state:
   - `xcodebuild -version` -> `Xcode 26.3`
   - `xcrun --sdk iphoneos --show-sdk-path` -> `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.2.sdk`
   - `security find-identity -v -p codesigning` -> two valid Apple Development identities were available locally
2. Confirmed device visibility:
   - `xcrun xctrace list devices` showed `iPhone Air (26.3.1)` as available and paired
   - `xcrun devicectl list devices` showed `iPad Egor Merkushev` in `unavailable` state
3. Installed matching Godot export templates locally:
   - Downloaded `Godot_v4.6.1-stable_export_templates.tpz`
   - Installed extracted template files under `~/Library/Application Support/Godot/export_templates/4.6.1.stable/`
4. Verified Godot export:
   - `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug "iOS" /tmp/ToysSandbox-ios`
   - Result: **PASS**, generated `/tmp/ToysSandbox-ios.xcodeproj`, `/tmp/ToysSandbox-ios`, and `/tmp/ToysSandbox-ios.xcframework`
5. Verified generated Info.plist quality:
   - Confirmed `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, and `NSPhotoLibraryUsageDescription` are now non-empty in `/tmp/ToysSandbox-ios/ToysSandbox-ios-Info.plist`
6. Verified Xcode build:
   - `xcodebuild -project /tmp/ToysSandbox-ios.xcodeproj -scheme ToysSandbox-ios -configuration Debug -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build`
   - Result: `** BUILD SUCCEEDED **`
7. Ran configured Flow quality gates:
   - `bash scripts/ci/flow_validate.sh tests` -> **PASS**
   - `bash scripts/ci/flow_validate.sh lint` -> **PASS**

## Acceptance Criteria Mapping

- **`export_presets.cfg` contains a working iOS preset with required application metadata placeholders** -> Implemented with a versioned `iOS` preset and placeholder Team ID / bundle identifier fields.
- **Build/signing prerequisites (Xcode, Team ID, bundle identifier, provisioning) are documented for local setup** -> Implemented in `docs/ios-ipad-export-checklist.md`.
- **The project exports to an Xcode project and launches successfully on at least one physical iPad** -> Xcode project export is verified; physical iPad launch remains **unverified** because the available iPad is offline.
- **iOS/iPad deployment steps are documented as a reproducible checklist** -> Implemented in `docs/ios-ipad-export-checklist.md`.

## Remaining Blocker

- The physical iPad required by the workplan is currently unavailable:
  - `xcrun devicectl list devices` reports `iPad Egor Merkushev` as `unavailable`
  - Until the iPad is connected, trusted, and selected in Xcode, the final device-launch acceptance item cannot be closed

## Notes

- A paired physical iPhone is available locally, but this task’s acceptance specifically calls for iPad deployment evidence, so iPhone deployment was not used as a substitute.
- Godot CLI logs still include the pre-existing `Failed to bind socket. Error: 3.` and headless `ObjectDB instances leaked at exit` warnings during validation runs; neither blocked export or validation success in this task.
