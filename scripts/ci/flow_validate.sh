#!/usr/bin/env bash
set -euo pipefail

mode="${1:-tests}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

print_usage() {
  cat <<'EOF'
Usage: bash scripts/ci/flow_validate.sh [tests|lint]

Modes:
  tests   Validate the curated baseline scene/script set.
  lint    Recursively validate all .gd and .tscn files under scenes/ and scripts/.
EOF
}

case "${mode}" in
  tests|lint)
    ;;
  *)
    echo "Unknown validation mode: ${mode}" >&2
    print_usage >&2
    exit 2
    ;;
esac

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

# Ensure imported resources (for textures/SVGs) exist in clean CI checkouts
# before loading scenes/scripts in validation mode.
"${godot_binary}" --headless --import --quit --path "${repo_root}"

exec "${godot_binary}" --headless --path "${repo_root}" res://scenes/ci/FlowValidation.tscn -- "${mode}"
