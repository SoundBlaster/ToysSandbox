# ToysSandbox MVP PRD

## Document Control

| Field | Value |
| --- | --- |
| Document type | Product Requirements Document |
| Product name | ToysSandbox |
| Version | 0.1 |
| Status | Draft for implementation |
| Engine | Godot 4.x |
| Scope | MVP without AI, camera import, or online services |
| Primary audience | Children ages 3-9 with parent-assisted onboarding |
| Secondary audience | Parents evaluating short-session creative play |

## 1. Objective

Build a cross-platform 2D physics toybox in `Godot 4` where players spawn curated toy objects into a sandbox and experiment with simple, expressive interactions. The MVP must validate whether the sandbox itself is fun before any AI-driven photo import is added.

### 1.1 Product Intent

The MVP is not a construction game, level-based puzzle game, or realistic physics simulator. It is a short-session playful sandbox where each object has a clear personality and produces satisfying reactions when dropped, thrown, duplicated, resized, popped, smashed, or pushed by environmental tools.

### 1.2 Primary Deliverables

1. A playable Godot project containing one sandbox scene and one simple menu flow.
2. A catalog of `8` handcrafted toy objects with distinct behavior archetypes.
3. A minimal interaction toolset that supports immediate experimentation.
4. Local save for player settings and unlocked session state if needed.
5. Export-ready builds for desktop and Android tablet/phone.

### 1.3 Success Criteria

1. A first-time player can spawn and manipulate a toy within `10` seconds from launch.
2. Each of the `8` toys is behaviorally distinguishable within `3` minutes of play.
3. The sandbox remains stable at `60 FPS` on desktop reference hardware and `30 FPS` on a mid-range Android tablet with `25` active objects.
4. A `10` minute session contains enough combinational play that the player can meaningfully ask "what happens if I combine these?"
5. The MVP can be exported from one Godot codebase to `Windows/macOS/Linux` and `Android` without platform-specific gameplay forks.

## 2. Constraints, Assumptions, and Dependencies

### 2.1 Constraints

1. Engine must be `Godot 4.x`.
2. MVP must exclude AI, camera import, segmentation, procedural stylization, online accounts, ads, and multiplayer.
3. Core gameplay must work with both `mouse` and `touch` input.
4. Physics must feel playful and readable, not physically accurate.
5. Implementation must prefer built-in Godot systems over native plugins.

### 2.2 Assumptions

1. The first commercial-quality validation build targets desktop and Android; iOS support is a post-MVP export task.
2. Art style is simple, colorful, and readable at tablet scale.
3. Sessions are short, typically `3-10` minutes.
4. Parent-free text reading should be minimal; icons and audio feedback carry most onboarding load.
5. Soft-body behavior will be faked with animation and preset reactions rather than real deformable simulation.

### 2.3 External Dependencies

| Dependency | Purpose | Required for MVP |
| --- | --- | --- |
| Godot 4 export templates | Cross-platform builds | Yes |
| 2D art assets | Toy sprites, UI icons, backgrounds | Yes |
| Audio assets | Impact, squeeze, bounce, pop, shatter sounds | Yes |
| Android signing setup | Device build and smoke testing | Yes |
| Crash reporting / analytics SDK | Telemetry | No |

## 3. MVP Definition

### 3.1 Core Loop

1. Player opens the game and enters the sandbox.
2. Player chooses a toy from the toy shelf.
3. Player places, drags, throws, duplicates, resizes, or destroys the toy.
4. Toy reacts with readable motion, sound, and a small visual effect.
5. Player combines several toys and environmental tools to discover outcomes.
6. Player resets or continues the sandbox session.

### 3.2 Non-Goals

1. No photo import.
2. No AI classification or generation.
3. No story campaign.
4. No progression economy.
5. No social sharing.
6. No user-generated asset pipeline.
7. No advanced level editor.

## 4. Target Platforms and Input Model

### 4.1 Platforms

