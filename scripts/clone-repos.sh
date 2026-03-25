#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"

mkdir -p "${REPOS_DIR}"

CF_ACCEPTANCE_TESTS_DIR="${REPOS_DIR}/cf-acceptance-tests"

if [ ! -d "${CF_ACCEPTANCE_TESTS_DIR}" ]; then
  echo "Cloning cf-acceptance-tests into ${CF_ACCEPTANCE_TESTS_DIR}..."
  git clone https://github.com/cloudfoundry/cf-acceptance-tests "${CF_ACCEPTANCE_TESTS_DIR}"
else
  echo "cf-acceptance-tests already exists at ${CF_ACCEPTANCE_TESTS_DIR}, skipping clone."
fi
