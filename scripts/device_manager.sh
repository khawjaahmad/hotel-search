#!/bin/bash
# scripts/device_manager.sh
# Device Manager for Your Specific Test Devices

# Colors
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

# Your specific device configuration
LOCAL_IOS_UDID="AEEFBF8D-12AB-4AC1-9BA7-9751ED8AC5D8"
LOCAL_IOS_NAME="iPhone 16 Plus"
LOCAL_ANDROID_AVD="Pixel_7"

# Firebase Test Lab configuration
FIREBASE_PROJECT="your-firebase-project-id"  # Replace with your actual project ID
FIREBASE_IOS_MODEL="iphone15pro"
FIREBASE_IOS_VERSION="18.0"
FIREBASE_ANDROID_MODEL="shiba"  # Pixel 8
FIREBASE_ANDROID_VERSION="34"

list_devices() {
    print_status "Your Configured Test Devices:"
    echo ""
    
    print_status "LOCAL DEVICES:"
    echo "  📱 iOS: $LOCAL_IOS_NAME ($LOCAL_IOS_UDID)"
    echo "  🤖 Android: $LOCAL_ANDROID_AVD"
    echo ""
    
    print_status "FIREBASE TEST LAB DEVICES:"
    echo "  📱 iOS: $FIREBASE_IOS_MODEL (iOS $FIREBASE_IOS_VERSION)"
    echo "  🤖 Android: $FIREBASE_ANDROID_MODEL (API $FIREBASE_ANDROID_VERSION)"
    echo ""
    
    print_status "Currently Available to Flutter:"
    if command -v flutter &> /dev/null; then
        flutter devices --machine 2>/dev/null | jq -r '.[] | "  \(.name) (\(.id)) - \(.platform)"' 2>/dev/null || flutter devices
    else
        print_warning "Flutter not found"
    fi
    echo ""
    
    print_status "iOS Simulators Status:"
    if command -v xcrun &> /dev/null; then
        local ios_state=$(xcrun simctl list devices | grep "$LOCAL_IOS_NAME" | grep -o "([^)]*)" | head -1)
        echo "  $LOCAL_IOS_NAME: ${ios_state:-"Not Found"}"
    else
        print_warning "Xcode command line tools not available"
    fi
    echo ""
    
    print_status "Android Emulators Status:"
    if command -v adb &> /dev/null; then
        local android_running=$(adb devices | grep "emulator" | wc -l)
        echo "  Running emulators: $android_running"
        if [ "$android_running" -gt 0 ]; then
            adb devices | grep "emulator" | while read line; do
                local device_id=$(echo "$line" | cut -f1)
                echo "    $device_id"
            done
        fi
    else
        print_warning "ADB not available"
    fi
}

start_ios_local() {
    print_status "Starting iPhone 16 Plus..."
    
    if ! command -v xcrun &> /dev/null; then
        print_error "Xcode command line tools not found"
        return 1
    fi
    
    # Check if device exists
    if ! xcrun simctl list devices | grep -q "$LOCAL_IOS_NAME"; then
        print_error "iOS device '$LOCAL_IOS_NAME' not found"
        print_status "Available iOS devices:"
        xcrun simctl list devices | grep "iPhone\|iPad" | head -5
        return 1
    fi
    
    # Boot device
    local current_state=$(xcrun simctl list devices | grep "$LOCAL_IOS_NAME" | grep -o "([^)]*)" | head -1)
    
    if [[ "$current_state" == "(Booted)" ]]; then
        print_success "iPhone 16 Plus is already running"
    else
        xcrun simctl boot "$LOCAL_IOS_UDID" 2>/dev/null || {
            print_error "Failed to boot iPhone 16 Plus"
            return 1
        }
        print_success "iPhone 16 Plus started successfully"
    fi
}

start_android_local() {
    print_status "Starting Pixel 7 emulator..."
    
    # Check if Android SDK is available
    if ! command -v emulator &> /dev/null; then
        print_error "Android emulator not found"
        print_status "Make sure Android SDK is installed and emulator is in PATH"
        return 1
    fi
    
    # Check if AVD exists
    if ! emulator -list-avds | grep -q "$LOCAL_ANDROID_AVD"; then
        print_error "Android AVD '$LOCAL_ANDROID_AVD' not found"
        print_status "Available AVDs:"
        emulator -list-avds | head -5
        return 1
    fi
    
    # Check if already running
    if adb devices | grep -q "emulator.*device"; then
        print_success "Android emulator is already running"
    else
        print_status "Starting Android emulator (this may take a moment)..."
        emulator -avd "$LOCAL_ANDROID_AVD" -no-window -no-snapshot &
        
        # Wait for device to be ready
        local timeout=120
        local elapsed=0
        print_status "Waiting for emulator to be ready..."
        
        while [ $elapsed -lt $timeout ]; do
            if adb devices | grep -q "emulator.*device"; then
                print_success "Pixel 7 emulator started successfully"
                return 0
            fi
            sleep 5
            elapsed=$((elapsed + 5))
            printf "."
        done
        
        echo ""
        print_error "Android emulator failed to start within $timeout seconds"
        return 1
    fi
}

