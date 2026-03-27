#!/usr/bin/env bash
set -euo pipefail

mode="${1:-tests}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

godot_binary="${GODOT_BIN:-}"
if [[ -z "${godot_binary}" ]]; then
  for candidate in godot godot4 /Applications/Godot.app/Contents/MacOS/Godot; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      godot_binary="$(command -v "${candidate}")"
      break
    fi
    if [[ -x "${candidate}" ]]; then
      godot_binary="${candidate}"
      break
    fi
  done
fi

if [[ -z "${godot_binary}" ]]; then
  echo "Godot editor binary not found. Set GODOT_BIN or install Godot 4 with a 'godot' executable in PATH." >&2
  exit 1
fi

cd "${repo_root}"
exec "${godot_binary}" --headless --path "${repo_root}" res://scenes/ci/FlowValidation.tscn -- "${mode}"
