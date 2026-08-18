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
ANDROID_SDK_ROOT="$PROJECT_ROOT/.tooling/android-sdk"

exec env \
  PATH="$FLUTTER_ROOT/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH" \
  ANDROID_HOME="$ANDROID_SDK_ROOT" \
  ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/28.2.13676358" \
  "$FLUTTER_ROOT/bin/flutter" run \
  -d emulator-5554 \
  --dart-define="MISTRAL_API_KEY=$MISTRAL_API_KEY" \
  "$@"