start_local_devices() {
    print_status "Starting all local devices..."
    
    local ios_result=0
    local android_result=0
    
    # Start iOS in background
    start_ios_local &
    local ios_pid=$!
    
    # Start Android in background
    start_android_local &
    local android_pid=$!
    
    # Wait for both
    wait $ios_pid || ios_result=1
    wait $android_pid || android_result=1
    
    if [ $ios_result -eq 0 ] && [ $android_result -eq 0 ]; then
        print_success "All local devices started successfully"
        return 0
    else
        print_warning "Some devices failed to start"
        return 1
    fi
}

stop_devices() {
    print_status "Stopping all running devices..."
    
    # Stop iOS simulators
    if command -v xcrun &> /dev/null; then
        xcrun simctl shutdown all 2>/dev/null || true
        print_success "iOS simulators stopped"
    fi
    
    # Stop Android emulators
    if command -v adb &> /dev/null; then
        adb devices | grep emulator | cut -f1 | while read -r device_id; do
            adb -s "$device_id" emu kill 2>/dev/null || true
        done
        print_success "Android emulators stopped"
    fi
    
    # Kill any remaining emulator processes
    pkill -f "emulator" 2>/dev/null || true
}

check_firebase_setup() {
    print_status "Checking Firebase Test Lab setup..."
    
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI not found"
        echo "Install with: npm install -g firebase-tools"
        return 1
    fi
    
    # Check if logged in
    if ! firebase projects:list &>/dev/null; then
        print_error "Not logged in to Firebase"
        echo "Run: firebase login"
        return 1
    fi
    
    # Check project
    if [ "$FIREBASE_PROJECT" = "your-firebase-project-id" ]; then
        print_warning "Firebase project ID not configured"
        echo "Please update FIREBASE_PROJECT in this script"
        return 1
    fi
    
    print_success "Firebase CLI is ready"
    print_status "Project: $FIREBASE_PROJECT"
    print_status "iOS Device: $FIREBASE_IOS_MODEL (iOS $FIREBASE_IOS_VERSION)"
    print_status "Android Device: $FIREBASE_ANDROID_MODEL (API $FIREBASE_ANDROID_VERSION)"
}

test_devices() {
    print_status "Testing device connectivity..."
    
    # Test iOS
    if command -v xcrun &> /dev/null; then
        if xcrun simctl list devices | grep -q "$LOCAL_IOS_NAME.*Booted"; then
            print_success "iOS simulator is accessible"
        else
            print_warning "iOS simulator not running"
        fi
    fi
    
    # Test Android
    if command -v adb &> /dev/null; then
        local android_devices=$(adb devices | grep "device$" | wc -l)
        if [ "$android_devices" -gt 0 ]; then
            print_success "Android devices accessible: $android_devices"
        else
            print_warning "No Android devices found"
        fi
    fi
    
    # Test Flutter
    if command -v flutter &> /dev/null; then
        local flutter_devices=$(flutter devices --machine 2>/dev/null | jq length 2>/dev/null || echo "0")
        print_status "Flutter can see $flutter_devices device(s)"
    fi
}

show_help() {
    echo "Device Manager for Hotel Booking App"
    echo ""
    echo "Usage: $0 {command}"
    echo ""
    echo "Commands:"
    echo "  list                - List all configured devices"
    echo "  start-ios          - Start local iOS simulator"
    echo "  start-android      - Start local Android emulator"
    echo "  start-local        - Start all local devices"
    echo "  stop               - Stop all running devices"
    echo "  test               - Test device connectivity"
    echo "  firebase-check     - Check Firebase Test Lab setup"
    echo "  help               - Show this help"
    echo ""
    echo "Device Configuration:"
    echo "  Local iOS: $LOCAL_IOS_NAME"
    echo "  Local Android: $LOCAL_ANDROID_AVD"
    echo "  Firebase iOS: $FIREBASE_IOS_MODEL"
    echo "  Firebase Android: $FIREBASE_ANDROID_MODEL"
}

# Main script logic
case "${1:-list}" in
    list)
        list_devices
        ;;
    start-ios)
        start_ios_local
        ;;
    start-android)
        start_android_local
        ;;
    start-local)
        start_local_devices
        ;;
    stop)
        stop_devices
        ;;
    test)
        test_devices
        ;;
    firebase-check)
        check_firebase_setup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac