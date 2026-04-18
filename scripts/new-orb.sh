#!/usr/bin/env bash
# Scaffold a new orb by copying the `hello` template and renaming it.
# Usage: ./scripts/new-orb.sh <orb-name>
#
# After running this, you still need to:
#   1. Edit orbs/<name>/src/@orb.yml, README.md, and example with real docs.
#   2. Add a `run-<name>` mapping line in .circleci/config.yml.
#   3. Add a `run-<name>` parameter and workflow block in
#      .circleci/continue-config.yml (copy the `hello` block).
#   4. On CircleCI, claim the slug:  circleci orb create <namespace>/<name>

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <orb-name>" >&2
    exit 1
fi

NAME=$1

if ! [[ "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: orb name must be lowercase letters, digits, and hyphens, starting with a letter." >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/orbs/hello"
DEST="$REPO_ROOT/orbs/$NAME"

if [[ -e "$DEST" ]]; then
    echo "Error: $DEST already exists." >&2
    exit 1
fi

cp -r "$SRC" "$DEST"

# Replace every literal reference to "hello" in the template with the new
# orb name. Only touching text files under the new orb's directory.
find "$DEST" -type f \( -name '*.yml' -o -name '*.md' -o -name '*.sh' \) -print0 \
    | xargs -0 sed -i "s/hello/$NAME/g"

echo "Created orbs/$NAME/ from the hello template."
echo
echo "Next steps:"
echo "  1. Edit orbs/$NAME/src/@orb.yml and orbs/$NAME/README.md."
echo "  2. Add to .circleci/config.yml mapping:"
echo "       orbs/$NAME/.* run-$NAME true"
echo "  3. Add to .circleci/continue-config.yml:"
echo "       - a run-$NAME boolean parameter (default false)"
echo "       - a workflow block (copy the \`hello\` one, s/hello/$NAME/g)"
echo "  4. Claim the orb on CircleCI:"
echo "       circleci orb create <namespace>/$NAME"
