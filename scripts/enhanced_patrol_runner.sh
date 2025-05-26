#!/bin/bash
# scripts/enhanced_patrol_runner.sh
# Enhanced Patrol integration test runner with robust error handling

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
RETRY_COUNT=3
VERBOSE=${VERBOSE:-false}

# Device configurations
IOS_LOCAL_DEVICE="iPhone 16 Plus"
IOS_LOCAL_UDID="AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
ANDROID_LOCAL_DEVICE="Pixel_7"

# Directories
TEST_RESULTS_DIR="test-results"
ALLURE_RESULTS_DIR="allure-results" 
SCREENSHOTS_DIR="screenshots"
LOGS_DIR="$TEST_RESULTS_DIR/logs"
REPORTS_DIR="$TEST_RESULTS_DIR/reports"

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
        "ios-local"|"android-local"|"local"|"single")
            print_info "Target: $TARGET"
            ;;
        *)
            print_error "Invalid target: $TARGET"
            echo ""
            echo "Valid targets:"
            echo "  ios-local     - Run on local iOS simulator"
            echo "  android-local - Run on local Android emulator"
            echo "  local         - Run on all local devices"
            echo "  single        - Run single test file (specify with TEST_FILE env var)"
            exit 1
            ;;
    esac
}

# Setup directories with proper error handling
setup_directories() {
    print_step "Setting up directories..."
    
    # Create all necessary directories
    local dirs=("$TEST_RESULTS_DIR" "$ALLURE_RESULTS_DIR" "$SCREENSHOTS_DIR" "$LOGS_DIR" "$REPORTS_DIR")
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir"; then
            print_error "Failed to create directory: $dir"
            exit 1
        fi
    done
    
    # Ensure directories are writable
    for dir in "${dirs[@]}"; do
        if [ ! -w "$dir" ]; then
            print_error "Directory not writable: $dir"
            exit 1
        fi
    done
    
    print_success "Directories created and verified"
}

