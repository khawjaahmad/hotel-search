# =============================================================================
# HOTEL BOOKING QA AUTOMATION - COMPREHENSIVE MAKEFILE
# =============================================================================
# Patrol Test Runner with Full Integration Support
# =============================================================================

.PHONY: help setup clean unit widget test-all coverage allure-test \
        overview-ios overview-android overview-coverage overview-allure overview-full \
        account-ios account-android account-coverage account-allure account-full \
        hotels-ios hotels-android hotels-coverage hotels-allure hotels-full \
        dashboard-ios dashboard-android dashboard-coverage dashboard-allure dashboard-full \
        all-coverage all-allure all-full test-units test-widgets test-flutter setup

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m

# Device names (from patrol.yaml)
IOS_DEVICE := "iPhone 16 Plus"
ANDROID_DEVICE := "emulator-5554"

# =============================================================================
# HELP
# =============================================================================

help: ## Show available commands
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    HOTEL BOOKING QA AUTOMATION                             $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)🧪 UNIT & WIDGET TESTS:$(NC)"
	@echo "  $(YELLOW)make test-units$(NC)               - Run unit tests"
	@echo "  $(YELLOW)make test-widgets$(NC)             - Run widget tests"
	@echo "  $(YELLOW)make test-flutter$(NC)             - Run unit + widget tests"
	@echo "  $(YELLOW)make coverage$(NC)                 - Run tests with coverage report"
	@echo "  $(YELLOW)make allure-test$(NC)              - Run tests with Allure reporting"
	@echo ""
	@echo "$(GREEN)📱 PATROL INTEGRATION TESTS:$(NC)"
	@echo "  $(YELLOW)make overview-android$(NC)         - Run overview test on Android"
	@echo "  $(YELLOW)make overview-ios$(NC)             - Run overview test on iOS"
	@echo "  $(YELLOW)make overview-coverage$(NC)        - Overview test with coverage"
	@echo "  $(YELLOW)make overview-allure$(NC)          - Overview test with Allure"
	@echo "  $(YELLOW)make overview-full$(NC)            - Overview test with coverage + Allure"
	@echo ""
	@echo "  $(YELLOW)make account-android$(NC)          - Run account test on Android"
	@echo "  $(YELLOW)make account-ios$(NC)              - Run account test on iOS"
	@echo "  $(YELLOW)make account-coverage$(NC)         - Account test with coverage"
	@echo "  $(YELLOW)make account-allure$(NC)           - Account test with Allure"
	@echo "  $(YELLOW)make account-full$(NC)             - Account test with coverage + Allure"
	@echo ""
	@echo "  $(YELLOW)make hotels-android$(NC)           - Run hotels test on Android"
	@echo "  $(YELLOW)make hotels-ios$(NC)               - Run hotels test on iOS"
	@echo "  $(YELLOW)make hotels-coverage$(NC)          - Hotels test with coverage"
	@echo "  $(YELLOW)make hotels-allure$(NC)            - Hotels test with Allure"
	@echo "  $(YELLOW)make hotels-full$(NC)              - Hotels test with coverage + Allure"
	@echo ""
	@echo "  $(YELLOW)make dashboard-android$(NC)        - Run dashboard test on Android"
	@echo "  $(YELLOW)make dashboard-ios$(NC)            - Run dashboard test on iOS"
	@echo "  $(YELLOW)make dashboard-coverage$(NC)       - Dashboard test with coverage"
	@echo "  $(YELLOW)make dashboard-allure$(NC)         - Dashboard test with Allure"
	@echo "  $(YELLOW)make dashboard-full$(NC)           - Dashboard test with coverage + Allure"
	@echo ""
	@echo "$(GREEN)🚀 COMPREHENSIVE TEST SUITES:$(NC)"
	@echo "  $(YELLOW)make all-coverage$(NC)             - All integration tests with coverage"
	@echo "  $(YELLOW)make all-allure$(NC)               - All integration tests with Allure"
	@echo "  $(YELLOW)make all-full$(NC)                 - All integration tests with coverage + Allure"
	@echo ""
	@echo "$(GREEN)☁️ FIREBASE TEST LAB:$(NC)"
	@echo "  $(YELLOW)./scripts/firebase_android.sh$(NC) - Run Android tests on Firebase"
	@echo "  $(YELLOW)./scripts/firebase_ios.sh$(NC)     - Run iOS tests on Firebase"
	@echo "  $(YELLOW)./scripts/setup_firebase.sh$(NC)   - Setup Firebase Test Lab"
	@echo "  $(YELLOW)./scripts/diagnose_firebase_setup.sh$(NC) - Diagnose Firebase issues"
	@echo ""
	@echo "$(GREEN)🔧 UTILITIES:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)                    - Setup dependencies"
	@echo "  $(YELLOW)make clean$(NC)                    - Clean all artifacts"
	@echo ""

