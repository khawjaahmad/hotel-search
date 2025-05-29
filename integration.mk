# =============================================================================
# INTEGRATION.MK - PATROL INTEGRATION TESTS
# =============================================================================
# QA Automation Lead: Patrol integration test automation
# Supports: iOS Simulator, Android Emulator with Patrol CLI
# Usage: Include in main Makefile
# =============================================================================

# =============================================================================
# INTEGRATION TEST CONFIGURATION
# =============================================================================

INTEGRATION_TEST_DIR := integration_test/tests

# Device Configuration (Your Specific Devices)
IOS_DEVICE_NAME := iPhone 16 Plus
IOS_DEVICE_UDID := AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8
ANDROID_EMULATOR := emulator-5554
ANDROID_EMULATOR_NAME := Pixel_7

# Test Files
ACCOUNT_TEST := $(INTEGRATION_TEST_DIR)/account_test.dart
DASHBOARD_TEST := $(INTEGRATION_TEST_DIR)/dashboard_test.dart
OVERVIEW_TEST := $(INTEGRATION_TEST_DIR)/overview_test.dart
HOTELS_TEST := $(INTEGRATION_TEST_DIR)/hotels_test.dart

# =============================================================================
# DEVICE MANAGEMENT
# =============================================================================

device-start-ios: ## Start iOS simulator
	@echo "$(BLUE)📱 Starting iOS Simulator: $(IOS_DEVICE_NAME)...$(NC)"
	@if xcrun simctl list devices | grep "$(IOS_DEVICE_UDID)" | grep -q "Booted"; then \
		echo "$(GREEN)✓ iOS Simulator already running$(NC)"; \
	else \
		echo "$(YELLOW)⏳ Booting iOS Simulator...$(NC)"; \
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

device-status: ## Check device status
	@echo "$(BLUE)📱 Device Status:$(NC)"
	@echo ""
	@echo "$(YELLOW)Target iOS Device:$(NC)"
	@if xcrun simctl list devices | grep "$(IOS_DEVICE_UDID)" | grep -q "Booted"; then \
		echo "  ✅ $(IOS_DEVICE_NAME) ($(IOS_DEVICE_UDID)) - RUNNING"; \
	else \
		echo "  ❌ $(IOS_DEVICE_NAME) ($(IOS_DEVICE_UDID)) - STOPPED"; \
	fi
	@echo ""
	@echo "$(YELLOW)Target Android Device:$(NC)"
	@if adb devices | grep -q "$(ANDROID_EMULATOR).*device"; then \
		echo "  ✅ $(ANDROID_EMULATOR_NAME) ($(ANDROID_EMULATOR)) - RUNNING"; \
	else \
		echo "  ❌ $(ANDROID_EMULATOR_NAME) ($(ANDROID_EMULATOR)) - STOPPED"; \
	fi

# =============================================================================
# INTEGRATION TESTS - INDIVIDUAL
# =============================================================================

test-account: ## Run account integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(ACCOUNT_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-dashboard: ## Run dashboard integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(DASHBOARD_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-overview: ## Run overview integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(OVERVIEW_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

test-hotels: ## Run hotels integration tests (requires: ios/android)
	@$(MAKE) _run-patrol-test TEST_FILE=$(HOTELS_TEST) PLATFORM=$(filter ios android,$(MAKECMDGOALS))

# =============================================================================
# INTEGRATION TESTS - SUITES
# =============================================================================

test-all: ## Run all integration tests (requires: ios/android)
	@echo "$(BLUE)🚀 Running all integration tests...$(NC)"
	@$(MAKE) test-account $(filter ios android,$(MAKECMDGOALS))
	@$(MAKE) test-dashboard $(filter ios android,$(MAKECMDGOALS))
	@$(MAKE) test-overview $(filter ios android,$(MAKECMDGOALS))
	@$(MAKE) test-hotels $(filter ios android,$(MAKECMDGOALS))
	@echo "$(GREEN)✅ All integration tests completed$(NC)"

