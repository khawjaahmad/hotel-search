#!/bin/bash
# scripts/fix_integration_tests.sh
# Script to diagnose and fix common integration test issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}================================================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Configuration
PROJECT_ROOT=$(pwd)
REQUIRED_DIRS=("test-results" "test-results/logs" "allure-results" "screenshots")
IOS_DEVICE="iPhone 16 Plus"
IOS_UDID="AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"

# Main diagnostic function
run_diagnostics() {
    print_header "INTEGRATION TEST DIAGNOSTICS"
    
    print_step "Checking project structure..."
    check_project_structure
    
    print_step "Checking Flutter environment..."
    check_flutter_environment
    
    print_step "Checking Patrol setup..."
    check_patrol_setup
    
    print_step "Checking test devices..."
    check_test_devices
    
    print_step "Checking test files..."
    check_test_files
    
    print_step "Checking dependencies..."
    check_dependencies
    
    print_step "Checking permissions..."
    check_permissions
}

# Check project structure
check_project_structure() {
    local issues=0
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project root (pubspec.yaml not found)"
        issues=$((issues + 1))
    else
        print_success "Found pubspec.yaml"
    fi
    
    # Check integration test directory
    if [ ! -d "integration_test" ]; then
        print_error "integration_test directory not found"
        print_info "Create with: mkdir -p integration_test/tests"
        issues=$((issues + 1))
    else
        print_success "integration_test directory exists"
    fi
    
    # Check required directories
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            print_warning "Creating missing directory: $dir"
            mkdir -p "$dir"
        else
            print_success "Directory exists: $dir"
        fi
    done
    
    # Check scripts directory
    if [ ! -d "scripts" ]; then
        print_warning "scripts directory not found"
        mkdir -p scripts
    else
        print_success "scripts directory exists"
    fi
    
    return $issues
}

# Check Flutter environment
check_flutter_environment() {
    local issues=0
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not installed or not in PATH"
        print_info "Install from: https://flutter.dev/docs/get-started/install"
        issues=$((issues + 1))
    else
        local flutter_version=$(flutter --version | head -n1)
        print_success "Flutter: $flutter_version"
    fi
    
    # Check Dart installation
    if ! command -v dart &> /dev/null; then
        print_error "Dart not installed or not in PATH"
        issues=$((issues + 1))
    else
        local dart_version=$(dart --version)
        print_success "Dart: $dart_version"
    fi
    
    # Run Flutter doctor
    print_info "Running Flutter doctor..."
    if flutter doctor | grep -q "No issues found"; then
        print_success "Flutter doctor: No issues"
    else
        print_warning "Flutter doctor found issues - check output above"
    fi
    
    return $issues
}

# Check Patrol setup
check_patrol_setup() {
    local issues=0
    
    # Check if Patrol is in pubspec.yaml
    if ! grep -q "patrol:" pubspec.yaml; then
        print_error "Patrol not found in pubspec.yaml"
        print_info "Add to dev_dependencies:"
        print_info "  patrol: ^3.15.2"
        issues=$((issues + 1))
    else
        print_success "Patrol found in pubspec.yaml"
    fi
    
    # Check Patrol CLI
    if ! command -v patrol &> /dev/null; then
        print_error "Patrol CLI not installed"
        print_info "Install with: dart pub global activate patrol_cli"
        issues=$((issues + 1))
    else
        local patrol_version=$(patrol --version 2>/dev/null || echo "unknown")
        print_success "Patrol CLI: $patrol_version"
    fi
    
    return $issues
}

# Check test devices
check_test_devices() {
    local issues=0
    
    # Check iOS simulators (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_info "Checking iOS simulators..."
        
        if ! command -v xcrun &> /dev/null; then
            print_error "Xcode command line tools not installed"
            print_info "Install with: xcode-select --install"
            issues=$((issues + 1))
        else
            # Check if target device exists
            if xcrun simctl list devices | grep -q "$IOS_DEVICE"; then
                print_success "iOS device '$IOS_DEVICE' found"
                
                # Check device state
                local device_state=$(xcrun simctl list devices | grep "$IOS_DEVICE" | grep "$IOS_UDID" | grep -o "([^)]*)" | tr -d "()" || echo "Unknown")
                print_info "Device state: $device_state"
                
                if [[ "$device_state" == "Booted" ]]; then
                    print_success "iOS simulator is ready"
                else
                    print_warning "iOS simulator not booted"
                    print_info "Boot with: xcrun simctl boot $IOS_UDID"
                fi
            else
                print_error "iOS device '$IOS_DEVICE' not found"
                print_info "Available devices:"
                xcrun simctl list devices available | grep "iPhone\|iPad" | head -5
                issues=$((issues + 1))
            fi
        fi
    else
        print_info "Skipping iOS checks (not on macOS)"
    fi
    
    # Check Android emulators
    print_info "Checking Android emulators..."
    
    if ! command -v adb &> /dev/null; then
        print_error "Android SDK tools not found"
        print_info "Install Android Studio and SDK tools"
        issues=$((issues + 1))
    else
        # Check running emulators
        local running_emulators=$(adb devices | grep "emulator.*device" | wc -l)
        if [ $running_emulators -gt 0 ]; then
            print_success "$running_emulators Android emulator(s) running"
        else
            print_warning "No Android emulators running"
            
            # Check available AVDs
            if command -v avdmanager &> /dev/null; then
                local avd_count=$(avdmanager list avd 2>/dev/null | grep -c "Name:" || echo "0")
                if [ $avd_count -gt 0 ]; then
                    print_info "$avd_count Android AVD(s) available"
                    print_info "Start with: emulator -avd <avd_name>"
                else
                    print_error "No Android AVDs found"
                    print_info "Create AVDs in Android Studio"
                    issues=$((issues + 1))
                fi
            else
                print_warning "avdmanager not found"
            fi
        fi
    fi
    
    return $issues
}

