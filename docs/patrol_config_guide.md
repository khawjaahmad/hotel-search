# 🎯 Patrol Configuration Guide

Comprehensive guide for configuring Patrol framework in the Hotel Booking QA Automation project.

## 📄 patrol.yaml Configuration

The `patrol.yaml` file is the main configuration file for Patrol testing framework:

```yaml
# patrol.yaml - Patrol Configuration for Hotel Booking App
patrol:
  app_name: Hotel Booking
  
  android:
    package_name: com.example.hotel_booking
    
  ios:
    bundle_id: com.ahmadwaqar.hotelBooking

# Test configuration
test:
  timeout: 600  # 10 minutes timeout for tests
  retry_count: 2
  
  # Environment variables passed to tests
  environment:
    PATROL_WAIT: "5000"
    ALLURE_RESULTS_DIRECTORY: "allure-results"
    INTEGRATION_TEST_SCREENSHOTS: "screenshots"
    
  # Test execution settings
  execution:
    parallel_enabled: true
    max_parallel_tests: 4
    screenshot_on_failure: true
    video_recording: false

# Device configurations
devices:
  local:
    ios:
      - name: "iPhone 16 Plus"
        udid: "AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
        version: "18.4"
        preferred: true
        
    android:
      - name: "Pixel_7"
        avd_name: "Pixel_7"
        api_level: 34
        preferred: true
        
  firebase:
    project_id: "your-firebase-project-id"
    
    ios:
      - model: "iphone15pro"
        version: "18.0"
        locale: "en"
        orientation: "portrait"
        
    android:
      - model: "shiba"  # Pixel 8
        version: "34"
        locale: "en"
        orientation: "portrait"

# Reporting configuration
reporting:
  allure:
    enabled: true
    results_directory: "allure-results"
    report_directory: "allure-report"
    
  screenshots:
    enabled: true
    directory: "screenshots"
    on_failure: true
    on_success: false
    
  logs:
    enabled: true
    directory: "test-results/logs"
    level: "info"

# Integration test files
tests:
  - "integration_test/tests/hotels_test.dart"
  - "integration_test/tests/overview_test.dart"
  - "integration_test/tests/account_test.dart"
  - "integration_test/tests/dashboard_test.dart"
```

## 🔧 Configuration Sections Explained

### 1. Basic App Configuration

```yaml
patrol:
  app_name: Hotel Booking           # Human-readable app name
  
  android:
    package_name: com.example.hotel_booking  # Android package identifier
    
  ios:
    bundle_id: com.ahmadwaqar.hotelBooking   # iOS bundle identifier
```

**Purpose**: Identifies the application for Patrol to interact with during testing.

### 2. Test Configuration

```yaml
test:
  timeout: 600                      # Global test timeout (seconds)
  retry_count: 2                    # Number of retry attempts for flaky tests
  
  environment:                      # Environment variables for tests
    PATROL_WAIT: "5000"            # Default wait time (milliseconds)
    ALLURE_RESULTS_DIRECTORY: "allure-results"
    INTEGRATION_TEST_SCREENSHOTS: "screenshots"
    
  execution:
    parallel_enabled: true          # Enable parallel test execution
    max_parallel_tests: 4          # Maximum concurrent tests
    screenshot_on_failure: true    # Take screenshots on test failures
    video_recording: false         # Disable video recording for performance
```

### 3. Device Configuration

#### Local Devices
```yaml
devices:
  local:
    ios:
      - name: "iPhone 16 Plus"                    # Simulator name
        udid: "AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"  # Unique device identifier
        version: "18.4"                          # iOS version
        preferred: true                          # Primary device for iOS tests
        
    android:
      - name: "Pixel_7"                          # Emulator name
        avd_name: "Pixel_7"                      # Android Virtual Device name
        api_level: 34                            # Android API level
        preferred: true                          # Primary device for Android tests
```