test-suite-ios: ## Run all integration tests on iOS (no parameter needed)
	@echo "$(BLUE)📱 Running complete iOS integration test suite...$(NC)"
	@$(MAKE) _ensure-ios-device
	@$(MAKE) _run-patrol-test TEST_FILE=$(ACCOUNT_TEST) PLATFORM=ios
	@$(MAKE) _run-patrol-test TEST_FILE=$(DASHBOARD_TEST) PLATFORM=ios
	@$(MAKE) _run-patrol-test TEST_FILE=$(OVERVIEW_TEST) PLATFORM=ios
	@$(MAKE) _run-patrol-test TEST_FILE=$(HOTELS_TEST) PLATFORM=ios
	@echo "$(GREEN)✅ iOS integration test suite completed$(NC)"

test-suite-android: ## Run all integration tests on Android (no parameter needed)
	@echo "$(BLUE)🤖 Running complete Android integration test suite...$(NC)"
	@$(MAKE) _ensure-android-device
	@$(MAKE) _run-patrol-test TEST_FILE=$(ACCOUNT_TEST) PLATFORM=android
	@$(MAKE) _run-patrol-test TEST_FILE=$(DASHBOARD_TEST) PLATFORM=android
	@$(MAKE) _run-patrol-test TEST_FILE=$(OVERVIEW_TEST) PLATFORM=android
	@$(MAKE) _run-patrol-test TEST_FILE=$(HOTELS_TEST) PLATFORM=android
	@echo "$(GREEN)✅ Android integration test suite completed$(NC)"

# =============================================================================
# PATROL COMMAND SHORTCUTS
# =============================================================================

patrol-hotels-ios: ## Quick: Hotels test on iOS
	@$(MAKE) device-start-ios
	@$(MAKE) _run-patrol-test TEST_FILE=$(HOTELS_TEST) PLATFORM=ios

patrol-hotels-android: ## Quick: Hotels test on Android
	@$(MAKE) device-start-android
	@$(MAKE) _run-patrol-test TEST_FILE=$(HOTELS_TEST) PLATFORM=android

patrol-account-ios: ## Quick: Account test on iOS
	@$(MAKE) device-start-ios
	@$(MAKE) _run-patrol-test TEST_FILE=$(ACCOUNT_TEST) PLATFORM=ios

patrol-account-android: ## Quick: Account test on Android
	@$(MAKE) device-start-android
	@$(MAKE) _run-patrol-test TEST_FILE=$(ACCOUNT_TEST) PLATFORM=android

# =============================================================================
# PLATFORM TARGETS (for parameter consumption)
# =============================================================================

ios: ## Platform target (consumed by test-* targets)
	@: # Do nothing, just consumed by test-* targets

android: ## Platform target (consumed by test-* targets)
	@: # Do nothing, just consumed by test-* targets

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

_run-patrol-test: ## Internal: Execute Patrol test
	@if [ -z "$(TEST_FILE)" ]; then \
		echo "$(RED)❌ TEST_FILE not specified$(NC)"; \
		exit 1; \
	fi
	@if [ -z "$(PLATFORM)" ]; then \
		echo "$(RED)❌ Platform not specified$(NC)"; \
		echo "$(YELLOW)Usage: make test-account ios$(NC) or $(YELLOW)make test-account android$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(TEST_FILE)" ]; then \
		echo "$(RED)❌ Test file not found: $(TEST_FILE)$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🚀 Running Patrol integration test...$(NC)"
	@echo "$(YELLOW)📋 Test: $(TEST_FILE)$(NC)"
	@echo "$(YELLOW)📱 Platform: $(PLATFORM)$(NC)"
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

_check-patrol: ## Internal: Check Patrol installation
	@if ! command -v patrol &> /dev/null; then \
		echo "$(RED)❌ Patrol CLI not installed$(NC)"; \
		echo "$(YELLOW)Install: dart pub global activate patrol_cli$(NC)"; \
		exit 1; \
	fi

_check-integration-setup: ## Internal: Verify integration test setup
	@echo "$(BLUE)🔍 Checking integration test setup...$(NC)"
	@$(MAKE) _check-patrol
	@if [ ! -d "$(INTEGRATION_TEST_DIR)" ]; then \
		echo "$(RED)❌ Integration test directory not found: $(INTEGRATION_TEST_DIR)$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Integration test setup verified$(NC)"

# =============================================================================
# INTEGRATION TEST REPORTING
# =============================================================================

