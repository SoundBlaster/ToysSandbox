# ToysSandbox Workplan

## Phase 1: Foundation

#### P1-T1: Scaffold Godot Project Shell ✅ Complete
- **Description:** Create the initial Godot 4 project, folder layout, and bootstrap scenes needed to move from planning docs into an executable sandbox prototype.
- **Priority:** P0
- **Dependencies:** None
- **Parallelizable:** no
- **Acceptance Criteria:**
  - `project.godot` exists and opens successfully in Godot 4
  - Repository has a clear runtime structure for scenes, scripts, assets, and audio
  - Main entry path supports a menu scene and a sandbox scene

#### P1-T2: Define Toy Data Model And Spawn Pipeline ✅ Complete
- **Description:** Establish reusable toy definitions, archetype presets, and a spawn path that can instantiate toys into the sandbox from one shared data source.
- **Priority:** P0
- **Dependencies:** P1-T1
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Toy definitions encode behavior archetype, scale presets, and reaction hooks
  - Sandbox can spawn at least one configured toy from data
  - Spawn flow works with both mouse and touch-oriented input events

#### P1-T3: Establish Asset Pipeline For Sprites, Icons, And Placeholder Audio ✅ Complete
- **Description:** Create a consistent import and naming pipeline for toy sprites, UI icons, backgrounds, VFX textures, and temporary sounds so the later art pass can swap files without changing gameplay code.
- **Priority:** P1
- **Dependencies:** P1-T1, P1-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Asset folders exist for toy icons, world sprites, UI, backgrounds, VFX, and audio
  - Each MVP toy has a placeholder `icon_texture` and `world_texture` mapped or stubbed in data
  - Core UI buttons and feedback states have placeholder art assets available
  - Import rules, naming conventions, and texture size expectations are documented

#### P1-T4: Add Godot Validation And Flow Quality Gates ✅ Complete
- **Description:** Replace placeholder Flow verification commands with a real local automation path that validates the Godot scaffold, asset imports, and future scene/script changes.
- **Priority:** P1
- **Dependencies:** P1-T1, P1-T3
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - The repo has a documented command or script for headless Godot validation
  - `.flow/params.yaml` no longer uses placeholder `verify.tests` and `verify.lint` commands
  - Validation prerequisites are documented for local and CI usage

## Phase 2: Core Sandbox

#### P2-T1: Build Sandbox Scene, Camera, Bounds, And Shelf UI ✅ Complete
- **Description:** Implement the playable sandbox view with a stable framing camera, floor and side bounds, and a minimal main menu flow that gets the player into play quickly.
- **Priority:** P0
- **Dependencies:** P1-T2
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Main menu has a visible Play action that opens the sandbox scene
  - Sandbox includes floor, side bounds, and non-blocking shelf UI
  - Shelf exposes the full planned toy catalog, even if some toys use temporary art

#### P2-T2: Wire Toy Presentation, Selection, And Spawn Preview ✅ Complete
- **Description:** Bind toy catalog entries to shelf icons and in-world visuals so the player can see the selected toy, preview spawn state, and fall back cleanly when final art is missing.
- **Priority:** P0
- **Dependencies:** P1-T3, P2-T1
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Shelf shows all toys with icon-first presentation and a readable selected state
  - Spawned toys use the correct placeholder or final world art for their catalog entry
  - Missing art falls back to a simple placeholder silhouette without breaking gameplay
  - Toy selection state is shared between shelf, spawn logic, and persistence hooks

#### P2-T3: Implement Core Interaction Verbs ✅ Complete
- **Description:** Add the core player actions for spawn, grab, duplicate, resize, and reset using one interaction model across desktop and touch devices.
- **Priority:** P0
- **Dependencies:** P2-T1
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Players can spawn and manipulate toys within two actions
  - Duplicate, resize, and reset operate on active toy instances without breaking state
  - Core interactions remain stable with at least 10 simultaneous objects during development

