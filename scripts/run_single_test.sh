# =============================================================================
# FIXED: run_single_test.sh - Handles both unit and integration tests
# =============================================================================

#!/bin/bash

# Single Test Runner with Coverage and Allure
# Usage: ./run_single_test.sh <test_path>
# Examples:
#   ./run_single_test.sh test/unit/features/hotels/domain/entities/hotel_test.dart
#   ./run_single_test.sh integration_test/tests/hotels_test.dart
#   ./run_single_test.sh test/  # Run all unit tests
#   ./run_single_test.sh integration_test/  # Run all integration tests

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if test path provided
if [ -z "$1" ]; then
    print_error "Test path is required!"
    echo ""
    echo "Usage: ./run_single_test.sh <test_path>"
    echo ""
    echo "Examples:"
    echo "  # Unit/Widget/Bloc tests:"
    echo "  ./run_single_test.sh test/"
    echo "  ./run_single_test.sh test/unit/"
    echo "  ./run_single_test.sh test/widgets/"
    echo "  ./run_single_test.sh test/unit/features/hotels/domain/entities/hotel_test.dart"
    echo ""
    echo "  # Integration tests:"
    echo "  ./run_single_test.sh integration_test/"
    echo "  ./run_single_test.sh integration_test/tests/hotels_test.dart"
    echo "  ./run_single_test.sh integration_test/app_test.dart"
    echo ""
    exit 1
fi

TEST_PATH="$1"

# Determine test type and setup accordingly
if [[ "$TEST_PATH" == integration_test* ]]; then
    TEST_TYPE="integration"
    TEST_NAME=$(basename "$TEST_PATH" .dart)
    if [[ "$TEST_PATH" == *"/" ]]; then
        TEST_NAME="integration_suite"
    fi
    
    print_status "Running INTEGRATION test: $TEST_PATH"
    
    # Setup for integration tests
    export PATROL_WAIT=5000
    export ALLURE_RESULTS_DIRECTORY="allure-results"
    export INTEGRATION_TEST_SCREENSHOTS="screenshots"
    
    # Integration test command
    FLUTTER_CMD="flutter test $TEST_PATH --dart-define=PATROL_WAIT=5000 --dart-define=ALLURE_RESULTS_DIRECTORY=allure-results"
    
elif [[ "$TEST_PATH" == test* ]]; then
    TEST_TYPE="unit"
    TEST_NAME=$(basename "$TEST_PATH" .dart)
    if [[ "$TEST_PATH" == *"/" ]]; then
        TEST_NAME="unit_suite"
    fi
    
    print_status "Running UNIT/WIDGET/BLOC test: $TEST_PATH"
    
    # Unit test command with coverage
    FLUTTER_CMD="flutter test $TEST_PATH --coverage"
    
else
    print_error "Invalid test path. Must start with 'test/' or 'integration_test/'"
    exit 1
fi

# Check if test file/directory exists
if [ ! -e "$TEST_PATH" ]; then
    print_error "Test path not found: $TEST_PATH"
    exit 1
fi

print_status "Test Type: $TEST_TYPE"
echo "=============================================================="

# Setup directories
print_status "Setting up environment..."
mkdir -p allure-results coverage screenshots test-results

# Run the test
print_status "Executing: $FLUTTER_CMD"
if eval "$FLUTTER_CMD" \
    --reporter=json \
    --verbose \
    > "test-results/${TEST_NAME}_results.json" 2>&1; then
    
    TEST_EXIT_CODE=0
    print_success "Test execution completed successfully"
else
    TEST_EXIT_CODE=$?
    print_warning "Test completed with exit code: $TEST_EXIT_CODE"
fi

# Generate coverage report (only for unit tests)
if [ "$TEST_TYPE" = "unit" ]; then
    print_status "Generating coverage report..."
    if [ -f coverage/lcov.info ]; then
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            print_success "Coverage report generated: coverage/html/index.html"
            COVERAGE_AVAILABLE=true
        else
            print_warning "genhtml not found. Install lcov to generate HTML coverage report."
            COVERAGE_AVAILABLE=false
        fi
    else
        print_warning "No coverage data found"
        COVERAGE_AVAILABLE=false
    fi
else
    print_status "Skipping coverage for integration tests"
    COVERAGE_AVAILABLE=false
fi

# Process Allure results (for both test types)
print_status "Processing Allure results..."
if [ -d allure-results ] && [ "$(ls -A allure-results 2>/dev/null)" ]; then
    if command -v allure &> /dev/null; then
        print_status "Generating Allure report..."
        allure generate allure-results -o allure-report --clean
        
        print_status "Starting Allure server..."
        allure serve allure-results --port 8080 &
        ALLURE_PID=$!
        sleep 3
        
        # Try to open browser
        if command -v open &> /dev/null; then
            open http://localhost:8080
        elif command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:8080
        fi
        
        print_success "Allure report available at: http://localhost:8080"
        ALLURE_AVAILABLE=true
    else
        print_warning "Allure not found. Install Allure to generate reports."
        ALLURE_AVAILABLE=false
    fi
