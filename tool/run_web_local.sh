#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Create it with MISTRAL_API_KEY=..." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${MISTRAL_API_KEY:?MISTRAL_API_KEY is missing from .env}"

FLUTTER_ROOT="$PROJECT_ROOT/.tooling/flutter"
WEB_PORT="${WEB_PORT:-8080}"

exec env \
  PATH="$FLUTTER_ROOT/bin:$PATH" \
  "$FLUTTER_ROOT/bin/flutter" run \
  -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port "$WEB_PORT" \
  --dart-define="MISTRAL_API_KEY=$MISTRAL_API_KEY" \
  "$@"