| Platform | MVP Requirement | Notes |
| --- | --- | --- |
| Windows | Required | Keyboard optional, mouse primary |
| macOS | Required | Mouse/trackpad primary |
| Linux | Required | Best-effort support from same desktop build flow |
| Android | Required | Touch primary, tablet-first layout |
| iOS | Out of MVP scope | Architecture must not block future export |
| Web | Out of MVP scope | No requirement for MVP performance parity |

### 4.2 Input Model

1. Single-pointer input must support drag, release, tap, and hold.
2. Optional two-finger pinch-to-scale is not required for MVP; scaling may be button-driven.
3. Desktop and mobile input must call the same gameplay actions through a unified input adapter.

## 5. Feature Set

### 5.1 Sandbox Scene

The sandbox is a single side-view 2D play area with:

1. Static floor and side bounds.
2. A calm background with no gameplay effect.
3. A toy shelf UI anchored to screen edges.
4. A small set of tool buttons.
5. Simple particle and sound feedback.

### 5.2 Toy Catalog

The MVP toy set must contain the following items:

| Toy ID | Name | Archetype | Signature Reactions |
| --- | --- | --- | --- |
| TOY-001 | Ball | Bouncy | Rebounds, rolls, bonks |
| TOY-002 | Pillow | Soft | Squashes on impact, muffled landing |
| TOY-003 | Brick | Heavy Rigid | Falls fast, pushes others, hard impact |
| TOY-004 | Vase | Fragile | Cracks and shatters after threshold impact |
| TOY-005 | Balloon | Light | Floats slowly, reacts strongly to fan |
| TOY-006 | Jelly Cube | Deformable | Jiggles, partial bounce, wobble settle |
| TOY-007 | Pot | Noisy Metal | Spins, rings on impact, medium-heavy |
| TOY-008 | Sticky Block | Sticky | Adheres to surfaces or nearby toys for a limited count |

### 5.3 Player Tools

The MVP toolset must include:

1. `Spawn`: place selected toy into the sandbox.
2. `Grab`: drag existing toys with pointer input.
3. `Duplicate`: create a copy of the selected toy.
4. `Resize`: cycle toy scale across `small`, `normal`, `large`.
5. `Fan`: apply directional force to nearby light objects.
6. `Smash`: destroy fragile toys or force a reaction if supported.
7. `Reset`: clear the sandbox and return to initial state.

### 5.4 Immediate Feedback

Every player action must produce at least one of:

1. Motion response.
2. Impact or reaction sound.
3. Small visual effect.
4. State change such as crack, squash, or stick.

## 6. Functional Requirements

### 6.1 Core Gameplay Requirements

| ID | Requirement |
| --- | --- |
| FR-001 | The game must launch into a main menu with a visible `Play` button. |
| FR-002 | Selecting `Play` must open the sandbox scene in under `3` seconds on reference hardware. |
| FR-003 | The player must be able to spawn any toy from the shelf with at most `2` input actions. |
| FR-004 | Spawned toys must use predefined behavior presets rather than runtime-generated physics. |
| FR-005 | The player must be able to drag and release toys using the same interaction model on mouse and touch. |
| FR-006 | The player must be able to duplicate at least one selected toy instance. |
| FR-007 | The player must be able to resize a toy instance among exactly `3` preset sizes. |
| FR-008 | The sandbox must support at least `25` active toy instances before automatic cleanup or hard spawn refusal. |
| FR-009 | Fragile toys must visually and mechanically transition to a broken state after threshold impact or smash action. |
| FR-010 | Sticky toys must adhere to surfaces or toys using a deterministic preset rule. |
| FR-011 | Light toys must be more affected by fan force than heavy toys. |
| FR-012 | Reset must clear all active toys and restore the default empty sandbox in under `1` second. |
| FR-013 | Audio and haptic-equivalent feedback must be configurable from settings; haptics are optional and may map to vibration on Android only if implemented easily. |
| FR-014 | The last selected toy and user audio settings must persist across app restarts. |

### 6.2 UI Requirements

| ID | Requirement |
| --- | --- |
| UI-001 | The shelf must display all `8` toys with icon-first presentation. |
| UI-002 | Tool buttons must remain reachable in portrait-oriented tablet layouts without obscuring the sandbox center. |
| UI-003 | No gameplay-critical label may require reading more than two short words. |
| UI-004 | The first launch must include a lightweight onboarding overlay that demonstrates `spawn`, `drag`, and `reset`. |
| UI-005 | Settings must include `music volume`, `sound volume`, and `reset tutorial` at minimum. |

