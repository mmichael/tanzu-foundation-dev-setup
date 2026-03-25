#!/usr/bin/env bash
set -euo pipefail

cf create-org "${ORG_PREFIX}-org"
cf target -o "${ORG_PREFIX}-org"
cf create-space space-1

cf target -o "${ORG_PREFIX}-org" -s space-1
