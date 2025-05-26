#!/bin/bash
# scripts/patrol_test_runner.sh
# Patrol integration test runner with support for local and Firebase Test Lab

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
TARGET="$1"
TIMEOUT=600
RETRY_COUNT=2

# Device configurations
IOS_LOCAL_DEVICE="iPhone 16 Plus"
IOS_LOCAL_UDID="AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
ANDROID_LOCAL_DEVICE="Pixel_7"
FIREBASE_PROJECT="your-firebase-project-id"  # Replace with your project ID

# Firebase Test Lab device configurations
FIREBASE_IOS_MODEL="iphone15pro"
FIREBASE_IOS_VERSION="18.0"
FIREBASE_ANDROID_MODEL="shiba"  # Pixel 8
FIREBASE_ANDROID_VERSION="34"

# Directories
TEST_RESULTS_DIR="test-results"
ALLURE_RESULTS_DIR="allure-results"
SCREENSHOTS_DIR="screenshots"
LOGS_DIR="$TEST_RESULTS_DIR/logs"

# Available integration tests
INTEGRATION_TESTS=(
    "integration_test/tests/hotels_test.dart"
    "integration_test/tests/overview_test.dart"
    "integration_test/tests/account_test.dart"
    "integration_test/tests/dashboard_test.dart"
)

# Validate target
validate_target() {
    case "$TARGET" in
        "ios-local"|"android-local"|"ios-firebase"|"android-firebase"|"local"|"firebase"|"parallel")
            print_info "Target: $TARGET"
            ;;
        *)
            print_error "Invalid target: $TARGET"
            echo ""
            echo "Valid targets:"
            echo "  ios-local        - Run on local iOS simulator"
            echo "  android-local    - Run on local Android emulator"
            echo "  ios-firebase     - Run on Firebase Test Lab iOS"
            echo "  android-firebase - Run on Firebase Test Lab Android"
            echo "  local            - Run on all local devices"
            echo "  firebase         - Run on Firebase Test Lab"
            echo "  parallel         - Run on all devices simultaneously"
            exit 1
            ;;
    esac
}

# Setup directories
setup_directories() {
    print_step "Setting up directories..."
    mkdir -p "$TEST_RESULTS_DIR" "$ALLURE_RESULTS_DIR" "$SCREENSHOTS_DIR" "$LOGS_DIR"
    print_success "Directories created"
}