### 6.3 Content Requirements

| ID | Requirement |
| --- | --- |
| CT-001 | Each toy must have a unique silhouette readable at `128x128` icon size. |
| CT-002 | Each toy must have at least `1` unique sound family. |
| CT-003 | Each toy must expose at least `2` distinct reactions that are visible without reading text. |
| CT-004 | The visual style must remain consistent across all toys and UI elements. |

## 7. Non-Functional Requirements

### 7.1 Performance

| ID | Requirement |
| --- | --- |
| NFR-P-001 | Desktop builds must target `60 FPS` at `1920x1080` with `25` active objects. |
| NFR-P-002 | Android builds must target `30 FPS` at common tablet resolutions with `25` active objects. |
| NFR-P-003 | No object interaction may trigger a blocking allocation spike visible to the player. |
| NFR-P-004 | Particle and fragment counts must be capped per event type. |

### 7.2 Reliability

| ID | Requirement |
| --- | --- |
| NFR-R-001 | No physics object may permanently escape the sandbox play area. |
| NFR-R-002 | The game must recover cleanly from Android background/resume without resetting settings. |
| NFR-R-003 | Repeated reset actions must not leak nodes or duplicate persistent state. |

### 7.3 Accessibility and UX

| ID | Requirement |
| --- | --- |
| NFR-U-001 | Core interactions must be understandable without reading a long tutorial. |
| NFR-U-002 | Buttons must be touch-friendly and spaced for children. |
| NFR-U-003 | Audio feedback must not be the sole channel for understanding state changes. |

### 7.4 Security and Compliance

| ID | Requirement |
| --- | --- |
| NFR-S-001 | MVP must not collect personal data. |
| NFR-S-002 | MVP must not require network connectivity for gameplay. |
| NFR-S-003 | Saved data must remain local to the device. |

## 8. User Interaction Flows

### 8.1 Flow A: First Launch

1. Launch app.
2. Main menu appears with `Play` and `Settings`.
3. Player taps `Play`.
4. Sandbox opens with a short overlay:
   - `Pick a toy`
   - `Drag and drop it`
   - `Tap Reset to clear`
5. Overlay disappears after first successful spawn or manual close.

### 8.2 Flow B: Free Play Session

1. Player chooses a toy from the shelf.
2. Player taps or drags into sandbox to spawn.
3. Player grabs and throws the toy.
4. Player uses duplicate or resize.
5. Player adds a second toy and observes combined behavior.
6. Player uses fan or smash where relevant.
7. Player resets when the sandbox is cluttered.

### 8.3 Flow C: Resume Session

1. Player reopens app.
2. Audio settings and last-selected toy load from save.
3. Player starts a fresh sandbox; persisted world-state restoration is not required for MVP.

## 9. Edge Cases and Failure Scenarios

| Case ID | Scenario | Expected Behavior |
| --- | --- | --- |
| EC-001 | Player tries to spawn above the active object limit | Spawn is refused with a short visual nudge and soft warning sound |
| EC-002 | Toy is dragged outside bounds | Toy is clamped back into playable area or deleted if fully out of bounds |
| EC-003 | Multiple toys overlap at spawn | Spawn location is offset to nearest valid open position |
| EC-004 | Fragile toy receives repeated low impacts | Damage accumulates deterministically or resets; behavior must be documented and consistent |
| EC-005 | Sticky toy sticks to an already sticky chain | Maximum chain size or joint count is enforced |
| EC-006 | Android app is backgrounded during active physics motion | Simulation pauses and resumes without exploding velocities |
| EC-007 | Audio assets fail to load | Gameplay continues with silent fallback and logged error |
| EC-008 | Save file is missing or corrupted | Default settings are recreated without blocking launch |

## 10. Godot-Oriented Technical Architecture

### 10.1 Scene Structure