#### P2-T4: Add Environmental Tools And Feedback ✅ Complete
- **Description:** Introduce the fan and smash tools plus baseline sound, animation, and particle feedback so every interaction feels toy-like rather than purely physical.
- **Priority:** P1
- **Dependencies:** P2-T2, P2-T3
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Fan and smash tools trigger deterministic reactions by archetype
  - Each player action produces motion, sound, or visual feedback
  - Fragile and soft reactions are visibly distinct from rigid behavior

#### P2-T5: Fix Drag Inertia And Pointer Alignment Regression (macOS) ✅ Complete
- **Description:** Resolve unresolved drag-release physics issues observed on macOS trackpad where release inertia is inconsistent and dragged bodies can appear vertically offset/underlapping near the ground.
- **Priority:** P0
- **Dependencies:** P2-T3
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Drag release inertia is reproducible and consistent across repeated drags in one session on macOS
  - Released toys preserve expected throw momentum (not immediate stop + pure gravity fall)
  - Dragged toy center remains aligned with pointer/finger during drag
  - Dragged toy does not visually underlap floor/other toys due to incorrect Y/ordering during drag
  - Validation includes a short reproducible manual test protocol documented in the task report

#### P2-T6: Extract Interaction Controller From Sandbox Orchestration ✅ Complete
- **Description:** Reduce maintenance risk by moving pointer/drag/action orchestration out of `Sandbox.gd` into a dedicated interaction controller while preserving current behavior for spawn, drag, duplicate, resize, and reset verbs.
- **Priority:** P1
- **Dependencies:** P2-T3, P2-T5
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - `Sandbox.gd` no longer directly owns full drag lifecycle and verb dispatch logic
  - A dedicated script/module encapsulates interaction state transitions (pointer down/move/up, active toy selection, release behavior)
  - Existing interaction behavior remains functionally equivalent for mouse and touch input paths
  - Validation confirms no regression in drag, duplicate, resize, and reset interactions

#### P2-T7: Add Physics Materials For Elastic Collision Feedback ✅ Complete
- **Description:** Introduce per-archetype and world-boundary physics materials (bounce/friction) so fan-driven and throw-driven collisions feel toy-like, including visible rebound from floor/walls for bouncy toys.
- **Priority:** P1
- **Dependencies:** P2-T4
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Toys can be assigned collision materials by archetype without duplicating scene files per toy
  - Floor and wall colliders have explicit physics material settings (not engine defaults)
  - Bouncy toys (e.g., Ball) visibly rebound from floor/walls after fan or throw impact
  - Heavy/sticky toys remain comparatively less elastic than bouncy toys under the same test setup
  - Validation report documents before/after behavior and tuning values used

#### P2-T8: Draw Bodies Perimeter For Debug Build
- **Description:** Render toy collision/body perimeters only in debug builds to simplify interaction and physics troubleshooting without affecting release visuals.
- **Priority:** P2
- **Dependencies:** P2-T3
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Body perimeter overlays are visible in debug runs for spawned toy instances
  - Overlay rendering is disabled in non-debug/export gameplay builds
  - Overlay does not alter physics behavior, selection, or drag interactions
  - Visual style remains readable over existing toy sprites and fallback polygons

#### P2-T9: Select Spawned Toys By Clicking In-World Instances ✅ Complete
- **Description:** Allow players to select the active toy directly by clicking/tapping an already spawned toy in the sandbox world, with UI selection state synchronized to the shelf.
- **Priority:** P1
- **Dependencies:** P2-T2, P2-T6
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Clicking/tapping an existing spawned toy marks it as the active selection without spawning a new toy
  - The selected in-world toy is visually highlighted and receives tool actions (duplicate, resize, fan, smash) immediately
  - Shelf selection updates to the matching toy definition when an in-world instance is selected
  - Selection behavior remains consistent for both mouse and touch input paths

#### P2-T10: Add Top-Right Collapse/Expand Menu Button
- **Description:** Add a collapse/expand control on the menu panel’s top-right corner so players can quickly hide or restore the in-game menu while keeping sandbox interactions accessible.
- **Priority:** P2
- **Dependencies:** P2-T1, P3-T3
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - A clearly visible collapse/expand button exists at the menu panel’s top-right corner
  - Collapsing the menu reduces UI obstruction while preserving access to core sandbox interactions
  - Expanding restores the full menu state and controls without losing selection context
  - Behavior works consistently for mouse and touch input paths