# Clean previous results
clean_previous_results() {
    print_step "Cleaning previous results..."
    rm -rf "$TEST_RESULTS_DIR"/* "$ALLURE_RESULTS_DIR"/* "$SCREENSHOTS_DIR"/* 2>/dev/null || true
    print_success "Previous results cleaned"
}

# Check dependencies
check_dependencies() {
    print_step "Checking dependencies..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found"
        exit 1
    fi
    
    # Check Patrol
    if ! flutter pub deps | grep -q "patrol"; then
        print_error "Patrol not found in dependencies"
        print_info "Please ensure Patrol is added to pubspec.yaml"
        exit 1
    fi
    
    # Check Firebase CLI for Firebase targets
    if [[ "$TARGET" == *"firebase"* ]] && ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI not found"
        print_info "Install with: npm install -g firebase-tools"
        exit 1
    fi
    
    print_success "Dependencies checked"
}

# Start local iOS device
start_ios_local() {
    print_step "Starting local iOS simulator..."
    
    # Check if device exists
    if ! xcrun simctl list devices | grep -q "$IOS_LOCAL_DEVICE"; then
        print_error "iOS device '$IOS_LOCAL_DEVICE' not found"
        print_info "Run 'make setup' to create test devices"
        return 1
    fi
    
    # Boot device if not already booted
    local device_state=$(xcrun simctl list devices | grep "$IOS_LOCAL_DEVICE" | grep -o "([^)]*)" | head -1)
    if [[ "$device_state" != "(Booted)" ]]; then
        xcrun simctl boot "$IOS_LOCAL_UDID"
        sleep 5
    fi
    
    print_success "iOS simulator ready"
    return 0
}

# Start local Android device
start_android_local() {
    print_step "Starting local Android emulator..."
    
    # Check if AVD exists
    if ! avdmanager list avd | grep -q "$ANDROID_LOCAL_DEVICE"; then
        print_error "Android AVD '$ANDROID_LOCAL_DEVICE' not found"
        print_info "Run 'make setup' to create test devices"
        return 1
    fi
    
    # Check if emulator is already running
    if ! adb devices | grep -q "emulator.*device"; then
        print_step "Starting Android emulator..."
        emulator -avd "$ANDROID_LOCAL_DEVICE" -no-window -no-snapshot &
        
        # Wait for device to be ready
        local timeout=120
        local elapsed=0
        while [ $elapsed -lt $timeout ]; do
            if adb devices | grep -q "emulator.*device"; then
                break
            fi
            sleep 5
            elapsed=$((elapsed + 5))
        done
        
        if [ $elapsed -ge $timeout ]; then
            print_error "Android emulator failed to start"
            return 1
        fi
    fi
    
    print_success "Android emulator ready"
    return 0
}

# Run Patrol test on local device
run_patrol_test_local() {
    local platform="$1"
    local test_file="$2"
    local device_id="$3"
    
    local test_name=$(basename "$test_file" .dart)
    local log_file="$LOGS_DIR/${platform}_${test_name}.log"
    
    print_step "Running $test_name on $platform (local)..."
    
    # Set environment variables
    export PATROL_WAIT=5000
    export ALLURE_RESULTS_DIRECTORY="$ALLURE_RESULTS_DIR"
    export INTEGRATION_TEST_SCREENSHOTS="$SCREENSHOTS_DIR"
    
    # Build Patrol command
    local patrol_cmd="patrol test"
    patrol_cmd="$patrol_cmd $test_file"
    patrol_cmd="$patrol_cmd --target integration_test/test_bundle.dart"
    
    if [ -n "$device_id" ]; then
        patrol_cmd="$patrol_cmd --device-id \"$device_id\""
    fi
    
    patrol_cmd="$patrol_cmd --dart-define=PATROL_WAIT=5000"
    patrol_cmd="$patrol_cmd --dart-define=ALLURE_RESULTS_DIRECTORY=$ALLURE_RESULTS_DIR"
    patrol_cmd="$patrol_cmd --verbose"
    
    # Execute command
    echo "Command: $patrol_cmd" > "$log_file"
    echo "Started at: $(date)" >> "$log_file"
    echo "Platform: $platform" >> "$log_file"
    echo "Device: $device_id" >> "$log_file"
    echo "----------------------------------------" >> "$log_file"
    
    if eval "$patrol_cmd" >> "$log_file" 2>&1; then
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: SUCCESS" >> "$log_file"
        print_success "$test_name completed successfully on $platform"
        return 0
    else
        local exit_code=$?
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: FAILED (exit code: $exit_code)" >> "$log_file"
        print_error "$test_name failed on $platform (exit code: $exit_code)"
        return 1
    fi
}

# Run test on Firebase Test Lab
run_firebase_test() {
    local platform="$1"
    local test_file="$2"
    
    local test_name=$(basename "$test_file" .dart)
    local log_file="$LOGS_DIR/firebase_${platform}_${test_name}.log"
    
    print_step "Running $test_name on Firebase $platform..."
    
    # Build Firebase Test Lab command
    local firebase_cmd="firebase testlab android run"
    
    if [ "$platform" = "ios" ]; then
        firebase_cmd="firebase testlab ios run"
        firebase_cmd="$firebase_cmd --test integration_test/test_bundle.dart"
        firebase_cmd="$firebase_cmd --device model=$FIREBASE_IOS_MODEL,version=$FIREBASE_IOS_VERSION"
    else
        firebase_cmd="$firebase_cmd --type instrumentation"
        firebase_cmd="$firebase_cmd --app build/app/outputs/flutter-apk/app-debug.apk"
        firebase_cmd="$firebase_cmd --test build/app/outputs/flutter-apk/app-debug-androidTest.apk"
        firebase_cmd="$firebase_cmd --device model=$FIREBASE_ANDROID_MODEL,version=$FIREBASE_ANDROID_VERSION"
    fi
    
    firebase_cmd="$firebase_cmd --project $FIREBASE_PROJECT"
    firebase_cmd="$firebase_cmd --results-bucket gs://${FIREBASE_PROJECT}_test_results"
    firebase_cmd="$firebase_cmd --timeout 15m"
    
    # Execute command
    echo "Command: $firebase_cmd" > "$log_file"
    echo "Started at: $(date)" >> "$log_file"
    echo "Platform: Firebase $platform" >> "$log_file"
    echo "----------------------------------------" >> "$log_file"
    
    if eval "$firebase_cmd" >> "$log_file" 2>&1; then
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: SUCCESS" >> "$log_file"
        print_success "$test_name completed successfully on Firebase $platform"
        return 0
    else
        local exit_code=$?
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: FAILED (exit code: $exit_code)" >> "$log_file"
        print_error "$test_name failed on Firebase $platform (exit code: $exit_code)"
        return 1
    fi
}

# Run tests on iOS local
run_ios_local_tests() {
    print_header "RUNNING TESTS ON LOCAL iOS"
    
    if ! start_ios_local; then
        return 1
    fi
    
    local success_count=0
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        if run_patrol_test_local "ios" "$test_file" "$IOS_LOCAL_UDID"; then
            success_count=$((success_count + 1))
        fi
    done
    
    print_info "iOS local tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run tests on Android local
run_android_local_tests() {
    print_header "RUNNING TESTS ON LOCAL ANDROID"
    
    if ! start_android_local; then
        return 1
    fi
    
    local success_count=0
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    # Get Android device ID
    local android_device_id=$(adb devices | grep "emulator" | cut -f1)
    
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        if run_patrol_test_local "android" "$test_file" "$android_device_id"; then
            success_count=$((success_count + 1))
        fi
    done
    
    print_info "Android local tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run tests on Firebase iOS
run_firebase_ios_tests() {
    print_header "RUNNING TESTS ON FIREBASE iOS"
    
    # Build iOS for Firebase
    print_step "Building iOS app for Firebase Test Lab..."
    if ! flutter build ios --config-only --no-codesign --debug; then
        print_error "Failed to build iOS app for Firebase"
        return 0
    fi
    
    local success_count=0
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        if run_firebase_test "ios" "$test_file"; then
            success_count=$((success_count + 1))
        fi
    done
    
    print_info "Firebase iOS tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run tests on Firebase Android
run_firebase_android_tests() {
    print_header "RUNNING TESTS ON FIREBASE ANDROID"
    
    # Build Android for Firebase
    print_step "Building Android app for Firebase Test Lab..."
    if ! flutter build apk --debug; then
        print_error "Failed to build Android APK for Firebase"
        return 0
    fi
    
    if ! flutter build apk --debug --target=integration_test/test_bundle.dart; then
        print_error "Failed to build Android test APK for Firebase"
        return 0
    fi
    
    local success_count=0
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        if run_firebase_test "android" "$test_file"; then
            success_count=$((success_count + 1))
        fi
    done
    
    print_info "Firebase Android tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run tests on all local devices
run_local_tests() {
    print_header "RUNNING TESTS ON ALL LOCAL DEVICES"
    
    local ios_success=$(run_ios_local_tests)
    local android_success=$(run_android_local_tests)
    local total_success=$((ios_success + android_success))
    
    print_info "Local tests completed: $total_success total successful"
    return $total_success
}

# Run tests on Firebase Test Lab
run_firebase_tests() {
    print_header "RUNNING TESTS ON FIREBASE TEST LAB"
    
    local ios_success=$(run_firebase_ios_tests)
    local android_success=$(run_firebase_android_tests)
    local total_success=$((ios_success + android_success))
    
    print_info "Firebase tests completed: $total_success total successful"
    return $total_success
}

# Run tests on all devices in parallel
run_parallel_tests() {
    print_header "RUNNING TESTS ON ALL DEVICES IN PARALLEL"
    
    # Start local tests in background
    run_local_tests &
    local local_pid=$!
    
    # Start Firebase tests in background
    run_firebase_tests &
    local firebase_pid=$!
    
    # Wait for both to complete
    local local_success=0
    local firebase_success=0
    
    if wait $local_pid; then
        local_success=$?
    fi
    
    if wait $firebase_pid; then
        firebase_success=$?
    fi
    
    local total_success=$((local_success + firebase_success))
    print_info "Parallel tests completed: $total_success total successful"
    return $total_success
}

# Generate Allure report
generate_allure_report() {
    if [ ! -d "$ALLURE_RESULTS_DIR" ] || [ -z "$(ls -A $ALLURE_RESULTS_DIR 2>/dev/null)" ]; then
        print_warning "No Allure results found"
        return 1
    fi
    
    print_step "Generating Allure report..."
    
    if command -v allure &> /dev/null; then
        if allure generate "$ALLURE_RESULTS_DIR" -o "allure-report" --clean 2>/dev/null; then
            print_success "Allure report generated: allure-report/index.html"
            
            # Open in browser
            if command -v open &> /dev/null; then
                open "allure-report/index.html"
            elif command -v xdg-open &> /dev/null; then
                xdg-open "allure-report/index.html"
            fi
            
            return 0
        else
            print_error "Failed to generate Allure report"
            return 1
        fi
    else
        print_warning "Allure CLI not available. Results saved in: $ALLURE_RESULTS_DIR"
        return 1
    fi
}

# Display summary
display_summary() {
    local success_count=$1
    local target_description="$2"
    
    print_header "TEST EXECUTION SUMMARY"
    
    echo -e "${BLUE}Target:${NC} $target_description"
    echo -e "${BLUE}Successful Tests:${NC} $success_count"
    echo -e "${BLUE}Total Integration Tests:${NC} ${#INTEGRATION_TESTS[@]}"
    echo ""
    
    echo -e "${BLUE}Test Files:${NC}"
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        echo -e "  $(basename "$test_file")"
    done
    echo ""
    
    echo -e "${BLUE}Artifacts:${NC}"
    echo -e "  Test Logs: $LOGS_DIR/"
    echo -e "  Screenshots: $SCREENSHOTS_DIR/"
    echo -e "  Allure Results: $ALLURE_RESULTS_DIR/"
    
    if [ -f "allure-report/index.html" ]; then
        echo -e "  Allure Report: ${GREEN}allure-report/index.html${NC}"
    fi
}

# Main execution
main() {
    print_header "PATROL INTEGRATION TEST RUNNER"
    
    validate_target
    setup_directories
    clean_previous_results
    check_dependencies
    
    # Prepare Flutter environment
    print_step "Preparing Flutter environment..."
    flutter clean
    flutter pub get
    print_success "Flutter environment ready"
    
    local success_count=0
    local target_description=""
    
    # Execute based on target
    case "$TARGET" in
        "ios-local")
            success_count=$(run_ios_local_tests)
            target_description="Local iOS Simulator"
            ;;
        "android-local")
            success_count=$(run_android_local_tests)
            target_description="Local Android Emulator"
            ;;
        "ios-firebase")
            success_count=$(run_firebase_ios_tests)
            target_description="Firebase Test Lab iOS"
            ;;
        "android-firebase")
            success_count=$(run_firebase_android_tests)
            target_description="Firebase Test Lab Android"
            ;;
        "local")
            success_count=$(run_local_tests)
            target_description="All Local Devices"
            ;;
        "firebase")
            success_count=$(run_firebase_tests)
            target_description="Firebase Test Lab"
            ;;
        "parallel")
            success_count=$(run_parallel_tests)
            target_description="All Devices (Parallel)"
            ;;
    esac
    
    # Generate reports
    generate_allure_report
    
    # Display summary
    display_summary $success_count "$target_description"
    
    # Exit with appropriate code
    if [ $success_count -gt 0 ]; then
        print_success "Integration tests completed with $success_count successful runs"
        exit 0
    else
        print_error "All integration tests failed"
        exit 1
    fi
}

# Show help
show_help() {
    echo "Usage: $0 <target>"
    echo ""
    echo "Targets:"
    echo "  ios-local        - Run on local iOS simulator"
    echo "  android-local    - Run on local Android emulator"
    echo "  ios-firebase     - Run on Firebase Test Lab iOS"
    echo "  android-firebase - Run on Firebase Test Lab Android"
    echo "  local            - Run on all local devices"
    echo "  firebase         - Run on Firebase Test Lab"
    echo "  parallel         - Run on all devices simultaneously"
    echo ""
    echo "Examples:"
    echo "  $0 ios-local"
    echo "  $0 parallel"
}

# Handle help
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
    show_help
    exit 0
fi

# Run main function
main "$@"