#### Firebase Test Lab Devices
```yaml
  firebase:
    project_id: "your-firebase-project-id"      # Firebase project ID
    
    ios:
      - model: "iphone15pro"                     # Firebase device model
        version: "18.0"                          # iOS version
        locale: "en"                             # Device locale
        orientation: "portrait"                  # Screen orientation
        
    android:
      - model: "shiba"                           # Firebase device model (Pixel 8)
        version: "34"                            # Android API level
        locale: "en"                             # Device locale
        orientation: "portrait"                  # Screen orientation
```

### 4. Reporting Configuration

```yaml
reporting:
  allure:
    enabled: true                               # Enable Allure reporting
    results_directory: "allure-results"         # Raw results directory
    report_directory: "allure-report"           # Generated report directory
    
  screenshots:
    enabled: true                               # Enable screenshot capture
    directory: "screenshots"                    # Screenshot storage directory
    on_failure: true                           # Take screenshots on failures
    on_success: false                          # Skip screenshots on success
    
  logs:
    enabled: true                               # Enable test logging
    directory: "test-results/logs"              # Log storage directory
    level: "info"                              # Logging level (debug, info, warn, error)
```

## 🎮 Command Line Usage

### Basic Commands

```bash
# Run all tests with default configuration
patrol test

# Run specific test file
patrol test integration_test/tests/hotels_test.dart

# Run with specific device
patrol test --device "iPhone 16 Plus"
patrol test --device "Pixel_7"

# Run with custom configuration
patrol test --config patrol.yaml

# Run with verbose output
patrol test --verbose

# Run with coverage
patrol test --coverage
```

### Advanced Commands

```bash
# Run tests in parallel
patrol test --parallel

# Run with custom timeout
patrol test --timeout 900

# Run specific test by name pattern
patrol test --name "Hotels search functionality"

# Run with tags
patrol test --tag demo

# Run with screenshots enabled
patrol test --screenshots

# Debug mode
patrol test --debug
```

### Firebase Test Lab Integration

```bash
# Build for Firebase Android
patrol build android --target integration_test/tests/dashboard_test.dart

# Build for Firebase iOS
patrol build ios --target integration_test/tests/dashboard_test.dart

# Run on Firebase (using scripts)
./scripts/firebase_android.sh
./scripts/firebase_ios.sh
```

## 🔧 PatrolTesterConfig

Advanced configuration can be done programmatically in test files:

```dart
// integration_test/config/patrol_config.dart
import 'package:patrol/patrol.dart';

class PatrolConfig {
  static PatrolTesterConfig getConfig() {
    return PatrolTesterConfig(
      settleTimeout: const Duration(seconds: 10),    // Widget settle timeout
      existsTimeout: const Duration(seconds: 10),    // Element existence timeout
      visibleTimeout: const Duration(seconds: 10),   // Element visibility timeout
    );
  }
  
  static PatrolTesterConfig getDebugConfig() {
    return PatrolTesterConfig(
      settleTimeout: const Duration(seconds: 30),    // Longer timeouts for debugging
      existsTimeout: const Duration(seconds: 30),
      visibleTimeout: const Duration(seconds: 30),
    );
  }
  
  static PatrolTesterConfig getFastConfig() {
    return PatrolTesterConfig(
      settleTimeout: const Duration(seconds: 5),     // Shorter timeouts for fast tests
      existsTimeout: const Duration(seconds: 5),
      visibleTimeout: const Duration(seconds: 5),
    );
  }
}
```

Usage in tests:
```dart
patrolTest(
  'Hotels page navigation test',
  config: PatrolConfig.getConfig(),  // Use custom configuration
  ($) async {
    // Test implementation
  },
);
```

## 📱 Device Management

### Getting Device Information

```bash
# List available devices
patrol devices

# List iOS simulators
xcrun simctl list devices

# List Android emulators
avdmanager list avd

# Check connected devices
adb devices  # Android
```

### Device Setup Commands

