#!/bin/bash
# scripts/firebase_testlab_setup.sh
# Firebase Test Lab configuration and setup script

set -e

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

# Configuration
FIREBASE_PROJECT="your-firebase-project-id"  # Replace with your project ID
RESULTS_BUCKET="gs://${FIREBASE_PROJECT}_test_results"

# iOS Test Lab configuration
IOS_MODEL="iphone15pro"
IOS_VERSION="18.0"
IOS_LOCALE="en"
IOS_ORIENTATION="portrait"

# Android Test Lab configuration
ANDROID_MODEL="shiba"  # Pixel 8
ANDROID_VERSION="34"
ANDROID_LOCALE="en"
ANDROID_ORIENTATION="portrait"

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI not found"
        print_status "Install with: npm install -g firebase-tools"
        return 1
    fi
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found"
        return 1
    fi
    
    # Check gcloud CLI
    if ! command -v gcloud &> /dev/null; then
        print_warning "Google Cloud SDK not found (optional for advanced features)"
    fi
    
    print_success "Prerequisites checked"
}

# Setup Firebase project
setup_firebase_project() {
    print_status "Setting up Firebase project..."
    
    # Check if logged in
    if ! firebase projects:list &>/dev/null; then
        print_error "Not logged in to Firebase"
        print_status "Please run: firebase login"
        return 1
    fi
    
    # Set project
    if [ "$FIREBASE_PROJECT" = "your-firebase-project-id" ]; then
        print_error "Please update FIREBASE_PROJECT in the configuration"
        print_status "Edit this script and set your actual Firebase project ID"
        return 1
    fi
    
    firebase use "$FIREBASE_PROJECT" || {
        print_error "Failed to set Firebase project"
        print_status "Make sure the project ID is correct: $FIREBASE_PROJECT"
        return 1
    }
    
    print_success "Firebase project configured: $FIREBASE_PROJECT"
}

# Create results bucket
create_results_bucket() {
    print_status "Setting up results bucket..."
    
    if command -v gsutil &> /dev/null; then
        # Check if bucket exists
        if gsutil ls "$RESULTS_BUCKET" &>/dev/null; then
            print_success "Results bucket already exists: $RESULTS_BUCKET"
        else
            print_status "Creating results bucket..."
            gsutil mb "$RESULTS_BUCKET" || {
                print_warning "Could not create bucket. It may already exist or you may not have permissions."
            }
        fi
    else
        print_warning "gsutil not found. Results bucket creation skipped."
        print_status "Results will be stored in Firebase console"
    fi
}

# List available devices
list_available_devices() {
    print_status "Available Firebase Test Lab devices:"
    echo ""
    
    print_status "iOS Devices:"
    firebase testlab ios models list --format="table(id,name,supportedVersionIds[0]:label=iOS_VERSION)" 2>/dev/null | head -10 || {
        print_warning "Could not fetch iOS devices list"
    }
    
    echo ""
    print_status "Android Devices:"
    firebase testlab android models list --format="table(id,name,supportedVersionIds[0]:label=API_LEVEL)" 2>/dev/null | head -10 || {
        print_warning "Could not fetch Android devices list"
    }
}

# Build apps for testing
build_apps() {
    print_status "Building apps for Firebase Test Lab..."
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    # Build iOS
    print_status "Building iOS app..."
    if flutter build ios --config-only --no-codesign --debug; then
        print_success "iOS app built successfully"
    else
        print_error "iOS build failed"
        return 1
    fi
    
    # Build Android APKs
    print_status "Building Android APK..."
    if flutter build apk --debug; then
        print_success "Android APK built successfully"
    else
        print_error "Android APK build failed"
        return 1
    fi
    
    # Build Android test APK
    print_status "Building Android test APK..."
    if flutter build apk --debug --target=integration_test/test_bundle.dart; then
        print_success "Android test APK built successfully"
    else
        print_error "Android test APK build failed"
        return 1
    fi
}

# Run iOS test on Firebase
run_ios_test() {
    local test_name="$1"
    
    print_status "Running iOS test on Firebase Test Lab: $test_name"
    
    firebase testlab ios run \
        --test integration_test/test_bundle.dart \
        --device model="$IOS_MODEL",version="$IOS_VERSION",locale="$IOS_LOCALE",orientation="$IOS_ORIENTATION" \
        --project "$FIREBASE_PROJECT" \
        --results-bucket "$RESULTS_BUCKET" \
        --results-dir="ios_$(date +%Y%m%d_%H%M%S)" \
        --timeout 15m \
        --quiet || {
        print_error "iOS test failed: $test_name"
        return 1
    }
    
    print_success "iOS test completed: $test_name"
}

