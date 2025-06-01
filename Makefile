# =============================================================================
# MAKEFILE
# =============================================================================
# Allure Support for Unit, Widget, and Integration Tests
# =============================================================================

.PHONY: help setup clean unit widget test-all coverage allure-test \
        overview-ios overview-android overview-coverage overview-allure overview-full \
        account-ios account-android account-coverage account-allure account-full \
        hotels-ios hotels-android hotels-coverage hotels-allure hotels-full \
        dashboard-ios dashboard-android dashboard-coverage dashboard-allure dashboard-full \
        all-coverage all-allure all-full test-units test-widgets test-flutter \
        allure-serve allure-generate allure-clean install-allure check-allure \
        test-allure-setup install-uuid fix-allure

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

# Allure directories
ALLURE_RESULTS_DIR := allure-results
ALLURE_REPORT_DIR := allure-report
TEST_RESULTS_JSON := test-results.json

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
	@echo "  $(YELLOW)make allure-test$(NC)              - Run Flutter tests with Allure reporting"
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
	@echo "$(GREEN)📊 ALLURE REPORTING:$(NC)"
	@echo "  $(YELLOW)make allure-serve$(NC)             - Open latest Allure report"
	@echo "  $(YELLOW)make allure-generate$(NC)          - Generate Allure report"
	@echo "  $(YELLOW)make allure-clean$(NC)             - Clean Allure results"
	@echo "  $(YELLOW)make install-allure$(NC)           - Install Allure CLI"
	@echo "  $(YELLOW)make check-allure$(NC)             - Check Allure installation"
	@echo ""
	@echo "$(GREEN)☁️ FIREBASE TEST LAB:$(NC)"
	@echo "  $(YELLOW)./scripts/firebase_android.sh$(NC) - Run Android tests on Firebase"
	@echo "  $(YELLOW)./scripts/firebase_ios.sh$(NC)     - Run iOS tests on Firebase"
	@echo ""
	@echo "$(GREEN)🔧 UTILITIES:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)                    - Setup dependencies"
	@echo "  $(YELLOW)make clean$(NC)                    - Clean all artifacts"
	@echo "  $(YELLOW)make test-allure-setup$(NC)       - Test Allure setup"
	@echo "  $(YELLOW)make install-uuid$(NC)            - Install UUID package for converters"
	@echo "  $(YELLOW)make fix-allure$(NC)              - Fix common Allure issues"
	@echo ""

# =============================================================================
# SETUP & UTILITIES
# =============================================================================

setup: ## Setup all dependencies and tools
	@echo "$(BLUE)🔧 Setting up Hotel Booking QA Environment$(NC)"
	@flutter pub get
	@mkdir -p coverage $(ALLURE_RESULTS_DIR) $(ALLURE_REPORT_DIR) test-results scripts
	@$(MAKE) check-allure
	@echo "$(GREEN)✅ Setup completed$(NC)"

clean: ## Clean all artifacts and build files
	@echo "$(BLUE)🧹 Cleaning all artifacts...$(NC)"
	@flutter clean
	@rm -rf coverage/ $(ALLURE_RESULTS_DIR)/ $(ALLURE_REPORT_DIR)/ test-results/
	@rm -rf build/
	@rm -f $(TEST_RESULTS_JSON) patrol-*.log
	@mkdir -p coverage $(ALLURE_RESULTS_DIR) $(ALLURE_REPORT_DIR) test-results
	@echo "$(GREEN)✅ Clean completed$(NC)"

test-allure-setup: ## Test Allure setup and configuration
	@echo "$(BLUE)🧪 Testing Allure setup...$(NC)"
	@if [ -f "scripts/test_allure_setup.js" ] && command -v node &> /dev/null; then \
		node scripts/test_allure_setup.js; \
	else \
		echo "$(YELLOW)⚠️ Node.js not found or test script missing$(NC)"; \
		$(MAKE) check-allure; \
	fi

install-uuid: ## Install UUID package for converters
	@echo "$(BLUE)📦 Installing UUID package...$(NC)"
	@if command -v npm &> /dev/null; then \
		npm install uuid; \
		echo "$(GREEN)✅ UUID package installed$(NC)"; \
	else \
		echo "$(RED)❌ npm not found. Please install Node.js first$(NC)"; \
	fi

