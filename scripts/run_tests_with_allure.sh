#!/bin/bash
# scripts/run_tests_with_allure.sh

set -e

echo "🧪 Running Flutter Tests with Enhanced Reporting..."

# Clean previous results
rm -rf allure-results allure-report coverage test_results.json

# Create directories
mkdir -p allure-results coverage

echo "📊 Running tests with coverage..."

# Run tests with JSON output and coverage
flutter test \
  --coverage \
  --reporter=json \
  --file-reporter=json:test_results.json \
  test/unit/ || TEST_EXIT_CODE=$?

echo "📈 Generating coverage report..."

# Check if lcov is available
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html 2>/dev/null || {
        echo "⚠️  Could not generate HTML coverage report"
        echo "Install lcov with: brew install lcov (macOS) or apt-get install lcov (Ubuntu)"
    }
else
    echo "⚠️  genhtml not found. Install lcov for HTML coverage reports"
fi

# Check if Node.js is available for Allure conversion
if command -v node &> /dev/null && [ -f "scripts/convert_to_allure.js" ]; then
    echo "🎯 Converting test results to Allure format..."
    
    # Check if uuid package is available
    if node -e "require('uuid')" 2>/dev/null; then
        node scripts/convert_to_allure.js
        
        # Generate Allure report if CLI is available
        if command -v allure &> /dev/null; then
            echo "📊 Generating Allure report..."
            allure generate allure-results -o allure-report --clean
            echo "🚀 Opening Allure report..."
            allure open allure-report &
        else
            echo "⚠️  Allure CLI not found. Install with: npm install -g allure-commandline"
            echo "📊 Raw test results saved in allure-results/"
        fi
    else
        echo "⚠️  uuid package not found. Run: npm install"
    fi
else
    echo "⚠️  Node.js not found or converter script missing"
    echo "💡 Install Node.js and run: npm install"
fi

# Open coverage report if it exists
if [ -f "coverage/html/index.html" ]; then
    echo "📈 Opening coverage report..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open coverage/html/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open coverage/html/index.html
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Windows
        start coverage/html/index.html
    fi
fi

# Summary
echo ""
echo "✅ Test execution completed!"

if [ -d "allure-report" ]; then
    echo "📊 Allure Report: allure-report/index.html"
fi

if [ -f "coverage/html/index.html" ]; then
    echo "📈 Coverage Report: coverage/html/index.html"
fi

if [ -f "coverage/lcov.info" ]; then
    echo "📋 LCOV Data: coverage/lcov.info"
fi

# Parse test results for summary
if [ -f "test_results.json" ]; then
    echo ""
    echo "📊 Test Summary:"
    
    # Count test results using grep and wc (works without Node.js)
    TOTAL_TESTS=$(grep -c '"type":"testDone"' test_results.json 2>/dev/null || echo "0")
    PASSED_TESTS=$(grep -c '"result":"success"' test_results.json 2>/dev/null || echo "0")
    FAILED_TESTS=$(grep -c '"result":"failure"' test_results.json 2>/dev/null || echo "0")
    ERROR_TESTS=$(grep -c '"result":"error"' test_results.json 2>/dev/null || echo "0")
    
    echo "   Total: $TOTAL_TESTS"
    echo "   ✅ Passed: $PASSED_TESTS"
    echo "   ❌ Failed: $FAILED_TESTS"
    echo "   💥 Errors: $ERROR_TESTS"
fi

# Exit with test result code if available
exit ${TEST_EXIT_CODE:-0}