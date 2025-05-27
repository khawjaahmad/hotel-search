#!/bin/bash

# =============================================================================
# FIREBASE TEST LAB - MANUAL EXECUTION SCRIPT
# =============================================================================
# This script provides manual control over Firebase Test Lab execution
# Use this for ad-hoc testing, debugging, or custom device configurations
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
FIREBASE_PROJECT_ID="home-search-d7c7c"
FIREBASE_BUCKET="hotel-booking-test-results"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter SDK."
        exit 1
    fi
    
    # Check Patrol
    if ! command -v patrol &> /dev/null; then
        print_warning "Patrol CLI not found. Installing..."
        dart pub global activate patrol_cli
    fi
    
    # Check Google Cloud SDK
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK not found. Please install from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        print_warning "Not authenticated with Google Cloud. Running authentication..."
        gcloud auth application-default login
    fi
    
    # Set project
    gcloud config set project "$FIREBASE_PROJECT_ID"
    
    print_success "Prerequisites check completed"
}

# Build applications
build_for_firebase() {
    local platform="$1"
    
    print_step "Building $platform app for Firebase Test Lab..."
    cd "$PROJECT_ROOT"
    
    case $platform in
        "ios")
            print_info "Building iOS app with Patrol..."
            patrol build ios --verbose
            
            # Create test bundle
            cd build/ios_integ/Build/Products
            rm -f ios_tests.zip
            zip -r ios_tests.zip Release-iphoneos/*.app *.xctestrun
            
            if [[ -f "ios_tests.zip" ]]; then
                local size=$(ls -lh ios_tests.zip | awk '{print $5}')
                print_success "iOS test bundle created: ios_tests.zip ($size)"
            else
                print_error "Failed to create iOS test bundle"
                exit 1
            fi
            cd "$PROJECT_ROOT"
            ;;
            
        "android")
            print_info "Building Android app with Patrol..."
            patrol build android --verbose
            
            # Verify APK files
            if [[ -f "build/app/outputs/apk/debug/app-debug.apk" ]] && [[ -f "build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk" ]]; then
                local app_size=$(ls -lh build/app/outputs/apk/debug/app-debug.apk | awk '{print $5}')
                local test_size=$(ls -lh build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk | awk '{print $5}')
                print_success "Android APKs ready:"
                print_info "  App APK: $app_size"
                print_info "  Test APK: $test_size"
            else
                print_error "Failed to build Android APKs"
                exit 1
            fi
            ;;
            
        *)
            print_error "Unknown platform: $platform"
            exit 1
            ;;
    esac
}

# Execute Firebase tests
run_firebase_tests() {
    local platform="$1"
    local device_config="$2"
    
    print_step "Running $platform tests on Firebase Test Lab..."
    
    # Generate timestamp for results
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local results_dir="${platform}-tests/${timestamp}-manual"
    
    print_info "Results will be stored in: gs://$FIREBASE_BUCKET/$results_dir"
    
    case $platform in
        "ios")
            local test_bundle="$PROJECT_ROOT/build/ios_integ/Build/Products/ios_tests.zip"
            
            if [[ ! -f "$test_bundle" ]]; then
                print_error "iOS test bundle not found. Run build first."
                exit 1
            fi
            
            # Parse device configuration
            IFS=',' read -ra DEVICES <<< "$device_config"
            local device_args=""
            
            for device in "${DEVICES[@]}"; do
                IFS=':' read -ra DEVICE_INFO <<< "$device"
                local model="${DEVICE_INFO[0]}"
                local version="${DEVICE_INFO[1]:-18.0}"
                device_args="$device_args --device model=$model,version=$version,locale=en_US,orientation=portrait"
            done
            
            print_info "Testing on iOS devices: $device_config"
            
            gcloud firebase test ios run \
                --type xctest \
                --test "$test_bundle" \
                $device_args \
                --timeout 20m \
                --results-bucket="$FIREBASE_BUCKET" \
                --results-dir="$results_dir" \
                --project="$FIREBASE_PROJECT_ID" \
                --format=json | tee "firebase-ios-results.json"
            ;;
            
        "android")
            local app_apk="$PROJECT_ROOT/build/app/outputs/apk/debug/app-debug.apk"
            local test_apk="$PROJECT_ROOT/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
            
            if [[ ! -f "$app_apk" ]] || [[ ! -f "$test_apk" ]]; then
                print_error "Android APKs not found. Run build first."
                exit 1
            fi
            
            # Parse device configuration
            IFS=',' read -ra DEVICES <<< "$device_config"
            local device_args=""
            
            for device in "${DEVICES[@]}"; do
                IFS=':' read -ra DEVICE_INFO <<< "$device"
                local model="${DEVICE_INFO[0]}"
                local version="${DEVICE_INFO[1]:-34}"
                device_args="$device_args --device model=$model,version=$version,locale=en,orientation=portrait"
            done
            
            print_info "Testing on Android devices: $device_config"
            
            gcloud firebase test android run \
                --type instrumentation \
                --app "$app_apk" \
                --test "$test_apk" \
                $device_args \
                --timeout 20m \
                --results-bucket="$FIREBASE_BUCKET" \
                --results-dir="$results_dir" \
                --use-orchestrator \
                --environment-variables clearPackageData=true \
                --project="$FIREBASE_PROJECT_ID" \
                --format=json | tee "firebase-android-results.json"
            ;;
    esac
}

# Process test results
process_results() {
    local platform="$1"
    local results_file="firebase-${platform}-results.json"
    
    print_step "Processing $platform test results..."
    
    if [[ -f "$results_file" ]]; then
        # Extract results URL
        local results_url=$(cat "$results_file" | jq -r '.[0].testDetails.resultsUrl // empty' 2>/dev/null)
        
        if [[ -n "$results_url" ]]; then
            print_success "Firebase $platform Results: $results_url"
            echo "$results_url" > "firebase-${platform}-url.txt"
        fi
        
        # Extract test outcome
        local outcome=$(cat "$results_file" | jq -r '.[0].outcome // empty' 2>/dev/null)
        
        case $outcome in
            "PASSED")
                print_success "All $platform tests PASSED ✅"
                ;;
            "FAILED")
                print_error "Some $platform tests FAILED ❌"
                ;;
            *)
                print_warning "$platform test outcome: $outcome"
                ;;
        esac
        
        # Show device results summary
        local device_count=$(cat "$results_file" | jq length 2>/dev/null)
        print_info "Tested on $device_count device(s)"
        
    else
        print_warning "No results file found for $platform"
    fi
}

# Download test artifacts
download_results() {
    local platform="$1"
    
    print_step "Downloading $platform test artifacts..."
    
    # Create results directory
    mkdir -p "firebase-results/$platform"
    
    # Find latest results directory
    local latest_dir=$(gsutil ls "gs://$FIREBASE_BUCKET/${platform}-tests/" | grep -E "${platform}-tests/.*manual" | tail -1)
    
    if [[ -n "$latest_dir" ]]; then
        print_info "Downloading from: $latest_dir"
        gsutil -m cp -r "$latest_dir" "firebase-results/$platform/" || true
        print_success "Results downloaded to: firebase-results/$platform/"
    else
        print_warning "No recent test results found for $platform"
    fi
}

# Main execution functions
run_ios_tests() {
    local devices="${1:-iphone15pro:18.0,iphone14pro:17.0}"
    
    print_header "🍎 FIREBASE iOS TESTING"
    
    check_prerequisites
    build_for_firebase "ios"
    run_firebase_tests "ios" "$devices"
    process_results "ios"
    download_results "ios"
    
    print_success "iOS testing completed!"
}

run_android_tests() {
    local devices="${1:-shiba:34,oriole:33}"
    
    print_header "🤖 FIREBASE ANDROID TESTING"
    
    check_prerequisites
    build_for_firebase "android"
    run_firebase_tests "android" "$devices"
    process_results "android"
    download_results "android"
    
    print_success "Android testing completed!"
}

run_both_platforms() {
    local ios_devices="${1:-iphone15pro:18.0,iphone14pro:17.0}"
    local android_devices="${2:-shiba:34,oriole:33}"
    
    print_header "🚀 FIREBASE MULTI-PLATFORM TESTING"
    
    print_info "iOS devices: $ios_devices"
    print_info "Android devices: $android_devices"
    
    check_prerequisites
    
    # Build both platforms
    build_for_firebase "ios"
    build_for_firebase "android"
    
    # Run tests in parallel
    print_step "Running tests on both platforms..."
    
    # iOS tests in background
    (run_firebase_tests "ios" "$ios_devices" && process_results "ios" && download_results "ios") &
    local ios_pid=$!
    
    # Android tests in foreground
    run_firebase_tests "android" "$android_devices"
    process_results "android"
    download_results "android"
    
    # Wait for iOS to complete
    print_step "Waiting for iOS tests to complete..."
    wait $ios_pid
    
    print_success "Multi-platform testing completed!"
}

# Device configuration presets
list_device_presets() {
    print_header "📱 DEVICE CONFIGURATION PRESETS"
    
    echo -e "${YELLOW}iOS Device Presets:${NC}"
    echo "  minimal    : iphone15pro:18.0"
    echo "  standard   : iphone15pro:18.0,iphone14pro:17.0"
    echo "  extended   : iphone15pro:18.0,iphone14pro:17.0,iphone13pro:16.0"
    echo "  ipad       : iphone15pro:18.0,ipad13:17.0"
    echo ""
    echo -e "${YELLOW}Android Device Presets:${NC}"
    echo "  minimal    : shiba:34"
    echo "  standard   : shiba:34,oriole:33"
    echo "  extended   : shiba:34,oriole:33,redfin:30"
    echo "  legacy     : shiba:34,oriole:33,redfin:30,flame:29"
    echo ""
    echo -e "${YELLOW}Custom Format:${NC}"
    echo "  model:version,model:version"
    echo "  Example: iphone15pro:18.0,shiba:34"
}

# Show available devices
show_available_devices() {
    print_header "📋 AVAILABLE FIREBASE TEST LAB DEVICES"
    
    print_step "Fetching iOS devices..."
    echo -e "${YELLOW}iOS Devices:${NC}"
    gcloud firebase test ios models list --format="table(id,name,supportedVersions.list():label=VERSIONS)" --limit=15 2>/dev/null || print_warning "Failed to fetch iOS devices"
    
    echo ""
    print_step "Fetching Android devices..."
    echo -e "${YELLOW}Android Devices:${NC}"
    gcloud firebase test android models list --format="table(id,brand,name,supportedVersionIds.list():label=API_LEVELS)" --limit=15 2>/dev/null || print_warning "Failed to fetch Android devices"
}

# Performance testing mode
run_performance_tests() {
    local platform="$1"
    local device="$2"
    
    print_header "⚡ FIREBASE PERFORMANCE TESTING"
    
    print_info "Running performance tests on $platform device: $device"
    
    check_prerequisites
    build_for_firebase "$platform"
    
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local results_dir="performance-${platform}/${timestamp}"
    
    case $platform in
        "ios")
            gcloud firebase test ios run \
                --type xctest \
                --test "$PROJECT_ROOT/build/ios_integ/Build/Products/ios_tests.zip" \
                --device "model=$device,version=18.0,locale=en_US,orientation=portrait" \
                --timeout 30m \
                --results-bucket="$FIREBASE_BUCKET" \
                --results-dir="$results_dir" \
                --project="$FIREBASE_PROJECT_ID"
            ;;
        "android")
            gcloud firebase test android run \
                --type instrumentation \
                --app "$PROJECT_ROOT/build/app/outputs/apk/debug/app-debug.apk" \
                --test "$PROJECT_ROOT/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk" \
                --device "model=$device,version=34,locale=en,orientation=portrait" \
                --timeout 30m \
                --results-bucket="$FIREBASE_BUCKET" \
                --results-dir="$results_dir" \
                --use-orchestrator \
                --environment-variables clearPackageData=true,performance_metrics=true \
                --project="$FIREBASE_PROJECT_ID"
            ;;
    esac
    
    print_success "Performance testing completed!"
}

# Custom test configuration
run_custom_test() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        print_error "Configuration file not found: $config_file"
        exit 1
    fi
    
    print_header "🔧 FIREBASE CUSTOM TESTING"
    print_info "Using configuration: $config_file"
    
    # Source the configuration
    source "$config_file"
    
    check_prerequisites
    
    # Build platforms as specified in config
    if [[ "$TEST_IOS" == "true" ]]; then
        build_for_firebase "ios"
    fi
    
    if [[ "$TEST_ANDROID" == "true" ]]; then
        build_for_firebase "android"
    fi
    
    # Run tests based on configuration
    if [[ "$TEST_IOS" == "true" ]]; then
        run_firebase_tests "ios" "$IOS_DEVICES"
        process_results "ios"
    fi
    
    if [[ "$TEST_ANDROID" == "true" ]]; then
        run_firebase_tests "android" "$ANDROID_DEVICES"
        process_results "android"
    fi
    
    print_success "Custom testing completed!"
}

# Generate test configuration template
generate_config_template() {
    local config_file="${1:-firebase-test-config.sh}"
    
    print_step "Generating configuration template: $config_file"
    
    cat > "$config_file" << 'EOF'
#!/bin/bash
# Firebase Test Lab Configuration Template
# Customize this file for your testing needs

# Platform Configuration
TEST_IOS=true
TEST_ANDROID=true

# iOS Device Configuration
# Format: model:version,model:version
IOS_DEVICES="iphone15pro:18.0,iphone14pro:17.0"

# Android Device Configuration  
# Format: model:version,model:version
ANDROID_DEVICES="shiba:34,oriole:33"

# Test Configuration
TIMEOUT="20m"
RESULTS_PREFIX="custom-test"

# Environment Variables (Android only)
ANDROID_ENV_VARS="clearPackageData=true,enableDebugLogs=true"

# Additional gcloud options
EXTRA_GCLOUD_ARGS=""

# Notification settings
SEND_SLACK_NOTIFICATION=false
SLACK_WEBHOOK_URL=""
EOF

    print_success "Configuration template created: $config_file"
    print_info "Edit this file to customize your test configuration"
}

# Status and monitoring
show_test_status() {
    print_header "📊 FIREBASE TEST STATUS"
    
    print_step "Checking recent test results..."
    
    # Check bucket contents
    echo -e "${YELLOW}Recent Test Executions:${NC}"
    gsutil ls -l "gs://$FIREBASE_BUCKET/" | tail -10 2>/dev/null || print_warning "No recent results found"
    
    echo ""
    
    # Check if any tests are currently running
    print_step "Checking for running tests..."
    local running_tests=$(gcloud firebase test ios models list --filter="state:RUNNING" --format="value(name)" 2>/dev/null | wc -l)
    
    if [[ $running_tests -gt 0 ]]; then
        print_info "Found $running_tests running test(s)"
    else
        print_info "No tests currently running"
    fi
    
    # Show recent URLs if available
    if [[ -f "firebase-ios-url.txt" ]]; then
        echo -e "${YELLOW}Latest iOS Results:${NC} $(cat firebase-ios-url.txt)"
    fi
    
    if [[ -f "firebase-android-url.txt" ]]; then
        echo -e "${YELLOW}Latest Android Results:${NC} $(cat firebase-android-url.txt)"
    fi
}

# Cleanup utilities
cleanup_old_results() {
    local days="${1:-30}"
    
    print_header "🧹 CLEANUP OLD RESULTS"
    
    print_warning "This will delete Firebase test results older than $days days"
    read -p "Continue? [y/N]: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        print_step "Cleaning up results older than $days days..."
        
        # Calculate cutoff date
        local cutoff_date
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            cutoff_date=$(date -v-${days}d +%Y%m%d)
        else
            # Linux
            cutoff_date=$(date -d "$days days ago" +%Y%m%d)
        fi
        
        # Clean up old results
        gsutil -m rm -r "gs://$FIREBASE_BUCKET/**/*$cutoff_date*" 2>/dev/null || true
        
        print_success "Cleanup completed"
    else
        print_info "Cleanup cancelled"
    fi
}