#### iOS Simulator Management
```bash
# Create new simulator
xcrun simctl create "iPhone 16 Plus" "iPhone 16 Plus" "iOS 18.4"

# Boot simulator
xcrun simctl boot "iPhone 16 Plus"

# Shutdown simulator
xcrun simctl shutdown "iPhone 16 Plus"

# Delete simulator
xcrun simctl delete "iPhone 16 Plus"

# Get simulator UDID
xcrun simctl list devices | grep "iPhone 16 Plus"
```

#### Android Emulator Management
```bash
# Create new AVD
avdmanager create avd -n Pixel_7 -k "system-images;android-34;google_apis;x86_64"

# Start emulator
emulator -avd Pixel_7

# Start emulator in headless mode
emulator -avd Pixel_7 -no-window

# List available system images
sdkmanager --list | grep system-images
```

## 🎯 Test Organization

### Test File Structure
```
integration_test/
├── tests/                          # Main test files
│   ├── dashboard_test.dart         # Dashboard functionality tests
│   ├── hotels_test.dart           # Hotel search and booking tests
│   ├── overview_test.dart         # Overview page tests
│   └── account_test.dart          # Account management tests
├── screens/                        # Screen action objects
│   ├── dashboard_screen_actions.dart
│   ├── hotels_screen_actions.dart
│   ├── overview_screen_actions.dart
│   └── account_screen_actions.dart
├── locators/                       # Element locators
│   └── app_locators.dart
├── helpers/                        # Test utilities
│   ├── test_helpers.dart
│   ├── test_logger.dart
│   └── test_data_factory.dart
└── config/                         # Configuration files
    └── patrol_config.dart
```

### Test Naming Conventions

```dart
// Test file naming: feature_test.dart
// Test group naming: Feature functionality
// Test case naming: descriptive action or verification

patrolTest(
  'Hotels search functionality test',    // Clear, descriptive name
  config: PatrolConfig.getConfig(),
  ($) async {
    TestLogger.logTestStart($, 'Hotels Search Test');
    await TestHelpers.initializeApp($);
    await HotelsScreenActions.performSearchTest($, 'Dubai');
    TestLogger.logTestSuccess($, 'Search functionality verified');
  },
);
```

## 🔍 Debugging Configuration

### Debug Mode Settings
```yaml
# patrol.yaml - Debug configuration
test:
  timeout: 1800                     # Longer timeout for debugging (30 minutes)
  retry_count: 0                    # Disable retries during debugging
  
  execution:
    parallel_enabled: false         # Disable parallel execution
    screenshot_on_failure: true     # Always take screenshots
    video_recording: true           # Enable video recording for debugging
    
reporting:
  logs:
    level: "debug"                  # Verbose logging
```

### Debug Commands
```bash
# Run in debug mode with verbose output
patrol test --debug --verbose

# Run single test with extended timeout
patrol test integration_test/tests/hotels_test.dart --timeout 1800

# Run with video recording
patrol test --video
```

## ⚡ Performance Optimization

### Optimized Configuration for CI/CD
```yaml
# patrol.yaml - CI/CD optimized configuration
test:
  timeout: 600                      # Standard timeout
  retry_count: 2                    # Retry flaky tests
  
  execution:
    parallel_enabled: true          # Enable parallel execution
    max_parallel_tests: 6          # Higher parallelism for CI
    screenshot_on_failure: true     # Screenshots for debugging failures
    video_recording: false          # Disable video for performance
    
reporting:
  logs:
    level: "warn"                   # Reduce log noise
```

### Resource Management
```bash
# Set memory limits for tests
export PATROL_MAX_MEMORY=4G

# Set parallel execution limits
export PATROL_MAX_PARALLEL=4

# Enable build caching
export PATROL_CACHE_ENABLED=true
```

## 🔐 Security Configuration

### Environment Variables
```yaml
# patrol.yaml - Security considerations
test:
  environment:
    PATROL_SECURE_MODE: "true"      # Enable secure mode
    PATROL_LOG_SENSITIVE: "false"   # Disable sensitive data logging
    PATROL_SCREENSHOT_SAFE: "true"  # Safe screenshot mode
```

