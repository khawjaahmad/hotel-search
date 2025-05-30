#!/bin/bash

# Make all scripts executable
echo "🔧 Making scripts executable..."

chmod +x scripts/setup_firebase.sh
chmod +x scripts/firebase_android.sh
chmod +x scripts/firebase_ios.sh
chmod +x scripts/diagnose_firebase_setup.sh
chmod +x scripts/convert_to_allure.js
chmod +x pre_test_check.sh

echo "✅ All scripts are now executable"

# Show available scripts
echo ""
echo "📋 Available scripts:"
echo "  🔥 ./scripts/setup_firebase.sh - Complete Firebase setup"
echo "  🧪 ./scripts/firebase_android.sh - Run Android tests on Firebase"
echo "  🍎 ./scripts/firebase_ios.sh - Run iOS tests on Firebase"
echo "  🔍 ./scripts/diagnose_firebase_setup.sh - Diagnose setup issues"
echo "  📊 ./scripts/convert_to_allure.js - Convert test results to Allure"
echo "  ✅ ./pre_test_check.sh - Pre-test validation"