#!/bin/bash

# Enhanced Device Setup and Management Script
# Handles creation and management of iOS simulators and Android emulators

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================================================${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running on macOS (required for iOS simulators)
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "iOS simulators only available on macOS"
        return 1
    fi
    return 0
}

# Find Android SDK path
find_android_sdk() {
    local sdk_paths=(
        "$ANDROID_HOME"
        "$ANDROID_SDK_ROOT"
        "$HOME/Library/Android/sdk"
        "$HOME/Android/Sdk"
        "/usr/local/android-sdk"
        "/opt/android-sdk"
    )
    
    for path in "${sdk_paths[@]}"; do
        if [ -n "$path" ] && [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Setup Android environment
setup_android_environment() {
    print_status "Setting up Android environment..."
    
    # Try to find Android SDK
    ANDROID_SDK=$(find_android_sdk)
    
    if [ -z "$ANDROID_SDK" ]; then
        print_error "Android SDK not found!"
        echo ""
        echo "Please install Android Studio or set up Android SDK:"
        echo "1. Download Android Studio from: https://developer.android.com/studio"
        echo "2. Or set ANDROID_HOME environment variable to your SDK path"
        echo ""
        echo "Common SDK locations:"
        echo "  macOS: ~/Library/Android/sdk"
        echo "  Linux: ~/Android/Sdk"
        echo "  Windows: %LOCALAPPDATA%\\Android\\Sdk"
        echo ""
        return 1
    fi
    
    print_success "Android SDK found at: $ANDROID_SDK"
    
    # Add SDK tools to PATH if not already there
    export ANDROID_HOME="$ANDROID_SDK"
    export ANDROID_SDK_ROOT="$ANDROID_SDK"
    export PATH="$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools:$ANDROID_SDK/emulator:$PATH"
    
    # Check if tools are available
    if ! command -v avdmanager &> /dev/null; then
        print_error "avdmanager not found in SDK tools"
        print_status "Checking for cmdline-tools..."
        
        local cmdline_tools="$ANDROID_SDK/cmdline-tools/latest/bin"
        if [ -d "$cmdline_tools" ]; then
            export PATH="$cmdline_tools:$PATH"
            print_success "Added cmdline-tools to PATH"
        else
            print_error "cmdline-tools not found. Please install via Android Studio SDK Manager:"
            echo "SDK Manager > SDK Tools > Android SDK Command-line Tools"
            return 1
        fi
    fi
    
    if ! command -v emulator &> /dev/null; then
        print_error "emulator command not found"
        return 1
    fi
    
    print_success "Android tools are available"
    return 0
}

# Accept Android licenses
accept_android_licenses() {
    print_status "Accepting Android licenses..."
    
    if command -v sdkmanager &> /dev/null; then
        yes | sdkmanager --licenses > /dev/null 2>&1 || true
        print_success "Android licenses accepted"
    else
        print_warning "sdkmanager not found, skipping license acceptance"
    fi
}

# Setup iOS Simulators
setup_ios_simulators() {
    if ! check_macos; then
        return 0
    fi
    
    print_header "SETTING UP iOS SIMULATORS"
    
    # Check available iOS runtimes
    print_status "Checking available iOS runtimes..."
    if command -v xcrun &> /dev/null; then
        xcrun simctl list runtimes ios --json | jq -r '.runtimes[] | select(.isAvailable == true) | "  ✓ \(.name) - \(.identifier)"' 2>/dev/null || {
            xcrun simctl list runtimes ios | grep "iOS" || print_warning "No iOS runtimes found"
        }
    else
        print_error "Xcode command line tools not found"
        return 1
    fi
    
    # Setup specific devices
    setup_ios_device "iPhone 15 Pro" "com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro" "iOS-17-0"
    setup_ios_device "iPhone 15" "com.apple.CoreSimulator.SimDeviceType.iPhone-15" "iOS-17-0"
    setup_ios_device "iPad Air (5th generation)" "com.apple.CoreSimulator.SimDeviceType.iPad-Air--5th-generation-" "iOS-17-0"
    
    print_success "iOS simulators setup completed"
}

setup_ios_device() {
    local device_name="$1"
    local device_type="$2"
    local runtime="$3"
    
    print_status "Setting up $device_name..."
    
    # Check if device already exists
    local existing_device=$(xcrun simctl list devices --json 2>/dev/null | jq -r ".devices[\"com.apple.CoreSimulator.SimRuntime.$runtime\"][]? | select(.name == \"$device_name\") | .udid" 2>/dev/null || echo "")
    
    if [ -n "$existing_device" ]; then
        print_success "$device_name already exists (UDID: $existing_device)"
        
        # Boot the device if not already booted
        local device_state=$(xcrun simctl list devices --json 2>/dev/null | jq -r ".devices[\"com.apple.CoreSimulator.SimRuntime.$runtime\"][]? | select(.udid == \"$existing_device\") | .state" 2>/dev/null || echo "Unknown")
        if [ "$device_state" != "Booted" ]; then
            print_status "Booting $device_name..."
            xcrun simctl boot "$existing_device" 2>/dev/null || print_warning "Failed to boot $device_name"
        fi
    else
        # Try to create the device with available runtime
        local available_runtime=$(xcrun simctl list runtimes --json 2>/dev/null | jq -r ".runtimes[] | select(.isAvailable == true and (.identifier | contains(\"iOS\"))) | .identifier" 2>/dev/null | head -1 || echo "")
        
        if [ -n "$available_runtime" ]; then
            print_status "Creating $device_name with $available_runtime..."
            local new_udid=$(xcrun simctl create "$device_name" "$device_type" "$available_runtime" 2>/dev/null || echo "")
            
            if [ -n "$new_udid" ]; then
                print_success "$device_name created (UDID: $new_udid)"
                
                # Boot the new device
                print_status "Booting $device_name..."
                xcrun simctl boot "$new_udid" 2>/dev/null || print_warning "Failed to boot $device_name"
            else
                print_warning "Failed to create $device_name"
            fi
        else
            print_warning "No available iOS runtime found for $device_name"
        fi
    fi
}

# Setup Android Emulators
setup_android_emulators() {
    print_header "SETTING UP ANDROID EMULATORS"
    
    if ! setup_android_environment; then
        return 1
    fi
    
    accept_android_licenses
    
    # Setup modern Android emulators
    setup_android_emulator "Pixel_7_API_34" "android-34" "google_apis" "x86_64" "pixel_7"
    setup_android_emulator "Pixel_6_API_33" "android-33" "google_apis" "x86_64" "pixel_6"
    
    print_success "Android emulators setup completed"
}

setup_android_emulator() {
    local avd_name="$1"
    local target="$2"
    local tag="$3"
    local abi="$4"
    local device_profile="$5"
    
    print_status "Setting up Android emulator: $avd_name..."
    
    # Check if AVD already exists
    if avdmanager list avd 2>/dev/null | grep -q "Name: $avd_name"; then
        print_success "Android emulator $avd_name already exists"
        return 0
    fi
    
    # Check if system image is installed
    local image_path="system-images;$target;$tag;$abi"
    if ! sdkmanager --list_installed 2>/dev/null | grep -q "$image_path"; then
        print_status "Installing system image for $target..."
        if ! sdkmanager "$image_path" 2>/dev/null; then
            print_error "Failed to install system image: $image_path"
            return 1
        fi
    fi
    
    # Create AVD
    print_status "Creating AVD: $avd_name..."
    if echo "no" | avdmanager create avd \
        -n "$avd_name" \
        -k "$image_path" \
        -d "$device_profile" 2>/dev/null; then
        
        print_success "Android emulator $avd_name created successfully"
        
        # Configure AVD for better performance
        configure_android_emulator "$avd_name"
    else
        print_error "Failed to create AVD: $avd_name"
        return 1
    fi
}

# Configure Android emulator for better performance
configure_android_emulator() {
    local avd_name="$1"
    local avd_path="$HOME/.android/avd/${avd_name}.avd"
    
    if [ -d "$avd_path" ]; then
        print_status "Configuring $avd_name for better performance..."
        
        # Add performance configurations
        cat >> "$avd_path/config.ini" << EOF

# Performance optimizations
hw.gpu.enabled=yes
hw.gpu.mode=host
hw.ramSize=2048
vm.heapSize=512
hw.keyboard=yes
hw.dPad=no
hw.trackBall=no
skin.dynamic=yes
hw.camera.back=webcam0
hw.camera.front=webcam0
hw.accelerometer=yes
hw.sensors.proximity=yes
hw.sensors.magnetic_field=yes
hw.sensors.orientation=yes
hw.sensors.temperature=yes
showDeviceFrame=no
EOF
        
        print_success "$avd_name configured for better performance"
    fi
}

# List all available devices
list_devices() {
    print_header "AVAILABLE DEVICES"
    
    if check_macos; then
        print_status "iOS Simulators:"
        if command -v xcrun &> /dev/null; then
            xcrun simctl list devices --json 2>/dev/null | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.isAvailable == true) | "  \(.name) - \(.udid) - \(.state)"' 2>/dev/null || {
                xcrun simctl list devices | grep iPhone || print_warning "No iOS devices found"
            }
        else
            print_warning "Xcode command line tools not available"
        fi
        echo ""
    fi
    
    if setup_android_environment &>/dev/null; then
        print_status "Android Emulators:"
        if avdmanager list avd 2>/dev/null | grep "Name:" | sed 's/Name: /  /' | head -10; then
            echo ""
        else
            print_warning "No Android emulators found"
            echo ""
        fi
    fi
    
    print_status "Currently Running Devices:"
    if flutter devices --machine 2>/dev/null | jq -r '.[] | "  \(.name) (\(.id)) - \(.platform)"' 2>/dev/null; then
        echo ""
    else
        flutter devices 2>/dev/null || print_warning "Flutter not available"
    fi
}

