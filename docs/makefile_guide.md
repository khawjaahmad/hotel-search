# 🛠️ Makefile Commands Guide

Complete guide to using the Makefile automation in the Hotel Booking QA Framework.

## 📋 Overview

The Makefile provides streamlined commands for development, testing, and CI/CD operations. It's designed to simplify complex workflows into single commands.

## 🎯 Quick Reference

```bash
make help                    # Show all available commands
make setup                   # Complete project setup
make clean                   # Clean all artifacts
make test-all               # Run all unit + widget tests
make coverage               # Run tests with coverage report
patrol test                 # Run integration tests (Patrol CLI)
```

## 📚 Command Categories

### 🔧 Setup & Utilities

#### `make setup`
**Purpose**: Complete project initialization and dependency setup.

```bash
make setup
```

**What it does**:
- Installs Flutter dependencies (`flutter pub get`)
- Creates necessary directories (`coverage`, `allure-results`, etc.)
- Verifies project structure
- Sets up development environment

**When to use**: First time setup, after cloning repository, or when dependencies change.

#### `make clean`
**Purpose**: Clean all build artifacts and generated files.

```bash
make clean
```

**What it does**:
- Runs `flutter clean`
- Removes coverage reports (`coverage/`)
- Clears Allure results (`allure-results/`, `allure-report/`)
- Deletes test output (`test-results/`)
- Cleans build directories (`build/`)
- Recreates necessary directories

**When to use**: Before fresh builds, when experiencing build issues, or for repository cleanup.

#### `make help`
**Purpose**: Display all available commands with descriptions.

```bash
make help
```

**Output Example**:
```
=============================================================================
                    HOTEL BOOKING QA AUTOMATION                             
=============================================================================

🧪 UNIT & WIDGET TESTS:
  make unit                     - Run unit tests
  make widget                   - Run widget tests
  make test-all                 - Run unit + widget tests
  make coverage                 - Run tests with coverage report
  make allure-test              - Run tests with Allure reporting

📱 INTEGRATION TESTS (Patrol CLI):
  patrol test                   - Run all integration tests
  patrol test -t overview_test.dart      - Run specific test
  patrol test --device="iPhone 16 Plus" - Run on specific device
  patrol test --coverage        - Run with coverage

☁️ FIREBASE TEST LAB:
  ./scripts/firebase_android.sh - Run Android tests on Firebase
  ./scripts/firebase_ios.sh     - iOS tests (placeholder - needs code signing)

🔧 UTILITIES:
  make setup                    - Setup dependencies
  make clean                    - Clean all artifacts
```

### 🧪 Unit & Widget Tests

#### `make unit`
**Purpose**: Run unit tests only (business logic validation).

```bash
make unit
```

**What it does**:
- Executes `flutter test test/unit/`
- Tests domain logic, use cases, repositories
- Fast execution (~2 minutes)
- No UI component testing

**Output Example**:
```
🧪 Running unit tests...
00:02 +115: All tests passed!
✅ Unit tests completed
```

#### `make widget`
**Purpose**: Run widget tests only (UI component validation).

```bash
make widget
```

**What it does**:
- Executes `flutter test test/widgets/`
- Tests UI components, pages, navigation
- Medium execution time (~3 minutes)
- Widget rendering validation

**Output Example**:
```
🎯 Running widget tests...
00:03 +45: All tests passed!
✅ Widget tests completed
```

#### `make test-all`
**Purpose**: Run complete unit and widget test suite.

```bash
make test-all
```

**What it does**:
- Executes `flutter test` (all test directories)
- Combines unit + widget tests
- Complete validation (~5 minutes)
- Comprehensive test coverage

**Output Example**:
```
🧪 Running all unit and widget tests...
00:05 +160: All tests passed!
✅ All tests completed
```

### 📊 Coverage & Reporting

#### `make coverage`
**Purpose**: Run tests with coverage analysis and HTML report generation.

```bash
make coverage
```

**What it does**:
- Executes `flutter test --coverage`
- Generates `coverage/lcov.info`
- Creates HTML report (if `genhtml` is available)
- Opens report in browser automatically
- Shows coverage percentages

