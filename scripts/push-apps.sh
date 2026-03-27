#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATS_DIR="${SCRIPT_DIR}/../repos/cf-acceptance-tests"

if [ ! -d "${CATS_DIR}" ]; then
  echo "ERROR: cf-acceptance-tests not found at ${CATS_DIR}. Run clone-repos.sh first."
  exit 1
fi

cd "${CATS_DIR}"

FAILED_BUILDPACKS_FILE="${FAILED_BUILDPACKS_FILE:-/tmp/tanzu-setup-failed-buildpacks}"

buildpack_failed() {
  local bp="$1"
  [[ -f "${FAILED_BUILDPACKS_FILE}" ]] && grep -qxF "${bp}" "${FAILED_BUILDPACKS_FILE}"
}

push_app_if_not_exists() {
  local app_name="$1"
  shift

  local arg bp_name=""
  for arg in "$@"; do
    if [[ "${prev_arg:-}" == "-b" ]]; then
      bp_name="${arg}"
      break
    fi
    prev_arg="${arg}"
  done
  unset prev_arg

  if [[ -n "${bp_name}" ]] && buildpack_failed "${bp_name}"; then
    echo "Skipping '${app_name}': buildpack '${bp_name}' failed to install."
    return
  fi

  local existing
  existing=$(cf curl "/v3/apps?names=${app_name}" | jq '.pagination.total_results // 0')
  if [[ "${existing}" -gt 0 ]]; then
    echo "App '${app_name}' already exists, skipping."
    return
  fi
  echo "Pushing ${app_name}..."
  if ! cf push "${app_name}" "$@"; then
    echo "WARNING: Failed to push '${app_name}', continuing."
  fi
}

P="${APP_PREFIX:+${APP_PREFIX}-}"

echo "Pushing go apps..."
push_app_if_not_exists "${P}go-app"          -f assets/golang/manifest.yml -p assets/golang -m 0.25G
push_app_if_not_exists "${P}go-app-v1_10_64" -f assets/golang/manifest.yml -p assets/golang -m 0.25G -b go_buildpack_v1_10_64

echo "Pushing java spring apps..."
push_app_if_not_exists "${P}java-spring-app"          -f assets/java-spring/manifest.yml
push_app_if_not_exists "${P}java-spring-app-v4_81_0"  -f assets/java-spring/manifest.yml -b java_buildpack_offline_v4_81_0

echo "Pushing ruby apps..."
push_app_if_not_exists "${P}ruby-app" -p assets/ruby_simple -m 0.25G

echo "Pushing node apps..."
push_app_if_not_exists "${P}node-app" -p assets/node -m 0.25G
push_app_if_not_exists "${P}node-app-v1_8_65" -p assets/node -m 0.25G -b nodejs_buildpack_v1_8_65

echo "Pushing nginx apps..."
push_app_if_not_exists "${P}nginx-app" -p assets/nginx -m 0.25G

echo "Pushing python apps..."
push_app_if_not_exists "${P}python-app" -p assets/python -m 0.25G

echo "Pushing php apps..."
push_app_if_not_exists "${P}php-app" -p assets/php -m 0.25G

echo "Pushing r apps..."
push_app_if_not_exists "${P}r-app" -p assets/r -m 0.25G