# Start specific device
start_device() {
    local device_name="$1"
    
    if [ -z "$device_name" ]; then
        print_error "Device name required"
        echo "Usage: $0 start <device_name>"
        return 1
    fi
    
    print_status "Starting device: $device_name"
    
    # Try iOS simulator first
    if check_macos; then
        local ios_udid=$(xcrun simctl list devices --json 2>/dev/null | jq -r ".devices | to_entries[] | .value[] | select(.name == \"$device_name\") | .udid" 2>/dev/null | head -1)
        if [ -n "$ios_udid" ]; then
            print_status "Starting iOS simulator: $device_name"
            if xcrun simctl boot "$ios_udid" 2>/dev/null; then
                print_success "iOS simulator $device_name started"
                return 0
            else
                print_warning "Failed to start iOS simulator $device_name"
            fi
        fi
    fi
    
    # Try Android emulator
    if setup_android_environment &>/dev/null; then
        if avdmanager list avd 2>/dev/null | grep -q "Name: $device_name"; then
            print_status "Starting Android emulator: $device_name"
            emulator -avd "$device_name" -no-snapshot -wipe-data -no-window &
            local emulator_pid=$!
            
            print_status "Waiting for emulator to start..."
            local timeout=120
            local elapsed=0
            
            while [ $elapsed -lt $timeout ]; do
                if adb devices 2>/dev/null | grep -q "emulator.*device"; then
                    print_success "Android emulator $device_name started"
                    return 0
                fi
                sleep 5
                elapsed=$((elapsed + 5))
                printf "."
            done
            
            echo ""
            print_warning "Emulator may still be starting (PID: $emulator_pid)"
            return 0
        fi
    fi
    
    print_error "Device not found: $device_name"
    return 1
}

