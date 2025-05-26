#!/bin/bash

# Complete Setup Script for Hotel Booking App
# Configures everything for your specific devices

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}================================================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Check if we're in the right directory
check_project_directory() {
    if [ ! -f "pubspec.yaml" ]; then
        print_error "This doesn't appear to be a Flutter project directory"
        print_info "Please run this script from your hotel_booking project root"
        exit 1
    fi
    
    if ! grep -q "hotel_booking" pubspec.yaml 2>/dev/null; then
        print_warning "This might not be the hotel booking project"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Create directory structure
setup_directories() {
    print_step "Setting up directory structure..."
    
    mkdir -p scripts
    mkdir -p integration_test/config
    mkdir -p allure-results
    mkdir -p test-results
    mkdir -p coverage
    
    print_success "Directories created"
}

# Save device configuration
save_device_config() {
    print_step "Saving device configuration..."
    
    cat > integration_test/config/device_config.yaml << 'EOF'
# Device Configuration for Hotel Booking App Tests
# Configured for your specific available devices

environments:
  local:
    ios_simulators:
      iphone_16_plus:
        name: "iPhone 16 Plus"
        udid: "AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
        version: "18.0"
        runtime: "iOS-18-0"
        device_type: "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Plus"
        status: "booted"
        description: "Primary iOS test device"
    
    android_emulators:
      pixel_7:
        name: "Pixel 7"
        avd_name: "Pixel_7"
        api_level: 36
        target: "android-36"
        abi: "arm64-v8a"
        tag: "google_apis_playstore"
        description: "Android 14.0 (API 36) | arm64-v8a | Google Play"
        ram_size: "2048"
        heap_size: "228"

  firebase_test_lab:
    ios_devices:
      iphone_15_pro:
        model: "iphone15pro"
        model_name: "iPhone 15 Pro"
        version: "18.0"
        locale: "en"
        orientation: "portrait"
        device_capacity: "Medium"
        description: "Firebase Test Lab iOS device"
    
    android_devices:
      pixel_8:
        model: "shiba"
        model_name: "Pixel 8"
        version: "34"
        locale: "en"
        orientation: "portrait"
        device_capacity: "High"
        description: "Firebase Test Lab Android device"

execution:
  default_platform: "local"
  parallel_execution: true
  max_parallel_devices: 2
  device_startup_timeout: 120
  test_timeout: 600
  retry_count: 2
  
  preferred_devices:
    local_ios: "iphone_16_plus"
    local_android: "pixel_7"
    firebase_ios: "iphone_15_pro"
    firebase_android: "pixel_8"
EOF
    
    print_success "Device configuration saved"
}

# Save package.json for Node.js dependencies
save_package_json() {
    print_step "Creating package.json for test dependencies..."
    
    cat > package.json << 'EOF'
{
  "name": "hotel-booking-test-tools",
  "version": "1.0.0",
  "description": "Test utilities for Hotel Booking Flutter app",
  "private": true,
  "scripts": {
    "install-allure": "npm install -g allure-commandline",
    "setup": "npm install",
    "test:allure": "allure generate allure-results -o allure-report --clean",
    "serve:allure": "allure serve allure-results"
  },
  "dependencies": {
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "allure-commandline": "^2.25.0"
  }
}
EOF
    
    print_success "package.json created"
}

# Install Node.js dependencies
install_node_dependencies() {
    print_step "Installing Node.js dependencies..."
    
    if command -v npm >/dev/null 2>&1; then
        npm install
        print_success "Node.js dependencies installed"
        
        # Try to install Allure globally
        if npm install -g allure-commandline 2>/dev/null; then
            print_success "Allure CLI installed globally"
        else
            print_warning "Could not install Allure CLI globally (may need sudo)"
            print_info "You can install it later with: npm install -g allure-commandline"
        fi
    else
        print_warning "npm not found. Please install Node.js to use Allure features"
        print_info "Download from: https://nodejs.org/"
    fi
}

# Save scripts (simplified versions for the setup)
save_scripts() {
    print_step "Creating test scripts..."
    
    # Create a simple test runner script
    cat > scripts/test_runner.sh << 'EOF'
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
EOF
    
    chmod +x scripts/test_runner.sh
    
    # Create device manager script
    cat > scripts/device_manager.sh << 'EOF'
#!/bin/bash
# Device Manager for Your Specific Devices

LOCAL_IOS_UDID="AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
LOCAL_ANDROID_AVD="Pixel_7"

case "${1:-list}" in
    list)
        echo "📱 Your Configured Devices:"
        echo "iOS: iPhone 16 Plus ($LOCAL_IOS_UDID)"
        echo "Android: $LOCAL_ANDROID_AVD"
        echo ""
        echo "Available to Flutter:"
        flutter devices
        ;;
    start-ios)
        echo "📱 Starting iPhone 16 Plus..."
        xcrun simctl boot "$LOCAL_IOS_UDID" 2>/dev/null || echo "Already running"
        ;;
    start-android)
        echo "🤖 Starting Pixel 7..."
        emulator -avd "$LOCAL_ANDROID_AVD" -no-window &
        ;;
    stop)
        echo "🛑 Stopping devices..."
        xcrun simctl shutdown "$LOCAL_IOS_UDID" 2>/dev/null || true
        pkill -f "emulator" 2>/dev/null || true
        ;;
    *)
        echo "Usage: $0 {list|start-ios|start-android|stop}"
        ;;
