#!/usr/bin/env bash
#
# generate-hardware-config.sh
#
# Regenerates hosts/<host>/hardware.nix from the current machine using
# `nixos-generate-config`. Run this on the target machine BEFORE installing or
# rebuilding, because the committed hardware.nix is only a placeholder.
#
# Usage:
#   sudo ./generate-hardware-config.sh                 # host=default, root=/mnt (if mounted) else /
#   sudo ./generate-hardware-config.sh --host my-host
#   sudo ./generate-hardware-config.sh --root /        # already-installed system
#
set -euo pipefail

HOST="default"
ROOT=""
SUDO=""
if command -v sudo >/dev/null 2>&1 && [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  SUDO="sudo"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2;;
    --root) ROOT="$2"; shift 2;;
    -h|--help)
      echo "Usage: $0 [--host NAME] [--root PATH]"
      echo "  --host NAME   host directory under hosts/ (default: default)"
      echo "  --root PATH   target system root to scan (default: /mnt if mounted, else /)"
      exit 0;;
    *) echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

# Auto-detect root: prefer /mnt when it is a real mountpoint (installer case)
if [[ -z "$ROOT" ]]; then
  if mountpoint -q /mnt 2>/dev/null; then
    ROOT="/mnt"
  else
    ROOT="/"
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_DIR="$SCRIPT_DIR/hosts/$HOST"
OUT="$HOST_DIR/hardware.nix"

if [[ ! -d "$HOST_DIR" ]]; then
  echo "Error: host directory '$HOST_DIR' does not exist." >&2
  echo "Available hosts:" >&2
  ls -1 "$SCRIPT_DIR/hosts" >&2
  exit 1
fi

echo ">> Regenerating hardware config"
echo "   host : $HOST"
echo "   root : $ROOT"
echo "   out  : $OUT"

$SUDO nixos-generate-config --root "$ROOT" --show-hardware-config > "$OUT"

echo ">> Wrote $OUT"
echo ">> Review it, then install/rebuild, e.g.:"
echo "   sudo nixos-install --flake $SCRIPT_DIR#$HOST"
echo "   # or, on an already-installed system:"
echo "   sudo nixos-rebuild switch --flake $SCRIPT_DIR#$HOST"