# Stop all running devices
stop_all_devices() {
    print_status "Stopping all running devices..."
    
    # Stop iOS simulators
    if check_macos; then
        xcrun simctl shutdown all 2>/dev/null || true
        print_success "All iOS simulators stopped"
    fi
    
    # Stop Android emulators
    if command -v adb &> /dev/null; then
        adb devices 2>/dev/null | grep emulator | cut -f1 | while read -r line; do
            adb -s "$line" emu kill 2>/dev/null || true
        done
        print_success "All Android emulators stopped"
    fi
    
    # Kill any remaining emulator processes
    pkill -f "emulator" 2>/dev/null || true
}

# Clean up devices
cleanup_devices() {
    print_status "Cleaning up devices..."
    
    # Erase iOS simulators
    if check_macos; then
        print_status "Erasing iOS simulators..."
        xcrun simctl list devices --json 2>/dev/null | jq -r '.devices | to_entries[] | .value[] | select(.name | contains("iPhone") or contains("iPad")) | .udid' 2>/dev/null | while read -r udid; do
            xcrun simctl erase "$udid" 2>/dev/null || true
        done
        print_success "iOS simulators cleaned"
    fi
    
    # Clean Android emulators (wipe data)
    print_status "Android emulators will be wiped on next start"
}

# Check system requirements
check_system_requirements() {
    print_header "SYSTEM REQUIREMENTS CHECK"
    
    local issues=0
    
    # Check Flutter
    if command -v flutter &> /dev/null; then
        local flutter_version=$(flutter --version | head -1)
        print_success "Flutter: $flutter_version"
    else
        print_error "Flutter not found"
        issues=$((issues + 1))
    fi
    
    # Check Dart
    if command -v dart &> /dev/null; then
        local dart_version=$(dart --version 2>&1)
        print_success "Dart: $dart_version"
    else
        print_warning "Dart not found (should be included with Flutter)"
    fi
    
    # Check Xcode (macOS only)
    if check_macos; then
        if command -v xcodebuild &> /dev/null; then
            local xcode_version=$(xcodebuild -version | head -1)
            print_success "Xcode: $xcode_version"
        else
            print_error "Xcode not found (required for iOS development)"
            issues=$((issues + 1))
        fi
        
        if command -v xcrun &> /dev/null; then
            print_success "Xcode command line tools available"
        else
            print_error "Xcode command line tools not found"
            echo "Install with: xcode-select --install"
            issues=$((issues + 1))
        fi
    fi
    
    # Check Android SDK
    if setup_android_environment &>/dev/null; then
        print_success "Android SDK found"
        
        if command -v avdmanager &> /dev/null; then
            print_success "Android AVD Manager available"
        else
            print_error "Android AVD Manager not found"
            issues=$((issues + 1))
        fi
        
        if command -v emulator &> /dev/null; then
            print_success "Android Emulator available"
        else
            print_error "Android Emulator not found"
            issues=$((issues + 1))
        fi
    else
        print_error "Android SDK not found"
        issues=$((issues + 1))
    fi
    
    # Check additional tools
    if command -v jq &> /dev/null; then
        print_success "jq (JSON processor) available"
    else
        print_warning "jq not found (install for better JSON parsing)"
    fi
    
    echo ""
    if [ $issues -eq 0 ]; then
        print_success "All system requirements met!"
        return 0
    else
        print_error "$issues issue(s) found. Please resolve them before proceeding."
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
Enhanced Device Setup and Management Script

Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    setup           Create and configure all test devices (default)
    list            List all available devices
    start <name>    Start specific device
    stop            Stop all running devices
    clean           Clean/reset all devices
    check           Check system requirements
    help            Show this help message

EXAMPLES:
    $0                              # Setup all devices
    $0 list                         # List available devices
    $0 start "iPhone 15 Pro"        # Start specific iOS simulator
    $0 start "Pixel_7_API_34"       # Start specific Android emulator
    $0 stop                         # Stop all running devices
    $0 clean                        # Clean all devices
    $0 check                        # Check system requirements

REQUIREMENTS:
    - Flutter SDK
    - For iOS: Xcode and command line tools (macOS only)
    - For Android: Android Studio or Android SDK with cmdline-tools

SETUP NOTES:
    - iOS simulators are only available on macOS
    - Android emulators require hardware acceleration (Intel HAXM/AMD)
    - First-time setup may take several minutes to download system images

TROUBLESHOOTING:
    If you encounter issues:
    1. Run '$0 check' to verify system requirements
    2. Ensure Android SDK path is set correctly
    3. Accept Android licenses via Android Studio
    4. Enable hardware acceleration for Android emulators

EOF
}

# Main script logic
main() {
    case "${1:-setup}" in
        setup)
            print_header "DEVICE SETUP"
            check_system_requirements
            echo ""
            setup_ios_simulators
            echo ""
            setup_android_emulators
            echo ""
            print_success "Device setup complete!"
            echo ""
            list_devices
            ;;
        list)
            list_devices
            ;;
        start)
            start_device "$2"
            ;;
        stop)
            stop_all_devices
            ;;
        clean)
            cleanup_devices
            ;;
        check)
            check_system_requirements
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"