esac
EOF
    
    chmod +x scripts/device_manager.sh
    
    print_success "Scripts created and made executable"
}

# Update .gitignore
update_gitignore() {
    print_step "Updating .gitignore..."
    
    # Create .gitignore entries for test artifacts
    cat >> .gitignore << 'EOF'

# Test artifacts
allure-results/
allure-report/
test-results/
coverage/
node_modules/
*.log

# Temporary files
.DS_Store
Thumbs.db
EOF
    
    print_success ".gitignore updated"
}

# Verify setup
verify_setup() {
    print_header "VERIFYING SETUP"
    
    local issues=0
    
    # Check Flutter
    if command -v flutter >/dev/null 2>&1; then
        print_success "Flutter is available"
    else
        print_error "Flutter not found"
        issues=$((issues + 1))
    fi
    
    # Check your iOS device
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if xcrun simctl list devices | grep -q "AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"; then
            print_success "iPhone 16 Plus is available"
        else
            print_warning "iPhone 16 Plus not found"
            issues=$((issues + 1))
        fi
    else
        print_info "iOS testing not available on this platform"
    fi
    
    # Check Android setup
    if command -v adb >/dev/null 2>&1; then
        print_success "Android tools are available"
    else
        print_warning "Android tools not found"
        issues=$((issues + 1))
    fi
    
    # Check Node.js (optional)
    if command -v node >/dev/null 2>&1; then
        print_success "Node.js is available"
    else
        print_warning "Node.js not found (Allure features will be limited)"
    fi
    
    echo ""
    if [ $issues -eq 0 ]; then
        print_success "Setup verification passed! ✨"
        return 0
    else
        print_warning "Setup completed with $issues warnings"
        return 1
    fi
}

# Show next steps
show_next_steps() {
    print_header "NEXT STEPS"
    
    echo -e "${BLUE}🎯 Your setup is ready! Here's what you can do:${NC}"
    echo ""
    echo -e "${PURPLE}📋 Basic Commands:${NC}"
    echo "  make test-unit          # Run unit tests with Allure"
    echo "  make test-widget        # Run widget tests with Allure" 
    echo "  make test-integration   # Run integration tests"
    echo "  make test-all           # Run all tests with reports"
    echo ""
    echo -e "${PURPLE}📱 Device Commands:${NC}"
    echo "  make devices-list       # Show your device status"
    echo "  make devices-start-ios  # Start iPhone 16 Plus"
    echo "  make devices-start-android  # Start Pixel 7"
    echo "  make devices-start-all  # Start both devices"
    echo ""
    echo -e "${PURPLE}📊 Report Commands:${NC}"
    echo "  make coverage          # Generate coverage report"
    echo "  make allure           # Generate Allure report"
    echo ""
    echo -e "${PURPLE}🚀 Quick Start:${NC}"
    echo "  make dev-setup        # Complete development setup"
    echo "  make quick-test       # Fast unit + widget tests"
    echo "  make full-test        # All tests with reports"
    echo ""
    echo -e "${BLUE}📖 For more commands, run: make help${NC}"
    echo ""
    echo -e "${GREEN}🎉 Happy testing!${NC}"
}

# Main execution
main() {
    print_header "HOTEL BOOKING APP - COMPLETE SETUP"
    print_info "Configuring for your specific devices:"
    print_info "• iOS: iPhone 16 Plus (AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8)"
    print_info "• Android: Pixel_7 (API 36)"
    print_info "• Firebase: iPhone 15 Pro + Pixel 8"
    echo ""
    
    check_project_directory
    setup_directories
    save_device_config
    save_package_json
    save_scripts
    update_gitignore
    
    # Install dependencies
    print_step "Installing Flutter dependencies..."
    flutter pub get
    print_success "Flutter dependencies installed"
    
    install_node_dependencies
    
    # Run verification
    verify_setup
    
    show_next_steps
}

main "$@"