integration-status: ## Show integration test status
	@echo "$(BLUE)📊 Integration Test Status$(NC)"
	@echo ""
	@$(MAKE) device-status
	@echo ""
	@echo "$(YELLOW)Test Files:$(NC)"
	@for test in $(ACCOUNT_TEST) $(DASHBOARD_TEST) $(OVERVIEW_TEST) $(HOTELS_TEST); do \
		if [ -f "$$test" ]; then \
			echo "  ✅ $$test"; \
		else \
			echo "  ❌ $$test (missing)"; \
		fi; \
	done
	@echo ""
	@echo "$(YELLOW)Patrol CLI:$(NC)"
	@if command -v patrol &> /dev/null; then \
		echo "  ✅ $(shell patrol --version 2>/dev/null)"; \
	else \
		echo "  ❌ Not installed"; \
	fi

integration-clean: ## Clean integration test artifacts
	@echo "$(BLUE)🧹 Cleaning integration test artifacts...$(NC)"
	@rm -rf build/
	@find . -name "*.patrol" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Integration artifacts cleaned$(NC)"

# =============================================================================
# HELP FOR INTEGRATION TESTS
# =============================================================================

integration-help: ## Show detailed integration test help
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    PATROL INTEGRATION TESTS HELP                           $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)📱 INDIVIDUAL TESTS:$(NC)"
	@echo "  $(YELLOW)make test-account ios$(NC)         - Account tests on iOS"
	@echo "  $(YELLOW)make test-dashboard android$(NC)   - Dashboard tests on Android"
	@echo "  $(YELLOW)make test-overview ios$(NC)        - Overview tests on iOS"
	@echo "  $(YELLOW)make test-hotels android$(NC)      - Hotels tests on Android"
	@echo ""
	@echo "$(GREEN)🔄 TEST SUITES:$(NC)"
	@echo "  $(YELLOW)make test-all ios$(NC)             - All tests on iOS (requires 'ios' parameter)"
	@echo "  $(YELLOW)make test-all android$(NC)         - All tests on Android (requires 'android' parameter)"
	@echo "  $(YELLOW)make test-suite-ios$(NC)           - All tests on iOS (no parameter needed)"
	@echo "  $(YELLOW)make test-suite-android$(NC)       - All tests on Android (no parameter needed)"
	@echo ""
	@echo "$(GREEN)⚡ QUICK COMMANDS:$(NC)"
	@echo "  $(YELLOW)make patrol-hotels-ios$(NC)        - Start iOS + run hotels test"
	@echo "  $(YELLOW)make patrol-account-android$(NC)   - Start Android + run account test"
	@echo ""
	@echo "$(GREEN)🔧 DEVICE MANAGEMENT:$(NC)"
	@echo "  $(YELLOW)make device-start-ios$(NC)         - Start iOS simulator"
	@echo "  $(YELLOW)make device-start-android$(NC)     - Start Android emulator"
	@echo "  $(YELLOW)make device-stop-ios$(NC)          - Stop iOS simulator"
	@echo "  $(YELLOW)make device-stop-android$(NC)      - Stop Android emulator"
	@echo "  $(YELLOW)make device-list$(NC)              - List all devices"
	@echo "  $(YELLOW)make device-status$(NC)            - Check target device status"
	@echo ""
	@echo "$(GREEN)📊 UTILITIES:$(NC)"
	@echo "  $(YELLOW)make integration-status$(NC)       - Check integration test setup"
	@echo "  $(YELLOW)make integration-clean$(NC)        - Clean integration artifacts"
	@echo ""
	@echo "$(GREEN)📋 CONFIGURED DEVICES:$(NC)"
	@echo "  iOS: $(IOS_DEVICE_NAME) ($(IOS_DEVICE_UDID))"
	@echo "  Android: $(ANDROID_EMULATOR_NAME) ($(ANDROID_EMULATOR))"
	@echo ""
	@echo "$(GREEN)💡 EXAMPLES:$(NC)"
	@echo "  $(YELLOW)make device-start-ios && make test-hotels ios$(NC)"
	@echo "  $(YELLOW)make patrol-account-android$(NC)"
	@echo "  $(YELLOW)make test-suite-ios$(NC)"
	@echo ""