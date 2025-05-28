# =============================================================================
# HOTEL BOOKING APP - PATROL INTEGRATION TESTS
# =============================================================================
# Patrol integration test automation
# Supports: iOS Simulator, Android Emulator with Patrol CLI
# =============================================================================

.PHONY: help device-* test-* ios android all

# =============================================================================
# CONFIGURATION
# =============================================================================

PROJECT_NAME := hotel_booking
INTEGRATION_TEST_DIR := integration_test/tests

# Device Configuration
IOS_DEVICE_NAME := iPhone 16 Plus
IOS_DEVICE_UDID := AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8
ANDROID_EMULATOR := emulator-5554
ANDROID_EMULATOR_NAME := Pixel_7

# Test Files
ACCOUNT_TEST := $(INTEGRATION_TEST_DIR)/account_test.dart
DASHBOARD_TEST := $(INTEGRATION_TEST_DIR)/dashboard_test.dart
OVERVIEW_TEST := $(INTEGRATION_TEST_DIR)/overview_test.dart
HOTELS_TEST := $(INTEGRATION_TEST_DIR)/hotels_test.dart

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m
N
# =============================================================================
# HELP
# =============================================================================

help: ## Show help menu
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    PATROL INTEGRATION TESTS                                $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)📱 iOS TESTS:$(NC)"
	@echo "  $(YELLOW)make test-account ios$(NC)        - Run account tests on iOS"
	@echo "  $(YELLOW)make test-dashboard ios$(NC)      - Run dashboard tests on iOS"
	@echo "  $(YELLOW)make test-overview ios$(NC)       - Run overview tests on iOS"
	@echo "  $(YELLOW)make test-hotels ios$(NC)         - Run hotels tests on iOS"
	@echo "  $(YELLOW)make test-all ios$(NC)            - Run all tests on iOS"
	@echo ""
	@echo "$(GREEN)🤖 ANDROID TESTS:$(NC)"
	@echo "  $(YELLOW)make test-account android$(NC)    - Run account tests on Android"
	@echo "  $(YELLOW)make test-dashboard android$(NC)  - Run dashboard tests on Android"
	@echo "  $(YELLOW)make test-overview android$(NC)   - Run overview tests on Android"
	@echo "  $(YELLOW)make test-hotels android$(NC)     - Run hotels tests on Android"
	@echo "  $(YELLOW)make test-all android$(NC)        - Run all tests on Android"
	@echo ""
	@echo "$(GREEN)🔧 DEVICE MANAGEMENT:$(NC)"
	@echo "  $(YELLOW)make device-start-ios$(NC)        - Start iOS simulator"
	@echo "  $(YELLOW)make device-start-android$(NC)    - Start Android emulator"
	@echo "  $(YELLOW)make device-stop-ios$(NC)         - Stop iOS simulator"
	@echo "  $(YELLOW)make device-stop-android$(NC)     - Stop Android emulator"
	@echo "  $(YELLOW)make device-list$(NC)             - List available devices"
	@echo ""
	@echo "$(GREEN)💡 EXAMPLES:$(NC)"
	@echo "  $(YELLOW)make test-hotels ios --verbose$(NC)"
	@echo "  $(YELLOW)make test-account android --build$(NC)"
	@echo ""
	@echo "$(GREEN)🏃 QUICK START:$(NC)"
	@echo "  $(YELLOW)make device-start-ios && make test-hotels ios$(NC)"
	@echo "  $(YELLOW)make device-start-android && make test-account android$(NC)"
	@echo ""

# =============================================================================
# DEVICE MANAGEMENT
# =============================================================================

device-start-ios: ## Start iOS simulator
	@echo "$(BLUE)📱 Starting iOS Simulator: $(IOS_DEVICE_NAME)...$(NC)"
	@if xcrun simctl list devices | grep "$(IOS_DEVICE_UDID)" | grep -q "Booted"; then \
		echo "$(GREEN)✓ iOS Simulator already running$(NC)"; \
	else \
		xcrun simctl boot $(IOS_DEVICE_UDID) || true; \
		sleep 5; \
		echo "$(GREEN)✓ iOS Simulator started$(NC)"; \
	fi

device-start-android: ## Start Android emulator
	@echo "$(BLUE)🤖 Starting Android Emulator: $(ANDROID_EMULATOR_NAME)...$(NC)"
	@if adb devices | grep -q "$(ANDROID_EMULATOR)"; then \
		echo "$(GREEN)✓ Android Emulator already running$(NC)"; \
	else \
		echo "$(YELLOW)⏳ Starting emulator (this may take a minute)...$(NC)"; \
		emulator -avd $(ANDROID_EMULATOR_NAME) -no-snapshot -wipe-data > /dev/null 2>&1 & \
		timeout=60; \
		while [ $$timeout -gt 0 ]; do \
			if adb devices | grep -q "$(ANDROID_EMULATOR).*device"; then \
				echo "$(GREEN)✓ Android Emulator started$(NC)"; \
				break; \
			fi; \
			sleep 2; \
			timeout=$$((timeout - 2)); \
		done; \
		if [ $$timeout -le 0 ]; then \
			echo "$(RED)❌ Timeout waiting for emulator$(NC)"; \
			exit 1; \
		fi; \
	fi

device-stop-ios: ## Stop iOS simulator
	@echo "$(BLUE)📱 Stopping iOS Simulators...$(NC)"
	@xcrun simctl shutdown all
	@echo "$(GREEN)✓ iOS Simulators stopped$(NC)"

