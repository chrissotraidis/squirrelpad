#!/usr/bin/env bash
set -euo pipefail
project=$(cd "$(dirname "$0")/.." && pwd)
exec python3 "$project/scripts/setup-source.py" "$@"
