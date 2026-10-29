#!/usr/bin/env bash
# Launch the three-device comparison; Python manages paths and resources.
set -euo pipefail
exec python3 "$(cd "$(dirname "$0")" && pwd)/ui_compare.py" "$@"
