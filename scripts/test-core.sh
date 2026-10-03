#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "$(uname -s)" == Darwin ]] || { echo "Run this on a Mac with Xcode." >&2; exit 1; }
xcrun swift test