# =============================================================================
# SETUP & UTILITIES
# =============================================================================

setup: ## Setup all dependencies and tools
	@echo "$(BLUE)🔧 Setting up Hotel Booking QA Environment$(NC)"
	@flutter pub get
	@mkdir -p coverage allure-results allure-report test-results scripts
	@echo "$(GREEN)✅ Setup completed$(NC)"

clean: ## Clean all artifacts and build files
	@echo "$(BLUE)🧹 Cleaning all artifacts...$(NC)"
	@flutter clean
	@rm -rf coverage/ allure-results/ allure-report/ test-results/
	@rm -rf build/
	@rm -f test-results.json
	@mkdir -p coverage allure-results allure-report test-results
	@echo "$(GREEN)✅ Clean completed$(NC)"

# =============================================================================
# FLUTTER TESTS (EXISTING)
# =============================================================================

test-units: ## Run unit tests
	@echo "$(BLUE)🧪 Running unit tests...$(NC)"
	@flutter test test/unit/
	@echo "$(GREEN)✅ Unit tests completed$(NC)"

test-widgets: ## Run widget tests
	@echo "$(BLUE)🎯 Running widget tests...$(NC)"
	@flutter test test/widgets/
	@echo "$(GREEN)✅ Widget tests completed$(NC)"

test-flutter: ## Run all flutter tests
	@echo "$(BLUE)🧪 Running all unit and widget tests...$(NC)"
	@flutter test
	@echo "$(GREEN)✅ All tests completed$(NC)"

coverage: ## Run tests with coverage
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	@flutter test --coverage
	@if command -v genhtml &> /dev/null; then \
		genhtml coverage/lcov.info -o coverage/html --quiet; \
		echo "$(GREEN)📊 Coverage report: coverage/html/index.html$(NC)"; \
		if command -v open &> /dev/null; then \
			open coverage/html/index.html; \
		elif command -v xdg-open &> /dev/null; then \
			xdg-open coverage/html/index.html; \
		fi; \
	else \
		echo "$(YELLOW)⚠️ genhtml not found - install lcov for HTML reports$(NC)"; \
	fi
	@echo "$(GREEN)✅ Coverage completed$(NC)"