#### P2-T11: Delete Toys With Double Click Or Double Tap
- **Description:** Let players remove an existing toy directly from the sandbox by double clicking or double tapping it, without affecting other toys or shelf selection flow.
- **Priority:** P3
- **Dependencies:** P2-T6, P2-T9
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Double clicking a spawned toy deletes that toy from the world immediately
  - Double tapping a spawned toy on touch input deletes that toy from the world immediately
  - Single click/tap behavior for selection and drag start remains unchanged
  - Deleting a toy this way does not break active selection state, sandbox stats, or subsequent spawn/interaction flow

## Phase 3: Toy Catalog

#### P3-T1: Ship The First Four Toy Archetypes With Final Silhouettes ✅ Complete
- **Description:** Implement Ball, Pillow, Brick, and Vase as the first complete set of readable behavior archetypes for playtesting, including final icon and in-world visual treatment.
- **Priority:** P1
- **Dependencies:** P2-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Each toy has a unique silhouette and reaction profile
  - Each toy has matching shelf icon art and world sprite art
  - At least two visible reactions exist per toy
  - Interactions among the first four toys stay readable and fun in short play sessions

#### P3-T2: Complete The Full Eight-Toy MVP Catalog And Remaining Asset Variants ✅ Complete
- **Description:** Add Balloon, Jelly Cube, Pot, and Sticky Block with tuned presets and complete their final visual variants so the MVP supports the full variety promised in the PRD.
- **Priority:** P1
- **Dependencies:** P3-T1, P2-T3
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - All eight MVP toys are available from the shelf
  - Light, deformable, metallic, and sticky behaviors are differentiated in play
  - Each toy has a consistent icon, world sprite, and broken-state or reaction visual where needed
  - Sandbox remains stable with mixed toy interactions at the target object count

#### P3-T3: Finalize Backgrounds, Effects, And UI Polish ✅ Complete
- **Description:** Tighten the non-toy visual layer with background art, particle textures, button states, and fragment visuals so the sandbox reads as one cohesive game rather than a collection of placeholders.
- **Priority:** P2
- **Dependencies:** P2-T4, P3-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Background, HUD, and tool visuals follow one consistent style
  - Fragment, crack, squash, and pop effects are visually distinct
  - Placeholder art is minimized or replaced on the main play path
  - Visual states remain readable at tablet scale and 128x128 icon size

## Phase 4: UX, Persistence, And Release Readiness

#### P4-T1: Add Onboarding, Settings, And Local Persistence ✅ Complete
- **Description:** Implement first-launch guidance plus settings for audio and tutorial reset, and persist the last selected toy and user preferences.
- **Priority:** P1
- **Dependencies:** P2-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - First launch teaches spawn, drag, and reset without heavy text
  - Settings include music volume, sound volume, and tutorial reset
  - Last selected toy and audio settings survive app restart

#### P4-T2: Performance Pass, Asset Cleanup, And Export Validation ✅ Complete
- **Description:** Tune the sandbox to meet the MVP object-count goals, remove unused placeholder assets, and verify export readiness for desktop and Android from one codebase.
- **Priority:** P1
- **Dependencies:** P3-T2, P3-T3, P4-T1
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Desktop build holds 60 FPS with 25 active objects on reference hardware
  - Android build holds 30 FPS with 25 active objects on target hardware class
  - Unused placeholder art and textures are removed or clearly marked for follow-up
  - Export checklist for Windows, macOS, Linux, and Android is documented and reproducible

#### P4-T3: Add iOS/iPad Export Pipeline And Device Validation ✅ Complete
- **Description:** Configure first-class iOS export support in Godot, integrate with Xcode signing, and validate reproducible deployment to a physical iPad without gameplay forks.
- **Priority:** P2
- **Dependencies:** P4-T2
- **Parallelizable:** no
- **Acceptance Criteria:**
  - `export_presets.cfg` contains a working iOS preset with required application metadata placeholders
  - Build/signing prerequisites (Xcode, Team ID, bundle identifier, provisioning) are documented for local setup
  - The project exports to an Xcode project and launches successfully on at least one physical iPad
  - iOS/iPad deployment steps are documented as a reproducible checklist

