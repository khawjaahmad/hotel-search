#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Starting Pre-Test Validation..."

# 1. Check Flutter Installation and Version
check_flutter() {
    echo -n "Checking Flutter installation... "
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found${NC}"
        exit 1
    fi
    flutter --version
    echo -e "${GREEN}✓ Flutter installation verified${NC}"
}

# 2. Check Patrol Installation and Config
check_patrol() {
    echo -n "Checking Patrol setup... "
    if ! command -v patrol &> /dev/null; then
        echo -e "${RED}❌ Patrol CLI not found${NC}"
        echo "Run: dart pub global activate patrol_cli"
        exit 1
    fi

    # Check patrol configuration file
    if [ ! -f "patrol.yaml" ]; then
        echo -e "${RED}❌ patrol.yaml not found${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Patrol configuration verified${NC}"
}

# 3. Validate Integration Test Directory Structure
check_test_files() {
    local test_dir="integration_test/tests"
    echo "Checking integration test files..."

    declare -a required_files=(
        "account_test.dart"
        "dashboard_test.dart"
        "overview_test.dart"
        "hotels_test.dart"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$test_dir/$file" ]; then
            echo -e "${RED}❌ Missing test file: $file${NC}"
            exit 1
        fi

        # Basic Dart syntax check
        dart analyze "$test_dir/$file" || {
            echo -e "${RED}❌ Syntax error in $file${NC}"
            exit 1
        }
    done
    echo -e "${GREEN}✓ All test files present and valid${NC}"
}

# 4. Check Device Availability
check_ios_simulator() {
    echo "Checking iOS Simulator..."
    local device_id="AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
    local device_name="iPhone 16 Plus"

    if ! xcrun simctl list devices | grep -q "$device_id"; then
        echo -e "${RED}❌ iOS Simulator $device_name ($device_id) not found${NC}"
        exit 1
    fi

    # Check if simulator is booted
    if ! xcrun simctl list devices | grep "$device_id" | grep -q "Booted"; then
        echo -e "${YELLOW}⚠️  iOS Simulator not booted${NC}"
    else
        echo -e "${GREEN}✓ iOS Simulator ready${NC}"
    fi
}

check_android_emulator() {
    echo "Checking Android Emulator..."
    local emulator_id="emulator-5554"
    local emulator_name="Pixel_7"

    # Check if emulator exists
    if ! avdmanager list avd | grep -q "$emulator_name"; then
        echo -e "${RED}❌ Android Emulator $emulator_name not found${NC}"
        exit 1
    fi

    # Check if emulator is running
    if ! adb devices | grep -q "$emulator_id"; then
        echo -e "${YELLOW}⚠️  Android Emulator not running${NC}"
    else
        echo -e "${GREEN}✓ Android Emulator ready${NC}"
    fi
}

# 5. Check Project Dependencies
check_dependencies() {
    echo "Checking project dependencies..."

    # Verify pubspec.yaml exists
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ pubspec.yaml not found${NC}"
        exit 1
    fi

    # Run flutter pub get
    flutter pub get || {
        echo -e "${RED}❌ Failed to get dependencies${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ Dependencies verified${NC}"
}

# 6. Check Network Connectivity (if tests require it)
check_network() {
    echo -n "Checking network connectivity... "
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: No network connectivity${NC}"
    else
        echo -e "${GREEN}✓ Network is available${NC}"
    fi
}

# Main execution
main() {
    echo "================================"
    echo "🔎 Pre-Test Environment Validation"
    echo "================================"

    check_flutter
    check_patrol
    check_test_files
    check_dependencies
    check_ios_simulator
    check_android_emulator
    check_network

    echo "================================"
    echo -e "${GREEN}✅ All checks completed${NC}"
    echo "================================"
}

main