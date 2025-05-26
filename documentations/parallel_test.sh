#!/bin/bash

# =============================================================================
# PARALLEL MULTI-DEVICE INTEGRATION TEST RUNNER
# =============================================================================
# This script runs integration tests on multiple iOS and Android devices
# simultaneously for maximum efficiency and coverage
# =============================================================================

set -e
# =============================================================================
# CONFIGURATION
# =============================================================================

# Test configuration
TEST_FILE="${1:-integration_test/app_test.dart}"
TIMEOUT="${2:-600}"
RETRY_COUNT="${3:-2}"
COVERAGE_ENABLED="${4:-true}"
ALLURE_ENABLED="${5:-true}"

# Device configurations
IOS_DEVICES=(
    "iPhone 15 Pro"
    "iPhone 15"
    "iPad Air (5th generation)"
)

ANDROID_DEVICES=(
    "Pixel_7_API_34"
    "Pixel_6_API_33" 
    "Samsung_Galaxy_S23_API_34"
)

# Test tags
IOS_TAGS="ios"
ANDROID_TAGS="android"
CROSS_PLATFORM_TAGS="ios||android"

# Output directories
OUTPUT_DIR="test_results"
COVERAGE_DIR="$OUTPUT_DIR/coverage"
ALLURE_DIR="$OUTPUT_DIR/allure-results"
LOGS_DIR="$OUTPUT_DIR/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

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

# Create output directories
setup_directories() {
    print_step "Setting up output directories"
    mkdir -p "$OUTPUT_DIR" "$COVERAGE_DIR" "$ALLURE_DIR" "$LOGS_DIR"
    print_success "Directories created"
}

