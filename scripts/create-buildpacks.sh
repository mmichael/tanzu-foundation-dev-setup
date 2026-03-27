#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDPACK_DIR="${SCRIPT_DIR}/../buildpacks"

position=30

zip_files=()
while IFS= read -r line; do
  zip_files+=("$line")
done < <(printf '%s\n' "${BUILDPACK_DIR}"/*.zip | sort -r)

for zip_file in "${zip_files[@]}"; do
  name="$(basename "${zip_file}" .zip)"
  name="${name//-cached-cflinuxfs4/}"
  name="${name//./_}"

  existing=$(cf curl "/v3/buildpacks?names=${name}" | jq '.pagination.total_results // 0')
  if [[ "${existing}" -gt 0 ]]; then
    echo "Buildpack '${name}' already exists, skipping."
    continue
  fi

  cf create-buildpack "${name}" "${zip_file}" "${position}"
  cf update-buildpack "${name}" --assign-stack "cflinuxfs4"
  position=$((position + 1))
done