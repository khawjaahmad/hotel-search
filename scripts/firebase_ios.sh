#!/usr/bin/env bash
set -euo pipefail

# Required env vars:
# IOS_DEVICE_MODEL (e.g., iphone15pro)
# IOS_DEVICE_VERSION (e.g., 18.0)

: "${IOS_DEVICE_MODEL:?Missing IOS_DEVICE_MODEL}"
: "${IOS_DEVICE_VERSION:?Missing IOS_DEVICE_VERSION}"

# Build iOS app and test bundle
echo "▶️ Building iOS integration test..."
patrol build ios --target integration_test/tests/dashboard_test.dart --debug --simulator



# Create zip for Firebase Test Lab
cd build/ios_integ/Build/Products
rm -f ios_tests.zip

echo "📦 Zipping .app and .xctestrun files..."
zip -r ios_tests.zip Release-iphoneos/*.app *.xctestrun

cd -

# Run on Firebase Test Lab
echo "🚀 Running test on Firebase Test Lab..."
gcloud firebase test ios run \
  --type xctest \
  --test "build/ios_integ/Build/Products/ios_tests.zip" \
  --device model="$IOS_DEVICE_MODEL",version="$IOS_DEVICE_VERSION",locale=en_US,orientation=portrait \
  --timeout 10m