#!/usr/bin/env bash
set -euo pipefail

org_exists=$(cf curl "/v3/organizations?names=${CF_ORG}" | jq '.pagination.total_results // 0')
if [[ "${org_exists}" -gt 0 ]]; then
  echo "Org '${CF_ORG}' already exists, skipping."
else
  cf create-org "${CF_ORG}"
fi

cf target -o "${CF_ORG}"

ORG_GUID=$(cf org "${CF_ORG}" --guid)
space_exists=$(cf curl "/v3/spaces?names=${CF_SPACE}&organization_guids=${ORG_GUID}" | jq '.pagination.total_results // 0')
if [[ "${space_exists}" -gt 0 ]]; then
  echo "Space '${CF_SPACE}' already exists in org '${CF_ORG}', skipping."
else
  cf create-space "${CF_SPACE}"
fi
cf target -o "${CF_ORG}" -s "${CF_SPACE}"