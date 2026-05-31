#!/usr/bin/env bash
set -euo pipefail

echo "== Environment checks =="
for cmd in git gh jq curl; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd"
  else
    echo "MISSING: $cmd"
  fi
done

echo

echo "== GitHub auth status =="
if command -v gh >/dev/null 2>&1; then
  gh auth status -h github.com || true
else
  echo "gh is not installed"
fi

echo

echo "== Token mode check =="
if [[ -n "${GITHUB_TOKEN:-}" ]] || [[ -n "${GH_TOKEN:-}" ]]; then
  echo "Codespace token variables detected (GITHUB_TOKEN/GH_TOKEN)."
  echo "To force manual auth, run: env -u GITHUB_TOKEN -u GH_TOKEN gh auth login"
else
  echo "No injected GH token variables detected."
fi