device-stop-android: ## Stop Android emulator
	@echo "$(BLUE)🤖 Stopping Android Emulators...$(NC)"
	@adb devices | grep emulator | cut -f1 | while read -r line; do \
		adb -s "$$line" emu kill; \
	done || true
	@echo "$(GREEN)✓ Android Emulators stopped$(NC)"

device-list: ## List available devices
	@echo "$(BLUE)📋 Available Devices:$(NC)"
	@echo ""
	@echo "$(YELLOW)iOS Simulators:$(NC)"
	@xcrun simctl list devices | grep -E "(Booted|Shutdown)" | grep -v "unavailable" || true
	@echo ""
	@echo "$(YELLOW)Android Devices:$(NC)"
	@adb devices -l || echo "  No Android devices connected"

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

test-account: ## Run account integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(ACCOUNT_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-dashboard: ## Run dashboard integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(DASHBOARD_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-overview: ## Run overview integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(OVERVIEW_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-hotels: ## Run hotels integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(HOTELS_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-all: ## Run all integration tests (requires: ios/android)
	@echo "$(BLUE)🚀 Running all integration tests...$(NC)"
	@$(MAKE) test-account $(filter ios android,$(MAKECMDGOALS))
	@$(MAKE) test-dashboard $(filter ios android,$(MAKECMDGOALS))
	@$(MAKE) test-overview $(filter ios android,$(MAKECMDGOALS))
	@$(MAKE) test-hotels $(filter ios android,$(MAKECMDGOALS))
	@echo "$(GREEN)✅ All integration tests completed$(NC)"

# Platform targets (consumed by test-* targets)
ios:
	@: # Do nothing, just consumed by test-* targets

android:
	@: # Do nothing, just consumed by test-* targets

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

_run-patrol-test: ## Internal: Execute Patrol test
	@echo "$(BLUE)🚀 Running Patrol integration test...$(NC)"
	@echo "$(YELLOW)📋 Test: $(TEST_FILE)$(NC)"
	@echo "$(YELLOW)📱 Platform: $(PLATFORM)$(NC)"
	@if [ -z "$(PLATFORM)" ]; then \
		echo "$(RED)❌ Platform not specified$(NC)"; \
		echo "$(YELLOW)Usage: make test-account ios$(NC) or $(YELLOW)make test-account android$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(TEST_FILE)" ]; then \
		echo "$(RED)❌ Test file not found: $(TEST_FILE)$(NC)"; \
		exit 1; \
	fi
	@if [ "$(PLATFORM)" = "ios" ]; then \
		echo "$(BLUE)📱 Ensuring iOS simulator is ready...$(NC)"; \
		$(MAKE) _ensure-ios-device; \
		echo "$(BLUE)🚀 Executing iOS test...$(NC)"; \
		patrol test --target $(TEST_FILE) --device "$(IOS_DEVICE_NAME)" --verbose; \
	elif [ "$(PLATFORM)" = "android" ]; then \
		echo "$(BLUE)🤖 Ensuring Android emulator is ready...$(NC)"; \
		$(MAKE) _ensure-android-device; \
		echo "$(BLUE)🚀 Executing Android test...$(NC)"; \
		patrol test --target $(TEST_FILE) --device $(ANDROID_EMULATOR) --verbose; \
	else \
		echo "$(RED)❌ Invalid platform: $(PLATFORM)$(NC)"; \
		echo "$(YELLOW)Supported platforms: ios, android$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Test completed successfully$(NC)"

_ensure-ios-device: ## Internal: Ensure iOS device is ready
	@if ! xcrun simctl list devices | grep "$(IOS_DEVICE_UDID)" | grep -q "Booted"; then \
		echo "$(YELLOW)⏳ Starting iOS simulator...$(NC)"; \
		$(MAKE) device-start-ios; \
	fi

_ensure-android-device: ## Internal: Ensure Android device is ready
	@if ! adb devices | grep -q "$(ANDROID_EMULATOR).*device"; then \
		echo "$(YELLOW)⏳ Starting Android emulator...$(NC)"; \
		$(MAKE) device-start-android; \
	fi

# =============================================================================
# PATROL COMMAND EXAMPLES (for reference)
# =============================================================================

# Basic Examples:
# patrol test --target integration_test/tests/example_test.dart
# patrol test --target integration_test/tests/example_test.dart --device emulator-5554
# patrol test --target integration_test/tests/example_test.dart --build
# patrol test --target integration_test/tests/example_test.dart --devices "emulator-5554,emulator-5556"
# patrol test --target integration_test/tests/example_test.dart --build --config patrol.yaml
# patrol test --target integration_test/tests/example_test.dart --verbose
# patrol test --target integration_test/tests/example_test.dart --device emulator-5554 --build --verbose
# patrol test --target integration_test/tests/example_test.dart --devices "emulator-5554,emulator-5556" --build --config patrol.yaml --verbose

# Use Case Examples:
# patrol test --target integration_test/tests/account_test.dart --device='iPhone 14' --allure --coverage
# patrol test --target integration_test/tests/dashboard_test.dart --device=emulator-5554 --allure
# patrol test --target integration_test/tests/overview_test.dart --device=emulator-5556
# patrol test --target integration_test/tests/hotels_test.dart --device=all --allure

.DEFAULT_GOAL := help