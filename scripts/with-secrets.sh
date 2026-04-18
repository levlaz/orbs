#!/usr/bin/env bash
# Run any command with CIRCLE_TOKEN / GITHUB_TOKEN injected from 1Password.
#
# Usage:
#   ./scripts/with-secrets.sh circleci orb publish ...
#   ./scripts/with-secrets.sh bash       # drop into a shell with secrets set
#
# References live in .env.1password at the repo root. Requires `op` signed
# in with access to the `devops` vault.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env.1password"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: $ENV_FILE not found." >&2
    exit 1
fi

if ! command -v op >/dev/null 2>&1; then
    echo "Error: 1Password CLI (\`op\`) not installed." >&2
    echo "Install: https://developer.1password.com/docs/cli/get-started/" >&2
    exit 1
fi

exec op run --env-file="$ENV_FILE" -- "$@"
