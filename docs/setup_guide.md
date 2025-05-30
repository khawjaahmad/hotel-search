# 🚀 Setup & Installation Guide

Complete setup guide for the Hotel Booking QA Automation Framework with Patrol.

## 📋 Prerequisites Checklist

Before starting, ensure you have the following installed:

### Required Tools

| Tool | Version | Download Link | Purpose |
|------|---------|---------------|---------|
| **Flutter** | 3.6.0+ | [flutter.dev](https://flutter.dev/docs/get-started/install) | Mobile framework |
| **Dart** | 3.0.0+ | Included with Flutter | Programming language |
| **Git** | Latest | [git-scm.com](https://git-scm.com/) | Version control |
| **VS Code/Android Studio** | Latest | IDE of choice | Development environment |

### Platform-Specific Requirements

#### macOS (for iOS testing)

- **Xcode** 15.0+ from App Store
- **iOS Simulator** (included with Xcode)
- **CocoaPods**: `sudo gem install cocoapods`

#### Windows/Linux (Android only)
- **Android Studio** with Android SDK
- **Java JDK** 17+ 
- **Android Emulator** or physical device

### Testing Tools

- **Patrol CLI**: `dart pub global activate patrol_cli`
- **Node.js** 18+ (for Allure reports): [nodejs.org](https://nodejs.org/)

## 🔧 Step-by-Step Installation

### 1. Flutter Installation

#### macOS
```bash
# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.6.0-stable.zip

# Extract and add to PATH
unzip flutter_macos_3.6.0-stable.zip
sudo mv flutter /usr/local/

# Add to shell profile (.zshrc or .bash_profile)
echo 'export PATH="/usr/local/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter doctor
```

#### Windows
```powershell
# Download Flutter SDK from flutter.dev
# Extract to C:\flutter
# Add C:\flutter\bin to System PATH

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.6.0-stable.tar.xz

# Extract and add to PATH
tar xf flutter_linux_3.6.0-stable.tar.xz
sudo mv flutter /opt/

# Add to ~/.bashrc
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor
```

### 2. Project Setup

```bash
# Clone the repository
git clone https://github.com/your-org/hotel-booking.git
cd hotel-booking

# Install dependencies
flutter pub get

# Generate code (build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Verify project setup
flutter analyze
```

### 3. Patrol CLI Installation

```bash
# Install Patrol CLI globally
dart pub global activate patrol_cli

# Verify installation
patrol --version

# Setup Patrol for the project
patrol setup
```

### 4. Device Setup

#### iOS Simulator (macOS only)
```bash
# List available simulators
xcrun simctl list devices

# Create iPhone 16 Plus simulator (if not exists)
xcrun simctl create "iPhone 16 Plus" "iPhone 16 Plus" "iOS 18.4"

# Boot the simulator
xcrun simctl boot "iPhone 16 Plus"

# Open Simulator app
open -a Simulator
```

#### Android Emulator
```bash
# List available AVDs
avdmanager list avd

# Create Pixel_7 AVD (if not exists)
avdmanager create avd -n Pixel_7 -k "system-images;android-34;google_apis;x86_64"

# Start emulator
emulator -avd Pixel_7

# Verify device connection
adb devices
```

### 5. Additional Tools

#### Node.js & Allure (for advanced reporting)
```bash
# Install Node.js (visit nodejs.org or use package manager)
# macOS with Homebrew
brew install node

# Install project dependencies
npm install

# Install Allure CLI globally
npm install -g allure-commandline

# Verify installation
allure --version
```

## 🔒 Environment Configuration

### 1. API Keys Setup

Create a `.env` file in the project root:
```bash
# .env file
SERPAPI_API_KEY=your_serpapi_key_here
```

Generate the environment file:
```bash
flutter pub run build_runner build
```

### 2. Firebase Configuration (Optional)

For Firebase Test Lab integration:
```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Initialize gcloud
gcloud init

# Set project
gcloud config set project your-firebase-project-id

# Authenticate
gcloud auth login
gcloud auth application-default login
```

### 3. IDE Configuration

#### VS Code Extensions
```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "streetsidesoftware.code-spell-checker"
  ]
}
```

#### VS Code Settings
```json
{
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": false,
  "dart.showTodos": true,
  "dart.runPubGetOnPubspecChanges": true,
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": "off"
  }
}
```

## ✅ Verification Steps

### 1. Flutter Doctor Check
```bash
flutter doctor -v
```

Expected output should show:
- ✅ Flutter (Channel stable, 3.6.0+)
- ✅ Android toolchain
- ✅ Xcode (macOS only)
- ✅ VS Code/Android Studio
- ✅ Connected device

### 2. Project Health Check
```bash
# Analyze code
flutter analyze

# Run unit tests
flutter test test/unit/

# Check dependencies
flutter pub deps
```

### 3. Patrol Verification
```bash
# Check Patrol installation
patrol doctor

# Verify device connectivity
patrol devices

# Run a simple test
patrol test integration_test/tests/overview_test.dart
```

## 🛠️ Makefile Commands

The project includes a comprehensive Makefile for automation:

### Setup Commands
```bash
make setup              # Complete project setup
make clean              # Clean all artifacts
make help               # Show all available commands
```

### Testing Commands
```bash
make unit               # Run unit tests
make widget             # Run widget tests  
make test-all           # Run all tests
make coverage           # Run with coverage
make allure-test        # Run with Allure reporting
```

### Usage Examples
```bash
# First time setup
make setup

# Daily development workflow
make unit               # Quick validation
patrol test             # Integration tests

# Before PR submission
make test-all           # Full test suite
make coverage           # Verify coverage
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
# Android SDK not found
flutter config --android-sdk /path/to/android/sdk

# iOS deployment issues (macOS)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### 2. Patrol Installation Issues
```bash
# Reset Patrol
dart pub global deactivate patrol_cli
dart pub global activate patrol_cli

# Clean Patrol cache
patrol clean
```

#### 3. Build Issues
```bash
# Clean Flutter
flutter clean
flutter pub get

# Regenerate code
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 4. Device Connection Issues
```bash
# Android
adb kill-server
adb start-server
adb devices

# iOS Simulator
xcrun simctl shutdown all
xcrun simctl boot "iPhone 16 Plus"
```

### Performance Optimization

#### 1. Build Performance
```bash
# Enable parallel builds
export FLUTTER_BUILD_PARALLEL=true

# Use more memory for Gradle
export GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=2g"
```

#### 2. Test Performance
```bash
# Run tests in parallel
patrol test --parallel

# Skip slow tests during development
flutter test --exclude-tags slow
```

## 📋 Pre-Test Checklist

Before running integration tests, verify:

- [ ] Flutter doctor shows no issues
- [ ] Patrol CLI is installed and working
- [ ] Target device/simulator is running
- [ ] Environment variables are set
- [ ] Project builds without errors
- [ ] Unit tests pass

Run the pre-test check script:
```bash
./pre_test_check.sh
```

## 🔄 Update Procedure

### Updating Flutter
```bash
# Update Flutter
flutter upgrade

# Update dependencies
flutter pub upgrade

# Regenerate code if needed
flutter pub run build_runner build --delete-conflicting-outputs
```

### Updating Patrol
```bash
# Update Patrol CLI
dart pub global activate patrol_cli

# Update project dependencies
flutter pub upgrade patrol

# Verify update
patrol --version
```

## 🆘 Getting Help

If you encounter issues:

1. **Check Documentation**: Review relevant docs in `docs/` folder
2. **Search Issues**: Check GitHub Issues for similar problems
3. **Run Diagnostics**: Use `flutter doctor` and `patrol doctor`
4. **Ask for Help**: Create a GitHub Issue with:
   - Operating system and version
   - Flutter version (`flutter --version`)
   - Patrol version (`patrol --version`)
   - Error messages and logs
   - Steps to reproduce

## 🎯 Next Steps

After successful setup:

1. **[Read Test Writing Guide](../testing/writing-tests.md)** - Learn to write effective tests
2. **[Explore CI/CD Integration](../ci-cd/overview.md)** - Set up continuous integration
3. **[Review Best Practices](../testing/best-practices.md)** - Follow testing guidelines
4. **[Configure Reporting](../reporting/allure-setup.md)** - Set up advanced reporting

---

**Setup Complete! 🎉**  
You're now ready to run comprehensive tests on the Hotel Booking application.