| Scene | Purpose |
| --- | --- |
| `scenes/boot/Boot.tscn` | Startup routing, settings load |
| `scenes/menu/MainMenu.tscn` | Main entry UI |
| `scenes/game/Sandbox.tscn` | Core sandbox world |
| `scenes/ui/ToyShelf.tscn` | Toy selection shelf |
| `scenes/ui/ToolBar.tscn` | Tool actions |
| `scenes/toys/ToyInstance.tscn` | Base reusable toy scene |
| `scenes/toys/fragments/FragmentPiece.tscn` | Broken toy fragment visual if needed |

### 10.2 Recommended Node Patterns

1. Use `RigidBody2D` for active toys.
2. Use `StaticBody2D` for floor and side walls.
3. Use `Area2D` for tool influence zones such as fan.
4. Use `AnimationPlayer` or tween-based squash/stretch for soft and deformable toys.
5. Use `CPUParticles2D` or capped `GPUParticles2D` for simple effects depending on platform tests.

### 10.3 Data Model

Use a data-driven toy definition via custom Godot `Resource` objects.

#### `ToyDefinition` fields

| Field | Type | Purpose |
| --- | --- | --- |
| `toy_id` | `StringName` | Stable identifier |
| `display_name` | `String` | UI label |
| `icon_texture` | `Texture2D` | Shelf icon |
| `world_texture` | `Texture2D` | Main sprite |
| `collision_shape_type` | enum | Circle, rectangle, polygon |
| `mass_class` | enum | Light, medium, heavy |
| `behavior_archetype` | enum | Bouncy, soft, fragile, sticky, etc. |
| `base_scale` | `float` | Default size |
| `allowed_scales` | `PackedFloat32Array` | Small, normal, large |
| `impact_sfx` | `Array[AudioStream]` | Sound set |
| `reaction_flags` | bitmask | Breakable, squashable, stickable, fan-reactive |
| `break_threshold` | `float` | Only for fragile toys |
| `max_sticky_links` | `int` | Only for sticky toys |

### 10.4 Autoload Singletons

| Singleton | Responsibility |
| --- | --- |
| `GameState` | Current session state, selected toy, tutorial state |
| `ToyCatalog` | Loads and exposes `ToyDefinition` resources |
| `SaveService` | Read/write local config and lightweight persistence |
| `AudioService` | Music and SFX routing |

### 10.5 Physics Strategy

1. Use preset masses, damping, bounce, and friction values by archetype.
2. Do not attempt continuous material simulation.
3. Implement fragile break as a threshold event that swaps the intact toy node for a broken variant or fragments.
4. Implement sticky behavior with a capped deterministic attach system, preferably `PinJoint2D` or a simpler stateful adhesion rule.
5. Implement soft and deformable feedback visually rather than through complex runtime collider deformation.

### 10.6 Save Strategy

Persist only:

1. Audio settings.
2. Tutorial dismissed state.
3. Last selected toy.

Do not persist:

1. Full sandbox world state.
2. Session replay data.
3. Analytics events.

## 11. Art, Audio, and UX Direction

### 11.1 Visual Direction

1. Use bright, friendly shapes with high silhouette readability.
2. Background must not compete with toys.
3. Effects should be legible and brief.
4. Break and squash states should exaggerate action for readability.

### 11.2 Audio Direction

1. Every archetype needs a recognizable sound profile.
2. Impacts should vary slightly to avoid repetition.
3. Menu and tool sounds must be soft and not overstimulating.

## 12. Execution Plan

The following TODO plan is implementation-ready and dependency-aware.

### 12.1 Phase Overview

| Phase | Goal | Dependency |
| --- | --- | --- |
| P0 | Project setup and architecture foundation | None |
| P1 | Core sandbox and input loop | P0 |
| P2 | Toy behaviors and tools | P1 |
| P3 | UI, onboarding, save, and polish | P1 and partial P2 |
| P4 | Export, QA, and acceptance validation | P2 and P3 |

### 12.2 Detailed TODO Breakdown