# Clean previous results safely
clean_previous_results() {
    print_step "Cleaning previous results..."
    
    # Clean with error handling
    local dirs=("$TEST_RESULTS_DIR" "$ALLURE_RESULTS_DIR" "$SCREENSHOTS_DIR")
    
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            if ! rm -rf "${dir:?}"/* 2>/dev/null; then
                print_warning "Could not clean all files in $dir"
            fi
        fi
    done
    
    print_success "Previous results cleaned"
}

# Check dependencies with detailed feedback
check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        missing_deps+=("flutter")
    else
        local flutter_version=$(flutter --version | head -n1)
        print_info "Flutter: $flutter_version"
    fi
    
    # Check Patrol CLI
    if ! command -v patrol &> /dev/null; then
        missing_deps+=("patrol")
    else
        local patrol_version=$(patrol --version 2>/dev/null || echo "unknown")
        print_info "Patrol: $patrol_version"
    fi
    
    # Check if we're on macOS for iOS testing
    if [[ "$TARGET" == *"ios"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS testing requires macOS"
        exit 1
    fi
    
    # Check Xcode tools for iOS
    if [[ "$TARGET" == *"ios"* ]] && ! command -v xcrun &> /dev/null; then
        missing_deps+=("xcode-command-line-tools")
    fi
    
    # Check Android tools for Android testing
    if [[ "$TARGET" == *"android"* ]] && ! command -v adb &> /dev/null; then
        missing_deps+=("android-sdk")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Installation instructions:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "flutter")
                    echo "  Flutter: https://flutter.dev/docs/get-started/install"
                    ;;
                "patrol")
                    echo "  Patrol: dart pub global activate patrol_cli"
                    ;;
                "xcode-command-line-tools")
                    echo "  Xcode Tools: xcode-select --install"
                    ;;
                "android-sdk")
                    echo "  Android SDK: Install Android Studio"
                    ;;
            esac
        done
        exit 1
    fi
    
    print_success "Dependencies verified"
}

# Verify Flutter project structure
verify_project_structure() {
    print_step "Verifying project structure..."
    
    local required_files=("pubspec.yaml" "integration_test")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "Missing required files/directories: ${missing_files[*]}"
        print_info "Please run this script from your Flutter project root"
        exit 1
    fi
    
    # Check if Patrol is in pubspec.yaml
    if ! grep -q "patrol:" pubspec.yaml; then
        print_error "Patrol not found in pubspec.yaml"
        print_info "Add patrol as a dev dependency"
        exit 1
    fi
    
    print_success "Project structure verified"
}

# Start local iOS device with robust error handling
start_ios_local() {
    print_step "Preparing local iOS simulator..."
    
    # Check if simulator exists
    if ! xcrun simctl list devices | grep -q "$IOS_LOCAL_DEVICE"; then
        print_error "iOS device '$IOS_LOCAL_DEVICE' not found"
        print_info "Available devices:"
        xcrun simctl list devices available | grep "iPhone\|iPad" | head -5
        return 1
    fi
    
    # Get device state
    local device_state=$(xcrun simctl list devices | grep "$IOS_LOCAL_DEVICE" | grep "$IOS_LOCAL_UDID" | grep -o "([^)]*)" | tr -d "()")
    print_info "Device state: $device_state"
    
    # Boot device if needed
    if [[ "$device_state" != "Booted" ]]; then
        print_step "Booting iOS simulator..."
        if xcrun simctl boot "$IOS_LOCAL_UDID" 2>/dev/null; then
            print_success "iOS simulator booted"
        else
            print_warning "Device may already be booted or booting"
        fi
        
        # Wait for device to be ready
        local timeout=60
        local elapsed=0
        while [ $elapsed -lt $timeout ]; do
            if xcrun simctl list devices | grep "$IOS_LOCAL_UDID" | grep -q "Booted"; then
                break
            fi
            sleep 2
            elapsed=$((elapsed + 2))
        done
        
        if [ $elapsed -ge $timeout ]; then
            print_error "iOS simulator failed to boot within $timeout seconds"
            return 1
        fi
    fi
    
    print_success "iOS simulator ready"
    return 0
}

# Start local Android device with robust error handling
start_android_local() {
    print_step "Preparing local Android emulator..."
    
    # Check if AVD exists
    if ! avdmanager list avd 2>/dev/null | grep -q "Name: $ANDROID_LOCAL_DEVICE"; then
        print_error "Android AVD '$ANDROID_LOCAL_DEVICE' not found"
        print_info "Available AVDs:"
        avdmanager list avd 2>/dev/null | grep "Name:" | head -5 || echo "  No AVDs found"
        return 1
    fi
    
    # Check if emulator is already running
    if adb devices 2>/dev/null | grep -q "emulator.*device"; then
        print_success "Android emulator already running"
        return 0
    fi
    
    print_step "Starting Android emulator..."
    emulator -avd "$ANDROID_LOCAL_DEVICE" -no-window -no-snapshot &
    local emulator_pid=$!
    
    # Wait for device to be ready
    local timeout=120
    local elapsed=0
    print_info "Waiting for emulator to start (timeout: ${timeout}s)..."
    
    while [ $elapsed -lt $timeout ]; do
        if adb devices 2>/dev/null | grep -q "emulator.*device"; then
            print_success "Android emulator ready"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        if [ $((elapsed % 20)) -eq 0 ]; then
            print_info "Still waiting... (${elapsed}s elapsed)"
        fi
    done
    
    print_error "Android emulator failed to start within $timeout seconds"
    # Kill emulator process if still running
    kill $emulator_pid 2>/dev/null || true
    return 1
}

# Enhanced test execution with better error handling and logging
run_patrol_test_enhanced() {
    local platform="$1"
    local test_file="$2"
    local device_id="$3"
    
    local test_name=$(basename "$test_file" .dart)
    local log_file="$LOGS_DIR/${platform}_${test_name}.log"
    local status_file="$LOGS_DIR/${platform}_${test_name}.status"
    
    print_step "Running $test_name on $platform..."
    
    # Create log file with header
    cat > "$log_file" << EOF
PATROL INTEGRATION TEST LOG
============================
Test: $test_name
Platform: $platform
Device: $device_id
Started: $(date)
Test File: $test_file
============================

EOF
    
    # Set environment variables
    export PATROL_WAIT=5000
    export ALLURE_RESULTS_DIRECTORY="$ALLURE_RESULTS_DIR"
    export INTEGRATION_TEST_SCREENSHOTS="$SCREENSHOTS_DIR"
    
    # Build Patrol command with better error handling
    local patrol_cmd="patrol test"
    patrol_cmd="$patrol_cmd '$test_file'"
    
    if [ -n "$device_id" ]; then
        patrol_cmd="$patrol_cmd --device-id '$device_id'"
    fi
    
    # Add platform-specific flags
    if [[ "$platform" == "ios" ]]; then
        patrol_cmd="$patrol_cmd --dart-define=PATROL_IOS_DEVICE_ID='$device_id'"
    fi
    
    patrol_cmd="$patrol_cmd --dart-define=PATROL_WAIT=5000"
    patrol_cmd="$patrol_cmd --dart-define=ALLURE_RESULTS_DIRECTORY='$ALLURE_RESULTS_DIR'"
    patrol_cmd="$patrol_cmd --timeout $TIMEOUT"
    
    if [ "$VERBOSE" = "true" ]; then
        patrol_cmd="$patrol_cmd --verbose"
    fi
    
    echo "Command: $patrol_cmd" >> "$log_file"
    echo "Environment Variables:" >> "$log_file"
    echo "  PATROL_WAIT=$PATROL_WAIT" >> "$log_file"
    echo "  ALLURE_RESULTS_DIRECTORY=$ALLURE_RESULTS_DIRECTORY" >> "$log_file"
    echo "  INTEGRATION_TEST_SCREENSHOTS=$INTEGRATION_TEST_SCREENSHOTS" >> "$log_file"
    echo "" >> "$log_file"
    
    # Execute with retry logic
    local attempt=1
    local max_attempts=$RETRY_COUNT
    local success=false
    
    while [ $attempt -le $max_attempts ] && [ "$success" = "false" ]; do
        echo "========== ATTEMPT $attempt/$max_attempts ==========" >> "$log_file"
        echo "Started attempt $attempt at: $(date)" >> "$log_file"
        
        if [ $attempt -gt 1 ]; then
            print_info "Retry attempt $attempt/$max_attempts for $test_name"
            # Wait a bit before retry
            sleep 10
        fi
        
        # Execute the command
        if eval "$patrol_cmd" >> "$log_file" 2>&1; then
            success=true
            echo "SUCCESS" > "$status_file"
            echo "Completed successfully at: $(date)" >> "$log_file"
            print_success "$test_name completed successfully on $platform"
            return 0
        else
            local exit_code=$?
            echo "FAILED (exit code: $exit_code)" > "$status_file"
            echo "Failed at: $(date) with exit code: $exit_code" >> "$log_file"
            
            if [ $attempt -lt $max_attempts ]; then
                print_warning "$test_name failed (attempt $attempt/$max_attempts), retrying..."
            else
                print_error "$test_name failed after $max_attempts attempts"
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    return 1
}

# Run tests on iOS local with enhanced error handling
run_ios_local_tests() {
    print_header "RUNNING TESTS ON LOCAL iOS"
    
    if ! start_ios_local; then
        print_error "Failed to start iOS simulator"
        return 0
    fi
    
    local success_count=0
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        if [ -f "$test_file" ]; then
            if run_patrol_test_enhanced "ios" "$test_file" "$IOS_LOCAL_UDID"; then
                success_count=$((success_count + 1))
            fi
        else
            print_warning "Test file not found: $test_file"
        fi
    done
    
    print_info "iOS local tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run tests on Android local with enhanced error handling
run_android_local_tests() {
    print_header "RUNNING TESTS ON LOCAL ANDROID"
    
    if ! start_android_local; then
        print_error "Failed to start Android emulator"
        return 0
    fi
    
    local success_count=0
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    # Get Android device ID
    local android_device_id=$(adb devices | grep "emulator" | head -1 | cut -f1)
    
    if [ -z "$android_device_id" ]; then
        print_error "No Android emulator device found"
        return 0
    fi
    
    print_info "Using Android device: $android_device_id"
    
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        if [ -f "$test_file" ]; then
            if run_patrol_test_enhanced "android" "$test_file" "$android_device_id"; then
                success_count=$((success_count + 1))
            fi
        else
            print_warning "Test file not found: $test_file"
        fi
    done
    
    print_info "Android local tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run single test file
run_single_test() {
    local test_file="${TEST_FILE:-integration_test/tests/hotels_test.dart}"
    
    if [ ! -f "$test_file" ]; then
        print_error "Test file not found: $test_file"
        print_info "Available test files:"
        for file in "${INTEGRATION_TESTS[@]}"; do
            echo "  $file"
        done
        return 0
    fi
    
    print_header "RUNNING SINGLE TEST: $(basename "$test_file")"
    
    local platform="ios"
    local device_id="$IOS_LOCAL_UDID"
    
    # Start appropriate device
    if [[ "$TARGET" == *"android"* ]] || [[ "$OSTYPE" != "darwin"* ]]; then
        platform="android"
        if start_android_local; then
            device_id=$(adb devices | grep "emulator" | head -1 | cut -f1)
        else
            return 0
        fi
    else
        if ! start_ios_local; then
            return 0
        fi
    fi
    
    if run_patrol_test_enhanced "$platform" "$test_file" "$device_id"; then
        return 1
    else
        return 0
    fi
}

# Generate comprehensive test report
generate_test_report() {
    local success_count=$1
    local total_tests=${#INTEGRATION_TESTS[@]}
    local report_file="$REPORTS_DIR/test_summary.html"
    
    print_step "Generating test report..."
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Integration Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .success { color: green; }
        .failure { color: red; }
        .warning { color: orange; }
        .test-result { margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 3px; }
        .log-preview { background: #f9f9f9; padding: 10px; font-family: monospace; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Integration Test Report</h1>
        <p><strong>Target:</strong> $TARGET</p>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Success Rate:</strong> $success_count/$total_tests tests passed</p>
    </div>
    
    <h2>Test Results</h2>
EOF
    
    # Add individual test results
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        local test_name=$(basename "$test_file" .dart)
        local status_file="$LOGS_DIR/*_${test_name}.status"
        local log_file="$LOGS_DIR/*_${test_name}.log"
        
        if ls $status_file 1> /dev/null 2>&1; then
            local status=$(cat $status_file 2>/dev/null || echo "UNKNOWN")
            local class="success"
            if [[ "$status" == "FAILED"* ]]; then
                class="failure"
            fi
            
            echo "<div class='test-result'>" >> "$report_file"
            echo "<h3 class='$class'>$test_name: $status</h3>" >> "$report_file"
            
            if ls $log_file 1> /dev/null 2>&1; then
                echo "<details><summary>View Log</summary>" >> "$report_file"
                echo "<div class='log-preview'>" >> "$report_file"
                tail -20 $log_file 2>/dev/null | sed 's/</\&lt;/g; s/>/\&gt;/g' >> "$report_file"
                echo "</div></details>" >> "$report_file"
            fi
            
            echo "</div>" >> "$report_file"
        fi
    done
    
    echo "</body></html>" >> "$report_file"
    
    print_success "Test report generated: $report_file"
}

# Generate Allure report with fallback
generate_allure_report() {
    if [ ! -d "$ALLURE_RESULTS_DIR" ] || [ -z "$(ls -A $ALLURE_RESULTS_DIR 2>/dev/null)" ]; then
        print_warning "No Allure results found in $ALLURE_RESULTS_DIR"
        
        # Create basic Allure results from logs
        print_step "Creating basic Allure results from test logs..."
        create_fallback_allure_results
        
        if [ -z "$(ls -A $ALLURE_RESULTS_DIR 2>/dev/null)" ]; then
            return 1
        fi
    fi
    
    print_step "Generating Allure report..."
    
    if command -v allure &> /dev/null; then
        if allure generate "$ALLURE_RESULTS_DIR" -o "allure-report" --clean 2>/dev/null; then
            print_success "Allure report generated: allure-report/index.html"
            
            # Try to open in browser
            if [ -f "allure-report/index.html" ]; then
                if command -v open &> /dev/null; then
                    open "allure-report/index.html" 2>/dev/null &
                elif command -v xdg-open &> /dev/null; then
                    xdg-open "allure-report/index.html" 2>/dev/null &
                fi
            fi
            
            return 0
        else
            print_error "Failed to generate Allure report"
            return 1
        fi
    else
        print_warning "Allure CLI not available. Install with: npm install -g allure-commandline"
        print_info "Raw Allure results available in: $ALLURE_RESULTS_DIR"
        return 1
    fi
}

# Create fallback Allure results from test logs
create_fallback_allure_results() {
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        local test_name=$(basename "$test_file" .dart)
        local status_files=($LOGS_DIR/*_${test_name}.status)
        
        if [ -f "${status_files[0]}" ]; then
            local status=$(cat "${status_files[0]}" 2>/dev/null || echo "unknown")
            local uuid=$(date +%s%N | md5sum | cut -c1-32 2>/dev/null || echo "test-$test_name")
            
            # Create basic Allure result
            cat > "$ALLURE_RESULTS_DIR/$uuid-result.json" << EOF
{
  "uuid": "$uuid",
  "name": "$test_name",
  "fullName": "$test_file",
  "status": "$(echo $status | tr '[:upper:]' '[:lower:]' | sed 's/failed.*/failed/' | sed 's/success/passed/')",
  "start": $(date +%s000),
  "stop": $(date +%s000),
  "labels": [
    {"name": "framework", "value": "patrol"},
    {"name": "language", "value": "dart"},
    {"name": "suite", "value": "integration"}
  ]
}
EOF
        fi
    done
}

