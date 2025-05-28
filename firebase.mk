# =============================================================================
# FIREBASE.MK - FIREBASE TEST LAB
# =============================================================================
# QA Automation Lead: Firebase Test Lab automation for CI/CD
# Supports: iOS and Android cloud testing with parallel execution
# Usage: Include in main Makefile
# =============================================================================

# =============================================================================
# FIREBASE CONFIGURATION
# =============================================================================

# Firebase Project Settings
FIREBASE_PROJECT_ID := home-search-d7c7c
FIREBASE_BUCKET := patrol_runs
FIREBASE_RESULTS_DIR := firebase-results

# Device Configuration for Firebase Test Lab
IOS_DEVICE_MODEL := iphone15pro
IOS_DEVICE_VERSION := 18.0
ANDROID_DEVICE_MODEL := shiba
ANDROID_DEVICE_VERSION := 34

# Build Paths
IOS_BUILD_DIR := build/ios_integ/Build/Products
ANDROID_APP_APK := build/app/outputs/apk/debug/app-debug.apk
ANDROID_TEST_APK := build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk

# Test Configuration
FIREBASE_TIMEOUT := 10m
FIREBASE_LOCALE := en_US
FIREBASE_ORIENTATION := portrait

# =============================================================================
# FIREBASE SETUP & CONFIGURATION
# =============================================================================

firebase-setup: ## Setup Firebase Test Lab
	@echo "$(BLUE)☁️ Setting up Firebase Test Lab...$(NC)"
	@$(MAKE) _check-firebase-cli
	@echo "$(YELLOW)🔧 Configuring project: $(FIREBASE_PROJECT_ID)...$(NC)"
	@gcloud config set project $(FIREBASE_PROJECT_ID)
	@echo "$(YELLOW)📱 Enabling required APIs...$(NC)"
	@gcloud services enable testing.googleapis.com --quiet || echo "$(YELLOW)API already enabled$(NC)"
	@gcloud services enable toolresults.googleapis.com --quiet || echo "$(YELLOW)API already enabled$(NC)"
	@echo "$(YELLOW)🪣 Creating results bucket...$(NC)"
	@gsutil mb -p $(FIREBASE_PROJECT_ID) gs://$(FIREBASE_BUCKET) 2>/dev/null || echo "$(GREEN)Bucket already exists$(NC)"
	@mkdir -p $(FIREBASE_RESULTS_DIR)
	@echo "$(GREEN)✅ Firebase Test Lab setup completed$(NC)"
	@$(MAKE) firebase-status

firebase-login: ## Login to Firebase/Google Cloud
	@echo "$(BLUE)🔐 Firebase Authentication...$(NC)"
	@gcloud auth login
	@gcloud auth application-default login
	@echo "$(GREEN)✅ Firebase authentication completed$(NC)"

firebase-info: ## Show Firebase project information
	@echo "$(BLUE)📋 Firebase Test Lab Configuration$(NC)"
	@echo ""
	@echo "$(GREEN)Project Settings:$(NC)"
	@echo "  Project ID: $(FIREBASE_PROJECT_ID)"
	@echo "  Results Bucket: gs://$(FIREBASE_BUCKET)"
	@echo "  Results Directory: $(FIREBASE_RESULTS_DIR)"
	@echo "  Timeout: $(FIREBASE_TIMEOUT)"
	@echo ""
	@echo "$(GREEN)Target Devices:$(NC)"
	@echo "  iOS: $(IOS_DEVICE_MODEL) $(IOS_DEVICE_VERSION)"
	@echo "  Android: $(ANDROID_DEVICE_MODEL) API $(ANDROID_DEVICE_VERSION)"
	@echo ""
	@echo "$(GREEN)Current Project:$(NC)"
	@if gcloud config get-value project &>/dev/null; then \
		echo "  Active: $(shell gcloud config get-value project)"; \
	else \
		echo "  $(RED)❌ No project configured$(NC)"; \
	fi

# =============================================================================
# DEVICE MANAGEMENT
# =============================================================================

