# ToysSandbox Workplan

## Phase 1: Foundation

#### P1-T1: Scaffold Godot Project Shell **INPROGRESS**
- **Description:** Create the initial Godot 4 project, folder layout, and bootstrap scenes needed to move from planning docs into an executable sandbox prototype.
- **Priority:** P0
- **Dependencies:** None
- **Parallelizable:** no
- **Acceptance Criteria:**
  - `project.godot` exists and opens successfully in Godot 4
  - Repository has a clear runtime structure for scenes, scripts, assets, and audio
  - Main entry path supports a menu scene and a sandbox scene

#### P1-T2: Define Toy Data Model And Spawn Pipeline
- **Description:** Establish reusable toy definitions, archetype presets, and a spawn path that can instantiate toys into the sandbox from one shared data source.
- **Priority:** P0
- **Dependencies:** P1-T1
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Toy definitions encode behavior archetype, scale presets, and reaction hooks
  - Sandbox can spawn at least one configured toy from data
  - Spawn flow works with both mouse and touch-oriented input events

## Phase 2: Core Sandbox

#### P2-T1: Build Sandbox Scene And Toy Shelf UI
- **Description:** Implement the playable sandbox view with bounds, shelf UI, and a minimal main menu flow that gets the player into play quickly.
- **Priority:** P0
- **Dependencies:** P1-T2
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Main menu has a visible Play action that opens the sandbox scene
  - Sandbox includes floor, side bounds, and non-blocking shelf UI
  - Shelf exposes the full planned toy catalog, even if some toys use temporary art

#### P2-T2: Implement Core Interaction Verbs
- **Description:** Add the core player actions for spawn, grab, duplicate, resize, and reset using one interaction model across desktop and touch devices.
- **Priority:** P0
- **Dependencies:** P2-T1
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Players can spawn and manipulate toys within two actions
  - Duplicate, resize, and reset operate on active toy instances without breaking state
  - Core interactions remain stable with at least 10 simultaneous objects during development

#### P2-T3: Add Environmental Tools And Feedback
- **Description:** Introduce the fan and smash tools plus baseline sound, animation, and particle feedback so every interaction feels toy-like rather than purely physical.
- **Priority:** P1
- **Dependencies:** P2-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Fan and smash tools trigger deterministic reactions by archetype
  - Each player action produces motion, sound, or visual feedback
  - Fragile and soft reactions are visibly distinct from rigid behavior

## Phase 3: Toy Catalog

#### P3-T1: Ship The First Four Toy Archetypes
- **Description:** Implement Ball, Pillow, Brick, and Vase as the first complete set of readable behavior archetypes for playtesting.
- **Priority:** P1
- **Dependencies:** P2-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - Each toy has a unique silhouette and reaction profile
  - At least two visible reactions exist per toy
  - Interactions among the first four toys stay readable and fun in short play sessions

#### P3-T2: Complete The Full Eight-Toy MVP Catalog
- **Description:** Add Balloon, Jelly Cube, Pot, and Sticky Block with tuned presets so the MVP supports the full variety promised in the PRD.
- **Priority:** P1
- **Dependencies:** P3-T1, P2-T3
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - All eight MVP toys are available from the shelf
  - Light, deformable, metallic, and sticky behaviors are differentiated in play
  - Sandbox remains stable with mixed toy interactions at the target object count

## Phase 4: UX, Persistence, And Release Readiness

#### P4-T1: Add Onboarding, Settings, And Local Persistence
- **Description:** Implement first-launch guidance plus settings for audio and tutorial reset, and persist the last selected toy and user preferences.
- **Priority:** P1
- **Dependencies:** P2-T2
- **Parallelizable:** yes
- **Acceptance Criteria:**
  - First launch teaches spawn, drag, and reset without heavy text
  - Settings include music volume, sound volume, and tutorial reset
  - Last selected toy and audio settings survive app restart

#### P4-T2: Performance Pass And Export Validation
- **Description:** Tune the sandbox to meet the MVP object-count goals and verify export readiness for desktop and Android from one codebase.
- **Priority:** P1
- **Dependencies:** P3-T2, P4-T1
- **Parallelizable:** no
- **Acceptance Criteria:**
  - Desktop build holds 60 FPS with 25 active objects on reference hardware
  - Android build holds 30 FPS with 25 active objects on target hardware class
  - Export checklist for Windows, macOS, Linux, and Android is documented and reproducible
