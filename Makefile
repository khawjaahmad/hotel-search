# =============================================================================
# HOTEL BOOKING APP - MAIN MAKEFILE
# =============================================================================
# QA Automation Lead: Complete test automation suite
# Integrates: Unit/Widget tests, Integration tests, Firebase Test Lab
# =============================================================================

.PHONY: help setup clean status all-tests quick-start

# =============================================================================
# MAIN CONFIGURATION
# =============================================================================

PROJECT_NAME := hotel_booking
MAKEFILES_DIR := .

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
PURPLE := \033[0;35m
NC := \033[0m

# Include sub-makefiles
include firebase.mk
include integration.mk

# =============================================================================
# MAIN HELP MENU
# =============================================================================

help: ## Show complete help menu
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    HOTEL BOOKING QA AUTOMATION SUITE                       $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(PURPLE)🚀 QUICK START:$(NC)"
	@echo "  $(YELLOW)make quick-start$(NC)              - Setup + run basic tests"
	@echo "  $(YELLOW)make all-tests$(NC)                - Run all test suites"
	@echo "  $(YELLOW)make status$(NC)                   - Check project status"
	@echo ""
	@echo "$(GREEN)🧪 UNIT & WIDGET TESTS:$(NC)"
	@echo "  $(YELLOW)make test$(NC)                     - Run all unit and widget tests"
	@echo "  $(YELLOW)make unit$(NC)                     - Run unit tests only"
	@echo "  $(YELLOW)make widget$(NC)                   - Run widget tests only"
	@echo "  $(YELLOW)make unit-coverage$(NC)            - Unit tests with coverage"
	@echo "  $(YELLOW)make widget-coverage$(NC)          - Widget tests with coverage"
	@echo "  $(YELLOW)make coverage$(NC)                 - Generate coverage reports"
	@echo "  $(YELLOW)make unit-allure$(NC)              - Unit tests with Allure"
	@echo "  $(YELLOW)make widget-allure$(NC)            - Widget tests with Allure"
	@echo "  $(YELLOW)make allure-serve$(NC)             - Serve Allure reports"
	@echo ""
	@echo "$(GREEN)📱 INTEGRATION TESTS (Patrol):$(NC)"
	@echo "  $(YELLOW)make test-hotels ios$(NC)          - Hotels tests on iOS"
	@echo "  $(YELLOW)make test-account android$(NC)     - Account tests on Android"
	@echo "  $(YELLOW)make test-dashboard ios$(NC)       - Dashboard tests on iOS"
	@echo "  $(YELLOW)make test-overview android$(NC)    - Overview tests on Android"
	@echo "  $(YELLOW)make test-all ios$(NC)             - All integration tests on iOS"
	@echo "  $(YELLOW)make test-all android$(NC)         - All integration tests on Android"
	@echo "  $(YELLOW)make device-start-ios$(NC)         - Start iOS simulator"
	@echo "  $(YELLOW)make device-start-android$(NC)     - Start Android emulator"
	@echo "  $(YELLOW)make device-list$(NC)              - List available devices"
	@echo ""
	@echo "$(GREEN)☁️ FIREBASE TEST LAB:$(NC)"
	@echo "  $(YELLOW)make firebase-setup$(NC)           - Setup Firebase Test Lab"
	@echo "  $(YELLOW)make firebase-test-ios$(NC)        - Run iOS tests on Firebase"
	@echo "  $(YELLOW)make firebase-test-android$(NC)    - Run Android tests on Firebase"
	@echo "  $(YELLOW)make firebase-test-both$(NC)       - Run tests on both platforms"
	@echo "  $(YELLOW)make firebase-build-all$(NC)       - Build for Firebase"
	@echo "  $(YELLOW)make firebase-list-devices$(NC)    - List Firebase devices"
	@echo "  $(YELLOW)make firebase-status$(NC)          - Check Firebase results"
	@echo ""
	@echo "$(GREEN)🔧 UTILITIES:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)                    - Setup all dependencies"
	@echo "  $(YELLOW)make clean$(NC)                    - Clean all artifacts"
	@echo "  $(YELLOW)make deps$(NC)                     - Update Flutter dependencies"
	@echo ""
	@echo "$(GREEN)📊 REPORTING:$(NC)"
	@echo "  $(YELLOW)make reports$(NC)                  - Generate all reports"
	@echo "  $(YELLOW)make open-reports$(NC)             - Open all reports"
	@echo ""
	@echo "$(GREEN)💡 EXAMPLES:$(NC)"
	@echo "  $(YELLOW)make unit-coverage && make allure-serve$(NC)"
	@echo "  $(YELLOW)make device-start-ios && make test-hotels ios$(NC)"
	@echo "  $(YELLOW)make firebase-setup && make firebase-test-both$(NC)"
	@echo ""
	@echo "$(GREEN)📋 PROJECT INFO:$(NC)"
	@echo "  Project: $(PROJECT_NAME)"
	@echo "  Flutter SDK: $(shell flutter --version 2>/dev/null | head -n1 || echo 'Not installed')"
	@echo "  Patrol CLI: $(shell patrol --version 2>/dev/null || echo 'Not installed')"
	@echo "  Firebase CLI: $(shell gcloud version --format='value(Google Cloud SDK)' 2>/dev/null || echo 'Not installed')"
	@echo ""

# =============================================================================
# MAIN COMMANDS
# =============================================================================

quick-start: ## Quick setup and basic test run
	@echo "$(BLUE)🚀 Quick Start - Hotel Booking QA Suite$(NC)"
	@echo "$(YELLOW)1. Setting up dependencies...$(NC)"
	@$(MAKE) setup
	@echo "$(YELLOW)2. Running unit tests with coverage...$(NC)"
	@$(MAKE) unit-coverage
	@echo "$(YELLOW)3. Running widget tests...$(NC)"
	@$(MAKE) widget
	@echo "$(GREEN)✅ Quick start completed!$(NC)"
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  - Run integration tests: $(YELLOW)make device-start-ios && make test-hotels ios$(NC)"
	@echo "  - Setup Firebase: $(YELLOW)make firebase-setup$(NC)"
	@echo "  - View coverage: Open coverage/html/index.html"

all-tests: ## Run all test suites (unit, widget, integration)
	@echo "$(BLUE)🧪 Running Complete Test Suite$(NC)"
	@echo "$(YELLOW)Phase 1: Unit Tests with Coverage$(NC)"
	@$(MAKE) unit-coverage
	@echo "$(YELLOW)Phase 2: Widget Tests with Coverage$(NC)"
	@$(MAKE) widget-coverage
	@echo "$(YELLOW)Phase 3: Starting devices for integration tests$(NC)"
	@$(MAKE) device-start-ios &
	@$(MAKE) device-start-android &
	@wait
	@echo "$(YELLOW)Phase 4: Integration Tests - iOS$(NC)"
	@$(MAKE) test-all ios || echo "$(YELLOW)⚠️ iOS integration tests completed with issues$(NC)"
	@echo "$(YELLOW)Phase 5: Integration Tests - Android$(NC)"
	@$(MAKE) test-all android || echo "$(YELLOW)⚠️ Android integration tests completed with issues$(NC)"
	@echo "$(GREEN)✅ All test suites completed!$(NC)"

setup: ## Setup all dependencies and tools
	@echo "$(BLUE)🔧 Setting up Hotel Booking QA Environment$(NC)"
	@echo "$(YELLOW)1. Flutter dependencies...$(NC)"
	@flutter pub get
	@echo "$(YELLOW)2. Creating directories...$(NC)"
	@mkdir -p coverage allure-results allure-report firebase-results test-results
	@echo "$(YELLOW)3. Checking required tools...$(NC)"
	@$(MAKE) _check-tools
	@echo "$(GREEN)✅ Setup completed$(NC)"

clean: ## Clean all artifacts and build files
	@echo "$(BLUE)🧹 Cleaning all artifacts...$(NC)"
	@flutter clean
	@rm -rf coverage/ allure-results/ allure-report/ firebase-results/ test-results/
	@rm -rf build/
	@rm -f test-results.json firebase-*-results.json
	@echo "$(YELLOW)Recreating directories...$(NC)"
	@mkdir -p coverage allure-results allure-report firebase-results test-results
	@echo "$(GREEN)✅ Clean completed$(NC)"

status: ## Check project and tools status
	@echo "$(BLUE)📊 Hotel Booking QA Status$(NC)"
	@echo ""
	@echo "$(GREEN)🏗️ PROJECT:$(NC)"
	@echo "  Name: $(PROJECT_NAME)"
	@echo "  Path: $(PWD)"
	@echo ""
	@echo "$(GREEN)🛠️ TOOLS:$(NC)"
	@$(MAKE) _check-tools
	@echo ""
	@echo "$(GREEN)📱 DEVICES:$(NC)"
	@echo "$(YELLOW)iOS Simulators:$(NC)"
	@xcrun simctl list devices | grep -E "(Booted|Shutdown)" | grep -v "unavailable" | head -3 || echo "  No iOS simulators available"
	@echo "$(YELLOW)Android Devices:$(NC)"
	@adb devices | grep -v "List of devices" || echo "  No Android devices connected"
	@echo ""
	@echo "$(GREEN)📊 RECENT RESULTS:$(NC)"
	@if [ -d "coverage" ] && [ -f "coverage/lcov.info" ]; then \
		echo "  ✅ Coverage reports available"; \
	else \
		echo "  ❌ No coverage reports"; \
	fi
	@if [ -d "allure-results" ] && [ "$(ls -A allure-results 2>/dev/null)" ]; then \
		echo "  ✅ Allure results available"; \
	else \
		echo "  ❌ No Allure results"; \
	fi
	@if [ -d "firebase-results" ] && [ "$(ls -A firebase-results 2>/dev/null)" ]; then \
		echo "  ✅ Firebase results available"; \
	else \
		echo "  ❌ No Firebase results"; \
	fi

deps: ## Update Flutter dependencies
	@echo "$(BLUE)📦 Updating Flutter dependencies...$(NC)"
	@flutter pub get
	@flutter pub upgrade
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

# =============================================================================
# REPORTING COMMANDS
# =============================================================================

reports: ## Generate all reports
	@echo "$(BLUE)📊 Generating all reports...$(NC)"
	@if [ -f "coverage/lcov.info" ]; then \
		echo "$(YELLOW)Generating coverage report...$(NC)"; \
		$(MAKE) _generate-coverage-report; \
	fi
	@if [ -f "test-results.json" ]; then \
		echo "$(YELLOW)Converting to Allure...$(NC)"; \
		$(MAKE) _convert-to-allure; \
	fi
	@echo "$(GREEN)✅ Reports generated$(NC)"

open-reports: ## Open all available reports
	@echo "$(BLUE)🌐 Opening reports...$(NC)"
	@if [ -f "coverage/html/index.html" ]; then \
		echo "$(YELLOW)Opening coverage report...$(NC)"; \
		if command -v open &> /dev/null; then \
			open coverage/html/index.html; \
		elif command -v xdg-open &> /dev/null; then \
			xdg-open coverage/html/index.html; \
		fi; \
	fi
	@if [ -d "allure-results" ] && [ "$(ls -A allure-results 2>/dev/null)" ]; then \
		echo "$(YELLOW)Starting Allure server...$(NC)"; \
		$(MAKE) allure-serve & \
	fi

# =============================================================================
# FIREBASE ALIASES (for main makefile integration)
# =============================================================================

firebase-setup: setup ## Alias for Firebase setup
firebase-test-ios: test-ios ## Alias for Firebase iOS tests
firebase-test-android: test-android ## Alias for Firebase Android tests
firebase-test-both: test-both ## Alias for Firebase both platforms
firebase-build-all: build-all ## Alias for Firebase build all
firebase-list-devices: list-devices ## Alias for Firebase list devices
firebase-status: status ## Alias for Firebase status

# =============================================================================
# INTEGRATION TEST ALIASES (for better discoverability)
# =============================================================================

integration-help: ## Show integration tests help
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    INTEGRATION TESTS (PATROL)                              $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@$(MAKE) -f integration.mk help

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

_check-tools: ## Internal: Check required tools
	@echo "$(YELLOW)Checking tools...$(NC)"
	@printf "  Flutter: "
	@if command -v flutter &> /dev/null; then \
		echo "$(GREEN)✅ $(shell flutter --version | head -n1)$(NC)"; \
	else \
		echo "$(RED)❌ Not installed$(NC)"; \
	fi
	@printf "  Patrol: "
	@if command -v patrol &> /dev/null; then \
		echo "$(GREEN)✅ $(shell patrol --version 2>/dev/null)$(NC)"; \
	else \
		echo "$(RED)❌ Not installed$(NC)"; \
	fi
	@printf "  Firebase: "
	@if command -v gcloud &> /dev/null; then \
		echo "$(GREEN)✅ $(shell gcloud version --format='value(Google Cloud SDK)' 2>/dev/null)$(NC)"; \
	else \
		echo "$(RED)❌ Not installed$(NC)"; \
	fi
	@printf "  Allure: "
	@if command -v allure &> /dev/null; then \
		echo "$(GREEN)✅ $(shell allure --version 2>/dev/null)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Not installed (optional)$(NC)"; \
	fi
	@printf "  Node.js: "
	@if command -v node &> /dev/null; then \
		echo "$(GREEN)✅ $(shell node --version)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Not installed (needed for Allure conversion)$(NC)"; \
	fi

_generate-coverage-report: ## Internal: Generate coverage report
	@if [ -f "coverage/lcov.info" ]; then \
		echo "$(BLUE)📊 Generating coverage report...$(NC)"; \
		if command -v genhtml &> /dev/null; then \
			genhtml coverage/lcov.info -o coverage/html --quiet; \
			echo "$(GREEN)✓ Coverage report: coverage/html/index.html$(NC)"; \
		else \
			echo "$(YELLOW)⚠️ genhtml not found$(NC)"; \
			echo "$(BLUE)Install: brew install lcov (macOS) or apt-get install lcov (Ubuntu)$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)⚠️ No coverage data found$(NC)"; \
	fi

_convert-to-allure: ## Internal: Convert test results to Allure
	@if [ -f "test-results.json" ]; then \
		echo "$(BLUE)🔄 Converting to Allure format...$(NC)"; \
		if command -v node &> /dev/null && [ -f "scripts/convert_to_allure.js" ]; then \
			node scripts/convert_to_allure.js; \
			echo "$(GREEN)✓ Allure results generated$(NC)"; \
		else \
			echo "$(YELLOW)⚠️ Node.js or converter script not found$(NC)"; \
			echo "$(BLUE)Create scripts/convert_to_allure.js for conversion$(NC)"; \
		fi; \
	fi

# =============================================================================
# UNIT & WIDGET TESTS (Integrated from original Makefile)
# =============================================================================

test: ## Run all unit and widget tests
	@echo "$(BLUE)🧪 Running all tests for $(PROJECT_NAME)...$(NC)"
	@flutter test
	@echo "$(GREEN)✅ All tests completed$(NC)"

unit: ## Run all unit tests
	@echo "$(BLUE)🧪 Running unit tests...$(NC)"
	@flutter test test/unit/
	@echo "$(GREEN)✅ Unit tests completed$(NC)"

unit-coverage: ## Run unit tests with coverage
	@echo "$(BLUE)🧪 Running unit tests with coverage...$(NC)"
	@flutter test test/unit/ --coverage
	@$(MAKE) _generate-coverage-report
	@echo "$(GREEN)✅ Unit tests with coverage completed$(NC)"

unit-allure: ## Run unit tests with Allure
	@echo "$(BLUE)🧪 Running unit tests with Allure...$(NC)"
	@rm -rf allure-results/*
	@flutter test test/unit/ --machine > test-results.json
	@$(MAKE) _convert-to-allure
	@if command -v allure &> /dev/null; then \
		allure serve allure-results; \
	fi
	@echo "$(GREEN)✅ Unit tests with Allure completed$(NC)"

widget: ## Run all widget tests
	@echo "$(BLUE)🎯 Running widget tests...$(NC)"
	@flutter test test/widgets/
	@echo "$(GREEN)✅ Widget tests completed$(NC)"

widget-coverage: ## Run widget tests with coverage
	@echo "$(BLUE)🎯 Running widget tests with coverage...$(NC)"
	@flutter test test/widgets/ --coverage
	@$(MAKE) _generate-coverage-report
	@echo "$(GREEN)✅ Widget tests with coverage completed$(NC)"

widget-allure: ## Run widget tests with Allure
	@echo "$(BLUE)🎯 Running widget tests with Allure...$(NC)"
	@rm -rf allure-results/*
	@flutter test test/widgets/ --machine > test-results.json
	@$(MAKE) _convert-to-allure
	@if command -v allure &> /dev/null; then \
		allure serve allure-results; \
	fi
	@echo "$(GREEN)✅ Widget tests with Allure completed$(NC)"

coverage: ## Run tests with coverage
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	@flutter test --coverage \
		--coverage-path=coverage/lcov.info \
		--reporter=expanded
	@if [ -f "coverage/lcov.info" ]; then \
		lcov --remove coverage/lcov.info \
			'**/*.g.dart' \
			'**/*.freezed.dart' \
			-o coverage/filtered_lcov.info 2>/dev/null || cp coverage/lcov.info coverage/filtered_lcov.info; \
		$(MAKE) _generate-coverage-report; \
	fi

allure-serve: ## Serve Allure report
	@if [ -d "allure-results" ] && [ "$$(ls -A allure-results 2>/dev/null)" ]; then \
		echo "$(BLUE)🚀 Starting Allure server...$(NC)"; \
		if command -v allure &> /dev/null; then \
			PORT=8080; \
			while lsof -Pi :$$PORT -sTCP:LISTEN -t >/dev/null 2>&1; do \
				PORT=$$((PORT + 1)); \
				if [ $$PORT -gt 8090 ]; then \
					echo "$(RED)❌ Could not find available port$(NC)"; \
					exit 1; \
				fi; \
			done; \
			echo "$(GREEN)🌐 Server starting on port $$PORT...$(NC)"; \
			allure serve allure-results --port $$PORT; \
		else \
			echo "$(RED)❌ Allure CLI not installed$(NC)"; \
			echo "$(YELLOW)Install: npm install -g allure-commandline$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)⚠️ No Allure results found$(NC)"; \
		echo "$(BLUE)Run unit-allure or widget-allure first$(NC)"; \
	fi

allure-clean: ## Clean Allure artifacts
	@echo "$(BLUE)🧹 Cleaning Allure artifacts...$(NC)"
	@rm -rf allure-results allure-report test-results.json
	@mkdir -p allure-results
	@echo "$(GREEN)✅ Allure artifacts cleaned$(NC)"

.DEFAULT_GOAL := help