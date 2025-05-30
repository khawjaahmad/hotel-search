# Firebase Test Lab Setup Guide for Hotel Booking App

This guide will help you set up Firebase Test Lab for running Android integration tests automatically.

## 🔥 Quick Setup

### 1. Prerequisites

- Google Cloud SDK installed
- Flutter SDK installed  
- Patrol CLI installed
- Firebase project created
- GitHub repository set up

### 2. Automated Setup

Run the setup script to configure everything automatically:

```bash
chmod +x scripts/setup_firebase.sh
./scripts/setup_firebase.sh
```

This script will:
- ✅ Check all prerequisites
- 🔥 Set up Firebase project
- 🔑 Create service account for GitHub Actions
- 🪣 Create storage bucket for test results
- 🧪 Test the build process
- 📋 Provide GitHub secrets configuration

### 3. Manual Setup (Alternative)

If you prefer manual setup:

#### Create Firebase Project
```bash
# Create new project
gcloud projects create your-hotel-booking-project

# Set as active project
gcloud config set project your-hotel-booking-project

# Enable required APIs
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
```

#### Create Service Account
```bash
# Create service account
gcloud iam service-accounts create firebase-test-lab-sa \
    --display-name="Firebase Test Lab Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding your-hotel-booking-project \
    --member="serviceAccount:firebase-test-lab-sa@your-hotel-booking-project.iam.gserviceaccount.com" \
    --role="roles/firebase.testlab.admin"

gcloud projects add-iam-policy-binding your-hotel-booking-project \
    --member="serviceAccount:firebase-test-lab-sa@your-hotel-booking-project.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create key file
gcloud iam service-accounts keys create firebase-key.json \
    --iam-account="firebase-test-lab-sa@your-hotel-booking-project.iam.gserviceaccount.com"
```

#### Create Storage Bucket
```bash
gsutil mb gs://your-hotel-booking-project-test-results
```

## 🔐 GitHub Secrets Configuration

Add these secrets to your GitHub repository:

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click **New repository secret**
3. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `FIREBASE_PROJECT_ID` | Your Firebase project ID |
| `GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY` | Contents of the service account JSON key file |

## 🧪 Running Tests

### GitHub Actions (Automatic)

Tests run automatically on:
- Push to `main`, `master`, or `develop` branches
- Pull requests to these branches
- Changes to relevant files (`lib/`, `integration_test/`, `android/`, etc.)

### Manual Execution

#### Local Testing
```bash
# Single test file
./scripts/firebase_android.sh integration_test/tests/dashboard_test.dart your-project-id

# Or set environment variable
export FIREBASE_PROJECT_ID=your-project-id
./scripts/firebase_android.sh integration_test/tests/hotels_test.dart
```

#### Direct gcloud Command
```bash
# Build APKs first
patrol build android --target=integration_test/tests/dashboard_test.dart --release

# Run on Firebase Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=shiba,version=34,locale=en,orientation=portrait \
  --timeout 15m \
  --project your-project-id
```

## 📱 Test Devices

Currently configured devices:
- **Pixel 8** (`shiba`, API 34)
- **Galaxy S24** (`e3q`, API 34)

### Available Device Models
```bash
# List all available devices
gcloud firebase test android models list

# Popular devices for testing:
# - shiba (Pixel 8, API 34)
# - e3q (Galaxy S24, API 34)  
# - oriole (Pixel 6, API 33)
# - panther (Pixel 7, API 33)
# - blueline (Pixel 3, API 30)
```

## 📊 Test Results

### Viewing Results

1. **Firebase Console**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/testlab/histories/
2. **Google Cloud Storage**: `gs://your-project-test-results/`
3. **GitHub Actions**: Check the Actions tab in your repository

### Result Files

- **Videos**: Screen recordings of test execution
- **Screenshots**: Screenshots at key points
- **Logs**: Detailed logcat output
- **Performance**: CPU, memory, and network metrics
- **Test Results**: JUnit-style XML reports

## 🔧 Configuration Files

### Key Files Created/Modified

- `.github/workflows/firebase_test_lab.yml` - GitHub Actions workflow
- `scripts/firebase_android.sh` - Manual test execution script
- `scripts/setup_firebase.sh` - Automated setup script
- `android/app/build.gradle` - Updated with Patrol test runner
- `patrol.yaml` - Patrol configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `FIREBASE_PROJECT_ID` | Your Firebase project ID | Yes |
| `GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY` | Service account JSON key | Yes (GitHub Actions) |
| `TEST_TARGET` | Specific test file to run | No (defaults to dashboard_test.dart) |

## ❗ Troubleshooting

### Common Issues

#### 1. "Project not found" Error
```bash
# Verify project exists
gcloud projects list

# Set correct project  
gcloud config set project your-correct-project-id
```

#### 2. "APIs not enabled" Error
```bash
# Enable required APIs
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
```

#### 3. "Permission denied" Error
```bash
# Check authentication
gcloud auth list

# Re-authenticate if needed
gcloud auth login
```

#### 4. APK Build Failures
```bash
# Clean and rebuild
flutter clean
flutter pub get
patrol build android --target=integration_test/tests/dashboard_test.dart --release
```

#### 5. GitHub Actions Authentication Issues
- Verify `GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY` secret is correctly set
- Ensure the service account has proper permissions
- Check that the JSON key is valid and not expired

### Debug Mode

Add debugging to scripts:
```bash
# Enable debug output
export DEBUG=1
./scripts/firebase_android.sh
```

### Log Analysis

```bash
# Download and analyze logs
gsutil -m cp -r gs://your-project-test-results/latest-run/* ./logs/
grep -r "ERROR\|FAIL" ./logs/
```

## 📈 Cost Optimization

### Test Lab Pricing
- **Virtual devices**: $1 per device hour
- **Physical devices**: $5 per device hour  
- **Free tier**: 10 tests/day on virtual devices

### Cost Reduction Tips
1. Use virtual devices for most testing
2. Limit test duration with `--timeout`
3. Run tests only on code changes
4. Use matrix testing strategically
5. Clean up old test results regularly

### Cleanup Script
```bash
# Remove old test results (older than 30 days)
gsutil -m rm -r $(gsutil ls gs://your-project-test-results/ | head -n -10)
```

## 🎯 Next Steps

1. Run the setup script: `./scripts/setup_firebase.sh`
2. Add GitHub secrets as instructed
3. Push code to trigger your first test run
4. Monitor results in Firebase Console
5. Optimize test coverage and device matrix as needed

## 📚 Additional Resources

- [Firebase Test Lab Documentation](https://firebase.google.com/docs/test-lab)
- [Patrol Documentation](https://patrol.leancode.co/)
- [Google Cloud SDK Documentation](https://cloud.google.com/sdk/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)