# P1-T1 — Scaffold Godot Project Shell

## Objective

Create the first runnable Godot 4 project shell for ToysSandbox so the repository moves from product-only documentation into an executable prototype base. The scope is intentionally narrow: establish the project file, core directory layout, autoload stubs, and the initial boot-to-menu-to-sandbox scene flow without attempting gameplay systems that belong to later tasks.

## Deliverables

- A valid `project.godot` configured for a Godot 4 project.
- A repository layout for scenes, scripts, assets, and audio placeholders.
- Minimal autoload singleton scripts for future session, catalog, save, and audio logic.
- A boot scene that routes into a main menu.
- A main menu scene that can open a sandbox scene.
- A sandbox scene shell with floor, walls, and a placeholder label confirming the runtime path works.

## Success Criteria

- The repository contains the scaffold files expected by the PRD architecture.
- The scene tree supports the flow `Boot -> MainMenu -> Sandbox`.
- Scripts are small, readable, and aligned with later tasks for toy data and interaction systems.
- Validation captures both what was verified and what remains unverified because Godot is not installed in this environment.

## Acceptance Tests

1. Confirm the expected files and folders exist in the repo.
2. Review the scene files to ensure the startup path points to `Boot.tscn`.
3. Review autoload entries in `project.godot` for `GameState`, `ToyCatalog`, `SaveService`, and `AudioService`.
4. If `godot` is available, open the project headlessly and confirm no parse errors.
5. If `godot` is unavailable, record the limitation in the validation report and still verify file-level consistency.

## Test-First Plan

Before implementation, define what "working" means in terms of structure and routing:

- The project must have a startup scene and named autoloads.
- The menu must expose a Play action that transitions to the sandbox scene.
- The sandbox shell must include physical boundaries for future toys.

Given the environment does not provide Godot, the first executable checks will be file- and config-based rather than runtime-based. Runtime validation becomes an explicit follow-up for a machine with Godot installed.

## Execution Plan

### Phase 1 — Project Skeleton

- Create `project.godot` and a lightweight `icon.svg`.
- Create the top-level directories for `scenes/`, `scripts/`, `assets/`, and `audio/`.
- Add placeholder `.gdkeep` files where empty directories are useful to keep tracked.

### Phase 2 — Autoloads And Scene Flow

- Add `GameState.gd`, `ToyCatalog.gd`, `SaveService.gd`, and `AudioService.gd`.
- Create `Boot.gd` and `Boot.tscn` to route into the main menu after startup initialization.
- Create `MainMenu.gd` and `MainMenu.tscn` with a Play button and Quit button.

### Phase 3 — Sandbox Shell

- Create `Sandbox.gd` and `Sandbox.tscn`.
- Add floor and wall nodes for future physics objects.
- Add minimal placeholder UI text so scene intent is obvious when opened.

## Decisions And Constraints

- Use GDScript for the initial shell because the repo PRD already assumes a Godot-first implementation.
- Keep scene files minimal and avoid premature systems such as toy runtime logic, persistence implementation, or toolbar interactions.
- Favor explicit node names and plain scripts over abstractions because this task is scaffolding, not architecture completion.

## Verification Steps

- Inspect `project.godot` for startup scene and autoload correctness.
- Inspect each scene and script path for naming consistency.
- Run configured Flow quality gates from `.flow/params.yaml`.
- Record the lack of local Godot tooling as a validation gap if runtime checks cannot be executed.

## Notes

- Update `.flow/params.yaml` with `structure.*` once the scaffold lands.
- Future tasks should add a real task runner and quality gates so Flow no longer uses placeholder `verify.*` commands.
- `P1-T2` should build directly on this scaffold rather than reshaping folder names again.