# Check test files
check_test_files() {
    local issues=0
    
    # Integration test files
    local integration_tests=(
        "integration_test/tests/hotels_test.dart"
        "integration_test/tests/overview_test.dart"
        "integration_test/tests/account_test.dart"
        "integration_test/tests/dashboard_test.dart"
    )
    
    print_info "Checking integration test files..."
    for test_file in "${integration_tests[@]}"; do
        if [ -f "$test_file" ]; then
            print_success "Found: $test_file"
        else
            print_warning "Missing: $test_file"
        fi
    done
    
    # Check if test_bundle.dart exists or can be generated
    if [ ! -f "integration_test/test_bundle.dart" ]; then
        print_warning "test_bundle.dart not found"
        print_info "This will be generated automatically by Patrol"
    else
        print_success "Found: integration_test/test_bundle.dart"
    fi
    
    # Check unit tests
    if [ -d "test" ]; then
        local unit_test_count=$(find test -name "*.dart" | wc -l)
        print_success "Found $unit_test_count unit test files"
    else
        print_warning "No test directory found"
    fi
    
    return $issues
}

# Check dependencies
check_dependencies() {
    local issues=0
    
    print_info "Checking pubspec.yaml dependencies..."
    
    # Required dependencies
    local required_deps=("flutter_test" "integration_test" "patrol")
    
    for dep in "${required_deps[@]}"; do
        if grep -q "$dep:" pubspec.yaml; then
            print_success "Dependency found: $dep"
        else
            print_error "Missing dependency: $dep"
            issues=$((issues + 1))
        fi
    done
    
    # Check if dependencies are up to date
    print_info "Checking if dependencies are resolved..."
    if [ -f ".dart_tool/package_config.json" ]; then
        print_success "Dependencies resolved"
    else
        print_warning "Dependencies not resolved"
        print_info "Run: flutter pub get"
    fi
    
    return $issues
}