firebase-list-devices: ## List available Firebase devices
	@echo "$(BLUE)📱 Available Firebase Test Lab Devices$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo ""
	@echo "$(YELLOW)iOS Devices (Top 10):$(NC)"
	@gcloud firebase test ios models list \
		--format="table(id,name,supportedVersions.list():label=VERSIONS)" \
		--limit=10 2>/dev/null || echo "$(RED)Failed to list iOS devices$(NC)"
	@echo ""
	@echo "$(YELLOW)Android Devices (Top 10):$(NC)"
	@gcloud firebase test android models list \
		--format="table(id,brand,name,supportedVersionIds.list():label=API_LEVELS)" \
		--limit=10 2>/dev/null || echo "$(RED)Failed to list Android devices$(NC)"

firebase-test-config: ## Show current test configuration
	@echo "$(BLUE)⚙️ Firebase Test Configuration$(NC)"
	@echo ""
	@echo "$(YELLOW)iOS Configuration:$(NC)"
	@echo "  Model: $(IOS_DEVICE_MODEL)"
	@echo "  Version: $(IOS_DEVICE_VERSION)"
	@echo "  Locale: $(FIREBASE_LOCALE)"
	@echo "  Orientation: $(FIREBASE_ORIENTATION)"
	@echo ""
	@echo "$(YELLOW)Android Configuration:$(NC)"
	@echo "  Model: $(ANDROID_DEVICE_MODEL)"
	@echo "  API Level: $(ANDROID_DEVICE_VERSION)"
	@echo "  Locale: en"
	@echo "  Orientation: $(FIREBASE_ORIENTATION)"
	@echo ""
	@echo "$(YELLOW)Build Paths:$(NC)"
	@echo "  iOS Build: $(IOS_BUILD_DIR)"
	@echo "  Android App: $(ANDROID_APP_APK)"
	@echo "  Android Test: $(ANDROID_TEST_APK)"

# =============================================================================
# BUILD MANAGEMENT
# =============================================================================

