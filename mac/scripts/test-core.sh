#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcrun swift test
