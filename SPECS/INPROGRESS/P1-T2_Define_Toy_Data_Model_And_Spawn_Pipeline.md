# P1-T2 — Define Toy Data Model And Spawn Pipeline

## Objective

Replace the placeholder toy list with a reusable toy definition model and wire the sandbox to spawn real toy instances from that shared catalog. The scope stays intentionally narrow: one runtime toy scene, one authoritative catalog structure, and one input path that works for both mouse and touch-style presses. This task should leave the project with a stable data contract that later shelf, interaction, and archetype tasks can extend without reworking scene ownership.

## Deliverables

- A shared toy catalog API that exposes complete toy definitions instead of only placeholder IDs.
- Defined archetype metadata and per-toy presets for at least the first four planned toys.
- A reusable toy runtime scene/script that can render simple placeholder visuals and respond to physics.
- Sandbox spawn logic that instantiates toys from the catalog into a dedicated play area.
- Input handling that accepts both mouse and touch-oriented screen press events for spawning.
- Documentation and validation artifacts that describe what was implemented and what remains deferred.

## Success Criteria

- Toy definitions encode stable fields for toy identity, display name, archetype, size preset, color, and reaction hooks.
- The sandbox can spawn at least one configured toy entirely from catalog data with no hardcoded toy-specific values in `Sandbox.gd`.
- Spawn behavior works when triggered by desktop mouse input and by `InputEventScreenTouch`.
- The implementation remains readable and small enough for later tasks to build shelf UI, manipulation verbs, and toy-specific reactions on top of it.

## Acceptance Tests

1. Inspect `ToyCatalog.gd` and confirm it exposes full definitions for Ball, Pillow, Brick, and Vase.
2. Inspect the sandbox scene/script and confirm toy instances are added under a dedicated runtime container rather than mixed into UI nodes.
3. Confirm spawn input uses an event path that accepts mouse clicks and touch presses.
4. Confirm a spawned toy reads its label, scale, and color from catalog data.
5. Run configured Flow quality gates from `.flow/params.yaml` and capture the outcomes in the validation report.

## Test-First Plan

Before editing runtime behavior, define the contracts that the implementation must satisfy:

- `ToyCatalog` must return immutable-looking dictionaries with consistent keys for every toy.
- `Sandbox` must resolve toy IDs through the catalog before spawning and reject unknown IDs safely.
- A single helper should normalize screen input from mouse and touch into one spawn request path.
- The toy runtime should render a visible placeholder shape and label so catalog data is obvious without final art assets.

Given the environment does not currently provide Godot editor automation, validation will be source-level and command-level first. Runtime scene loading in the editor remains a documented follow-up for a local machine with Godot installed.

## Execution Plan

### Phase 1 — Catalog Contract

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Define archetype defaults | Workplan + current placeholder catalog | Shared archetype metadata with reaction hooks and physics-friendly defaults | Review dictionary structure and field naming consistency |
| Define toy presets | MVP toy list | Four concrete toy definitions | Confirm each toy references one archetype and one scale preset |

### Phase 2 — Runtime Toy Scene

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Create toy instance script | Catalog contract | Runtime node that accepts a toy definition and configures its visuals | Inspect script for one setup path and no toy-specific branching |
| Create placeholder scene | Runtime requirements | A reusable scene for spawned toys | Confirm it includes collision, visible art placeholder, and text label |

### Phase 3 — Sandbox Spawn Flow

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Add spawn root and UI affordances | Existing sandbox shell | Dedicated container for spawned toys and simple status guidance | Inspect scene tree structure |
| Normalize input path | Mouse and touch input requirements | Unified spawn handling in `Sandbox.gd` | Confirm both event types call the same spawn helper |
| Spawn default toy from data | Catalog + runtime scene | First end-to-end spawn pipeline | Confirm no hardcoded per-toy render values in sandbox logic |

## Decisions And Constraints

- Keep toy definitions in plain dictionaries for now; introducing custom Resource classes would add editor and serialization complexity before the project needs it.
- Use simple shapes and labels for placeholder visuals so the task proves the data flow without blocking on art production.
- Limit the first spawn path to a default selected toy ID. The shelf picker belongs to `P2-T1`.
- Treat reaction hooks as named metadata only in this task; actual reaction behavior will land in later interaction and feedback tasks.

## Verification Steps

- Review `project.godot`, `ToyCatalog.gd`, and the sandbox/runtime scene files for naming and path consistency.
- Run `verify.tests` and `verify.lint` from `.flow/params.yaml`.
- Record the lack of Godot runtime automation as a validation limitation if no editor binary is available.

## Notes

- Future tasks should preserve the toy-definition contract unless a migration plan is documented.
- `P2-T1` should bind the catalog to a shelf UI instead of inventing a second toy source.
- `P2-T2` should reuse the spawned toy scene for manipulation verbs rather than replacing it.
