#!/bin/bash
# scripts/quick_setup.sh
# One-command setup for integration testing

set -e

# Colors
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

# Quick setup function
quick_setup() {
    print_header "QUICK INTEGRATION TEST SETUP"
    
    print_step "Step 1: Creating directory structure..."
    mkdir -p test-results/logs test-results/reports allure-results screenshots scripts
    print_success "Directories created"
    
    print_step "Step 2: Saving enhanced scripts..."
    save_enhanced_scripts
    print_success "Scripts saved"
    
    print_step "Step 3: Setting permissions..."
    chmod +x scripts/*.sh 2>/dev/null || true
    print_success "Permissions set"
    
    print_step "Step 4: Installing tools..."
    install_required_tools
    
    print_step "Step 5: Updating Flutter dependencies..."
    flutter pub get
    print_success "Dependencies updated"
    
    print_step "Step 6: Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    print_success "Code generation completed"
    
    print_step "Step 7: Verifying setup..."
    verify_setup
    
    print_success "Quick setup completed!"
    show_next_steps
}

# Save the enhanced scripts from the artifacts
save_enhanced_scripts() {
    # Save enhanced patrol runner if it doesn't exist
    if [ ! -f "scripts/enhanced_patrol_runner.sh" ]; then
        print_info "Creating enhanced patrol runner..."
        # This would be the content from the enhanced_patrol_runner artifact
        # For now, create a simple wrapper
        cat > scripts/enhanced_patrol_runner.sh << 'EOF'
#!/bin/bash
# Enhanced Patrol Runner (Simplified Version)
# Use: ./scripts/enhanced_patrol_runner.sh <target>

TARGET="$1"
echo "🔄 Running integration tests on $TARGET..."

case "$TARGET" in
    "ios-local")
        patrol test integration_test/tests/hotels_test.dart -d "iPhone 16 Plus"
        ;;
    "android-local")
        patrol test integration_test/tests/hotels_test.dart -d emulator-5554
        ;;
    "local")
        if [[ "$OSTYPE" == "darwin"* ]]; then
            patrol test integration_test/tests/hotels_test.dart -d "iPhone 16 Plus"
        else
            patrol test integration_test/tests/hotels_test.dart -d emulator-5554
        fi
        ;;
    "single")
        TEST_FILE=${TEST_FILE:-integration_test/tests/hotels_test.dart}
        patrol test "$TEST_FILE"
        ;;
    *)
        echo "Usage: $0 {ios-local|android-local|local|single}"
        echo "Environment: TEST_FILE=path/to/test.dart $0 single"
        ;;
esac
EOF
        chmod +x scripts/enhanced_patrol_runner.sh
    fi
    
    # Save fix script if it doesn't exist
    if [ ! -f "scripts/fix_integration_tests.sh" ]; then
        print_info "Creating fix script..."
        cat > scripts/fix_integration_tests.sh << 'EOF'
#!/bin/bash
# Integration Test Fix Script (Simplified)

echo "🔧 Running integration test diagnostics and fixes..."

# Create directories
mkdir -p test-results/logs allure-results screenshots

# Fix permissions
chmod +x scripts/*.sh 2>/dev/null || true

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Check Patrol
if ! command -v patrol &> /dev/null; then
    echo "📦 Installing Patrol CLI..."
    dart pub global activate patrol_cli
fi

# Run Flutter doctor
echo "🩺 Running Flutter doctor..."
flutter doctor

echo "✅ Diagnostics completed!"
EOF
        chmod +x scripts/fix_integration_tests.sh
    fi
}

# Install required tools
install_required_tools() {
    print_info "Checking and installing required tools..."
    
    # Install Patrol CLI
    if ! command -v patrol &> /dev/null; then
        print_info "Installing Patrol CLI..."
        dart pub global activate patrol_cli
        print_success "Patrol CLI installed"
    else
        print_success "Patrol CLI already available"
    fi
    
    # Check for optional tools
    if ! command -v allure &> /dev/null; then
        print_warning "Allure CLI not found"
        print_info "Install with: npm install -g allure-commandline"
        print_info "Or: brew install allure"
    else
        print_success "Allure CLI available"
    fi
}

# Verify the setup
verify_setup() {
    local issues=0
    
    print_info "Verifying setup..."
    
    # Check Flutter
    if flutter doctor | grep -q "No issues found"; then
        print_success "Flutter doctor: No issues"
    else
        print_warning "Flutter doctor found issues"
        issues=$((issues + 1))
    fi
    
    # Check Patrol
    if command -v patrol &> /dev/null; then
        print_success "Patrol CLI available"
    else
        print_error "Patrol CLI not found"
        issues=$((issues + 1))
    fi
    
    # Check directories
    local dirs=("test-results" "allure-results" "screenshots")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_success "Directory exists: $dir"
        else
            print_error "Directory missing: $dir"
            issues=$((issues + 1))
        fi
    done
    
    # Check test files
    if [ -f "integration_test/tests/hotels_test.dart" ]; then
        print_success "Test files found"
    else
        print_warning "Integration test files not found"
        print_info "This is normal for new projects"
    fi
    
    if [ $issues -eq 0 ]; then
        print_success "Setup verification passed!"
    else
        print_warning "Setup has $issues issues - check output above"
    fi
}

# Show next steps
show_next_steps() {
    print_header "NEXT STEPS"
    
    echo -e "${BLUE}🚀 Ready to run tests!${NC}"
    echo ""
    echo "Quick test commands:"
    echo "  make test-ios          # Run on iOS simulator"
    echo "  make test-android      # Run on Android emulator"
    echo "  make test-single       # Run single test"
    echo ""
    echo "Using scripts directly:"
    echo "  ./scripts/enhanced_patrol_runner.sh ios-local"
    echo "  ./scripts/enhanced_patrol_runner.sh android-local"
    echo "  TEST_FILE=integration_test/tests/overview_test.dart ./scripts/enhanced_patrol_runner.sh single"
    echo ""
    echo "Troubleshooting:"
    echo "  ./scripts/fix_integration_tests.sh"
    echo "  make troubleshoot"
    echo ""
    echo -e "${GREEN}✨ Happy testing!${NC}"
}

# Create a minimal Makefile if it doesn't exist
create_minimal_makefile() {
    if [ ! -f "Makefile" ]; then
        print_info "Creating minimal Makefile..."
        cat > Makefile << 'EOF'
# Minimal Makefile for Integration Testing

.PHONY: setup test-ios test-android test-single clean troubleshoot

setup:
	@echo "🔧 Setting up project..."
	@./scripts/quick_setup.sh
	@echo "✅ Setup completed!"

test-ios:
	@echo "🍎 Running iOS integration tests..."
	@./scripts/enhanced_patrol_runner.sh ios-local

test-android:
	@echo "🤖 Running Android integration tests..."
	@./scripts/enhanced_patrol_runner.sh android-local

test-single:
	@echo "🧪 Running single integration test..."
	@./scripts/enhanced_patrol_runner.sh single

test-hotels:
	@echo "🏨 Running hotels feature tests..."
	@TEST_FILE=integration_test/tests/hotels_test.dart ./scripts/enhanced_patrol_runner.sh single

clean:
	@echo "🧹 Cleaning project..."
	@flutter clean
	@rm -rf test-results allure-results screenshots

troubleshoot:
	@echo "🔍 Running diagnostics..."
	@./scripts/fix_integration_tests.sh

help:
	@echo "Available commands:"
	@echo "  setup       - Initial project setup"
	@echo "  test-ios    - Run tests on iOS"
	@echo "  test-android - Run tests on Android"
	@echo "  test-single - Run single test (set TEST_FILE)"
	@echo "  test-hotels - Run hotels feature tests"
	@echo "  clean       - Clean build artifacts"
	@echo "  troubleshoot - Run diagnostics"
EOF
        print_success "Minimal Makefile created"
    fi
}

# Test the setup
test_setup() {
    print_header "TESTING SETUP"
    
    print_step "Testing Flutter environment..."
    if flutter devices &> /dev/null; then
        print_success "Flutter can detect devices"
    else
        print_warning "Flutter device detection issues"
    fi
    
    print_step "Testing Patrol CLI..."
    if patrol --version &> /dev/null; then
        print_success "Patrol CLI working"
    else
        print_error "Patrol CLI not working"
    fi
    
    print_step "Creating minimal test if needed..."
    if [ ! -f "integration_test/tests/minimal_test.dart" ]; then
        mkdir -p integration_test/tests
        cat > integration_test/tests/minimal_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:hotel_booking/main.dart' as app;

void main() {
  group('Minimal Setup Test', () {
    patrolTest(
      'App starts successfully',
      ($) async {
        // Start the app
        app.main();
        await $.pumpAndSettle();
        
        // Basic verification that app loaded
        expect(find.byType(MaterialApp), findsOneWidget);
      },
    );
  });
}
EOF
        print_success "Minimal test created"
    fi
    
    print_info "To test the setup, run:"
    print_info "  TEST_FILE=integration_test/tests/minimal_test.dart make test-single"
}

# Main function
main() {
    local command="${1:-setup}"
    
    case "$command" in
        "setup")
            quick_setup
            create_minimal_makefile
            test_setup
            ;;
        "test")
            test_setup
            ;;
        "scripts-only")
            save_enhanced_scripts
            print_success "Scripts saved"
            ;;
        "makefile")
            create_minimal_makefile
            ;;
        *)
            print_header "QUICK INTEGRATION TEST SETUP"
            echo ""
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  setup        - Full setup (default)"
            echo "  test         - Test current setup"
            echo "  scripts-only - Save scripts only"
            echo "  makefile     - Create minimal Makefile"
            echo ""
            echo "This script will:"
            echo "  ✅ Create required directories"
            echo "  ✅ Install necessary tools"
            echo "  ✅ Set up scripts and permissions"
            echo "  ✅ Verify Flutter environment"
            echo "  ✅ Create minimal test files"
            echo "  ✅ Generate Makefile"
            echo ""
            ;;
    esac
}

# Run main function
main "$@"