**Output Example**:
```
📊 Running tests with coverage...
00:05 +160: All tests passed!
Generating coverage report...
Overall coverage: 92.3%
📊 Coverage report: coverage/html/index.html
✅ Coverage completed
```

**Requirements**:
- `genhtml` (install with `brew install lcov` on macOS)
- Web browser for viewing reports

#### `make allure-test`
**Purpose**: Run tests with advanced Allure reporting.

```bash
make allure-test
```

**What it does**:
- Executes `flutter test --machine > test-results.json`
- Converts results to Allure format
- Generates interactive Allure report
- Serves report in browser

**Output Example**:
```
🧪 Running tests with Allure...
📊 Allure results generated
Serving Allure report at http://localhost:45678
✅ Allure test completed
```

**Requirements**:
- Node.js and npm
- Allure CLI (`npm install -g allure-commandline`)
- Custom conversion script (`scripts/convert_to_allure.js`)

## 📱 Integration Tests (Patrol)

Integration tests use the Patrol CLI directly, not Makefile commands:

### Basic Patrol Commands

```bash
# Run all integration tests
patrol test

# Run specific test file
patrol test integration_test/tests/hotels_test.dart

# Run with specific device
patrol test --device "iPhone 16 Plus"
patrol test --device "Pixel_7"

# Run with coverage
patrol test --coverage

# Run with verbose output
patrol test --verbose
```

### Advanced Patrol Usage

```bash
# Parallel execution
patrol test --parallel

# Custom timeout
patrol test --timeout 900

# Debug mode with screenshots
patrol test --debug --screenshots

# Run specific test by name
patrol test --name "Hotels search functionality"

# Run tests with tags
patrol test --tag demo
```

## ☁️ Firebase Test Lab Integration

### Android Firebase Testing
```bash
./scripts/firebase_android.sh
```

**What it does**:
- Builds Android APKs using Patrol
- Uploads to Firebase Test Lab
- Runs tests on multiple real devices
- Generates cloud test reports

**Prerequisites**:
- Google Cloud SDK installed
- Firebase project configured
- Authentication set up

### iOS Firebase Testing
```bash
./scripts/firebase_ios.sh
```

**Note**: iOS Firebase testing requires additional setup including code signing and provisioning profiles.

## 🔄 Workflow Examples

### Daily Development Workflow
```bash
# Start of day - quick validation
make unit

# After code changes - full validation
make test-all

# Before commit - comprehensive check
make coverage
patrol test integration_test/tests/relevant_test.dart
```

### Pre-Release Workflow
```bash
# Clean environment
make clean

# Full setup
make setup

# Complete test suite
make test-all
make coverage

# Integration tests
patrol test

# Advanced reporting
make allure-test
```

### CI/CD Pipeline Workflow
```bash
# Setup (CI environment)
make setup

# Unit tests (parallel job 1)
make unit

# Widget tests (parallel job 2)  
make widget

# Coverage analysis (parallel job 3)
make coverage

# Integration tests (parallel job 4)
patrol test --parallel

# Firebase testing (parallel job 5)
./scripts/firebase_android.sh
```

## ⚙️ Customization

### Environment Variables

The Makefile uses several environment variables for customization:

```bash
# Flutter build optimization
export FLUTTER_BUILD_PARALLEL=true

# Gradle memory settings
export GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=2g"

# Test execution settings
export PATROL_MAX_PARALLEL=4
export PATROL_TIMEOUT=600
```

### Custom Targets

You can extend the Makefile with custom targets:

```makefile
# Add to Makefile
test-hotels: ## Run hotel-specific tests only
	@echo "$(BLUE)🏨 Running hotel tests...$(NC)"
	@flutter test test/unit/features/hotels/
	@flutter test test/widgets/pages/hotels_page_test.dart
	@patrol test integration_test/tests/hotels_test.dart
	@echo "$(GREEN)✅ Hotel tests completed$(NC)"

test-favorites: ## Run favorites-specific tests only
	@echo "$(BLUE)❤️ Running favorites tests...$(NC)"
	@flutter test test/unit/features/favorites/
	@flutter test test/widgets/pages/favorites_page_test.dart
	@echo "$(GREEN)✅ Favorites tests completed$(NC)"
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Command Not Found
```bash
# Error: make: command not found
# Solution: Install make (usually pre-installed on macOS/Linux)

