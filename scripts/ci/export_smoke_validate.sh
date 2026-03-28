#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

find_godot_binary() {
  local godot_binary="${GODOT_BIN:-}"
  if [[ -n "${godot_binary}" ]]; then
    printf '%s\n' "${godot_binary}"
    return 0
  fi

  for candidate in godot godot4 /Applications/Godot.app/Contents/MacOS/Godot; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      command -v "${candidate}"
      return 0
    fi
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

resolve_output_path() {
  case "${1}" in
    "Windows Desktop") printf '%s\n' "${repo_root}/build/windows/ToysSandbox.exe" ;;
    "macOS") printf '%s\n' "${repo_root}/build/macos/ToysSandbox.zip" ;;
    "Linux/X11") printf '%s\n' "${repo_root}/build/linux/ToysSandbox.x86_64" ;;
    "Android") printf '%s\n' "${repo_root}/build/android/ToysSandbox.apk" ;;
    *) return 1 ;;
  esac
}

p1="${1:-macOS}"
p2="${2:-Android}"
presets=("${p1}" "${p2}")

if [[ "${p1}" == "--all" ]]; then
  presets=("Windows Desktop" "macOS" "Linux/X11" "Android")
fi

godot_binary="$(find_godot_binary || true)"
if [[ -z "${godot_binary}" ]]; then
  echo "ERROR: Godot editor binary not found. Set GODOT_BIN or install Godot 4." >&2
  exit 1
fi

cd "${repo_root}"

echo "Using Godot binary: ${godot_binary}"
echo "Running resource import pass..."
"${godot_binary}" --headless --import --quit --path "${repo_root}" >/dev/null

overall=0
for preset in "${presets[@]}"; do
  if [[ -z "${preset}" ]]; then
    continue
  fi

  if ! rg -q "name=\"${preset}\"" export_presets.cfg; then
    echo "RESULT preset=${preset} status=FAIL reason=preset-not-found"
    overall=1
    continue
  fi

  output_path="$(resolve_output_path "${preset}" || true)"
  if [[ -z "${output_path}" ]]; then
    echo "RESULT preset=${preset} status=FAIL reason=output-path-not-configured"
    overall=1
    continue
  fi

  mkdir -p "$(dirname "${output_path}")"
  rm -f "${output_path}"

  if "${godot_binary}" --headless --path "${repo_root}" --export-debug "${preset}" "${output_path}" >/tmp/toyssandbox-export-${preset//[^a-zA-Z0-9]/_}.log 2>&1; then
    if [[ -e "${output_path}" ]]; then
      echo "RESULT preset=${preset} status=PASS output=${output_path}"
    else
      echo "RESULT preset=${preset} status=FAIL reason=missing-export-output output=${output_path}"
      overall=1
    fi
  else
    echo "RESULT preset=${preset} status=FAIL reason=export-command-failed log=/tmp/toyssandbox-export-${preset//[^a-zA-Z0-9]/_}.log"
    overall=1
  fi
done

exit "${overall}"