firebase-build-ios: ## Build iOS for Firebase
	@echo "$(BLUE)🏗️ Building iOS for Firebase Test Lab...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo "$(YELLOW)📱 Building iOS integration tests...$(NC)"
	@patrol build ios --verbose
	@echo "$(YELLOW)📦 Creating iOS test bundle...$(NC)"
	@cd $(IOS_BUILD_DIR) && \
		rm -f ios_tests.zip && \
		if [ -d "Release-iphoneos" ] && [ -f "*.xctestrun" ]; then \
			zip -r ios_tests.zip Release-iphoneos/*.app *.xctestrun && \
			echo "$(GREEN)✅ iOS test bundle created: ios_tests.zip$(NC)"; \
		else \
			echo "$(RED)❌ iOS build artifacts not found$(NC)"; \
			echo "$(YELLOW)Expected: Release-iphoneos/*.app and *.xctestrun files$(NC)"; \
			exit 1; \
		fi

firebase-build-android: ## Build Android for Firebase
	@echo "$(BLUE)🏗️ Building Android for Firebase Test Lab...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo "$(YELLOW)🤖 Building Android integration tests...$(NC)"
	@patrol build android --verbose
	@echo "$(YELLOW)📦 Verifying Android APKs...$(NC)"
	@if [ -f "$(ANDROID_APP_APK)" ] && [ -f "$(ANDROID_TEST_APK)" ]; then \
		echo "$(GREEN)✅ Android APKs ready$(NC)"; \
		echo "  App APK: $(ANDROID_APP_APK) ($(shell ls -lh $(ANDROID_APP_APK) | awk '{print $$5}'))"; \
		echo "  Test APK: $(ANDROID_TEST_APK) ($(shell ls -lh $(ANDROID_TEST_APK) | awk '{print $$5}'))"; \
	else \
		echo "$(RED)❌ Android APK build failed$(NC)"; \
		echo "$(YELLOW)Expected files:$(NC)"; \
		echo "  $(ANDROID_APP_APK)"; \
		echo "  $(ANDROID_TEST_APK)"; \
		exit 1; \
	fi

firebase-build-all: firebase-build-ios firebase-build-android ## Build both platforms for Firebase

firebase-build-status: ## Check build status
	@echo "$(BLUE)📊 Firebase Build Status$(NC)"
	@echo ""
	@echo "$(YELLOW)iOS Build:$(NC)"
	@if [ -f "$(IOS_BUILD_DIR)/ios_tests.zip" ]; then \
		echo "  ✅ iOS test bundle ready ($(shell ls -lh $(IOS_BUILD_DIR)/ios_tests.zip | awk '{print $$5}'))"; \
	else \
		echo "  ❌ iOS test bundle missing"; \
		echo "     Run: make firebase-build-ios"; \
	fi
	@echo ""
	@echo "$(YELLOW)Android Build:$(NC)"
	@if [ -f "$(ANDROID_APP_APK)" ] && [ -f "$(ANDROID_TEST_APK)" ]; then \
		echo "  ✅ Android APKs ready"; \
		echo "     App: $(shell ls -lh $(ANDROID_APP_APK) | awk '{print $$5}')"; \
		echo "     Test: $(shell ls -lh $(ANDROID_TEST_APK) | awk '{print $$5}')"; \
	else \
		echo "  ❌ Android APKs missing"; \
		echo "     Run: make firebase-build-android"; \
	fi

# =============================================================================
# FIREBASE TESTING
# =============================================================================

firebase-test-ios: ## Run iOS tests on Firebase Test Lab
	@echo "$(BLUE)☁️ Running iOS tests on Firebase Test Lab...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@if [ ! -f "$(IOS_BUILD_DIR)/ios_tests.zip" ]; then \
		echo "$(YELLOW)⚠️ iOS build not found, building...$(NC)"; \
		$(MAKE) firebase-build-ios; \
	fi
	@$(MAKE) _execute-firebase-ios-test

firebase-test-android: ## Run Android tests on Firebase Test Lab
	@echo "$(BLUE)☁️ Running Android tests on Firebase Test Lab...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@if [ ! -f "$(ANDROID_APP_APK)" ] || [ ! -f "$(ANDROID_TEST_APK)" ]; then \
		echo "$(YELLOW)⚠️ Android build not found, building...$(NC)"; \
		$(MAKE) firebase-build-android; \
	fi
	@$(MAKE) _execute-firebase-android-test

firebase-test-both: ## Run tests on both platforms (parallel execution)
	@echo "$(BLUE)☁️ Running tests on both platforms in parallel...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo "$(YELLOW)📱 Starting iOS tests in background...$(NC)"
	@$(MAKE) firebase-test-ios > firebase-ios.log 2>&1 &
	@IOS_PID=$$!; \
	echo "$(YELLOW)🤖 Starting Android tests in background...$(NC)"; \
	$(MAKE) firebase-test-android > firebase-android.log 2>&1 & \
	ANDROID_PID=$$!; \
	echo "$(YELLOW)⏳ Waiting for both platforms to complete...$(NC)"; \
	wait $$IOS_PID; IOS_RESULT=$$?; \
	wait $$ANDROID_PID; ANDROID_RESULT=$$?; \
	echo "$(BLUE)📊 Results Summary:$(NC)"; \
	if [ $$IOS_RESULT -eq 0 ]; then \
		echo "  ✅ iOS tests: PASSED"; \
	else \
		echo "  ❌ iOS tests: FAILED (see firebase-ios.log)"; \
	fi; \
	if [ $$ANDROID_RESULT -eq 0 ]; then \
		echo "  ✅ Android tests: PASSED"; \
	else \
		echo "  ❌ Android tests: FAILED (see firebase-android.log)"; \
	fi; \
	if [ $$IOS_RESULT -eq 0 ] && [ $$ANDROID_RESULT -eq 0 ]; then \
		echo "$(GREEN)🎉 All Firebase tests PASSED!$(NC)"; \
	else \
		echo "$(RED)💥 Some Firebase tests FAILED$(NC)"; \
		exit 1; \
	fi

firebase-test-quick: ## Quick test on single device per platform
	@echo "$(BLUE)⚡ Quick Firebase Test (Single Device)$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@$(MAKE) firebase-build-all
	@$(MAKE) firebase-test-both

# =============================================================================
# RESULTS MANAGEMENT
# =============================================================================

firebase-status: ## Check Firebase test results and project status
	@echo "$(BLUE)📊 Firebase Test Lab Status$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo ""
	@echo "$(YELLOW)Project Configuration:$(NC)"
	@echo "  Project: $(shell gcloud config get-value project 2>/dev/null || echo 'Not configured')"
	@echo "  Bucket: gs://$(FIREBASE_BUCKET)"
	@echo ""
	@echo "$(YELLOW)Recent Results:$(NC)"
	@gsutil ls -l gs://$(FIREBASE_BUCKET)/ 2>/dev/null | tail -5 || echo "  No results found or bucket access denied"

firebase-results: ## Download latest Firebase results
	@echo "$(BLUE)📥 Downloading latest Firebase results...$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@mkdir -p $(FIREBASE_RESULTS_DIR)
	@echo "$(YELLOW)Checking for latest results...$(NC)"
	@LATEST_DIR=$$(gsutil ls gs://$(FIREBASE_BUCKET)/ | tail -1); \
	if [ -n "$$LATEST_DIR" ]; then \
		echo "$(YELLOW)Downloading: $$LATEST_DIR$(NC)"; \
		gsutil -m cp -r "$$LATEST_DIR" $(FIREBASE_RESULTS_DIR)/; \
		echo "$(GREEN)✅ Results downloaded to $(FIREBASE_RESULTS_DIR)/$(NC)"; \
		$(MAKE) _analyze-results; \
	else \
		echo "$(YELLOW)⚠️ No results found in Firebase bucket$(NC)"; \
	fi

firebase-results-list: ## List all Firebase test results
	@echo "$(BLUE)📋 Firebase Test Results History$(NC)"
	@$(MAKE) _ensure-firebase-setup
	@echo ""
	@gsutil ls -la gs://$(FIREBASE_BUCKET)/ | head -20 || echo "No results found or access denied"

firebase-results-clean: ## Clean local Firebase results
	@echo "$(BLUE)🧹 Cleaning local Firebase results...$(NC)"
	@rm -rf $(FIREBASE_RESULTS_DIR)
	@rm -f firebase-*-results.json firebase-*.log
	@mkdir -p $(FIREBASE_RESULTS_DIR)
	@echo "$(GREEN)✅ Local Firebase results cleaned$(NC)"

# =============================================================================
# UTILITIES
# =============================================================================

firebase-clean: ## Clean Firebase build artifacts
	@echo "$(BLUE)🧹 Cleaning Firebase build artifacts...$(NC)"
	@rm -rf build/
	@rm -f firebase-*-results.json firebase-*.log
	@rm -rf $(FIREBASE_RESULTS_DIR)
	@mkdir -p $(FIREBASE_RESULTS_DIR)
	@echo "$(GREEN)✅ Firebase artifacts cleaned$(NC)"

firebase-auth-status: ## Check Firebase authentication status
	@echo "$(BLUE)🔐 Firebase Authentication Status$(NC)"
	@echo ""
	@echo "$(YELLOW)Active Account:$(NC)"
	@gcloud auth list --format="table(account,status)" 2>/dev/null || echo "  Not authenticated"
	@echo ""
	@echo "$(YELLOW)Application Default Credentials:$(NC)"
	@gcloud auth application-default print-access-token >/dev/null 2>&1 && \
		echo "  ✅ Available" || echo "  ❌ Not configured"

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

_check-firebase-cli: ## Internal: Check Firebase CLI installation
	@if ! command -v gcloud &> /dev/null; then \
		echo "$(RED)❌ Google Cloud SDK not installed$(NC)"; \
		echo "$(YELLOW)Install from: https://cloud.google.com/sdk/docs/install$(NC)"; \
		exit 1; \
	fi
	@if ! command -v gsutil &> /dev/null; then \
		echo "$(RED)❌ gsutil not found$(NC)"; \
		echo "$(YELLOW)Install Google Cloud SDK with gsutil$(NC)"; \
		exit 1; \
	fi

_ensure-firebase-setup: ## Internal: Ensure Firebase is configured
	@$(MAKE) _check-firebase-cli
	@if ! gcloud config get-value project &>/dev/null; then \
		echo "$(RED)❌ Firebase not configured$(NC)"; \
		echo "$(YELLOW)Run: make firebase-setup$(NC)"; \
		exit 1; \
	fi
	@if [ "$$(gcloud config get-value project)" != "$(FIREBASE_PROJECT_ID)" ]; then \
		echo "$(YELLOW)⚠️ Switching to project: $(FIREBASE_PROJECT_ID)$(NC)"; \
		gcloud config set project $(FIREBASE_PROJECT_ID); \
	fi

_execute-firebase-ios-test: ## Internal: Execute iOS Firebase test
	@echo "$(BLUE)🚀 Executing iOS test on Firebase...$(NC)"
	@TIMESTAMP=$$(date +%Y%m%d-%H%M%S); \
	RESULTS_DIR="ios-tests/$$TIMESTAMP"; \
	echo "$(YELLOW)Results will be stored at: gs://$(FIREBASE_BUCKET)/$$RESULTS_DIR$(NC)"; \
	cd $(IOS_BUILD_DIR) && \
	if [ ! -f "ios_tests.zip" ]; then \
		echo "$(YELLOW)Creating iOS test bundle...$(NC)"; \
		zip -r ios_tests.zip Release-iphoneos/*.app *.xctestrun; \
	fi && \
	cd - && \
	gcloud firebase test ios run \
		--type xctest \
		--test "$(IOS_BUILD_DIR)/ios_tests.zip" \
		--device model="$(IOS_DEVICE_MODEL)",version="$(IOS_DEVICE_VERSION)",locale=$(FIREBASE_LOCALE),orientation=$(FIREBASE_ORIENTATION) \
		--timeout $(FIREBASE_TIMEOUT) \
		--results-bucket="$(FIREBASE_BUCKET)" \
		--results-dir="$$RESULTS_DIR" \
		--project="$(FIREBASE_PROJECT_ID)" \
		--format=json | tee firebase-ios-results.json; \
	$(MAKE) _process-firebase-results PLATFORM=ios RESULTS_FILE=firebase-ios-results.json

_execute-firebase-android-test: ## Internal: Execute Android Firebase test
	@echo "$(BLUE)🚀 Executing Android test on Firebase...$(NC)"
	@TIMESTAMP=$$(date +%Y%m%d-%H%M%S); \
	RESULTS_DIR="android-tests/$$TIMESTAMP"; \
	echo "$(YELLOW)Results will be stored at: gs://$(FIREBASE_BUCKET)/$$RESULTS_DIR$(NC)"; \
	gcloud firebase test android run \
		--type instrumentation \
		--app "$(ANDROID_APP_APK)" \
		--test "$(ANDROID_TEST_APK)" \
		--device model="$(ANDROID_DEVICE_MODEL)",version="$(ANDROID_DEVICE_VERSION)",locale=en,orientation=$(FIREBASE_ORIENTATION) \
		--timeout $(FIREBASE_TIMEOUT) \
		--results-bucket="$(FIREBASE_BUCKET)" \
		--results-dir="$$RESULTS_DIR" \
		--use-orchestrator \
		--environment-variables clearPackageData=true \
		--project="$(FIREBASE_PROJECT_ID)" \
		--format=json | tee firebase-android-results.json; \
	$(MAKE) _process-firebase-results PLATFORM=android RESULTS_FILE=firebase-android-results.json

_process-firebase-results: ## Internal: Process Firebase test results
	@echo "$(BLUE)📊 Processing $(PLATFORM) results...$(NC)"
	@if [ -f "$(RESULTS_FILE)" ]; then \
		RESULTS_URL=$$(cat $(RESULTS_FILE) | jq -r '.[0].testDetails.resultsUrl // empty' 2>/dev/null); \
		OUTCOME=$$(cat $(RESULTS_FILE) | jq -r '.[0].outcome // empty' 2>/dev/null); \
		if [ -n "$$RESULTS_URL" ]; then \
			echo "$(GREEN)🔗 $(PLATFORM) Results URL: $$RESULTS_URL$(NC)"; \
		fi; \
		case "$$OUTCOME" in \
			"PASSED") \
				echo "$(GREEN)✅ $(PLATFORM) tests PASSED$(NC)"; \
				;; \
			"FAILED") \
				echo "$(RED)❌ $(PLATFORM) tests FAILED$(NC)"; \
				;; \
			*) \
				echo "$(YELLOW)⚠️ $(PLATFORM) outcome: $$OUTCOME$(NC)"; \
				;; \
		esac; \
	else \
		echo "$(YELLOW)⚠️ No results file found: $(RESULTS_FILE)$(NC)"; \
	fi

_analyze-results: ## Internal: Analyze downloaded results
	@echo "$(BLUE)🔍 Analyzing downloaded results...$(NC)"
	@if [ -d "$(FIREBASE_RESULTS_DIR)" ]; then \
		RESULT_COUNT=$$(find $(FIREBASE_RESULTS_DIR) -name "*.xml" | wc -l); \
		if [ $$RESULT_COUNT -gt 0 ]; then \
			echo "$(GREEN)📊 Found $$RESULT_COUNT test result files$(NC)"; \
			echo "$(YELLOW)Latest results in: $(FIREBASE_RESULTS_DIR)$(NC)"; \
		else \
			echo "$(YELLOW)⚠️ No test result files found$(NC)"; \
		fi; \
	fi

# =============================================================================
# FIREBASE HELP
# =============================================================================

firebase-help: ## Show detailed Firebase help
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo "$(CYAN)                    FIREBASE TEST LAB HELP                                  $(NC)"
	@echo "$(CYAN)=============================================================================$(NC)"
	@echo ""
	@echo "$(GREEN)🚀 QUICK START:$(NC)"
	@echo "  $(YELLOW)make firebase-setup$(NC)           - Setup Firebase Test Lab"
	@echo "  $(YELLOW)make firebase-build-all$(NC)       - Build for both platforms"
	@echo "  $(YELLOW)make firebase-test-both$(NC)       - Run tests on both platforms"
	@echo ""
	@echo "$(GREEN)🏗️ BUILD COMMANDS:$(NC)"
	@echo "  $(YELLOW)make firebase-build-ios$(NC)       - Build iOS for Firebase"
	@echo "  $(YELLOW)make firebase-build-android$(NC)   - Build Android for Firebase"
	@echo "  $(YELLOW)make firebase-build-status$(NC)    - Check build status"
	@echo ""
	@echo "$(GREEN)☁️ TESTING COMMANDS:$(NC)"
	@echo "  $(YELLOW)make firebase-test-ios$(NC)        - Run iOS tests on Firebase"
	@echo "  $(YELLOW)make firebase-test-android$(NC)    - Run Android tests on Firebase"
	@echo "  $(YELLOW)make firebase-test-quick$(NC)      - Quick test (build + test)"
	@echo ""
	@echo "$(GREEN)📊 RESULTS & STATUS:$(NC)"
	@echo "  $(YELLOW)make firebase-status$(NC)          - Check Firebase status"
	@echo "  $(YELLOW)make firebase-results$(NC)         - Download latest results"
	@echo "  $(YELLOW)make firebase-results-list$(NC)    - List all results"
	@echo ""
	@echo "$(GREEN)🔧 MANAGEMENT:$(NC)"
	@echo "  $(YELLOW)make firebase-info$(NC)            - Show configuration"
	@echo "  $(YELLOW)make firebase-list-devices$(NC)    - List available devices"
	@echo "  $(YELLOW)make firebase-auth-status$(NC)     - Check authentication"
	@echo "  $(YELLOW)make firebase-clean$(NC)           - Clean all artifacts"
	@echo ""
	@echo "$(GREEN)📋 CONFIGURATION:$(NC)"
	@echo "  Project: $(FIREBASE_PROJECT_ID)"
	@echo "  Bucket: $(FIREBASE_BUCKET)"
	@echo "  iOS Device: $(IOS_DEVICE_MODEL) $(IOS_DEVICE_VERSION)"
	@echo "  Android Device: $(ANDROID_DEVICE_MODEL) API $(ANDROID_DEVICE_VERSION)"
	@echo ""