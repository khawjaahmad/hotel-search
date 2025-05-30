#!/bin/bash

# Firebase Test Lab Setup Script
# This script helps set up Firebase Test Lab for the Hotel Booking project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔥 Firebase Test Lab Setup for Hotel Booking${NC}"
echo "=============================================="

# Check if gcloud is installed
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}❌ Google Cloud SDK not found${NC}"
        echo -e "${YELLOW}Install from: https://cloud.google.com/sdk/docs/install${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Google Cloud SDK found${NC}"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Flutter found${NC}"
}

# Check if Patrol CLI is installed
check_patrol() {
    if ! command -v patrol &> /dev/null; then
        echo -e "${YELLOW}⚠️ Patrol CLI not found, installing...${NC}"
        dart pub global activate patrol_cli
        export PATH="$PATH":"$HOME/.pub-cache/bin"
    fi
    echo -e "${GREEN}✅ Patrol CLI ready${NC}"
}

# Create Firebase project (if needed)
setup_firebase_project() {
    echo -e "${BLUE}📋 Firebase Project Setup${NC}"
    
    # List existing projects
    echo "Available Firebase projects:"
    gcloud projects list --format="table(projectId,name,projectNumber)"
    
    echo ""
    read -p "Enter your Firebase Project ID (or press Enter to create new): " PROJECT_ID
    
    if [ -z "$PROJECT_ID" ]; then
        echo "Creating new Firebase project..."
        read -p "Enter new project ID: " NEW_PROJECT_ID
        gcloud projects create "$NEW_PROJECT_ID"
        PROJECT_ID="$NEW_PROJECT_ID"
    fi
    
    # Set the project
    gcloud config set project "$PROJECT_ID"
    echo -e "${GREEN}✅ Project set to: $PROJECT_ID${NC}"
    
    # Enable required APIs
    echo -e "${BLUE}🔧 Enabling required APIs...${NC}"
    gcloud services enable testing.googleapis.com
    gcloud services enable toolresults.googleapis.com
    gcloud services enable firebase.googleapis.com
    
    echo -e "${GREEN}✅ APIs enabled${NC}"
}

# Create service account for GitHub Actions
setup_service_account() {
    echo -e "${BLUE}🔑 Setting up Service Account for GitHub Actions${NC}"
    
    local SERVICE_ACCOUNT_NAME="firebase-test-lab-sa"
    local SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
    
    # Create service account
    if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" &>/dev/null; then
        gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
            --display-name="Firebase Test Lab Service Account"
        echo -e "${GREEN}✅ Service account created${NC}"
    else
        echo -e "${YELLOW}ℹ️ Service account already exists${NC}"
    fi
    
    # Grant necessary roles
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/firebase.testlab.admin"
    
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/storage.admin"
    
    # Create and download key
    local KEY_FILE="firebase-service-account-key.json"
    gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SERVICE_ACCOUNT_EMAIL"
    
    echo -e "${GREEN}✅ Service account configured${NC}"
    echo -e "${YELLOW}📁 Key saved to: $KEY_FILE${NC}"
    echo -e "${BLUE}🔒 Add this key content to GitHub Secrets as: GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY${NC}"
}

# Create storage bucket for test results
setup_storage_bucket() {
    echo -e "${BLUE}🪣 Setting up Storage Bucket${NC}"
    
    local BUCKET_NAME="${PROJECT_ID}-test-results"
    
    if ! gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null; then
        gsutil mb "gs://$BUCKET_NAME"
        echo -e "${GREEN}✅ Storage bucket created: $BUCKET_NAME${NC}"
    else
        echo -e "${YELLOW}ℹ️ Storage bucket already exists${NC}"
    fi
}

# Test the setup with a simple build
test_setup() {
    echo -e "${BLUE}🧪 Testing the setup...${NC}"
    
    # Build APK to verify everything works
    flutter pub get
    patrol build android --target=integration_test/tests/dashboard_test.dart --release
    
    if [ -f "build/app/outputs/apk/debug/app-debug.apk" ] && [ -f "build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk" ]; then
        echo -e "${GREEN}✅ APK build successful${NC}"
    else
        echo -e "${RED}❌ APK build failed${NC}"
        exit 1
    fi
}

# Generate GitHub secrets information
generate_secrets_info() {
    echo -e "${BLUE}🔐 GitHub Secrets Setup${NC}"
    echo "Add these secrets to your GitHub repository:"
    echo ""
    echo -e "${YELLOW}FIREBASE_PROJECT_ID${NC}: $PROJECT_ID"
    echo -e "${YELLOW}GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY${NC}: [Content of firebase-service-account-key.json]"
    echo ""
    echo "To add secrets:"
    echo "1. Go to your GitHub repository"
    echo "2. Settings > Secrets and variables > Actions"
    echo "3. Click 'New repository secret'"
    echo "4. Add each secret with the exact name above"
}

# Main execution
main() {
    check_gcloud
    check_flutter
    check_patrol
    
    echo ""
    setup_firebase_project
    
    echo ""
    setup_service_account
    
    echo ""
    setup_storage_bucket
    
    echo ""
    test_setup
    
    echo ""
    generate_secrets_info
    
    echo ""
    echo -e "${GREEN}🎉 Firebase Test Lab setup completed!${NC}"
    echo -e "${BLUE}📚 Next steps:${NC}"
    echo "1. Add the GitHub secrets mentioned above"
    echo "2. Push your code to trigger the workflow"
    echo "3. Check the Actions tab in GitHub for test results"
}

# Run main function
main "$@"