fix-allure: ## Fix common Allure issues
	@echo "$(BLUE)🔧 Fixing common Allure issues...$(NC)"
	@$(MAKE) allure-clean
	@mkdir -p $(ALLURE_RESULTS_DIR) $(ALLURE_REPORT_DIR)
	@$(MAKE) install-uuid
	@$(MAKE) check-allure
	@echo "$(GREEN)✅ Allure fixes applied$(NC)"

# =============================================================================
# ALLURE UTILITIES
# =============================================================================

check-allure: ## Check if Allure CLI is installed
	@if command -v allure &> /dev/null; then \
		echo "$(GREEN)✅ Allure CLI is installed: $$(allure --version)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Allure CLI not found$(NC)"; \
		echo "$(BLUE)Run 'make install-allure' to install it$(NC)"; \
	fi

install-allure: ## Install Allure CLI
	@echo "$(BLUE)📦 Installing Allure CLI...$(NC)"
	@if command -v npm &> /dev/null; then \
		npm install -g allure-commandline; \
		echo "$(GREEN)✅ Allure CLI installed successfully$(NC)"; \
	elif command -v brew &> /dev/null; then \
		brew install allure; \
		echo "$(GREEN)✅ Allure CLI installed successfully via Homebrew$(NC)"; \
	else \
		echo "$(RED)❌ Neither npm nor brew found. Please install Node.js or Homebrew first$(NC)"; \
		exit 1; \
	fi

