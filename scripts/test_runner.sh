#!/bin/bash
# Simple test runner for Hotel Booking App

set -e

TEST_TYPE="${1:-all}"

case "$TEST_TYPE" in
    unit)
        echo "🧪 Running unit tests..."
        flutter test test/unit/ --coverage --reporter=json --file-reporter=json:test-results/unit_results.json
        ;;
    widget)
        echo "🧪 Running widget tests..."
        flutter test test/widgets/ --coverage --reporter=json --file-reporter=json:test-results/widget_results.json
        ;;
    integration)
        echo "🧪 Running integration tests..."
        flutter test integration_test/ --dart-define=PATROL_WAIT=5000
        ;;
    all)
        echo "🧪 Running all tests..."
        mkdir -p test-results
        flutter test test/unit/ --coverage --reporter=json --file-reporter=json:test-results/unit_results.json
        flutter test test/widgets/ --coverage --reporter=json --file-reporter=json:test-results/widget_results.json
        flutter test integration_test/ --dart-define=PATROL_WAIT=5000
        ;;
    *)
        echo "Usage: $0 {unit|widget|integration|all}"
        exit 1
        ;;
esac
