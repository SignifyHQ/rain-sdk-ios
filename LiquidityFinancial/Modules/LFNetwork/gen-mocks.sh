#!/bin/bash
set -eu
cd "$(dirname "$0")"
swift package describe --type json > project.json
.build/checkouts/mockingbird/mockingbird generate --project project.json \
  --output-dir Sources/NetworkMocks \
  --testbundle AuthorizationManagerTests \
  --targets AuthorizationManager
