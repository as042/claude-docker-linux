#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Write .env file from environment (preserve existing values as fallback)
EXISTING_GH_TOKEN=$(grep -s '^GH_TOKEN=' "$SCRIPT_DIR/.env" | cut -d= -f2-)
cat > "$SCRIPT_DIR/.env" <<EOF
GALAXY_URL=${GALAXY_URL:-}
GALAXY_API_KEY=${GALAXY_API_KEY:-}
GH_TOKEN=${GH_TOKEN:-$EXISTING_GH_TOKEN}
EOF

# Run claude container
cd "$SCRIPT_DIR"
if [[ "$1" == "--service-ports" ]]; then
    shift
    docker compose run --rm --service-ports claude "$@"
else
    docker compose run --rm claude "$@"
fi
