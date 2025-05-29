# =============================================================================
# HOTEL BOOKING QA AUTOMATION - MINIMAL MAKEFILE
# =============================================================================
# QA Automation Lead: Clean test automation suite
# =============================================================================

.PHONY: help setup clean unit widget test-all coverage allure-test

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

# =============================================================================
# HELP
# =============================================================================

help: ## Show available commands
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    HOTEL BOOKING QA AUTOMATION                             $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)🧪 UNIT & WIDGET TESTS:$(NC)"
	@echo "  $(YELLOW)make unit$(NC)                     - Run unit tests"
	@echo "  $(YELLOW)make widget$(NC)                   - Run widget tests"
	@echo "  $(YELLOW)make test-all$(NC)                 - Run unit + widget tests"
	@echo "  $(YELLOW)make coverage$(NC)                 - Run tests with coverage report"
	@echo "  $(YELLOW)make allure-test$(NC)              - Run tests with Allure reporting"
	@echo ""
	@echo "$(GREEN)📱 INTEGRATION TESTS (Patrol CLI):$(NC)"
	@echo "  $(YELLOW)patrol test$(NC)                   - Run all integration tests"
	@echo "  $(YELLOW)patrol test -t overview_test.dart$(NC)      - Run specific test"
	@echo "  $(YELLOW)patrol test --device=\"iPhone 16 Plus\"$(NC) - Run on specific device"
	@echo "  $(YELLOW)patrol test --coverage$(NC)        - Run with coverage"
	@echo ""
	@echo "$(GREEN)☁️ FIREBASE TEST LAB:$(NC)"
	@echo "  $(YELLOW)./scripts/firebase_android.sh$(NC) - Run Android tests on Firebase"
	@echo "  $(YELLOW)./scripts/firebase_ios.sh$(NC)     - iOS tests (placeholder - needs code signing)"
	@echo "  $(BLUE)Note: Android tests auto-run on GitHub push$(NC)"
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
# UNIT & WIDGET TESTS
# =============================================================================

unit: ## Run unit tests
	@echo "$(BLUE)🧪 Running unit tests...$(NC)"
	@flutter test test/unit/
	@echo "$(GREEN)✅ Unit tests completed$(NC)"

widget: ## Run widget tests
	@echo "$(BLUE)🎯 Running widget tests...$(NC)"
	@flutter test test/widgets/
	@echo "$(GREEN)✅ Widget tests completed$(NC)"

test-all: ## Run unit + widget tests
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

.DEFAULT_GOAL := help