allure-test: ## Run tests with Allure reporting
	@echo "$(BLUE)🧪 Running tests with Allure...$(NC)"
	@rm -rf allure-results/*
	@flutter test --machine > test-results.json
	@if [ -f "scripts/convert_to_allure.js" ] && command -v node &> /dev/null; then \
		node scripts/convert_to_allure.js; \
		echo "$(GREEN)📊 Allure results generated$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Allure converter not available$(NC)"; \
	fi
	@if command -v allure &> /dev/null; then \
		allure serve allure-results; \
	else \
		echo "$(YELLOW)⚠️ Allure CLI not installed$(NC)"; \
		echo "$(BLUE)Install: npm install -g allure-commandline$(NC)"; \
	fi
	@echo "$(GREEN)✅ Allure test completed$(NC)"

# =============================================================================
# PATROL INTEGRATION TESTS - OVERVIEW
# =============================================================================

overview-ios: ## Run overview test on iOS
	@echo "$(BLUE)📱 Running overview test on iOS...$(NC)"
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(IOS_DEVICE)
	@echo "$(GREEN)✅ Overview iOS test completed$(NC)"

overview-android: ## Run overview test on Android
	@echo "$(BLUE)🤖 Running overview test on Android...$(NC)"
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(ANDROID_DEVICE)
	@echo "$(GREEN)✅ Overview Android test completed$(NC)"

overview-coverage: ## Run overview test with coverage
	@echo "$(BLUE)📊 Running overview test with coverage...$(NC)"
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(ANDROID_DEVICE) --coverage
	@echo "$(GREEN)✅ Overview coverage test completed$(NC)"

overview-allure: ## Run overview test with Allure
	@echo "$(BLUE)🧪 Running overview test with Allure...$(NC)"
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(ANDROID_DEVICE) --allure
	@echo "$(GREEN)✅ Overview Allure test completed$(NC)"

overview-full: ## Run overview test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running overview test with coverage + Allure...$(NC)"
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(ANDROID_DEVICE) --coverage --allure
	@echo "$(GREEN)✅ Overview full test completed$(NC)"

# =============================================================================
# PATROL INTEGRATION TESTS - ACCOUNT
# =============================================================================

account-ios: ## Run account test on iOS
	@echo "$(BLUE)📱 Running account test on iOS...$(NC)"
	@patrol test --target=integration_test/tests/account_test.dart --device=$(IOS_DEVICE)
	@echo "$(GREEN)✅ Account iOS test completed$(NC)"

account-android: ## Run account test on Android
	@echo "$(BLUE)🤖 Running account test on Android...$(NC)"
	@patrol test --target=integration_test/tests/account_test.dart --device=$(ANDROID_DEVICE)
	@echo "$(GREEN)✅ Account Android test completed$(NC)"

account-coverage: ## Run account test with coverage
	@echo "$(BLUE)📊 Running account test with coverage...$(NC)"
	@patrol test --target=integration_test/tests/account_test.dart --device=$(ANDROID_DEVICE) --coverage
	@echo "$(GREEN)✅ Account coverage test completed$(NC)"

account-allure: ## Run account test with Allure
	@echo "$(BLUE)🧪 Running account test with Allure...$(NC)"
	@patrol test --target=integration_test/tests/account_test.dart --device=$(ANDROID_DEVICE) --allure
	@echo "$(GREEN)✅ Account Allure test completed$(NC)"

account-full: ## Run account test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running account test with coverage + Allure...$(NC)"
	@patrol test --target=integration_test/tests/account_test.dart --device=$(ANDROID_DEVICE) --coverage --allure
	@echo "$(GREEN)✅ Account full test completed$(NC)"

# =============================================================================
# PATROL INTEGRATION TESTS - HOTELS
# =============================================================================

hotels-ios: ## Run hotels test on iOS
	@echo "$(BLUE)📱 Running hotels test on iOS...$(NC)"
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(IOS_DEVICE)
	@echo "$(GREEN)✅ Hotels iOS test completed$(NC)"

hotels-android: ## Run hotels test on Android
	@echo "$(BLUE)🤖 Running hotels test on Android...$(NC)"
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(ANDROID_DEVICE)
	@echo "$(GREEN)✅ Hotels Android test completed$(NC)"

hotels-coverage: ## Run hotels test with coverage
	@echo "$(BLUE)📊 Running hotels test with coverage...$(NC)"
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(ANDROID_DEVICE) --coverage
	@echo "$(GREEN)✅ Hotels coverage test completed$(NC)"

hotels-allure: ## Run hotels test with Allure
	@echo "$(BLUE)🧪 Running hotels test with Allure...$(NC)"
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(ANDROID_DEVICE) --allure
	@echo "$(GREEN)✅ Hotels Allure test completed$(NC)"

hotels-full: ## Run hotels test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running hotels test with coverage + Allure...$(NC)"
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(ANDROID_DEVICE) --coverage --allure
	@echo "$(GREEN)✅ Hotels full test completed$(NC)"

# =============================================================================
# PATROL INTEGRATION TESTS - DASHBOARD
# =============================================================================

dashboard-ios: ## Run dashboard test on iOS
	@echo "$(BLUE)📱 Running dashboard test on iOS...$(NC)"
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(IOS_DEVICE)
	@echo "$(GREEN)✅ Dashboard iOS test completed$(NC)"

dashboard-android: ## Run dashboard test on Android
	@echo "$(BLUE)🤖 Running dashboard test on Android...$(NC)"
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(ANDROID_DEVICE)
	@echo "$(GREEN)✅ Dashboard Android test completed$(NC)"

dashboard-coverage: ## Run dashboard test with coverage
	@echo "$(BLUE)📊 Running dashboard test with coverage...$(NC)"
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(ANDROID_DEVICE) --coverage
	@echo "$(GREEN)✅ Dashboard coverage test completed$(NC)"

dashboard-allure: ## Run dashboard test with Allure
	@echo "$(BLUE)🧪 Running dashboard test with Allure...$(NC)"
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(ANDROID_DEVICE) --allure
	@echo "$(GREEN)✅ Dashboard Allure test completed$(NC)"

dashboard-full: ## Run dashboard test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running dashboard test with coverage + Allure...$(NC)"
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(ANDROID_DEVICE) --coverage --allure
	@echo "$(GREEN)✅ Dashboard full test completed$(NC)"

# =============================================================================
# COMPREHENSIVE TEST SUITES
# =============================================================================

all-coverage: ## Run all integration tests with coverage
	@echo "$(BLUE)📊 Running all integration tests with coverage...$(NC)"
	@patrol test -t integration_test/tests/ --coverage
	@echo "$(GREEN)✅ All tests with coverage completed$(NC)"

all-allure: ## Run all integration tests with Allure
	@echo "$(BLUE)🧪 Running all integration tests with Allure...$(NC)"
	@patrol test -t integration_test/tests/ --allure
	@echo "$(GREEN)✅ All tests with Allure completed$(NC)"

all-full: ## Run all integration tests with coverage + Allure
	@echo "$(BLUE)📊🧪 Running all integration tests with coverage + Allure...$(NC)"
	@patrol test -t integration_test/tests/ --coverage --allure
	@echo "$(GREEN)✅ All full tests completed$(NC)"

# =============================================================================
# LEGACY ALIASES (for backward compatibility)
# =============================================================================

unit: test-units ## Alias for test-units
widget: test-widgets ## Alias for test-widgets
test-all: test-flutter ## Alias for test-flutter

.DEFAULT_GOAL := help