# Help and usage
show_help() {
    print_header "🚀 FIREBASE TEST LAB MANUAL SCRIPT"
    
    echo -e "${GREEN}USAGE:${NC}"
    echo "  $0 [COMMAND] [OPTIONS]"
    echo ""
    echo -e "${GREEN}COMMANDS:${NC}"
    echo "  ${YELLOW}ios [devices]${NC}           - Run iOS tests"
    echo "  ${YELLOW}android [devices]${NC}       - Run Android tests" 
    echo "  ${YELLOW}both [ios_devices] [android_devices]${NC} - Run both platforms"
    echo "  ${YELLOW}performance <platform> <device>${NC} - Run performance tests"
    echo "  ${YELLOW}custom <config_file>${NC}    - Run with custom configuration"
    echo ""
    echo "  ${YELLOW}devices${NC}                 - Show available devices"
    echo "  ${YELLOW}presets${NC}                 - Show device presets"
    echo "  ${YELLOW}status${NC}                  - Show test status"
    echo "  ${YELLOW}config${NC}                  - Generate config template"
    echo "  ${YELLOW}cleanup [days]${NC}          - Clean old results (default: 30 days)"
    echo ""
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo "  $0 ios"
    echo "  $0 android minimal"
    echo "  $0 both standard extended"
    echo "  $0 performance android shiba"
    echo "  $0 custom my-test-config.sh"
    echo ""
    echo -e "${GREEN}DEVICE FORMATS:${NC}"
    echo "  Use presets: minimal, standard, extended"
    echo "  Or custom: model:version,model:version"
    echo ""
    echo -e "${GREEN}QUICK START:${NC}"
    echo "  1. $0 presets    # See available presets"
    echo "  2. $0 ios        # Run iOS tests with default devices"
    echo "  3. $0 status     # Check results"
}

# Main script logic
main() {
    local command="${1:-help}"
    
    case "$command" in
        "ios")
            run_ios_tests "$2"
            ;;
        "android") 
            run_android_tests "$2"
            ;;
        "both")
            run_both_platforms "$2" "$3"
            ;;
        "performance")
            if [[ -z "$2" ]] || [[ -z "$3" ]]; then
                print_error "Performance testing requires platform and device"
                echo "Usage: $0 performance <ios|android> <device_model>"
                exit 1
            fi
            run_performance_tests "$2" "$3"
            ;;
        "custom")
            if [[ -z "$2" ]]; then
                print_error "Custom testing requires configuration file"
                echo "Usage: $0 custom <config_file>"
                exit 1
            fi
            run_custom_test "$2"
            ;;
        "devices")
            show_available_devices
            ;;
        "presets")
            list_device_presets
            ;;
        "status")
            show_test_status
            ;;
        "config")
            generate_config_template "$2"
            ;;
        "cleanup")
            cleanup_old_results "$2"
            ;;
        "help"|"-h"|"--help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@" "