# macOS
xcode-select --install

# Ubuntu/Debian
sudo apt-get install build-essential

# Windows (use WSL or install make)
choco install make
```

#### 2. Flutter Command Issues
```bash
# Error: flutter: command not found
# Solution: Ensure Flutter is in PATH

# Check Flutter installation
flutter doctor

# Add to PATH (example for zsh)
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

#### 3. Coverage Tools Missing
```bash
# Error: genhtml: command not found
# Solution: Install lcov

# macOS
brew install lcov

# Ubuntu/Debian
sudo apt-get install lcov

# Check installation
genhtml --version
```

#### 4. Permission Issues
```bash
# Error: Permission denied
# Solution: Fix file permissions

chmod +x scripts/*.sh
chmod +x pre_test_check.sh
```

### Debug Mode

Enable debug output for troubleshooting:

```bash
# Run make with debug output
make -d coverage

# Check specific variables
make -n test-all
```

## 📊 Performance Optimization

### Parallel Execution
```makefile
# Run tests in parallel (custom target)
test-parallel: ## Run all test types in parallel
	@echo "$(BLUE)🚀 Running tests in parallel...$(NC)"
	@make unit &
	@make widget &
	@wait
	@echo "$(GREEN)✅ Parallel tests completed$(NC)"
```

### Cached Builds
```bash
# Enable Flutter build caching
export FLUTTER_BUILD_CACHE=true

# Use ccache for C++ compilation (if available)
export CCACHE_DIR=~/.ccache
```

## 📈 Metrics and Monitoring

### Test Execution Time Tracking
```bash
# Time individual commands
time make unit
time make widget
time make coverage

# Full pipeline timing
time make test-all
```

### Coverage Targets
```makefile
check-coverage: ## Verify coverage meets minimum threshold
	@echo "$(BLUE)📊 Checking coverage threshold...$(NC)"
	@COVERAGE=$$(grep -o 'SF:[0-9]*' coverage/lcov.info | wc -l); \
	if [ $$COVERAGE -lt 90 ]; then \
		echo "$(RED)❌ Coverage below threshold: $$COVERAGE% < 90%$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ Coverage meets threshold: $$COVERAGE% >= 90%$(NC)"; \
	fi
```

## 🔐 Security Considerations

### Sensitive Data Handling
```makefile
# Never commit API keys in Makefile
setup-env: ## Setup environment variables securely
	@echo "$(BLUE)🔒 Setting up environment...$(NC)"
	@if [ ! -f .env ]; then \
		echo "SERPAPI_API_KEY=your-key-here" > .env; \
		echo "$(YELLOW)⚠️  Please update .env with real API keys$(NC)"; \
	fi
```

### Secure Test Execution
```bash
# Run tests without exposing sensitive data
make test-all 2>&1 | grep -v "API_KEY"
```

## 📚 Best Practices

### 1. Command Usage
- ✅ Use `make help` to discover available commands
- ✅ Run `make setup` after cloning or major changes
- ✅ Use `make clean` when experiencing build issues
- ✅ Combine commands for comprehensive validation

### 2. Development Workflow
- ✅ `make unit` for quick feedback during development
- ✅ `make test-all` before committing changes
- ✅ `make coverage` to maintain quality standards
- ✅ `patrol test` for integration validation

### 3. CI/CD Integration
- ✅ Use separate jobs for different test types
- ✅ Cache dependencies between runs
- ✅ Generate artifacts for later analysis
- ✅ Fail fast on critical test failures

### 4. Performance
- ✅ Monitor test execution times
- ✅ Use parallel execution where possible
- ✅ Cache build artifacts
- ✅ Optimize test selection for development

---

**Makefile Mastery Complete! 🛠️**  
You now have full control over the automated build and test processes.