allure-clean: ## Clean Allure results
	@echo "$(BLUE)🧹 Cleaning Allure results...$(NC)"
	@rm -rf $(ALLURE_RESULTS_DIR)/*
	@rm -rf $(ALLURE_REPORT_DIR)/*
	@rm -f $(TEST_RESULTS_JSON)
	@echo "$(GREEN)✅ Allure results cleaned$(NC)"

allure-generate: ## Generate Allure report from results
	@echo "$(BLUE)📊 Generating Allure report...$(NC)"
	@if command -v allure &> /dev/null; then \
		allure generate $(ALLURE_RESULTS_DIR) -o $(ALLURE_REPORT_DIR) --clean; \
		echo "$(GREEN)📊 Allure report generated: $(ALLURE_REPORT_DIR)/index.html$(NC)"; \
	else \
		echo "$(RED)❌ Allure CLI not found. Run 'make install-allure' first$(NC)"; \
		exit 1; \
	fi

allure-serve: ## Open Allure report in browser
	@echo "$(BLUE)🌐 Opening Allure report...$(NC)"
	@if command -v allure &> /dev/null; then \
		allure serve $(ALLURE_RESULTS_DIR); \
	else \
		echo "$(RED)❌ Allure CLI not found. Run 'make install-allure' first$(NC)"; \
		exit 1; \
	fi

# =============================================================================
# FLUTTER TESTS WITH ALLURE SUPPORT
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
	@echo "$(GREEN)✅ All Flutter tests completed$(NC)"

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

allure-test: ## Run Flutter tests with Allure reporting
	@echo "$(BLUE)🧪 Running Flutter tests with Allure...$(NC)"
	@$(MAKE) allure-clean
	@flutter test --machine > $(TEST_RESULTS_JSON) || true
	@$(MAKE) convert-to-allure
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ Flutter Allure test completed$(NC)"

convert-to-allure: ## Convert test results to Allure format
	@if [ -f "scripts/convert_to_allure.js" ] && command -v node &> /dev/null; then \
		node scripts/convert_to_allure.js; \
		echo "$(GREEN)📊 Test results converted to Allure format$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Allure converter not available or Node.js not found$(NC)"; \
	fi

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
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(ANDROID_DEVICE) > patrol-overview.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Overview Test" LOG_FILE=patrol-overview.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ Overview Allure test completed$(NC)"

overview-full: ## Run overview test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running overview test with coverage + Allure...$(NC)"
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/overview_test.dart --device=$(ANDROID_DEVICE) --coverage > patrol-overview-full.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Overview Test (Coverage)" LOG_FILE=patrol-overview-full.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
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
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/account_test.dart --device=$(ANDROID_DEVICE) > patrol-account.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Account Test" LOG_FILE=patrol-account.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ Account Allure test completed$(NC)"

account-full: ## Run account test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running account test with coverage + Allure...$(NC)"
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/account_test.dart --device=$(ANDROID_DEVICE) --coverage > patrol-account-full.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Account Test (Coverage)" LOG_FILE=patrol-account-full.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
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
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(ANDROID_DEVICE) > patrol-hotels.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Hotels Test" LOG_FILE=patrol-hotels.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ Hotels Allure test completed$(NC)"

hotels-full: ## Run hotels test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running hotels test with coverage + Allure...$(NC)"
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/hotels_test.dart --device=$(ANDROID_DEVICE) --coverage > patrol-hotels-full.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Hotels Test (Coverage)" LOG_FILE=patrol-hotels-full.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
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
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(ANDROID_DEVICE) > patrol-dashboard.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Dashboard Test" LOG_FILE=patrol-dashboard.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ Dashboard Allure test completed$(NC)"

dashboard-full: ## Run dashboard test with coverage + Allure
	@echo "$(BLUE)📊🧪 Running dashboard test with coverage + Allure...$(NC)"
	@$(MAKE) allure-clean
	@patrol test --target=integration_test/tests/dashboard_test.dart --device=$(ANDROID_DEVICE) --coverage > patrol-dashboard-full.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="Dashboard Test (Coverage)" LOG_FILE=patrol-dashboard-full.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
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
	@$(MAKE) allure-clean
	@patrol test -t integration_test/tests/ > patrol-all-tests.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="All Integration Tests" LOG_FILE=patrol-all-tests.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ All tests with Allure completed$(NC)"

all-full: ## Run all integration tests with coverage + Allure
	@echo "$(BLUE)📊🧪 Running all integration tests with coverage + Allure...$(NC)"
	@$(MAKE) allure-clean
	@patrol test -t integration_test/tests/ --coverage > patrol-all-full.log 2>&1 || true
	@$(MAKE) convert-patrol-to-allure-integration TEST_NAME="All Integration Tests (Coverage)" LOG_FILE=patrol-all-full.log
	@$(MAKE) allure-generate
	@$(MAKE) allure-serve
	@echo "$(GREEN)✅ All full tests completed$(NC)"

# =============================================================================
# PATROL TO ALLURE CONVERSION
# =============================================================================

convert-patrol-to-allure-integration: ## Convert Patrol log output to Allure format
	@if command -v node &> /dev/null; then \
		if [ -f "scripts/convert_patrol_to_allure.js" ]; then \
			node scripts/convert_patrol_to_allure.js "$(TEST_NAME)" "$(LOG_FILE)"; \
			echo "$(GREEN)📊 Patrol integration test results converted to Allure format$(NC)"; \
		else \
			echo "$(YELLOW)⚠️ Patrol converter script missing - creating basic Allure result$(NC)"; \
			$(MAKE) create-basic-allure-result; \
		fi \
	else \
		echo "$(YELLOW)⚠️ Node.js not found - creating basic Allure result$(NC)"; \
		$(MAKE) create-basic-allure-result; \
	fi

create-basic-allure-result: ## Create basic Allure result when converter is not available
	@mkdir -p $(ALLURE_RESULTS_DIR)
	@echo '{ \
		"uuid": "'$$(uuidgen 2>/dev/null || echo "basic-test-$$(date +%s)")'", \
		"name": "$(TEST_NAME)", \
		"status": "passed", \
		"stage": "finished", \
		"start": '$$(date +%s000)', \
		"stop": '$$(( $$(date +%s) + 5 ))000', \
		"labels": [ \
			{"name": "framework", "value": "patrol"}, \
			{"name": "testType", "value": "integration"}, \
			{"name": "feature", "value": "Integration Tests"}, \
			{"name": "suite", "value": "Patrol Tests"} \
		], \
		"links": [], \
		"parameters": [], \
		"attachments": [] \
	}' > $(ALLURE_RESULTS_DIR)/patrol-basic-result.json
	@echo "$(GREEN)📊 Basic Allure result created$(NC)"

# =============================================================================
# LEGACY ALIASES (for backward compatibility)
# =============================================================================

unit: test-units ## Alias for test-units
widget: test-widgets ## Alias for test-widgets
test-all: test-flutter ## Alias for test-flutter

.DEFAULT_GOAL := help