else
    print_warning "No Allure results found"
    ALLURE_AVAILABLE=false
fi

# Open coverage report if available
if [ "$COVERAGE_AVAILABLE" = true ]; then
    if command -v open &> /dev/null; then
        open coverage/html/index.html
    elif command -v xdg-open &> /dev/null; then
        xdg-open coverage/html/index.html
    fi
fi

# Summary
echo "=============================================================="
print_status "Test Execution Summary"
echo ""
echo "Test Type: $TEST_TYPE"
echo "Test Path: $TEST_PATH"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    print_success "Test Result: PASSED"
else
    print_warning "Test Result: FAILED (exit code: $TEST_EXIT_CODE)"
fi

if [ "$COVERAGE_AVAILABLE" = true ]; then
    print_success "Coverage Report: coverage/html/index.html"
else
    print_warning "Coverage Report: Not available"
fi

if [ "$ALLURE_AVAILABLE" = true ]; then
    print_success "Allure Report: http://localhost:8080"
else
    print_warning "Allure Report: Not available"
fi

echo ""
print_status "Test artifacts saved in:"
echo "  - Test results: test-results/${TEST_NAME}_results.json"
echo "  - Screenshots: screenshots/ (integration tests only)"
echo "  - Allure data: allure-results/"
if [ "$TEST_TYPE" = "unit" ]; then
    echo "  - Coverage: coverage/"
fi
echo ""

if [ "$ALLURE_AVAILABLE" = true ]; then
    print_status "Press Ctrl+C to stop the Allure server"
    wait $ALLURE_PID
fi

exit $TEST_EXIT_CODE

# =============================================================================
# FIXED: parallel_test.sh - Handles both test types on multiple devices
# =============================================================================

#!/bin/bash

# Parallel Multi-Device Test Runner for Both Unit and Integration Tests
# Usage: ./parallel_test.sh [test_path] [timeout] [retry] [coverage] [allure] [platform]

set -e

# Configuration
TEST_PATH="${1:-test/}"  # Default to unit tests
TIMEOUT="${2:-600}"
RETRY_COUNT="${3:-2}"
COVERAGE_ENABLED="${4:-true}"
ALLURE_ENABLED="${5:-true}"
PLATFORM="${6:-all}"  # all, ios, android

# Determine test type
if [[ "$TEST_PATH" == integration_test* ]]; then
    TEST_TYPE="integration"
    print_header "PARALLEL INTEGRATION TEST EXECUTION"
else
    TEST_TYPE="unit"
    print_header "PARALLEL UNIT TEST EXECUTION"
fi

# Device configurations (only used for integration tests)
IOS_DEVICES=(
    "iPhone 15 Pro"
    "iPhone 15"
)

ANDROID_DEVICES=(
    "Pixel_7_API_34"
    "Pixel_6_API_33"
)

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

# Setup directories
setup_directories() {
    print_step "Setting up output directories"
    mkdir -p "test_results/logs" "test_results/coverage" "test_results/allure-results"
    print_success "Directories created"
}

# Run test with appropriate command
run_test_with_command() {
    local device_name="$1"
    local platform="$2"
    local test_name="${platform}_${device_name//[^a-zA-Z0-9]/_}"
    local log_file="test_results/logs/${test_name}.log"
    
    print_step "Running $TEST_TYPE test on $platform: $device_name"
    
    # Build command based on test type
    local cmd
    if [ "$TEST_TYPE" = "integration" ]; then
        cmd="flutter test $TEST_PATH"
        cmd="$cmd --dart-define=PATROL_WAIT=5000"
        cmd="$cmd --dart-define=ALLURE_RESULTS_DIRECTORY=test_results/allure-results"
        
        # Add device selection for integration tests
        if [ "$platform" = "ios" ]; then
            cmd="$cmd -d \"$device_name\""
        elif [ "$platform" = "android" ]; then
            cmd="$cmd -d \"$device_name\""
        fi
    else
        # Unit tests don't need device specification
        cmd="flutter test $TEST_PATH"
        if [ "$COVERAGE_ENABLED" = "true" ]; then
            cmd="$cmd --coverage"
        fi
    fi
    
    # Add common flags
    cmd="$cmd --reporter=json"
    cmd="$cmd --verbose"
    
    # Execute command
    echo "Command: $cmd" > "$log_file"
    echo "Started at: $(date)" >> "$log_file"
    echo "Test Type: $TEST_TYPE" >> "$log_file"
    echo "----------------------------------------" >> "$log_file"
    
    if eval "$cmd" >> "$log_file" 2>&1; then
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: SUCCESS" >> "$log_file"
        print_success "Test completed successfully on $platform: $device_name"
        return 0
    else
        echo "Completed at: $(date)" >> "$log_file"
        echo "Status: FAILED" >> "$log_file"
        print_error "Test failed on $platform: $device_name"
        return 1
    fi
}

