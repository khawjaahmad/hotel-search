#!/bin/bash
# scripts/smart_test_runner.sh
# Smart test runner for unit and widget tests with conditional report generation

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

print_step() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# Configuration
TEST_TYPE="$1"
ENABLE_COVERAGE="$2"
ENABLE_ALLURE="$3"

# Validate test type
if [ "$TEST_TYPE" != "unit" ] && [ "$TEST_TYPE" != "widget" ]; then
    print_error "Invalid test type. Use 'unit' or 'widget'"
    exit 1
fi

# Directories
TEST_RESULTS_DIR="test-results"
COVERAGE_DIR="coverage"
ALLURE_RESULTS_DIR="allure-results"
ALLURE_REPORT_DIR="allure-report"

# Setup directories
setup_directories() {
    print_step "Setting up directories..."
    mkdir -p "$TEST_RESULTS_DIR" "$COVERAGE_DIR" "$ALLURE_RESULTS_DIR" "$ALLURE_REPORT_DIR"
    print_success "Directories created"
}

# Clean previous results
clean_previous_results() {
    print_step "Cleaning previous results..."
    rm -rf "$TEST_RESULTS_DIR"/* "$COVERAGE_DIR"/* "$ALLURE_RESULTS_DIR"/* "$ALLURE_REPORT_DIR"/* 2>/dev/null || true
    print_success "Previous results cleaned"
}

# Check dependencies
check_dependencies() {
    print_step "Checking dependencies..."

    # Check Flutter
    if ! command -v flutter &>/dev/null; then
        print_error "Flutter not found"
        exit 1
    fi

    # Check Node.js for Allure conversion (if needed)
    if [ "$ENABLE_ALLURE" = "allure" ] && ! command -v node &>/dev/null; then
        print_warning "Node.js not found. Allure conversion will be limited."
        NODE_AVAILABLE=false
    else
        NODE_AVAILABLE=true
    fi

    # Check zip command availability
    if ! command -v zip &>/dev/null; then
        print_warning "zip command not found. Install zip for report archiving"
    fi

    # Check Allure CLI (if needed)
    if [ "$ENABLE_ALLURE" = "allure" ] && ! command -v allure &>/dev/null; then
        print_warning "Allure CLI not found. Install with: npm install -g allure-commandline"
        ALLURE_CLI_AVAILABLE=false
    else
        ALLURE_CLI_AVAILABLE=true
    fi

    # Check lcov for coverage (if needed)
    if [ "$ENABLE_COVERAGE" = "coverage" ] && ! command -v genhtml &>/dev/null; then
        print_warning "genhtml not found. Install lcov for HTML coverage reports."
        LCOV_AVAILABLE=false
    else
        LCOV_AVAILABLE=true
    fi

    print_success "Dependencies checked"
}

# Install Node.js dependencies if needed
install_node_deps() {
    if [ "$ENABLE_ALLURE" = "allure" ] && [ "$NODE_AVAILABLE" = true ]; then
        if ! node -e "require('uuid')" 2>/dev/null; then
            print_step "Installing Node.js dependencies..."
            npm install uuid --save-dev 2>/dev/null || {
                print_warning "Failed to install uuid package"
                return 1
            }
            print_success "Node.js dependencies installed"
        fi
    fi
}

# Run tests
run_tests() {
    print_header "RUNNING $(echo "$TEST_TYPE" | tr '[:lower:]' '[:upper:]') TESTS"

    # Determine test path
    local test_path
    if [ "$TEST_TYPE" = "unit" ]; then
        test_path="test/unit/"
    else
        test_path="test/widgets/"
    fi

    # Build Flutter command
    local flutter_cmd="flutter test $test_path"

    # Add coverage if requested
    if [ "$ENABLE_COVERAGE" = "coverage" ]; then
        flutter_cmd="$flutter_cmd --coverage"
        print_info "Coverage enabled"
    fi

    # Add JSON reporter for Allure processing
    if [ "$ENABLE_ALLURE" = "allure" ]; then
        flutter_cmd="$flutter_cmd --reporter=json --file-reporter=json:$TEST_RESULTS_DIR/${TEST_TYPE}_results.json"
        print_info "Allure reporting enabled"
    fi

    print_step "Executing: $flutter_cmd"

    # Run the tests
    if eval "$flutter_cmd"; then
        print_success "$TEST_TYPE tests completed successfully"
        return 0
    else
        local exit_code=$?
        print_error "$TEST_TYPE tests failed with exit code: $exit_code"
        return $exit_code
    fi
}

# Convert test results to Allure format
convert_to_allure() {
    if [ "$ENABLE_ALLURE" != "allure" ] || [ "$NODE_AVAILABLE" != true ]; then
        return 0
    fi

    local json_file="$TEST_RESULTS_DIR/${TEST_TYPE}_results.json"

    if [ ! -f "$json_file" ]; then
        print_warning "No test results found for Allure conversion"
        return 1
    fi

    print_step "Converting test results to Allure format..."

    # Create Allure conversion script
    node <<EOF
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
                { name: 'suite', value: '$TEST_TYPE' },
                { name: 'framework', value: 'flutter_test' },
                { name: 'language', value: 'dart' },
                { name: 'testType', value: '$TEST_TYPE' },
                { name: 'feature', value: extractFeature(event.test.name) }
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

function extractFeature(testName) {
    const lower = testName.toLowerCase();
    if (lower.includes('hotel')) return 'Hotels';
    if (lower.includes('favorite')) return 'Favorites';
    if (lower.includes('search')) return 'Search';
    if (lower.includes('bloc')) return 'State Management';
    if (lower.includes('widget')) return 'UI Components';
    return 'Core';
}

// Create environment.properties
const envContent = \`
Test.Type=$TEST_TYPE
Test.Framework=Flutter Test
Execution.Date=\${new Date().toISOString()}
Platform=\${process.platform}
\`;

fs.writeFileSync(\`\${allureResultsDir}/environment.properties\`, envContent);

console.log(\`✅ $TEST_TYPE: Total: \${totalTests}, Passed: \${passedTests}, Failed: \${failedTests}\`);
EOF

    if [ $? -eq 0 ]; then
        print_success "Test results converted to Allure format"
        return 0
    else
        print_error "Failed to convert test results"
        return 1
    fi
}

# Generate coverage report
generate_coverage_report() {
    if [ "$ENABLE_COVERAGE" != "coverage" ]; then
        return 0
    fi

    print_step "Generating coverage report..."

    if [ -f "coverage/lcov.info" ]; then
        if [ "$LCOV_AVAILABLE" = true ]; then
            genhtml coverage/lcov.info -o "$COVERAGE_DIR/html" 2>/dev/null || {
                print_warning "Could not generate HTML coverage report"
                return 1
            }
            print_success "Coverage report generated: $COVERAGE_DIR/html/index.html"
            return 0
        else
            print_info "Coverage data available at: coverage/lcov.info"
            return 0
        fi
    else
        print_warning "No coverage data found"
        return 1
    fi
}

# Generate Allure report
generate_allure_report() {
    if [ "$ENABLE_ALLURE" != "allure" ]; then
        return 0
    fi

    print_step "Generating Allure report..."

    # Check if we have any Allure results
    if [ ! -d "$ALLURE_RESULTS_DIR" ] || [ -z "$(ls -A $ALLURE_RESULTS_DIR 2>/dev/null)" ]; then
        print_warning "No Allure results found"
        return 1
    fi

    if [ "$ALLURE_CLI_AVAILABLE" = true ]; then
        # Clean existing report directory
        rm -rf "$ALLURE_REPORT_DIR"

        # Generate fresh report with all dependencies
        if allure generate "$ALLURE_RESULTS_DIR" -o "$ALLURE_REPORT_DIR" --clean; then
            print_success "Allure report generated successfully"
            
            # Start Allure server in background and open in browser
            print_step "Starting Allure server..."
            allure serve "$ALLURE_RESULTS_DIR" > /dev/null 2>&1 &
            
            print_success "Allure report should open in your default browser"
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

# Open reports in browser
open_reports() {
    local coverage_opened=false
    local allure_opened=false

    # Open coverage report
    if [ "$ENABLE_COVERAGE" = "coverage" ] && [ -f "$COVERAGE_DIR/html/index.html" ]; then
        print_step "Opening coverage report..."
        if command -v open &>/dev/null; then
            # macOS
            open "$COVERAGE_DIR/html/index.html"
            coverage_opened=true
        elif command -v xdg-open &>/dev/null; then
            # Linux
            xdg-open "$COVERAGE_DIR/html/index.html"
            coverage_opened=true
        else
            print_info "Coverage report available at: $COVERAGE_DIR/html/index.html"
        fi

        if [ "$coverage_opened" = true ]; then
            print_success "Coverage report opened in browser"
        fi
    fi

    # Open Allure report
    if [ "$ENABLE_ALLURE" = "allure" ]; then
        print_step "Opening Allure report..."
        if [ -f "${ALLURE_REPORT_DIR%/}.zip" ]; then
            print_success "Allure report archive is ready for viewing"
            print_info "Please extract the zip file and open index.html in your browser"
            print_info "For better viewing experience, you can use: allure open $ALLURE_REPORT_DIR"
        elif [ -d "$ALLURE_REPORT_DIR" ]; then
            if command -v allure &>/dev/null; then
                # Serve the report using Allure's built-in server
                allure open "$ALLURE_REPORT_DIR" &
                print_success "Allure report opened in browser using Allure server"
            else
                print_warning "For better viewing experience, install Allure CLI"
                print_info "Report location: $ALLURE_REPORT_DIR/index.html"
            fi
        fi
    fi
}

# Display summary
display_summary() {
    local test_result=$1

    print_header "TEST EXECUTION SUMMARY"

    echo -e "${BLUE}Test Type:${NC} $(echo "$TEST_TYPE" | tr '[:lower:]' '[:upper:]')"
    echo -e "${BLUE}Test Result:${NC} $([ $test_result -eq 0 ] && echo "${GREEN}PASSED${NC}" || echo "${RED}FAILED${NC}")"
    echo ""

    echo -e "${BLUE}Reports Generated:${NC}"

    if [ "$ENABLE_COVERAGE" = "coverage" ]; then
        if [ -f "$COVERAGE_DIR/html/index.html" ]; then
            echo -e "  Coverage Report: ${GREEN}$COVERAGE_DIR/html/index.html${NC}"
        elif [ -f "coverage/lcov.info" ]; then
            echo -e "  Coverage Data: ${GREEN}coverage/lcov.info${NC}"
        else
            echo -e "  Coverage Report: ${RED}Not available${NC}"
        fi
    fi

    if [ "$ENABLE_ALLURE" = "allure" ]; then
        if [ -f "$ALLURE_REPORT_DIR/index.html" ]; then
            echo -e "  Allure Report: ${GREEN}$ALLURE_REPORT_DIR/index.html${NC}"
        elif [ -d "$ALLURE_RESULTS_DIR" ] && [ "$(ls -A $ALLURE_RESULTS_DIR 2>/dev/null)" ]; then
            echo -e "  Allure Data: ${GREEN}$ALLURE_RESULTS_DIR/${NC}"
        else
            echo -e "  Allure Report: ${RED}Not available${NC}"
        fi
    fi

    echo ""
    echo -e "${BLUE}Raw Data:${NC}"
    echo -e "  Test Results: $TEST_RESULTS_DIR/"
    echo -e "  Coverage Data: coverage/"
}

# Main execution
main() {
    print_header "SMART TEST RUNNER - $(echo "$TEST_TYPE" | tr '[:lower:]' '[:upper:]') TESTS"

    print_info "Configuration:"
    print_info "  Test Type: $TEST_TYPE"
    print_info "  Coverage: $([ "$ENABLE_COVERAGE" = "coverage" ] && echo "Enabled" || echo "Disabled")"
    print_info "  Allure: $([ "$ENABLE_ALLURE" = "allure" ] && echo "Enabled" || echo "Disabled")"
    echo ""

    # Setup
    setup_directories
    clean_previous_results
    check_dependencies
    install_node_deps

    # Run tests
    run_tests
    local test_result=$?

    # Generate reports
    if [ "$ENABLE_ALLURE" = "allure" ]; then
        convert_to_allure
        generate_allure_report
    fi

    if [ "$ENABLE_COVERAGE" = "coverage" ]; then
        generate_coverage_report
    fi

    # Open reports in browser
    open_reports

    # Display summary
    display_summary $test_result

    exit $test_result
}

# Run main function
main "$@"