| Task ID | Phase | Task | Input | Process | Output | Priority | Effort | Dependencies | Parallel | Tools / Systems | Acceptance Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T-001 | P0 | Initialize Godot project structure | PRD | Create folder layout, project settings, input map, autoload stubs | Working project skeleton | High | S | None | No | Godot editor | Project opens with no missing singleton errors | Launch project and inspect output log |
| T-002 | P0 | Define toy data resources | Toy catalog requirements | Create `ToyDefinition` resource class and placeholder assets list | Resource schema and 8 data assets | High | S | T-001 | Yes | Godot Resource system | All 8 toys are representable through data only | Load catalog in debug and print IDs |
| T-003 | P0 | Establish visual and audio placeholders | Toy list, UI list | Import placeholder sprites, icons, and sound files | Temporary content pack | Medium | S | T-001 | Yes | Asset pipeline | Every toy and tool has a placeholder asset | Open shelf and trigger sounds |
| T-004 | P1 | Build sandbox scene shell | Scene structure | Create floor, walls, camera framing, background, root nodes | Playable empty sandbox | High | S | T-001 | No | `Sandbox.tscn` | Empty scene loads and simulates cleanly | Run scene and observe no physics errors |
| T-005 | P1 | Implement unified input adapter | Input requirements | Map mouse and touch to select, drag, release, tap | Shared interaction layer | High | M | T-001, T-004 | No | InputMap, custom scripts | Same actions work on desktop and touch device | Test with mouse and Android touch |
| T-006 | P1 | Implement spawn pipeline | Toy definitions, sandbox shell | Spawn selected toy at valid location with default preset | Toy instancing system | High | M | T-002, T-004, T-005 | No | `PackedScene`, `ToyCatalog` | Any toy spawns consistently and respects object cap | Spawn all toys and hit object limit test |
| T-007 | P2 | Implement base toy runtime | Toy definitions | Create `ToyInstance` script applying mass, collision, and default feedback from resource | Shared toy behavior base | High | M | T-002, T-006 | No | `RigidBody2D`, audio, particles | All toys use one reusable runtime path | Spawn each toy and inspect runtime values |
| T-008 | P2 | Implement bouncy, heavy, light archetypes | Base toy runtime | Tune ball, brick, balloon physics and feedback | 3 working toy archetypes | High | M | T-007 | Yes | Physics materials, forces | Behaviors are visibly distinct | Comparative playtest against checklist |
| T-009 | P2 | Implement soft and deformable archetypes | Base toy runtime | Add squash/stretch feedback for pillow and jelly cube | 2 working toy archetypes | High | M | T-007 | Yes | AnimationPlayer, tweens | Soft toys visually compress on impact | Impact tests with video capture |
| T-010 | P2 | Implement fragile archetype | Base toy runtime | Add damage tracking and break swap for vase | Breakable toy behavior | High | M | T-007 | Yes | State machine, fragment scene | Vase breaks deterministically after threshold | Repeat controlled drop tests |
| T-011 | P2 | Implement sticky archetype | Base toy runtime | Add capped adhesion logic for sticky block | Sticky toy behavior | High | M | T-007 | Yes | Joint or attach rules | Sticky object adheres predictably without chain instability | Automated spawn-and-stick test scene |
| T-012 | P2 | Implement metal/noisy archetype | Base toy runtime | Tune pot spin, impact sound variation | Pot behavior | Medium | S | T-007 | Yes | Audio variation, angular damping | Pot feels distinct from brick | Comparative playtest |
| T-013 | P2 | Implement player tools | Toolbar requirements | Add duplicate, resize, fan, smash, reset actions | Functional tool system | High | M | T-006, T-007 | No | UI, area forces, state actions | All tools work on supported toy types | Manual checklist pass |
| T-014 | P3 | Build main menu, shelf UI, and toolbar UI | Flow and UI requirements | Create menu and in-game UI, icon states, selected toy state | Functional UI flow | High | M | T-003, T-005, T-006 | No | Control nodes, themes | Player can start game and use all tools without hidden controls | UI smoke test on desktop and Android |
| T-015 | P3 | Implement onboarding overlay | Flow A | Add first-run prompt with dismiss and reset path | Tutorial overlay | Medium | S | T-014 | Yes | UI and save | First-time player receives 3-step instruction | Clear save and retest first launch |
| T-016 | P3 | Implement local save | Persistence requirements | Save audio settings, tutorial state, last selected toy | Config persistence | High | S | T-001, T-014 | Yes | `ConfigFile` or JSON | App restart restores required settings | Kill/relaunch test |
| T-017 | P3 | Add feedback polish | Toy and UI systems | Tune particles, camera shake-lite, sound mixing, transition timing | More satisfying feel | Medium | M | T-008 through T-016 | Yes | AudioService, particles | Every core interaction gives immediate feedback | Feel checklist review |
| T-018 | P4 | Profile performance and tune caps | Full game build | Measure frame time and reduce unstable effects or object counts | Stable performance profile | High | M | T-013, T-017 | No | Godot profiler, Android device | Meets FPS requirements at object cap | Recorded profiling session |
| T-019 | P4 | Configure exports and smoke test platforms | Working project | Set export presets for desktop and Android, sign Android build | Export-ready builds | High | S | T-014, T-016, T-018 | No | Export templates, Android SDK | Successful launch on required platforms | Build and run on each platform |
| T-020 | P4 | Run MVP acceptance checklist | Complete build | Execute requirement-based QA pass | Acceptance report | High | S | T-019 | No | Test checklist | All High-priority requirements pass or are waived explicitly | Signed checklist artifact |

