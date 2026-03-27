#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! cf target > /dev/null 2>&1; then
  echo "ERROR: Not logged in to CF. Run 'cf login' first."
  exit 1
fi

if [[ -z "${ORG_PREFIX:-}" ]]; then
  read -rp "Enter org prefix: " ORG_PREFIX
fi
export ORG_PREFIX

if [[ -z "${APP_PREFIX:-}" ]]; then
  read -rp "Enter app prefix: " APP_PREFIX
fi
export APP_PREFIX

echo "==> Cloning repositories..."
bash "${SCRIPT_DIR}/clone-repos.sh"

echo "==> Creating buildpacks..."
bash "${SCRIPT_DIR}/create-buildpacks.sh"

echo "==> Creating orgs and spaces..."
bash "${SCRIPT_DIR}/create-orgs-and-spaces.sh"

echo "==> Pushing apps..."
bash "${SCRIPT_DIR}/push-apps.sh"

echo "==> Setup complete."