# Run Android test on Firebase
run_android_test() {
    local test_name="$1"
    
    print_status "Running Android test on Firebase Test Lab: $test_name"
    
    firebase testlab android run \
        --type instrumentation \
        --app build/app/outputs/flutter-apk/app-debug.apk \
        --test build/app/outputs/flutter-apk/app-debug-androidTest.apk \
        --device model="$ANDROID_MODEL",version="$ANDROID_VERSION",locale="$ANDROID_LOCALE",orientation="$ANDROID_ORIENTATION" \
        --project "$FIREBASE_PROJECT" \
        --results-bucket "$RESULTS_BUCKET" \
        --results-dir="android_$(date +%Y%m%d_%H%M%S)" \
        --timeout 15m \
        --quiet || {
        print_error "Android test failed: $test_name"
        return 1
    }
    
    print_success "Android test completed: $test_name"
}

# Run all tests
run_all_tests() {
    print_status "Running all tests on Firebase Test Lab..."
    
    local ios_success=0
    local android_success=0
    
    # Run iOS tests
    if run_ios_test "integration_suite"; then
        ios_success=1
    fi
    
    # Run Android tests
    if run_android_test "integration_suite"; then
        android_success=1
    fi
    
    local total_success=$((ios_success + android_success))
    
    print_status "Firebase Test Lab results:"
    print_status "  iOS: $([ $ios_success -eq 1 ] && echo "✅ PASSED" || echo "❌ FAILED")"
    print_status "  Android: $([ $android_success -eq 1 ] && echo "✅ PASSED" || echo "❌ FAILED")"
    print_status "  Total successful: $total_success/2"
    
    return $total_success
}

# Download test results
download_results() {
    print_status "Downloading test results..."
    
    if ! command -v gsutil &> /dev/null; then
        print_warning "gsutil not found. Cannot download results automatically."
        print_status "Check Firebase console for results: https://console.firebase.google.com/project/$FIREBASE_PROJECT/testlab/histories/"
        return 1
    fi
    
    # Create results directory
    mkdir -p firebase-results
    
    # Download recent results
    print_status "Downloading recent test results..."
    gsutil -m cp -r "$RESULTS_BUCKET/*" firebase-results/ 2>/dev/null || {
        print_warning "Could not download all results"
    }
    
    print_success "Results downloaded to: firebase-results/"
}

# Show configuration
show_config() {
    print_status "Firebase Test Lab Configuration:"
    echo ""
    echo "Project ID: $FIREBASE_PROJECT"
    echo "Results Bucket: $RESULTS_BUCKET"
    echo ""
    echo "iOS Configuration:"
    echo "  Model: $IOS_MODEL"
    echo "  Version: $IOS_VERSION"
    echo "  Locale: $IOS_LOCALE"
    echo "  Orientation: $IOS_ORIENTATION"
    echo ""
    echo "Android Configuration:"
    echo "  Model: $ANDROID_MODEL"
    echo "  Version: $ANDROID_VERSION"
    echo "  Locale: $ANDROID_LOCALE"
    echo "  Orientation: $ANDROID_ORIENTATION"
}

# Show help
show_help() {
    echo "Firebase Test Lab Setup and Runner"
    echo ""
    echo "Usage: $0 {command}"
    echo ""
    echo "Commands:"
    echo "  setup           - Setup Firebase project and buckets"
    echo "  build           - Build apps for testing"
    echo "  ios             - Run tests on iOS"
    echo "  android         - Run tests on Android"
    echo "  run             - Run tests on both platforms"
    echo "  download        - Download test results"
    echo "  devices         - List available devices"
    echo "  config          - Show current configuration"
    echo "  help            - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 setup        # Initial setup"
    echo "  $0 build        # Build apps"
    echo "  $0 run          # Run all tests"
    echo "  $0 download     # Download results"
}

# Main script logic
case "${1:-help}" in
    setup)
        check_prerequisites
        setup_firebase_project
        create_results_bucket
        ;;
    build)
        build_apps
        ;;
    ios)
        check_prerequisites
        run_ios_test "ios_suite"
        ;;
    android)
        check_prerequisites
        run_android_test "android_suite"
        ;;
    run)
        check_prerequisites
        build_apps
        run_all_tests
        ;;
    download)
        download_results
        ;;
    devices)
        list_available_devices
        ;;
    config)
        show_config
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