Effort scale:

| Effort | Meaning |
| --- | --- |
| S | Up to 0.5 day |
| M | 0.5 to 1.5 days |
| L | 1.5 to 3 days |

## 13. Parallelization Guidance

The following tasks can be executed in parallel after dependencies are satisfied:

1. `T-002` and `T-003` after project initialization.
2. `T-008`, `T-009`, `T-010`, `T-011`, and `T-012` after the base toy runtime exists.
3. `T-015` and `T-016` after UI foundation exists.
4. `T-017` can begin once at least half of the toy and tool systems are stable.

Tasks that should remain serialized:

1. `T-005` before `T-006`.
2. `T-006` before `T-013`.
3. `T-018` before final export sign-off.

## 14. Acceptance Test Matrix

| Test ID | Requirement Coverage | Procedure | Pass Condition |
| --- | --- | --- | --- |
| AT-001 | FR-001, FR-002 | Launch app and enter sandbox | Menu appears and sandbox opens within target time |
| AT-002 | FR-003, FR-004, UI-001 | Spawn each toy from shelf | All 8 toys spawn with correct preset behavior |
| AT-003 | FR-005 | Drag and throw toys with mouse and touch | Input is consistent and responsive on both |
| AT-004 | FR-006, FR-007 | Duplicate and resize a selected toy | Copies appear correctly and sizes cycle exactly three states |
| AT-005 | FR-009 | Drop vase repeatedly from controlled heights | Vase breaks only when threshold is crossed |
| AT-006 | FR-010 | Stick sticky block to wall and another toy | Adhesion follows deterministic cap rules |
| AT-007 | FR-011 | Apply fan to balloon and brick | Balloon visibly responds more than brick |
| AT-008 | FR-012 | Populate sandbox, then tap reset | Scene clears quickly and returns to empty state |
| AT-009 | FR-014 | Change settings, restart app | Settings and last selected toy persist |
| AT-010 | NFR-P-001, NFR-P-002 | Spawn up to object cap and profile | FPS remains within target thresholds |

## 15. Post-MVP Expansion Path

These items are intentionally deferred but supported by the architecture:

1. Photo import of real objects.
2. Manual object cutout and stylization.
3. AI-assisted toy archetype assignment.
4. Toy album or collection view.
5. Lightweight mission prompts such as `spawn three soft things`.
6. Additional environmental tools and object combinations.

## 16. Final Implementation Guidance

1. Prioritize feel over feature count.
2. Prefer deterministic preset behaviors over dynamic simulation complexity.
3. Keep the codebase data-driven so new toys can be added without rewriting gameplay systems.
4. Validate fun with placeholder assets before polishing content.
5. Do not expand scope into AI, progression, or content pipelines until the sandbox loop is independently fun.
