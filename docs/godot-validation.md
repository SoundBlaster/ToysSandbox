# Godot Validation

This project uses a small repo-local validation harness so Flow can run Godot checks in headless mode through `scenes/ci/FlowValidation.tscn`.

## Commands

- Tests: `bash scripts/ci/flow_validate.sh tests`
- Lint: `bash scripts/ci/flow_validate.sh lint`

Any mode other than `tests` or `lint` exits non-zero and prints a short usage message.

## Prerequisites

- Godot 4 editor binary available as `godot`, `godot4`, or through `GODOT_BIN`
- Bash available in the local shell or CI runner
- Project run from the repository root so `project.godot` is discoverable

## Local Usage

On macOS, you can point `GODOT_BIN` at the app bundle binary if Godot is not already on `PATH`:

```bash
export GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot
bash scripts/ci/flow_validate.sh tests
bash scripts/ci/flow_validate.sh lint
```

## CI Usage

Use the same commands in CI after installing Godot 4 and exposing the editor binary on `PATH` or through `GODOT_BIN`.

```bash
bash scripts/ci/flow_validate.sh tests
bash scripts/ci/flow_validate.sh lint
```

The `tests` mode validates the current runtime scenes and autoload scripts. The `lint` mode recursively loads `.gd` and `.tscn` files under `scripts/` and `scenes/` so parse or resource issues fail fast.
