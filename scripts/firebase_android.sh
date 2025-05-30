name: Firebase Test Lab - Android Integration Tests

on:
  push:
    branches: [ main, master, develop ]
    paths:
      - 'lib/**'
      - 'integration_test/**'
      - 'android/**'
      - 'pubspec.yaml'
      - '.github/workflows/**'
  pull_request:
    branches: [ main, master, develop ]
    paths:
      - 'lib/**'
      - 'integration_test/**'
      - 'android/**'
      - 'pubspec.yaml'

jobs:
  android_integration_tests:
    name: Android Integration Tests on Firebase
    runs-on: ubuntu-latest
    timeout-minutes: 45
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
          cache: true

      - name: Setup Patrol CLI
        run: |
          dart pub global activate patrol_cli
          echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH

      - name: Install Dependencies
        run: flutter pub get

      - name: Generate Code
        run: dart run build_runner build

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{secrets.GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY}}

      - name: Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{secrets.FIREBASE_PROJECT_ID}}

      - name: Enable Firebase Test Lab API
        run: |
          gcloud services enable testing.googleapis.com
          gcloud services enable toolresults.googleapis.com

      - name: Build Android APKs for Testing
        env:
          TEST_TARGET: integration_test/tests/dashboard_test.dart
        run: |
          echo "Building APKs for Firebase Test Lab..."
          patrol build android --target="$TEST_TARGET" --release

      - name: Verify APK Files
        run: |
          echo "Checking for APK files..."
          ls -la build/app/outputs/apk/debug/ || echo "Debug APK directory not found"
          ls -la build/app/outputs/apk/androidTest/debug/ || echo "Test APK directory not found"
          
          if [ ! -f "build/app/outputs/apk/debug/app-debug.apk" ]; then
            echo "❌ Main APK not found"
            exit 1
          fi
          
          if [ ! -f "build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk" ]; then
            echo "❌ Test APK not found"
            exit 1
          fi
          
          echo "✅ Both APK files found"

      - name: Run Tests on Firebase Test Lab
        env:
          FIREBASE_PROJECT_ID: ${{ secrets.FIREBASE_PROJECT_ID }}
        run: |
          echo "🚀 Running Android tests on Firebase Test Lab..."
          
          gcloud firebase test android run \
            --type instrumentation \
            --app build/app/outputs/apk/debug/app-debug.apk \
            --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
            --device model=shiba,version=34,locale=en,orientation=portrait \
            --device model=e3q,version=34,locale=en,orientation=portrait \
            --timeout 15m \
            --results-bucket=${FIREBASE_PROJECT_ID}-test-results \
            --results-dir=android-$(date +%Y%m%d-%H%M%S) \
            --environment-variables clearPackageData=true \
            --use-orchestrator \
            --record-video \
            --performance-metrics \
            --project $FIREBASE_PROJECT_ID

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: firebase-test-results
          path: |
            firebase-test-results.json
            test-results/
          retention-days: 30

  # Parallel job for multiple test files
  android_integration_tests_parallel:
    name: Android Tests (Parallel)
    runs-on: ubuntu-latest
    timeout-minutes: 45
    strategy:
      fail-fast: false
      matrix:
        test_target:
          - integration_test/tests/dashboard_test.dart
          - integration_test/tests/hotels_test.dart
          - integration_test/tests/account_test.dart
          - integration_test/tests/overview_test.dart
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
          cache: true

      - name: Setup Patrol CLI
        run: |
          dart pub global activate patrol_cli
          echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH

      - name: Install Dependencies
        run: flutter pub get

      - name: Generate Code
        run: dart run build_runner build

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY }}

      - name: Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{ secrets.FIREBASE_PROJECT_ID }}

      - name: Run Individual Test on Firebase
        env:
          TEST_TARGET: ${{ matrix.test_target }}
          FIREBASE_PROJECT_ID: ${{ secrets.FIREBASE_PROJECT_ID }}
        run: |
          echo "🧪 Testing: $TEST_TARGET"
          
          # Build APKs for specific test
          patrol build android --target="$TEST_TARGET" --release
          
          # Run on Firebase Test Lab
          gcloud firebase test android run \
            --type instrumentation \
            --app build/app/outputs/apk/debug/app-debug.apk \
            --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
            --device model=shiba,version=34,locale=en,orientation=portrait \
            --timeout 10m \
            --results-bucket=${FIREBASE_PROJECT_ID}-test-results \
            --results-dir=android-$(basename $TEST_TARGET .dart)-$(date +%Y%m%d-%H%M%S) \
            --environment-variables clearPackageData=true \
            --use-orchestrator \
            --project $FIREBASE_PROJECT_ID