#!/usr/bin/env bash
# Pull the latest templates from git, then install one (random by default).
# Usage: bash update.sh [template-name]
set -euo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
echo "updating from git..."
git -C "$DIR" pull --ff-only
exec bash "$DIR/deploy.sh" "$@"