# Clean previous test results
clean_previous_results() {
    print_step "Cleaning previous test results"
    rm -rf "$OUTPUT_DIR"/*
    print_success "Previous results cleaned"
}

# Check if device/simulator exists and is available
check_device() {
    local device_name="$1"
    local platform="$2"
    
    if [ "$platform" = "ios" ]; then
        if xcrun simctl list devices | grep -q "$device_name"; then
            return 0
        else
            print_warning "iOS device '$device_name' not found"
            return 1
        fi
    else
        if emulator -list-avds | grep -q "$device_name"; then
            return 0
        else
            print_warning "Android device '$device_name' not found"
            return 1
        fi
    fi
}

# Start iOS simulator
start_ios_simulator() {
    local device_name="$1"
    print_step "Starting iOS simulator: $device_name"
    
    xcrun simctl boot "$device_name" 2>/dev/null || true
    
    # Wait for simulator to be ready
    local timeout=60
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if xcrun simctl list devices | grep "$device_name" | grep -q "Booted"; then
            print_success "iOS simulator '$device_name' is ready"
            return 0
        fi
        sleep 2
        elapsed=$((elapsed + 2))
    done
    
    print_error "Failed to start iOS simulator '$device_name'"
    return 1
}

# Start Android emulator
start_android_emulator() {
    local device_name="$1"
    print_step "Starting Android emulator: $device_name"
    
    # Start emulator in background
    emulator -avd "$device_name" -no-window -no-audio -no-snapshot &
    local emulator_pid=$!
    
    # Wait for emulator to be ready
    local timeout=120
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if adb devices | grep -q "emulator.*device"; then
            print_success "Android emulator '$device_name' is ready"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    print_error "Failed to start Android emulator '$device_name'"
    return 1
}

# Run test on specific device
run_test_on_device() {
    local device_name="$1"
    local platform="$2"
    local tags="$3"
    local test_name="${platform}_${device_name//[^a-zA-Z0-9]/_}"
    local log_file="$LOGS_DIR/${test_name}.log"
    
    print_step "Running test on $platform device: $device_name"
    
    # Build command
    local cmd="patrol test $TEST_FILE"
    cmd="$cmd --tags $tags"
    cmd="$cmd --device-id \"$device_name\""
    cmd="$cmd --timeout $TIMEOUT"
    cmd="$cmd --retry $RETRY_COUNT"
    
    if [ "$COVERAGE_ENABLED" = "true" ]; then
        cmd="$cmd --coverage"
    fi
    
    if [ "$ALLURE_ENABLED" = "true" ]; then
        cmd="$cmd --dart-define ALLURE_ENABLED=true"
    fi
    
    # Run command and capture output
    echo "Command: $cmd" > "$log_file"
    echo "Started at: $(date)" >> "$log_file"
    echo "----------------------------------------" >> "$log_file"
    
    if eval "$cmd" >> "$log_file" 2>&1; then
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: SUCCESS" >> "$log_file"
        print_success "Test completed successfully on $platform device: $device_name"
        return 0
    else
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: FAILED" >> "$log_file"
        print_error "Test failed on $platform device: $device_name"
        return 1
    fi
}

# Run tests on iOS devices in parallel
run_ios_tests_parallel() {
    print_header "RUNNING iOS TESTS IN PARALLEL"
    
    local pids=()
    local devices=()
    
    for device in "${IOS_DEVICES[@]}"; do
        if check_device "$device" "ios"; then
            start_ios_simulator "$device" &
            devices+=("$device")
        fi
    done
    
    # Wait for all simulators to start
    wait
    
    # Run tests in parallel
    for device in "${devices[@]}"; do
        run_test_on_device "$device" "ios" "$IOS_TAGS" &
        pids+=($!)
    done
    
    # Wait for all iOS tests to complete
    local ios_success=0
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            ios_success=$((ios_success + 1))
        fi
    done
    
    print_info "iOS tests completed: $ios_success/${#devices[@]} successful"
    return $ios_success
}

# Run tests on Android devices in parallel
run_android_tests_parallel() {
    print_header "RUNNING ANDROID TESTS IN PARALLEL"
    
    local pids=()
    local devices=()
    
    for device in "${ANDROID_DEVICES[@]}"; do
        if check_device "$device" "android"; then
            start_android_emulator "$device" &
            devices+=("$device")
        fi
    done
    
    # Wait for all emulators to start
    wait
    
    # Run tests in parallel
    for device in "${devices[@]}"; do
        run_test_on_device "$device" "android" "$ANDROID_TAGS" &
        pids+=($!)
    done
    
    # Wait for all Android tests to complete
    local android_success=0
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            android_success=$((android_success + 1))
        fi
    done
    
    print_info "Android tests completed: $android_success/${#devices[@]} successful"
    return $android_success
}

# Generate consolidated reports
generate_reports() {
    print_header "GENERATING CONSOLIDATED REPORTS"
    
    if [ "$COVERAGE_ENABLED" = "true" ]; then
        print_step "Generating coverage report"
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o "$COVERAGE_DIR/html" 2>/dev/null || true
            print_success "Coverage report generated: $COVERAGE_DIR/html/index.html"
        else
            print_warning "genhtml not found, skipping coverage HTML report"
        fi
    fi
    
    if [ "$ALLURE_ENABLED" = "true" ]; then
        print_step "Generating Allure report"
        if command -v allure &> /dev/null; then
            allure generate allure-results --clean -o "$ALLURE_DIR/report" 2>/dev/null || true
            print_success "Allure report generated: $ALLURE_DIR/report/index.html"
        else
            print_warning "Allure not found, skipping Allure report"
        fi
    fi
}

# Display test summary
display_summary() {
    local ios_success=$1
    local android_success=$2
    local total_ios=${#IOS_DEVICES[@]}
    local total_android=${#ANDROID_DEVICES[@]}
    
    print_header "TEST EXECUTION SUMMARY"
    
    echo -e "${BLUE}Test File:${NC} $TEST_FILE"
    echo -e "${BLUE}Timeout:${NC} $TIMEOUT seconds"
    echo -e "${BLUE}Retry Count:${NC} $RETRY_COUNT"
    echo -e "${BLUE}Coverage Enabled:${NC} $COVERAGE_ENABLED"
    echo -e "${BLUE}Allure Enabled:${NC} $ALLURE_ENABLED"
    echo ""
    
    echo -e "${PURPLE}iOS Results:${NC}"
    echo -e "  Successful: ${GREEN}$ios_success${NC}/$total_ios"
    echo -e "  Failed: ${RED}$((total_ios - ios_success))${NC}/$total_ios"
    echo ""
    
    echo -e "${PURPLE}Android Results:${NC}"
    echo -e "  Successful: ${GREEN}$android_success${NC}/$total_android"
    echo -e "  Failed: ${RED}$((total_android - android_success))${NC}/$total_android"
    echo ""
    
    local total_success=$((ios_success + android_success))
    local total_tests=$((total_ios + total_android))
    
    echo -e "${PURPLE}Overall Results:${NC}"
    echo -e "  Total Successful: ${GREEN}$total_success${NC}/$total_tests"
    echo -e "  Total Failed: ${RED}$((total_tests - total_success))${NC}/$total_tests"
    echo -e "  Success Rate: ${CYAN}$(( (total_success * 100) / total_tests ))%${NC}"
    echo ""
    
    echo -e "${BLUE}Logs Directory:${NC} $LOGS_DIR"
    if [ "$COVERAGE_ENABLED" = "true" ]; then
        echo -e "${BLUE}Coverage Report:${NC} $COVERAGE_DIR/html/index.html"
    fi
    if [ "$ALLURE_ENABLED" = "true" ]; then
        echo -e "${BLUE}Allure Report:${NC} $ALLURE_DIR/report/index.html"
    fi
}

# Cleanup function
cleanup() {
    print_step "Cleaning up processes"
    
    # Kill any remaining emulator processes
    pkill -f "emulator" 2>/dev/null || true
    
    # Shutdown iOS simulators
    for device in "${IOS_DEVICES[@]}"; do
        xcrun simctl shutdown "$device" 2>/dev/null || true
    done
    
    print_success "Cleanup completed"
}

# =============================================================================
# MAIN EXECUTION FUNCTIONS
# =============================================================================

# Run tests on all platforms in parallel
run_all_parallel() {
    print_header "STARTING PARALLEL MULTI-DEVICE TESTING"
    
    setup_directories
    clean_previous_results
    
    # Prepare Flutter environment
    print_step "Preparing Flutter environment"
    flutter clean
    flutter pub get
    print_success "Flutter environment ready"
    
    # Run iOS and Android tests in parallel
    run_ios_tests_parallel &
    local ios_pid=$!
    
    run_android_tests_parallel &
    local android_pid=$!
    
    # Wait for both platforms to complete
    local ios_success=0
    local android_success=0
    
    if wait $ios_pid; then
        ios_success=$?
    fi
    
    if wait $android_pid; then
        android_success=$?
    fi
    
    generate_reports
    display_summary $ios_success $android_success
    
    # Return overall success status
    local total_success=$((ios_success + android_success))
    local total_tests=$((${#IOS_DEVICES[@]} + ${#ANDROID_DEVICES[@]}))
    
    if [ $total_success -eq $total_tests ]; then
        print_success "All tests passed successfully!"
        return 0
    else
        print_error "Some tests failed. Check logs for details."
        return 1
    fi
}

# Run tests on iOS devices only
run_ios_only() {
    print_header "RUNNING iOS TESTS ONLY"
    
    setup_directories
    clean_previous_results
    
    flutter clean
    flutter pub get
    
    local ios_success=$(run_ios_tests_parallel)
    
    generate_reports
    display_summary $ios_success 0
    
    if [ $ios_success -eq ${#IOS_DEVICES[@]} ]; then
        print_success "All iOS tests passed!"
        return 0
    else
        print_error "Some iOS tests failed."
        return 1
    fi
}

# Run tests on Android devices only
run_android_only() {
    print_header "RUNNING ANDROID TESTS ONLY"
    
    setup_directories
    clean_previous_results
    
    flutter clean
    flutter pub get
    
    local android_success=$(run_android_tests_parallel)
    
    generate_reports
    display_summary 0 $android_success
    
    if [ $android_success -eq ${#ANDROID_DEVICES[@]} ]; then
        print_success "All Android tests passed!"
        return 0
    else
        print_error "Some Android tests failed."
        return 1
    fi
}

# Display help
show_help() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "OPTIONS:"
    echo "  TEST_FILE      Test file to run (default: integration_test/app_test.dart)"
    echo "  TIMEOUT        Test timeout in seconds (default: 600)"
    echo "  RETRY_COUNT    Number of retries on failure (default: 2)"
    echo "  COVERAGE       Enable coverage (default: true)"
    echo "  ALLURE         Enable Allure reporting (default: true)"
    echo ""
    echo "COMMANDS:"
    echo "  all            Run tests on all platforms (default)"
    echo "  ios            Run tests on iOS devices only"
    echo "  android        Run tests on Android devices only"
    echo "  help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                                           # Run all tests with defaults"
    echo "  $0 integration_test/hotels_test.dart        # Run specific test file"
    echo "  $0 integration_test/app_test.dart 300 1     # Custom timeout and retry"
    echo "  $0 integration_test/app_test.dart 600 2 true false ios  # iOS only, no Allure"
    echo ""
    echo "DEVICE CONFIGURATION:"
    echo "  Edit IOS_DEVICES and ANDROID_DEVICES arrays in this script to customize devices"
}

# =============================================================================
# MAIN SCRIPT EXECUTION
# =============================================================================

# Trap cleanup on script exit
trap cleanup EXIT

# Parse command line arguments
COMMAND="${6:-all}"

case "$COMMAND" in
    "all")
        run_all_parallel
        ;;
    "ios")
        run_ios_only
        ;;
    "android")
        run_android_only
        ;;
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

exit $?