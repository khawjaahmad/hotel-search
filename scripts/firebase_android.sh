#!/usr/bin/env bash
set -euo pipefail

# Required env vars:
# TEST_TARGET (e.g., integration_test/tests/dashboard_test.dart)

: "${TEST_TARGET:?Missing TEST_TARGET}"

# Build APKs
echo "▶️ Building APKs for $TEST_TARGET..."
patrol build android --target="$TEST_TARGET"

# Run on multiple Android devices in parallel
echo "🚀 Running tests on Firebase Test Lab (parallel devices)..."
gcloud firebase test android run \
  --type instrumentation \
  --use-orchestrator \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 10m \
  --record-video \
  --device model=shiba,version=34,locale=en,orientation=portrait \
  --device model=e3q,version=34,locale=en,orientation=portrait \
  --environment-variables clearPackageData=true