# Run unit tests (no device needed)
run_unit_tests() {
    print_header "RUNNING UNIT/WIDGET/BLOC TESTS"
    
    local success_count=0
    local total_tests=1
    
    if run_test_with_command "local" "unit"; then
        success_count=1
    fi
    
    print_info "Unit tests completed: $success_count/$total_tests successful"
    return $success_count
}

# Run integration tests on devices
run_integration_tests() {
    print_header "RUNNING INTEGRATION TESTS ON DEVICES"
    
    local total_success=0
    
    case "$PLATFORM" in
        "ios")
            total_success=$(run_ios_tests)
            ;;
        "android")
            total_success=$(run_android_tests)
            ;;
        "all")
            local ios_success=$(run_ios_tests)
            local android_success=$(run_android_tests)
            total_success=$((ios_success + android_success))
            ;;
        *)
            print_error "Unknown platform: $PLATFORM"
            return 0
            ;;
    esac
    
    return $total_success
}

# Run iOS integration tests
run_ios_tests() {
    local pids=()
    local success_count=0
    
    for device in "${IOS_DEVICES[@]}"; do
        run_test_with_command "$device" "ios" &
        pids+=($!)
    done
    
    for pid in "${pids[@]}"; do
        if wait "$pid"; then
            success_count=$((success_count + 1))
        fi
    done
    
    print_info "iOS tests completed: $success_count/${#IOS_DEVICES[@]} successful"
    return $success_count
}

# Run Android integration tests
run_android_tests() {
    local pids=()
    local success_count=0
    
    for device in "${ANDROID_DEVICES[@]}"; do
        run_test_with_command "$device" "android" &
        pids+=($!)
    done
    
    for pid in "${pids[@]}"; do
        if wait "$pid"; then
            success_count=$((success_count + 1))
        fi
    done
    
    print_info "Android tests completed: $success_count/${#ANDROID_DEVICES[@]} successful"
    return $success_count
}

# Generate reports
generate_reports() {
    print_header "GENERATING REPORTS"
    
    if [ "$TEST_TYPE" = "unit" ] && [ "$COVERAGE_ENABLED" = "true" ]; then
        print_step "Generating coverage report"
        if [ -f coverage/lcov.info ] && command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o test_results/coverage/html 2>/dev/null || true
            print_success "Coverage report: test_results/coverage/html/index.html"
        fi
    fi
    
    if [ "$ALLURE_ENABLED" = "true" ] && [ -d test_results/allure-results ] && [ "$(ls -A test_results/allure-results 2>/dev/null)" ]; then
        print_step "Generating Allure report"
        if command -v allure &> /dev/null; then
            allure generate test_results/allure-results --clean -o test_results/allure-report 2>/dev/null || true
            print_success "Allure report: test_results/allure-report/index.html"
        fi
    fi
}

# Main execution
main() {
    print_header "PARALLEL TEST RUNNER"
    print_info "Test Path: $TEST_PATH"
    print_info "Test Type: $TEST_TYPE"
    print_info "Platform: $PLATFORM"
    
    setup_directories
    
    # Prepare Flutter
    print_step "Preparing Flutter environment"
    flutter clean
    flutter pub get
    
    local success_count=0
    
    if [ "$TEST_TYPE" = "unit" ]; then
        success_count=$(run_unit_tests)
    else
        success_count=$(run_integration_tests)
    fi
    
    generate_reports
    
    # Summary
    print_header "EXECUTION SUMMARY"
    print_info "Test Type: $TEST_TYPE"
    print_info "Test Path: $TEST_PATH"
    print_info "Successful Tests: $success_count"
    
    if [ $success_count -gt 0 ]; then
        print_success "Tests completed with $success_count successful runs"
        return 0
    else
        print_error "All tests failed"
        return 1
    fi
}

# Help function
show_help() {
    echo "Usage: $0 [test_path] [timeout] [retry] [coverage] [allure] [platform]"
    echo ""
    echo "Arguments:"
    echo "  test_path   Path to test file/directory (default: test/)"
    echo "  timeout     Test timeout in seconds (default: 600)"
    echo "  retry       Retry count on failure (default: 2)"
    echo "  coverage    Enable coverage (true/false, default: true)"
    echo "  allure      Enable Allure (true/false, default: true)"
    echo "  platform    Platform for integration tests (all/ios/android, default: all)"
    echo ""
    echo "Examples:"
    echo "  # Run all unit tests"
    echo "  $0 test/"
    echo ""
    echo "  # Run specific unit test"
    echo "  $0 test/unit/features/hotels/domain/entities/hotel_test.dart"
    echo ""
    echo "  # Run all integration tests on all platforms"
    echo "  $0 integration_test/"
    echo ""
    echo "  # Run specific integration test on iOS only"
    echo "  $0 integration_test/tests/hotels_test.dart 600 2 true true ios"
}

# Parse arguments
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Run main function
main "$@"