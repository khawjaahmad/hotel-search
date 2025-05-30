#!/bin/bash

# Firebase Test Lab Diagnostic Script
# This script helps diagnose issues with Firebase Test Lab setup

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Firebase Test Lab Diagnostic Tool${NC}"
echo "===================================="

# Check environment variables
check_environment() {
    echo -e "${BLUE}📋 Checking Environment Variables${NC}"

    local issues=0

    if [ -z "${FIREBASE_PROJECT_ID:-}" ]; then
        echo -e "${RED}❌ FIREBASE_PROJECT_ID not set${NC}"
        issues=$((issues + 1))
    else
        echo -e "${GREEN}✅ FIREBASE_PROJECT_ID: $FIREBASE_PROJECT_ID${NC}"
    fi

    if [ -z "${SERPAPI_API_KEY:-}" ]; then
        echo -e "${YELLOW}⚠️ SERPAPI_API_KEY not set (may cause test failures)${NC}"
    else
        echo -e "${GREEN}✅ SERPAPI_API_KEY is set${NC}"
    fi

    return $issues
}

# Check required tools
check_tools() {
    echo -e "${BLUE}🔧 Checking Required Tools${NC}"

    local issues=0

    # Flutter
    if command -v flutter &> /dev/null; then
        local flutter_version=$(flutter --version | grep "Flutter" | cut -d' ' -f2)
        echo -e "${GREEN}✅ Flutter: $flutter_version${NC}"
    else
        echo -e "${RED}❌ Flutter not found${NC}"
        issues=$((issues + 1))
    fi

    # Dart
    if command -v dart &> /dev/null; then
        local dart_version=$(dart --version | cut -d' ' -f4)
        echo -e "${GREEN}✅ Dart: $dart_version${NC}"
    else
        echo -e "${RED}❌ Dart not found${NC}"
        issues=$((issues + 1))
    fi

    # Patrol CLI
    if command -v patrol &> /dev/null; then
        echo -e "${GREEN}✅ Patrol CLI installed${NC}"
    else
        echo -e "${RED}❌ Patrol CLI not found${NC}"
        echo -e "${YELLOW}   Install: dart pub global activate patrol_cli${NC}"
        issues=$((issues + 1))
    fi

    # Google Cloud SDK
    if command -v gcloud &> /dev/null; then
        local gcloud_version=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null | head -n1)
        echo -e "${GREEN}✅ Google Cloud SDK: $gcloud_version${NC}"
    else
        echo -e "${RED}❌ Google Cloud SDK not found${NC}"
        issues=$((issues + 1))
    fi

    return $issues
}

# Check Google Cloud authentication
check_gcloud_auth() {
    echo -e "${BLUE}🔑 Checking Google Cloud Authentication${NC}"

    local issues=0

    # Check if authenticated
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
        local active_account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
        echo -e "${GREEN}✅ Authenticated as: $active_account${NC}"
    else
        echo -e "${RED}❌ Not authenticated with Google Cloud${NC}"
        echo -e "${YELLOW}   Run: gcloud auth login${NC}"
        issues=$((issues + 1))
    fi

    # Check project configuration
    local current_project=$(gcloud config get-value project 2>/dev/null || echo "")
    if [ -n "$current_project" ]; then
        echo -e "${GREEN}✅ Current project: $current_project${NC}"

        # Verify project exists
        if gcloud projects describe "$current_project" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Project exists and accessible${NC}"
        else
            echo -e "${RED}❌ Project not accessible${NC}"
            issues=$((issues + 1))
        fi
    else
        echo -e "${RED}❌ No project configured${NC}"
        echo -e "${YELLOW}   Run: gcloud config set project YOUR_PROJECT_ID${NC}"
        issues=$((issues + 1))
    fi

    return $issues
}

# Check Firebase APIs
check_firebase_apis() {
    echo -e "${BLUE}🔥 Checking Firebase APIs${NC}"

    local issues=0
    local project_id=$(gcloud config get-value project 2>/dev/null || echo "")

    if [ -z "$project_id" ]; then
        echo -e "${RED}❌ No project configured${NC}"
        return 1
    fi

    # Check required APIs
    local apis=("testing.googleapis.com" "toolresults.googleapis.com" "firebase.googleapis.com")

    for api in "${apis[@]}"; do
        if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
            echo -e "${GREEN}✅ $api enabled${NC}"
        else
            echo -e "${RED}❌ $api not enabled${NC}"
            echo -e "${YELLOW}   Enable: gcloud services enable $api${NC}"
            issues=$((issues + 1))
        fi
    done

    return $issues
}