# Check permissions
check_permissions() {
    local issues=0
    
    print_info "Checking file permissions..."
    
    # Check script permissions
    local scripts=("scripts/enhanced_patrol_runner.sh" "scripts/device_setup.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_success "Executable: $script"
            else
                print_warning "Not executable: $script"
                chmod +x "$script"
                print_info "Fixed permissions for: $script"
            fi
        else
            print_warning "Script not found: $script"
        fi
    done
    
    # Check directory permissions
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            print_success "Writable: $dir"
        elif [ -d "$dir" ]; then
            print_error "Not writable: $dir"
            issues=$((issues + 1))
        fi
    done
    
    return $issues
}

# Auto-fix common issues
auto_fix() {
    print_header "AUTO-FIXING COMMON ISSUES"
    
    print_step "Creating missing directories..."
    for dir in "${REQUIRED_DIRS[@]}"; do
        mkdir -p "$dir"
    done
    
    print_step "Fixing script permissions..."
    find scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    print_step "Running flutter pub get..."
    flutter pub get
    
    print_step "Cleaning build artifacts..."
    flutter clean
    
    print_step "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    
    print_success "Auto-fix completed"
}

# Create a minimal test file
create_minimal_test() {
    local test_file="integration_test/tests/minimal_test.dart"
    
    print_step "Creating minimal test file..."
    
    mkdir -p "integration_test/tests"
    
    cat > "$test_file" << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;

void main() {
  group('Minimal Integration Test', () {
    patrolTest(
      'App loads successfully',
      ($) async {
        // Start the app
        app.main();
        await $.pumpAndSettle();
        
        // Verify app loaded
        expect(find.byType(MaterialApp), findsOneWidget);
      },
    );
  });
}
EOF
    
    print_success "Created minimal test: $test_file"
    print_info "Test this with: patrol test $test_file"
}

# Test Patrol setup
test_patrol_setup() {
    print_header "TESTING PATROL SETUP"
    
    print_step "Checking Patrol CLI..."
    if command -v patrol &> /dev/null; then
        print_success "Patrol CLI found"
        patrol --version
    else
        print_error "Patrol CLI not found"
        print_info "Installing Patrol CLI..."
        dart pub global activate patrol_cli
    fi
    
    print_step "Testing basic Patrol command..."
    if patrol devices &> /dev/null; then
        print_success "Patrol can detect devices"
    else
        print_warning "Patrol device detection failed"
    fi
    
    print_step "Creating and testing minimal integration test..."
    create_minimal_test
    
    print_info "To test the minimal setup, run:"
    print_info "  patrol test integration_test/tests/minimal_test.dart"
}

# Show recommendations
show_recommendations() {
    print_header "RECOMMENDATIONS"
    
    echo -e "${BLUE}For iOS Testing:${NC}"
    echo "  1. Ensure Xcode is installed and up to date"
    echo "  2. Run: xcode-select --install"
    echo "  3. Create iOS simulators: xcrun simctl create 'iPhone 16 Plus' 'iPhone 16 Plus'"
    echo "  4. Boot simulator: xcrun simctl boot <device_udid>"
    echo ""
    
    echo -e "${BLUE}For Android Testing:${NC}"
    echo "  1. Install Android Studio"
    echo "  2. Install Android SDK and tools"
    echo "  3. Create AVDs in Android Studio"
    echo "  4. Start emulator: emulator -avd <avd_name>"
    echo ""
    
    echo -e "${BLUE}For Better Test Reliability:${NC}"
    echo "  1. Use the enhanced patrol runner script"
    echo "  2. Set appropriate timeouts (PATROL_WAIT=5000)"
    echo "  3. Use retry mechanisms for flaky tests"
    echo "  4. Implement proper wait strategies"
    echo ""
    
    echo -e "${BLUE}Common Commands:${NC}"
    echo "  make setup           - Initial project setup"
    echo "  make test-ios        - Run tests on iOS"
    echo "  make test-android    - Run tests on Android"
    echo "  make test-single     - Run single test"
    echo "  make troubleshoot    - Run diagnostics"
    echo ""
    
    echo -e "${BLUE}Environment Variables:${NC}"
    echo "  TEST_FILE=path/to/test.dart make test-single"
    echo "  VERBOSE=true make test-ios"
    echo "  RETRY_COUNT=3 make test-android"
}

# Create configuration file
create_config() {
    local config_file="integration_test_config.yaml"
    
    print_step "Creating configuration file..."
    
    cat > "$config_file" << EOF
# Integration Test Configuration
# Generated by fix_integration_tests.sh

project:
  name: hotel_booking
  flutter_version: 3.6.0

devices:
  ios:
    device_name: "iPhone 16 Plus"
    udid: "AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
  android:
    avd_name: "Pixel_7"
    device_id: "emulator-5554"

test_settings:
  timeout: 600
  retry_count: 3
  patrol_wait: 5000
  verbose: false

directories:
  test_results: "test-results"
  allure_results: "allure-results"
  screenshots: "screenshots"
  logs: "test-results/logs"

test_files:
  - "integration_test/tests/hotels_test.dart"
  - "integration_test/tests/overview_test.dart"
  - "integration_test/tests/account_test.dart"
  - "integration_test/tests/dashboard_test.dart"

# Environment variables
environment:
  PATROL_WAIT: "5000"
  ALLURE_RESULTS_DIRECTORY: "allure-results"
  INTEGRATION_TEST_SCREENSHOTS: "screenshots"
EOF
    
    print_success "Created configuration: $config_file"
}

# Main execution
main() {
    local command="${1:-diagnose}"
    
    case "$command" in
        "diagnose"|"check")
            run_diagnostics
            ;;
        "fix"|"auto-fix")
            auto_fix
            ;;
        "test-patrol")
            test_patrol_setup
            ;;
        "config")
            create_config
            ;;
        "minimal")
            create_minimal_test
            ;;
        "recommendations"|"help")
            show_recommendations
            ;;
        *)
            print_header "INTEGRATION TEST TROUBLESHOOTING TOOL"
            echo ""
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  diagnose        - Run full diagnostics (default)"
            echo "  fix             - Auto-fix common issues"
            echo "  test-patrol     - Test Patrol CLI setup"
            echo "  config          - Create configuration file"
            echo "  minimal         - Create minimal test file"
            echo "  recommendations - Show recommendations"
            echo ""
            echo "Examples:"
            echo "  $0 diagnose"
            echo "  $0 fix"
            echo "  $0 test-patrol"
            ;;
    esac
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Script interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"