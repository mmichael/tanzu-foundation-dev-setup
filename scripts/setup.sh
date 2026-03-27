#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! cf target > /dev/null 2>&1; then
  echo "ERROR: Not logged in to CF. Run 'cf login' first."
  exit 1
fi

if [[ -z "${CF_ORG:-}" ]]; then
  read -rp "Enter org name: " CF_ORG
fi
export CF_ORG

if [[ -z "${CF_SPACE:-}" ]]; then
  read -rp "Enter space name: " CF_SPACE
fi
export CF_SPACE

if [[ -z "${APP_PREFIX:-}" ]]; then
  read -rp "Enter app prefix (optional, press Enter to skip): " APP_PREFIX
fi
export APP_PREFIX

export FAILED_BUILDPACKS_FILE="${TMPDIR:-/tmp}/tanzu-setup-failed-buildpacks"
: > "${FAILED_BUILDPACKS_FILE}"

echo "==> Cloning repositories..."
bash "${SCRIPT_DIR}/clone-repos.sh"

echo "==> Creating buildpacks..."
bash "${SCRIPT_DIR}/create-buildpacks.sh"

echo "==> Creating orgs and spaces..."
bash "${SCRIPT_DIR}/create-orgs-and-spaces.sh"

echo "==> Pushing apps..."
bash "${SCRIPT_DIR}/push-apps.sh"

echo "==> Setup complete."
