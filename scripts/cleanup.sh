#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDPACK_DIR="${SCRIPT_DIR}/../buildpacks"

cf delete-org "${CF_ORG}" -f

for zip_file in "${BUILDPACK_DIR}"/*.zip; do
  name="$(basename "${zip_file}" .zip)"
  name="${name//-cached-cflinuxfs4/}"
  name="${name//./_}"
  cf delete-buildpack "${name}" -f
done