# Check project structure
check_project_structure() {
    echo -e "${BLUE}📁 Checking Project Structure${NC}"

    local issues=0

    # Required files and directories
    local required_paths=(
        "pubspec.yaml"
        "lib/main.dart"
        "integration_test/tests"
        "android/app/build.gradle"
        "patrol.yaml"
    )

    for path in "${required_paths[@]}"; do
        if [ -e "$path" ]; then
            echo -e "${GREEN}✅ $path exists${NC}"
        else
            echo -e "${RED}❌ $path missing${NC}"
            issues=$((issues + 1))
        fi
    done

    # Check specific test files
    local test_files=(
        "integration_test/tests/dashboard_test.dart"
        "integration_test/tests/hotels_test.dart"
        "integration_test/tests/account_test.dart"
        "integration_test/tests/overview_test.dart"
    )

    echo -e "${BLUE}🧪 Test Files:${NC}"
    for test_file in "${test_files[@]}"; do
        if [ -f "$test_file" ]; then
            echo -e "${GREEN}✅ $test_file${NC}"
        else
            echo -e "${YELLOW}⚠️ $test_file missing${NC}"
        fi
    done

    return $issues
}

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}📦 Checking Dependencies${NC}"

    local issues=0

    # Check if pub get has been run
    if [ -f "pubspec.lock" ]; then
        echo -e "${GREEN}✅ pubspec.lock exists${NC}"
    else
        echo -e "${RED}❌ pubspec.lock missing${NC}"
        echo -e "${YELLOW}   Run: flutter pub get${NC}"
        issues=$((issues + 1))
    fi

    # Check for .dart_tool
    if [ -d ".dart_tool" ]; then
        echo -e "${GREEN}✅ .dart_tool directory exists${NC}"
    else
        echo -e "${RED}❌ .dart_tool directory missing${NC}"
        echo -e "${YELLOW}   Run: flutter pub get${NC}"
        issues=$((issues + 1))
    fi

    # Check critical dependencies in pubspec.yaml
    local required_deps=("patrol" "flutter_test")

    for dep in "${required_deps[@]}"; do
        if grep -q "$dep:" pubspec.yaml; then
            echo -e "${GREEN}✅ $dep dependency found${NC}"
        else
            echo -e "${RED}❌ $dep dependency missing${NC}"
            issues=$((issues + 1))
        fi
    done

    return $issues
}

# Test APK build
test_apk_build() {
    echo -e "${BLUE}🔨 Testing APK Build${NC}"

    local issues=0

    # Clean previous builds
    rm -rf build/app/outputs/apk/

    # Try to build APKs
    echo -e "${YELLOW}Building APKs (this may take a few minutes)...${NC}"

    if patrol build android --target=integration_test/tests/dashboard_test.dart --release > /tmp/patrol_build.log 2>&1; then
        echo -e "${GREEN}✅ APK build successful${NC}"

        # Check for APK files
        local app_apk="build/app/outputs/apk/debug/app-debug.apk"
        local test_apk="build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"

        if [ -f "$app_apk" ]; then
            local app_size=$(du -h "$app_apk" | cut -f1)
            echo -e "${GREEN}✅ App APK: $app_size${NC}"
        else
            echo -e "${RED}❌ App APK not found${NC}"
            issues=$((issues + 1))
        fi

        if [ -f "$test_apk" ]; then
            local test_size=$(du -h "$test_apk" | cut -f1)
            echo -e "${GREEN}✅ Test APK: $test_size${NC}"
        else
            echo -e "${RED}❌ Test APK not found${NC}"
            issues=$((issues + 1))
        fi
    else
        echo -e "${RED}❌ APK build failed${NC}"
        echo -e "${YELLOW}Build log:${NC}"
        cat /tmp/patrol_build.log
        issues=$((issues + 1))
    fi

    return $issues
}

# Test Firebase connectivity
test_firebase_connectivity() {
    echo -e "${BLUE}🌐 Testing Firebase Connectivity${NC}"

    local issues=0
    local project_id=$(gcloud config get-value project 2>/dev/null || echo "")

    if [ -z "$project_id" ]; then
        echo -e "${RED}❌ No project configured${NC}"
        return 1
    fi

    # Test listing device models
    if gcloud firebase test android models list --format="value(id)" --limit=1 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Can access Firebase Test Lab${NC}"
    else
        echo -e "${RED}❌ Cannot access Firebase Test Lab${NC}"
        issues=$((issues + 1))
    fi

    # Test storage bucket access
    local bucket="${project_id}-test-results"
    if gsutil ls "gs://$bucket" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Storage bucket accessible: $bucket${NC}"
    else
        echo -e "${YELLOW}⚠️ Storage bucket not found: $bucket${NC}"
        echo -e "${YELLOW}   Creating bucket...${NC}"
        if gsutil mb "gs://$bucket" 2>/dev/null; then
            echo -e "${GREEN}✅ Storage bucket created${NC}"
        else
            echo -e "${RED}❌ Failed to create storage bucket${NC}"
            issues=$((issues + 1))
        fi
    fi

    return $issues
}

# Generate diagnosis report
generate_report() {
    local total_issues=$1

    echo ""
    echo -e "${BLUE}📊 Diagnosis Summary${NC}"
    echo "==================="

    if [ $total_issues -eq 0 ]; then
        echo -e "${GREEN}🎉 All checks passed! Firebase Test Lab setup looks good.${NC}"
        echo ""
        echo -e "${BLUE}Next steps:${NC}"
        echo "1. Push your code to trigger GitHub Actions"
        echo "2. Or run tests manually: ./scripts/firebase_android.sh"
        echo "3. Monitor results in Firebase Console"
    else
        echo -e "${RED}❌ Found $total_issues issues that need attention.${NC}"
        echo ""
        echo -e "${BLUE}Recommended actions:${NC}"
        echo "1. Fix the issues listed above"
        echo "2. Re-run this diagnostic script"
        echo "3. Try a manual test build"
        echo ""
        echo -e "${YELLOW}Need help? Check the Firebase_Setup_Guide.md${NC}"
    fi
}

# Main execution
main() {
    local total_issues=0

    check_environment || total_issues=$((total_issues + $?))
    echo ""

    check_tools || total_issues=$((total_issues + $?))
    echo ""

    check_gcloud_auth || total_issues=$((total_issues + $?))
    echo ""

    check_firebase_apis || total_issues=$((total_issues + $?))
    echo ""

    check_project_structure || total_issues=$((total_issues + $?))
    echo ""

    check_dependencies || total_issues=$((total_issues + $?))
    echo ""

    if [ $total_issues -eq 0 ]; then
        test_apk_build || total_issues=$((total_issues + $?))
        echo ""

        test_firebase_connectivity || total_issues=$((total_issues + $?))
        echo ""
    fi

    generate_report $total_issues

    return $total_issues
}

# Run main function
main "$@"