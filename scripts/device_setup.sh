#!/bin/bash

# Device Setup and Management Script
# Handles creation and management of iOS simulators and Android emulators

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Setup iOS Simulators
setup_ios_simulators() {
    if ! check_macos; then
        return 0
    fi
    
    print_status "Setting up iOS simulators..."
    
    # Check available iOS runtimes
    print_status "Checking available iOS runtimes..."
    xcrun simctl list runtimes ios --json | jq -r '.runtimes[] | select(.isAvailable == true) | "\(.name) - \(.identifier)"'
    
    # Create iPhone 16 (iOS 18.0)
    setup_ios_device "iPhone 16" "com.apple.CoreSimulator.SimDeviceType.iPhone-16" "iOS-18-0"
    
    # Create iPhone 15 (iOS 17.0) 
    setup_ios_device "iPhone 15" "com.apple.CoreSimulator.SimDeviceType.iPhone-15" "iOS-17-0"
}

setup_ios_device() {
    local device_name="$1"
    local device_type="$2"
    local runtime="$3"
    
    print_status "Setting up $device_name..."
    
    # Check if device already exists
    local existing_device=$(xcrun simctl list devices --json | jq -r ".devices[\"com.apple.CoreSimulator.SimRuntime.$runtime\"][]? | select(.name == \"$device_name\") | .udid")
    
    if [ -n "$existing_device" ]; then
        print_success "$device_name already exists (UDID: $existing_device)"
        
        # Boot the device if not already booted
        local device_state=$(xcrun simctl list devices --json | jq -r ".devices[\"com.apple.CoreSimulator.SimRuntime.$runtime\"][]? | select(.udid == \"$existing_device\") | .state")
        if [ "$device_state" != "Booted" ]; then
            print_status "Booting $device_name..."
            xcrun simctl boot "$existing_device"
            print_success "$device_name booted successfully"
        fi
    else
        # Check if runtime is available
        local runtime_available=$(xcrun simctl list runtimes --json | jq -r ".runtimes[] | select(.identifier == \"com.apple.CoreSimulator.SimRuntime.$runtime\") | .isAvailable")
        
        if [ "$runtime_available" = "true" ]; then
            print_status "Creating $device_name with $runtime..."
            local new_udid=$(xcrun simctl create "$device_name" "$device_type" "com.apple.CoreSimulator.SimRuntime.$runtime")
            print_success "$device_name created (UDID: $new_udid)"
            
            # Boot the new device
            print_status "Booting $device_name..."
            xcrun simctl boot "$new_udid"
            print_success "$device_name booted successfully"
        else
            print_error "Runtime $runtime not available for $device_name"
            print_status "Available runtimes:"
            xcrun simctl list runtimes ios --json | jq -r '.runtimes[] | select(.isAvailable == true) | .name'
        fi
    fi
}

# Setup Android Emulators
setup_android_emulators() {
    print_status "Setting up Android emulators..."
    
    # Check if Android SDK is available
    if ! command -v avdmanager &> /dev/null; then
        print_error "Android SDK not found. Please install Android Studio and SDK tools."
        return 1
    fi
    
    # Setup Android 7 (API 24)
    setup_android_emulator "Android_7_API_24" "android-24" "google_apis" "x86_64"
    
    # Setup Android 8 (API 26)  
    setup_android_emulator "Android_8_API_26" "android-26" "google_apis" "x86_64"
}

setup_android_emulator() {
    local avd_name="$1"
    local target="$2"
    local tag="$3"
    local abi="$4"
    
    print_status "Setting up Android emulator: $avd_name..."
    
    # Check if AVD already exists
    if avdmanager list avd | grep -q "Name: $avd_name"; then
        print_success "Android emulator $avd_name already exists"
    else
        # Check if system image is installed
        local image_installed=$(sdkmanager --list_installed | grep "system-images;$target;$tag;$abi" || echo "")
        
        if [ -z "$image_installed" ]; then
            print_status "Installing system image for $target..."
            sdkmanager "system-images;$target;$tag;$abi"
        fi
        
        # Create AVD
        print_status "Creating AVD: $avd_name..."
        echo "no" | avdmanager create avd \
            -n "$avd_name" \
            -k "system-images;$target;$tag;$abi" \
            -d "pixel_3a"
        
        print_success "Android emulator $avd_name created successfully"
    fi
}

# List all available devices
list_devices() {
    print_status "Available devices:"
    echo ""
    
    if check_macos; then
        print_status "iOS Simulators:"
        xcrun simctl list devices --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.isAvailable == true) | "  \(.name) - \(.udid) - \(.state)"'
        echo ""
    fi
    
    if command -v avdmanager &> /dev/null; then
        print_status "Android Emulators:"
        avdmanager list avd | grep "Name:" | sed 's/Name: /  /'
        echo ""
    fi
    
    print_status "Running devices:"
    if command -v adb &> /dev/null; then
        adb devices -l
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
    
    # Try iOS simulator first
    if check_macos; then
        local ios_udid=$(xcrun simctl list devices --json | jq -r ".devices | to_entries[] | .value[] | select(.name == \"$device_name\") | .udid")
        if [ -n "$ios_udid" ]; then
            print_status "Starting iOS simulator: $device_name"
            xcrun simctl boot "$ios_udid"
            print_success "iOS simulator $device_name started"
            return 0
        fi
    fi
    
    # Try Android emulator
    if avdmanager list avd | grep -q "Name: $device_name"; then
        print_status "Starting Android emulator: $device_name"
        emulator -avd "$device_name" -no-snapshot -wipe-data &
        print_success "Android emulator $device_name starting..."
        return 0
    fi
    
    print_error "Device not found: $device_name"
    return 1
}

# Stop all running devices
stop_all_devices() {
    print_status "Stopping all running devices..."
    
    # Stop iOS simulators
    if check_macos; then
        xcrun simctl shutdown all
        print_success "All iOS simulators stopped"
    fi
    
    # Stop Android emulators
    if command -v adb &> /dev/null; then
        adb devices | grep emulator | cut -f1 | while read -r line; do
            adb -s "$line" emu kill
        done
        print_success "All Android emulators stopped"
    fi
}

# Clean up devices
cleanup_devices() {
    print_status "Cleaning up devices..."
    
    # Erase iOS simulators
    if check_macos; then
        print_status "Erasing iOS simulators..."
        xcrun simctl list devices --json | jq -r '.devices | to_entries[] | .value[] | select(.name | contains("iPhone 16") or contains("iPhone 15")) | .udid' | while read -r udid; do
            xcrun simctl erase "$udid"
        done
        print_success "iOS simulators cleaned"
    fi
    
    # Clean Android emulators (wipe data)
    print_status "Android emulators will be wiped on next start"
}

# Main script logic
case "${1:-setup}" in
    setup)
        print_status "Setting up test devices..."
        setup_ios_simulators
        setup_android_emulators
        print_success "Device setup complete!"
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
    *)
        echo "Usage: $0 {setup|list|start|stop|clean}"
        echo ""
        echo "Commands:"
        echo "  setup        - Create and configure all test devices"
        echo "  list         - List all available devices"
        echo "  start <name> - Start specific device"
        echo "  stop         - Stop all running devices"
        echo "  clean        - Clean/reset all devices"
        exit 1
        ;;
esac