### Secrets Management
```bash
# Set API keys securely
export SERPAPI_API_KEY="your-secret-key"

# Use encrypted environment files
patrol test --env-file .env.encrypted
```

## 🚨 Error Handling

### Common Configuration Errors

#### 1. Invalid Device Configuration
```bash
# Error: Device not found
# Solution: Verify device UDID and availability
xcrun simctl list devices  # iOS
adb devices               # Android
```

#### 2. Timeout Issues
```yaml
# Increase timeouts for slow tests
test:
  timeout: 1200            # 20 minutes
  
  execution:
    screenshot_on_failure: true  # Help debug timeout issues
```

#### 3. Package Name Mismatch
```yaml
# Ensure package names match your app
android:
  package_name: com.example.hotel_booking  # Must match AndroidManifest.xml

ios:
  bundle_id: com.ahmadwaqar.hotelBooking   # Must match Info.plist
```

## 📊 Configuration Validation

### Validation Script
```bash
#!/bin/bash
# scripts/validate_patrol_config.sh

echo "🔍 Validating Patrol configuration..."

# Check patrol.yaml syntax
if ! patrol config validate; then
    echo "❌ Invalid patrol.yaml configuration"
    exit 1
fi

# Check device availability
if ! patrol devices | grep -q "Available"; then
    echo "❌ No available devices found"
    exit 1
fi

# Check app package/bundle ID
if ! grep -q "com.example.hotel_booking" patrol.yaml; then
    echo "⚠️  Warning: Package name may not match"
fi

echo "✅ Patrol configuration is valid"
```

### Test Configuration
```dart
// Test configuration validation
void main() {
  group('Patrol Configuration Tests', () {
    test('should have valid timeout settings', () {
      final config = PatrolConfig.getConfig();
      expect(config.settleTimeout.inSeconds, greaterThan(5));
      expect(config.settleTimeout.inSeconds, lessThan(30));
    });
    
    test('should have proper device configuration', () {
      // Validate device setup
      expect(PatrolTesterConfig(), isNotNull);
    });
  });
}
```

## 🔄 Configuration Updates

### Version Migration
```bash
# Update Patrol CLI
dart pub global activate patrol_cli

# Update project dependencies
flutter pub upgrade patrol

# Migrate configuration if needed
patrol migrate config
```

### Configuration Backup
```bash
# Backup current configuration
cp patrol.yaml patrol.yaml.backup

# Version control configuration
git add patrol.yaml
git commit -m "Update Patrol configuration"
```

## 📚 Best Practices

### 1. Configuration Management
- ✅ Keep `patrol.yaml` in version control
- ✅ Use environment-specific configurations
- ✅ Document configuration changes
- ✅ Validate configuration before commits

### 2. Device Management
- ✅ Use consistent device names across team
- ✅ Specify exact iOS/Android versions
- ✅ Maintain device configurations in CI/CD
- ✅ Regular device/emulator cleanup

### 3. Performance Optimization
- ✅ Adjust timeouts based on test complexity
- ✅ Use parallel execution for CI/CD
- ✅ Disable video recording for performance
- ✅ Optimize screenshot settings

### 4. Security
- ✅ Never commit API keys in configuration
- ✅ Use environment variables for secrets
- ✅ Enable secure mode for sensitive tests
- ✅ Regular security configuration reviews

## 🆘 Troubleshooting

### Configuration Issues
1. **Invalid YAML syntax**: Use YAML validator
2. **Device not found**: Check device UDID and availability
3. **Package name mismatch**: Verify against app manifest
4. **Timeout issues**: Adjust timeout values
5. **Permission errors**: Check file/directory permissions

### Debug Steps
```bash
# Validate configuration
patrol config validate

# Check device connectivity
patrol devices

# Test with verbose output
patrol test --verbose --debug

# Check logs
cat test-results/logs/patrol.log
```

---

**Configuration Complete! 🎯**  
Your Patrol framework is now properly configured for comprehensive mobile testing.