# Display comprehensive summary
display_summary() {
    local success_count=$1
    local target_description="$2"
    local total_tests=${#INTEGRATION_TESTS[@]}
    
    print_header "TEST EXECUTION SUMMARY"
    
    echo -e "${BLUE}Target:${NC} $target_description"
    echo -e "${BLUE}Successful Tests:${NC} ${GREEN}$success_count${NC}/$total_tests"
    echo -e "${BLUE}Failed Tests:${NC} ${RED}$((total_tests - success_count))${NC}/$total_tests"
    
    if [ $total_tests -gt 0 ]; then
        local success_rate=$((success_count * 100 / total_tests))
        echo -e "${BLUE}Success Rate:${NC} $success_rate%"
    fi
    
    echo ""
    echo -e "${BLUE}Test Files Executed:${NC}"
    for test_file in "${INTEGRATION_TESTS[@]}"; do
        local test_name=$(basename "$test_file" .dart)
        local status_files=($LOGS_DIR/*_${test_name}.status)
        local status="NOT_RUN"
        
        if [ -f "${status_files[0]}" ]; then
            status=$(cat "${status_files[0]}" 2>/dev/null || echo "UNKNOWN")
        fi
        
        case $status in
            "SUCCESS")
                echo -e "  ${GREEN}✅${NC} $test_name"
                ;;
            "FAILED"*)
                echo -e "  ${RED}❌${NC} $test_name"
                ;;
            *)
                echo -e "  ${YELLOW}⚠️${NC} $test_name ($status)"
                ;;
        esac
    done
    
    echo ""
    echo -e "${BLUE}Generated Artifacts:${NC}"
    echo -e "  📄 Test Logs: ${LOGS_DIR}/"
    echo -e "  📊 Test Report: ${REPORTS_DIR}/test_summary.html"
    echo -e "  📸 Screenshots: ${SCREENSHOTS_DIR}/"
    echo -e "  📋 Allure Results: ${ALLURE_RESULTS_DIR}/"
    
    if [ -f "allure-report/index.html" ]; then
        echo -e "  🎯 Allure Report: ${GREEN}allure-report/index.html${NC}"
    fi
    
    # Show log file locations for failed tests
    local failed_count=$((total_tests - success_count))
    if [ $failed_count -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Failed Test Logs:${NC}"
        for test_file in "${INTEGRATION_TESTS[@]}"; do
            local test_name=$(basename "$test_file" .dart)
            local status_files=($LOGS_DIR/*_${test_name}.status)
            
            if [ -f "${status_files[0]}" ]; then
                local status=$(cat "${status_files[0]}" 2>/dev/null)
                if [[ "$status" == "FAILED"* ]]; then
                    local log_files=($LOGS_DIR/*_${test_name}.log)
                    if [ -f "${log_files[0]}" ]; then
                        echo -e "  ${RED}📋${NC} $test_name: ${log_files[0]}"
                    fi
                fi
            fi
        done
    fi
}

# Cleanup function
cleanup() {
    print_step "Cleaning up..."
    
    # Kill any remaining emulator processes if needed
    if pgrep emulator > /dev/null; then
        print_info "Stopping Android emulators..."
        pkill emulator 2>/dev/null || true
        sleep 2
    fi
    
    print_success "Cleanup completed"
}

# Main execution function
main() {
    # Set up cleanup trap
    trap cleanup EXIT
    
    print_header "ENHANCED PATROL INTEGRATION TEST RUNNER"
    
    validate_target
    verify_project_structure
    setup_directories
    clean_previous_results
    check_dependencies
    
    # Prepare Flutter environment
    print_step "Preparing Flutter environment..."
    flutter clean > /dev/null 2>&1
    flutter pub get > /dev/null 2>&1
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
        "local")
            # Run on best available platform
            if [[ "$OSTYPE" == "darwin"* ]] && command -v xcrun &> /dev/null; then
                success_count=$(run_ios_local_tests)
                target_description="Local iOS Simulator"
            else
                success_count=$(run_android_local_tests)
                target_description="Local Android Emulator"
            fi
            ;;
        "single")
            success_count=$(run_single_test)
            target_description="Single Test: ${TEST_FILE:-hotels_test.dart}"
            ;;
    esac
    
    # Generate reports
    generate_test_report $success_count
    generate_allure_report
    
    # Display summary
    display_summary $success_count "$target_description"
    
    # Exit with appropriate code
    if [ $success_count -gt 0 ]; then
        print_success "Integration tests completed with $success_count successful test(s)"
        exit 0
    else
        print_error "All integration tests failed or were skipped"
        exit 1
    fi
}

# Show help
show_help() {
    echo "Enhanced Patrol Integration Test Runner"
    echo ""
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Targets:"
    echo "  ios-local     - Run on local iOS simulator"
    echo "  android-local - Run on local Android emulator"  
    echo "  local         - Run on best available local device"
    echo "  single        - Run single test file"
    echo ""
    echo "Environment Variables:"
    echo "  TEST_FILE     - Specific test file for 'single' target"
    echo "  VERBOSE       - Enable verbose output (true/false)"
    echo "  RETRY_COUNT   - Number of retry attempts (default: 3)"
    echo ""
    echo "Examples:"
    echo "  $0 ios-local"
    echo "  TEST_FILE=integration_test/tests/hotels_test.dart $0 single"
    echo "  VERBOSE=true $0 local"
    echo ""
}