#### P4-T4: Add Toy Styles/Skins With Settings Selection ✅ Complete
- **Description:** Introduce configurable toy visual styles (skins) and let players choose the active skin set from Settings, with the selected skin applied in gameplay and persisted between sessions.
- **Priority:** P1
- **Dependencies:** P3-T2, P4-T1
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - The game includes at least two distinct skin/style variants for toy visuals
  - Settings UI exposes a clear skin selector that can be changed without restarting the app
  - Selecting a skin updates newly spawned toys and existing visible toy visuals consistently
  - The selected skin is persisted locally and restored on next launch
  - Missing skin assets fall back safely to default visuals without breaking spawn or interactions

#### P4-T5: Complete Real Hardware Export And Performance Validation
- **Description:** Finish the acceptance proof left open by `P4-T2` by installing the required export templates/toolchains, exporting the current project for desktop and Android, and recording measured FPS at the 25-toy object budget on real target environments.
- **Priority:** P1
- **Dependencies:** P4-T2
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Required Godot export templates are installed locally or in CI for the target desktop platforms
  - Android SDK/signing prerequisites are configured well enough to produce an installable APK
  - Desktop and Android validation captures measured FPS with `25` active toys using the sandbox stats panel
  - Export smoke-test outcomes and performance measurements are documented in an archived validation report

#### P4-T6: Complete Physical iPad Launch Validation For iOS Export
- **Description:** Finish the remaining acceptance proof from `P4-T3` by launching the exported iOS build on a connected physical iPad with local signing enabled and recording the exact deployment evidence.
- **Priority:** P2
- **Dependencies:** P4-T3
- **Parallelizable:** no
- **Acceptance Criteria:**
  - A physical iPad is connected, trusted, and selectable in Xcode during validation
  - The generated `ToysSandbox-ios.xcodeproj` is signed with local development credentials without committing secrets to the repo
  - The app installs and launches successfully on the physical iPad
  - The validation report records device model, iOS version, signing mode, and observed launch outcome

#### P4-T7: Fix iOS/iPadOS Single-Touch Double Spawn Regression **INPROGRESS**
- **Description:** Resolve the mobile input regression where one screen touch on empty sandbox space creates two toys instead of one on iOS/iPadOS, and harden the input path so a single physical interaction can only produce one spawn request.
- **Priority:** P1
- **Dependencies:** P2-T6, P4-T3
- **Parallelizable:** no
- **Acceptance Criteria:**
  - A single tap on empty sandbox space creates exactly one toy on physical iPhone/iPad hardware
  - Touch selection and drag of existing toys still work after the fix
  - Desktop mouse spawn behavior remains unchanged
  - Validation documents the exact event path before the fix and the guarded path after the fix
- **S.T.A.R. Cause Analysis:**
  - **Situation:** On iOS/iPadOS, tapping empty sandbox space can create two toys from one physical touch.
  - **Task:** Find why one tap turns into two spawn requests without regressing shared desktop/mobile interaction behavior.
  - **Action:** Trace the input flow through `Sandbox._unhandled_input()` into `SandboxInteractionController.handle_input()`. The current controller calls `_handle_pointer_pressed()` for both `InputEventScreenTouch` and `InputEventMouseButton`, and empty-space presses spawn immediately inside `_handle_pointer_pressed()`. Mobile deduplication currently relies on `_should_ignore_emulated_mouse()`, a time/distance heuristic that only works when the synthesized mouse event arrives close enough to a previously registered touch event.
  - **Result:** The most likely root cause is duplicate handling of the same physical tap through two event classes on iOS/iPadOS: the real touch event and an emulated left-mouse event. Because spawn happens on press and the suppression is heuristic rather than authoritative, one tap can produce two toy spawns.
