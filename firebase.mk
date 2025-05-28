# =============================================================================
# HOTEL BOOKING APP - FIREBASE TEST LAB
# =============================================================================
# QA Automation Lead: Firebase Test Lab automation for CI/CD
# Supports: iOS and Android cloud testing with parallel execution
# =============================================================================

.PHONY: help setup list-devices test-* build-* clean status

# =============================================================================
# CONFIGURATION
# =============================================================================

PROJECT_NAME := hotel_booking
FIREBASE_PROJECT_ID := home-search-d7c7c
FIREBASE_BUCKET := patrol_runs

# Device Configuration
IOS_DEVICE_MODEL := iphone15pro
IOS_DEVICE_VERSION := 18.0
ANDROID_DEVICE_MODEL := shiba
ANDROID_DEVICE_VERSION := 34

# Build paths
IOS_BUILD_DIR := build/ios_integ/Build/Products
ANDROID_APP_APK := build/app/outputs/apk/debug/app-debug.apk
ANDROID_TEST_APK := build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk

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

help: ## Show Firebase Test Lab help
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    FIREBASE TEST LAB                                       $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)🔧 SETUP & CONFIGURATION:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)                   - Setup Firebase Test Lab"
	@echo "  $(YELLOW)make list-devices$(NC)            - List available devices"
	@echo "  $(YELLOW)make status$(NC)                  - Check test results"
	@echo ""
	@echo "$(GREEN)🏗️ BUILD:$(NC)"
	@echo "  $(YELLOW)make build-ios$(NC)               - Build iOS for Firebase"
	@echo "  $(YELLOW)make build-android$(NC)           - Build Android for Firebase"
	@echo "  $(YELLOW)make build-all$(NC)               - Build both platforms"
	@echo ""
	@echo "$(GREEN)☁️ TESTING:$(NC)"
	@echo "  $(YELLOW)make test-ios$(NC)                - Run iOS tests on Firebase"
	@echo "  $(YELLOW)make test-android$(NC)            - Run Android tests on Firebase"
	@echo "  $(YELLOW)make test-both$(NC)               - Run tests on both platforms"
	@echo ""
	@echo "$(GREEN)📊 UTILITIES:$(NC)"
	@echo "  $(YELLOW)make clean$(NC)                   - Clean build artifacts"
	@echo "  $(YELLOW)make download-results$(NC)        - Download latest results"
	@echo ""
	@echo "$(GREEN)💡 QUICK START:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)"
	@echo "  $(YELLOW)make build-all$(NC)"
	@echo "  $(YELLOW)make test-both$(NC)"
	@echo ""
	@echo "$(GREEN)📋 PROJECT INFO:$(NC)"
	@echo "  Project ID: $(FIREBASE_PROJECT_ID)"
	@echo "  Results Bucket: $(FIREBASE_BUCKET)"
	@echo "  iOS Device: $(IOS_DEVICE_MODEL) $(IOS_DEVICE_VERSION)"
	@echo "  Android Device: $(ANDROID_DEVICE_MODEL) $(ANDROID_DEVICE_VERSION)"
	@echo ""

# =============================================================================
# SETUP & CONFIGURATION
# =============================================================================

setup: ## Setup Firebase Test Lab
	@echo "$(BLUE)☁️ Setting up Firebase Test Lab...$(NC)"
	@if ! command -v gcloud &> /dev/null; then \
		echo "$(RED)❌ Google Cloud SDK not installed$(NC)"; \
		echo "$(YELLOW)Install from: https://cloud.google.com/sdk/docs/install$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔧 Configuring project...$(NC)"
	@gcloud config set project $(FIREBASE_PROJECT_ID)
	@echo "$(YELLOW)📱 Enabling APIs...$(NC)"
	@gcloud services enable testing.googleapis.com --quiet
	@gcloud services enable toolresults.googleapis.com --quiet
	@echo "$(YELLOW)🪣 Creating results bucket...$(NC)"
	@gsutil mb -p $(FIREBASE_PROJECT_ID) gs://$(FIREBASE_BUCKET) 2>/dev/null || echo "Bucket exists"
	@echo "$(GREEN)✓ Firebase Test Lab setup completed$(NC)"

