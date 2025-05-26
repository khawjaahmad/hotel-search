#!/bin/bash

# Single Test Runner with Coverage and Allure
# Usage: ./run_single_test.sh <test_name>

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

# Check if test name provided
if [ -z "$1" ]; then
    print_error "Test name is required!"
    echo ""
    echo "Usage: ./run_single_test.sh <test_name>"
    echo ""
    echo "Available tests:"
    echo "  hotels_test"
    echo "  overview_page_test"
    echo "  favorites_test"  
    echo "  account_test"
    echo "  dashboard_test"
    echo ""
    echo "Example: ./run_single_test.sh hotels_test"
    exit 1
fi

TEST_NAME="$1"
TEST_FILE="integration_test/tests/${TEST_NAME}.dart"

# Check if test file exists
if [ ! -f "$TEST_FILE" ]; then
    print_error "Test file not found: $TEST_FILE"
    exit 1
fi

print_status "Running single test with coverage and Allure: $TEST_NAME"
echo "=============================================================="

# Setup directories
print_status "Setting up environment..."
mkdir -p allure-results coverage screenshots test-results

# Set environment variables
export PATROL_WAIT=5000
export ALLURE_RESULTS_DIRECTORY="allure-results"
export INTEGRATION_TEST_SCREENSHOTS="screenshots"

# Run the test
print_status "Executing test: $TEST_FILE"
if flutter test "$TEST_FILE" \
    --coverage \
    --dart-define=PATROL_WAIT=5000 \
    --dart-define=ALLURE_RESULTS_DIRECTORY="allure-results" \
    --reporter=json \
    --verbose \
    > "test-results/${TEST_NAME}_results.json" 2>&1; then
    
    TEST_EXIT_CODE=0
    print_success "Test execution completed"
else
    TEST_EXIT_CODE=$?
    print_warning "Test completed with exit code: $TEST_EXIT_CODE"
fi

# Generate coverage report
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

# Process Allure results
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
echo "Test: $TEST_NAME"
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
echo "  - Screenshots: screenshots/"
echo "  - Allure data: allure-results/"
echo ""

if [ "$ALLURE_AVAILABLE" = true ]; then
    print_status "Press Ctrl+C to stop the Allure server"
    wait $ALLURE_PID
fi