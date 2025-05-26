#!/bin/bash

# Enhanced Test Runner with Allure Support for Unit, Widget, and Integration Tests
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================================================${NC}"
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
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Configuration
TEST_TYPE="${1:-all}"
ALLURE_RESULTS_DIR="allure-results"
ALLURE_REPORT_DIR="allure-report"
COVERAGE_DIR="coverage"
TEST_RESULTS_DIR="test-results"

# Setup directories
setup_directories() {
    print_info "Setting up directories..."
    mkdir -p "$ALLURE_RESULTS_DIR" "$ALLURE_REPORT_DIR" "$COVERAGE_DIR" "$TEST_RESULTS_DIR"
    print_success "Directories created"
}

# Clean previous results
clean_previous_results() {
    print_info "Cleaning previous results..."
    rm -rf "$ALLURE_RESULTS_DIR"/* "$ALLURE_REPORT_DIR"/* "$COVERAGE_DIR"/* "$TEST_RESULTS_DIR"/* 2>/dev/null || true
    print_success "Previous results cleaned"
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter."
        exit 1
    fi
    
    # Check Node.js for Allure conversion
    if ! command -v node &> /dev/null; then
        print_warning "Node.js not found. Allure conversion will be limited."
        NODE_AVAILABLE=false
    else
        NODE_AVAILABLE=true
    fi
    
    # Check Allure CLI
    if ! command -v allure &> /dev/null; then
        print_warning "Allure CLI not found. Install with: npm install -g allure-commandline"
        ALLURE_CLI_AVAILABLE=false
    else
        ALLURE_CLI_AVAILABLE=true
    fi
    
    # Check lcov for coverage
    if ! command -v genhtml &> /dev/null; then
        print_warning "genhtml not found. Install lcov for HTML coverage reports."
        LCOV_AVAILABLE=false
    else
        LCOV_AVAILABLE=true
    fi
    
    print_success "Dependencies checked"
}

# Convert test results to Allure format
convert_to_allure() {
    local test_type="$1"
    local json_file="$TEST_RESULTS_DIR/${test_type}_results.json"
    
    if [ ! -f "$json_file" ]; then
        print_warning "No test results found for $test_type"
        return 1
    fi
    
    print_info "Converting $test_type test results to Allure format..."
    
    # Create conversion script inline
    node << EOF
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const testResultsPath = '$json_file';
const allureResultsDir = '$ALLURE_RESULTS_DIR';

if (!fs.existsSync(testResultsPath)) {
    console.error('Test results file not found:', testResultsPath);
    process.exit(1);
}

const testResults = fs.readFileSync(testResultsPath, 'utf8')
    .split('\n')
    .filter(line => line.trim())
    .map(line => {
        try {
            return JSON.parse(line);
        } catch (e) {
            return null;
        }
    })
    .filter(result => result !== null);

const testCases = new Map();
let totalTests = 0, passedTests = 0, failedTests = 0;

testResults.forEach(event => {
    if (event.type === 'testStart') {
        const testCase = {
            name: event.test.name,
            uuid: uuidv4(),
            fullName: event.test.name,
            labels: [
                { name: 'suite', value: '$test_type' },
                { name: 'framework', value: 'flutter_test' },
                { name: 'language', value: 'dart' },
                { name: 'testType', value: '$test_type' }
            ],
            status: 'unknown',
            start: Date.now()
        };
        testCases.set(event.test.id, testCase);
    }
    
    if (event.type === 'testDone') {
        const testCase = testCases.get(event.testID);
        if (testCase) {
            testCase.stop = Date.now();
            totalTests++;
            
            if (event.result === 'success') {
                testCase.status = 'passed';
                passedTests++;
            } else {
                testCase.status = 'failed';
                failedTests++;
                testCase.statusDetails = {
                    message: event.error || 'Test failed',
                    trace: event.stackTrace || ''
                };
            }
            
            const resultPath = \`\${allureResultsDir}/\${testCase.uuid}-result.json\`;
            fs.writeFileSync(resultPath, JSON.stringify(testCase, null, 2));
        }
    }
});

console.log(\`✅ \${test_type}: Total: \${totalTests}, Passed: \${passedTests}, Failed: \${failedTests}\`);
EOF

    if [ $? -eq 0 ]; then
        print_success "$test_type results converted to Allure format"
    else
        print_error "Failed to convert $test_type results"
    fi
}

# Run unit tests
run_unit_tests() {
    print_header "RUNNING UNIT TESTS"
    
    print_info "Executing unit tests with coverage..."
    
    if flutter test test/unit/ \
        --coverage \
        --reporter=json \
        --file-reporter=json:"$TEST_RESULTS_DIR/unit_results.json" \
        test/unit/; then
        
        print_success "Unit tests completed successfully"
        
        if [ "$NODE_AVAILABLE" = true ]; then
            convert_to_allure "unit"
        fi
        
        return 0
    else
        print_error "Unit tests failed"
        
        if [ "$NODE_AVAILABLE" = true ]; then
            convert_to_allure "unit"
        fi
        
        return 1
    fi
}

# Run widget tests
run_widget_tests() {
    print_header "RUNNING WIDGET TESTS"
    
    print_info "Executing widget tests..."
    
    if flutter test test/widgets/ \
        --coverage \
        --reporter=json \
        --file-reporter=json:"$TEST_RESULTS_DIR/widget_results.json" \
        test/widgets/; then
        
        print_success "Widget tests completed successfully"
        
        if [ "$NODE_AVAILABLE" = true ]; then
            convert_to_allure "widget"
        fi
        
        return 0
    else
        print_error "Widget tests failed"
        
        if [ "$NODE_AVAILABLE" = true ]; then
            convert_to_allure "widget"
        fi
        
        return 1
    fi
}

# Run integration tests
run_integration_tests() {
    print_header "RUNNING INTEGRATION TESTS"
    
    print_info "Executing integration tests..."
    
    # Check for available devices
    local devices=$(flutter devices --machine | jq -r '.[].id' 2>/dev/null || echo "")
    
    if [ -z "$devices" ]; then
        print_error "No devices available for integration tests"
        print_info "Please start an emulator or simulator first"
        return 1
    fi
    
    print_info "Available devices: $devices"
    
    if flutter test integration_test/ \
        --dart-define=PATROL_WAIT=5000 \
        --dart-define=ALLURE_RESULTS_DIRECTORY="$ALLURE_RESULTS_DIR" \
        --reporter=json \
        --file-reporter=json:"$TEST_RESULTS_DIR/integration_results.json"; then
        
        print_success "Integration tests completed successfully"
        return 0
    else
        print_error "Integration tests failed"
        return 1
    fi
}

# Generate coverage report
generate_coverage_report() {
    print_info "Generating coverage report..."
    
    if [ -f "coverage/lcov.info" ]; then
        if [ "$LCOV_AVAILABLE" = true ]; then
            genhtml coverage/lcov.info -o "$COVERAGE_DIR/html" 2>/dev/null || {
                print_warning "Could not generate HTML coverage report"
            }
            print_success "Coverage report generated: $COVERAGE_DIR/html/index.html"
        else
            print_info "Coverage data available at: coverage/lcov.info"
        fi
    else
        print_warning "No coverage data found"
    fi
}

# Generate Allure report
generate_allure_report() {
    print_info "Generating Allure report..."
    
    # Check if we have any Allure results
    if [ ! -d "$ALLURE_RESULTS_DIR" ] || [ -z "$(ls -A $ALLURE_RESULTS_DIR 2>/dev/null)" ]; then
        print_warning "No Allure results found"
        return 1
    fi
    
    if [ "$ALLURE_CLI_AVAILABLE" = true ]; then
        if allure generate "$ALLURE_RESULTS_DIR" -o "$ALLURE_REPORT_DIR" --clean; then
            print_success "Allure report generated: $ALLURE_REPORT_DIR/index.html"
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

# Open reports
open_reports() {
    print_info "Opening reports..."
    
    # Open Allure report
    if [ -f "$ALLURE_REPORT_DIR/index.html" ]; then
        if command -v open &> /dev/null; then
            # macOS
            open "$ALLURE_REPORT_DIR/index.html"
            print_success "Allure report opened"
        elif command -v xdg-open &> /dev/null; then
            # Linux
            xdg-open "$ALLURE_REPORT_DIR/index.html"
            print_success "Allure report opened"
        else
            print_info "Open manually: $ALLURE_REPORT_DIR/index.html"
        fi
    fi
    
    # Open coverage report
    if [ -f "$COVERAGE_DIR/html/index.html" ]; then
        if command -v open &> /dev/null; then
            # macOS
            open "$COVERAGE_DIR/html/index.html"
            print_success "Coverage report opened"
        elif command -v xdg-open &> /dev/null; then
            # Linux
            xdg-open "$COVERAGE_DIR/html/index.html"
            print_success "Coverage report opened"
        else
            print_info "Open manually: $COVERAGE_DIR/html/index.html"
        fi
    fi
}

# Display summary
display_summary() {
    local unit_result=$1
    local widget_result=$2
    local integration_result=$3
    
    print_header "TEST EXECUTION SUMMARY"
    
    echo -e "${BLUE}Test Results:${NC}"
    echo -e "  Unit Tests: $([ $unit_result -eq 0 ] && echo "${GREEN}PASSED${NC}" || echo "${RED}FAILED${NC}")"
    echo -e "  Widget Tests: $([ $widget_result -eq 0 ] && echo "${GREEN}PASSED${NC}" || echo "${RED}FAILED${NC}")"
    echo -e "  Integration Tests: $([ $integration_result -eq 0 ] && echo "${GREEN}PASSED${NC}" || echo "${RED}FAILED${NC}")"
    echo ""
    
    echo -e "${BLUE}Reports:${NC}"
    [ -f "$ALLURE_REPORT_DIR/index.html" ] && echo -e "  Allure Report: ${GREEN}$ALLURE_REPORT_DIR/index.html${NC}"
    [ -f "$COVERAGE_DIR/html/index.html" ] && echo -e "  Coverage Report: ${GREEN}$COVERAGE_DIR/html/index.html${NC}"
    echo ""
    
    echo -e "${BLUE}Raw Data:${NC}"
    echo -e "  Test Results: $TEST_RESULTS_DIR/"
    echo -e "  Allure Data: $ALLURE_RESULTS_DIR/"
    echo -e "  Coverage Data: coverage/"
}

# Show help
show_help() {
    echo "Usage: $0 [TEST_TYPE]"
    echo ""
    echo "TEST_TYPE:"
    echo "  all         Run all tests (unit, widget, integration)"
    echo "  unit        Run unit tests only"
    echo "  widget      Run widget tests only"
    echo "  integration Run integration tests only"
    echo "  help        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0              # Run all tests"
    echo "  $0 unit         # Run only unit tests"
    echo "  $0 widget       # Run only widget tests"
    echo "  $0 integration  # Run only integration tests"
    echo ""
    echo "Reports will be generated automatically if dependencies are available."
}

# Main execution
main() {
    case "$TEST_TYPE" in
        "unit")
            print_header "UNIT TESTS ONLY"
            setup_directories
            clean_previous_results
            check_dependencies
            
            run_unit_tests
            unit_result=$?
            
            generate_coverage_report
            generate_allure_report
            open_reports
            display_summary $unit_result 0 0
            exit $unit_result
            ;;
            
        "widget")
            print_header "WIDGET TESTS ONLY"
            setup_directories
            clean_previous_results
            check_dependencies
            
            run_widget_tests
            widget_result=$?
            
            generate_coverage_report
            generate_allure_report
            open_reports
            display_summary 0 $widget_result 0
            exit $widget_result
            ;;
            
        "integration")
            print_header "INTEGRATION TESTS ONLY"
            setup_directories
            clean_previous_results
            check_dependencies
            
            run_integration_tests
            integration_result=$?
            
            generate_allure_report
            open_reports
            display_summary 0 0 $integration_result
            exit $integration_result
            ;;
            
        "all")
            print_header "ALL TESTS"
            setup_directories
            clean_previous_results
            check_dependencies
            
            # Run all tests
            run_unit_tests
            unit_result=$?
            
            run_widget_tests
            widget_result=$?
            
            run_integration_tests
            integration_result=$?
            
            # Generate reports
            generate_coverage_report
            generate_allure_report
            open_reports
            display_summary $unit_result $widget_result $integration_result
            
            # Exit with failure if any test failed
            if [ $unit_result -ne 0 ] || [ $widget_result -ne 0 ] || [ $integration_result -ne 0 ]; then
                exit 1
            fi
            exit 0
            ;;
            
        "help"|"-h"|"--help")
            show_help
            exit 0
            ;;
            
        *)
            print_error "Unknown test type: $TEST_TYPE"
            show_help
            exit 1
            ;;
    esac
}

# Check if Node.js and uuid are available
if [ "$NODE_AVAILABLE" = true ]; then
    if ! node -e "require('uuid')" 2>/dev/null; then
        print_warning "uuid package not found. Installing..."
        npm install uuid 2>/dev/null || print_warning "Failed to install uuid. Allure conversion may not work."
    fi
fi

main "$@"