list-devices: ## List available Firebase devices
	@echo "$(BLUE)📱 Available Firebase Test Lab Devices:$(NC)"
	@echo ""
	@echo "$(YELLOW)iOS Devices:$(NC)"
	@gcloud firebase test ios models list --format="table(id,name,supportedVersions.list():label=VERSIONS)" --limit=10
	@echo ""
	@echo "$(YELLOW)Android Devices:$(NC)"
	@gcloud firebase test android models list --format="table(id,brand,name,supportedVersionIds.list():label=API_LEVELS)" --limit=10

status: ## Check Firebase test results
	@echo "$(BLUE)📊 Firebase Test Lab Status:$(NC)"
	@echo "$(YELLOW)Recent results:$(NC)"
	@gsutil ls -l gs://$(FIREBASE_BUCKET)/ | tail -10 2>/dev/null || echo "No results found"

# =============================================================================
# BUILD
# =============================================================================

build-ios: ## Build iOS for Firebase
	@echo "$(BLUE)🏗️ Building iOS for Firebase Test Lab...$(NC)"
	@patrol build ios --verbose
	@echo "$(YELLOW)📦 Creating iOS test bundle...$(NC)"
	@cd $(IOS_BUILD_DIR) && \
		rm -f ios_tests.zip && \
		zip -r ios_tests.zip Release-iphoneos/*.app *.xctestrun && \
		echo "$(GREEN)✓ iOS test bundle created: ios_tests.zip$(NC)"

build-android: ## Build Android for Firebase
	@echo "$(BLUE)🏗️ Building Android for Firebase Test Lab...$(NC)"
	@patrol build android --verbose
	@if [ -f "$(ANDROID_APP_APK)" ] && [ -f "$(ANDROID_TEST_APK)" ]; then \
		echo "$(GREEN)✓ Android APKs ready$(NC)"; \
		ls -la $(ANDROID_APP_APK); \
		ls -la $(ANDROID_TEST_APK); \
	else \
		echo "$(RED)❌ Android APK build failed$(NC)"; \
		exit 1; \
	fi

build-all: build-ios build-android ## Build both platforms

# =============================================================================
# TESTING
# =============================================================================

test-ios: ## Run iOS tests on Firebase Test Lab
	@echo "$(BLUE)☁️ Running iOS tests on Firebase Test Lab...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@if [ ! -f "$(IOS_BUILD_DIR)/ios_tests.zip" ]; then \
		echo "$(YELLOW)⚠️  iOS build not found, building...$(NC)"; \
		$(MAKE) build-ios; \
	fi
	@$(MAKE) _run-ios-firebase

test-android: ## Run Android tests on Firebase Test Lab
	@echo "$(BLUE)☁️ Running Android tests on Firebase Test Lab...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@if [ ! -f "$(ANDROID_APP_APK)" ] || [ ! -f "$(ANDROID_TEST_APK)" ]; then \
		echo "$(YELLOW)⚠️  Android build not found, building...$(NC)"; \
		$(MAKE) build-android; \
	fi
	@$(MAKE) _run-android-firebase

test-both: ## Run tests on both platforms (parallel execution)
	@echo "$(BLUE)☁️ Running tests on both platforms...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo "$(YELLOW)📱 Starting iOS tests...$(NC)"
	@$(MAKE) test-ios &
	@echo "$(YELLOW)🤖 Starting Android tests...$(NC)"
	@$(MAKE) test-android &
	@echo "$(YELLOW)⏳ Waiting for both platforms to complete...$(NC)"
	@wait
	@echo "$(GREEN)✅ Both platforms completed$(NC)"

# =============================================================================
# UTILITIES
# =============================================================================

clean: ## Clean build artifacts
	@echo "$(BLUE)🧹 Cleaning Firebase build artifacts...$(NC)"
	@rm -rf build/
	@rm -f firebase-*-results.json
	@echo "$(GREEN)✓ Clean completed$(NC)"

download-results: ## Download latest Firebase results
	@echo "$(BLUE)📥 Downloading latest Firebase results...$(NC)"
	@mkdir -p firebase-results
	@LATEST_DIR=$(gsutil ls gs://$(FIREBASE_BUCKET)/ | tail -1); \
	if [ -n "$LATEST_DIR" ]; then \
		echo "$(YELLOW)Downloading: $LATEST_DIR$(NC)"; \
		gsutil -m cp -r "$LATEST_DIR" firebase-results/; \
		echo "$(GREEN)✓ Results downloaded to firebase-results/$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  No results found$(NC)"; \
	fi

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

_ensure-firebase-setup: ## Internal: Ensure Firebase is configured
	@if ! gcloud config get-value project &>/dev/null; then \
		echo "$(RED)❌ Firebase not configured$(NC)"; \
		echo "$(YELLOW)Run: make setup$(NC)"; \
		exit 1; \
	fi
	@if [ "$(gcloud config get-value project)" != "$(FIREBASE_PROJECT_ID)" ]; then \
		echo "$(YELLOW)⚠️  Switching to project: $(FIREBASE_PROJECT_ID)$(NC)"; \
		gcloud config set project $(FIREBASE_PROJECT_ID); \
	fi

_run-ios-firebase: ## Internal: Execute iOS Firebase tests
	@echo "$(BLUE)🚀 Executing iOS tests on Firebase...$(NC)"
	@TIMESTAMP=$(date +%Y%m%d-%H%M%S); \
	RESULTS_DIR="ios-tests/$TIMESTAMP"; \
	echo "$(YELLOW)Results: gs://$(FIREBASE_BUCKET)/$RESULTS_DIR$(NC)"; \
	cd $(IOS_BUILD_DIR) && \
	rm -f ios_tests.zip && \
	zip -r ios_tests.zip Release-iphoneos/*.app *.xctestrun && \
	cd - && \
	gcloud firebase test ios run \
		--type xctest \
		--test "$(IOS_BUILD_DIR)/ios_tests.zip" \
		--device model="$(IOS_DEVICE_MODEL)",version="$(IOS_DEVICE_VERSION)",locale=en_US,orientation=portrait \
		--timeout 10m \
		--results-bucket="$(FIREBASE_BUCKET)" \
		--results-dir="$RESULTS_DIR" \
		--project="$(FIREBASE_PROJECT_ID)" \
		--format=json | tee firebase-ios-results.json; \
	$(MAKE) _process-results PLATFORM=ios

_run-android-firebase: ## Internal: Execute Android Firebase tests
	@echo "$(BLUE)🚀 Executing Android tests on Firebase...$(NC)"
	@TIMESTAMP=$(date +%Y%m%d-%H%M%S); \
	RESULTS_DIR="android-tests/$TIMESTAMP"; \
	echo "$(YELLOW)Results: gs://$(FIREBASE_BUCKET)/$RESULTS_DIR$(NC)"; \
	gcloud firebase test android run \
		--type instrumentation \
		--app "$(ANDROID_APP_APK)" \
		--test "$(ANDROID_TEST_APK)" \
		--device model="$(ANDROID_DEVICE_MODEL)",version="$(ANDROID_DEVICE_VERSION)",locale=en,orientation=portrait \
		--timeout 10m \
		--results-bucket="$(FIREBASE_BUCKET)" \
		--results-dir="$RESULTS_DIR" \
		--use-orchestrator \
		--environment-variables clearPackageData=true \
		--project="$(FIREBASE_PROJECT_ID)" \
		--format=json | tee firebase-android-results.json; \
	$(MAKE) _process-results PLATFORM=android

_process-results: ## Internal: Process Firebase results
	@echo "$(BLUE)📊 Processing $(PLATFORM) results...$(NC)"
	@if [ -f "firebase-$(PLATFORM)-results.json" ]; then \
		RESULTS_URL=$(cat firebase-$(PLATFORM)-results.json | jq -r '.[0].testDetails.resultsUrl // empty' 2>/dev/null); \
		if [ -n "$RESULTS_URL" ]; then \
			echo "$(GREEN)🔗 $(PLATFORM) Results: $RESULTS_URL$(NC)"; \
		fi; \
		OUTCOME=$(cat firebase-$(PLATFORM)-results.json | jq -r '.[0].outcome // empty' 2>/dev/null); \
		if [ "$OUTCOME" = "PASSED" ]; then \
			echo "$(GREEN)✅ $(PLATFORM) tests PASSED$(NC)"; \
		elif [ "$OUTCOME" = "FAILED" ]; then \
			echo "$(RED)❌ $(PLATFORM) tests FAILED$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  $(PLATFORM) outcome: $OUTCOME$(NC)"; \
		fi; \
	fi

.DEFAULT_GOAL := help