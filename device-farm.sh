#!/bin/bash

# =============================================================================
# AWS Device Farm - Hotel Booking Patrol Tests (One-Step)
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ARN="arn:aws:devicefarm:us-west-2:593793041289:project:0177804d-42ab-44b5-9196-7e497e1585a9"
APP_APK="build/app/outputs/apk/debug/app-debug.apk"
TEST_APK="build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"

echo -e "${BLUE}🚀 Starting AWS Device Farm Test Run${NC}"

# Check if APKs exist
if [[ ! -f "$APP_APK" ]]; then
    echo -e "${RED}❌ App APK not found: $APP_APK${NC}"
    echo "Run: flutter build apk --debug"
    exit 1
fi

if [[ ! -f "$TEST_APK" ]]; then
    echo -e "${RED}❌ Test APK not found: $TEST_APK${NC}"
    echo "Run: patrol build android --target integration_test/tests/overview_test.dart"
    exit 1
fi

echo -e "${GREEN}✅ APKs found${NC}"

# 1. Upload App APK
echo -e "${BLUE}📤 Uploading app APK...${NC}"
APP_UPLOAD=$(aws devicefarm create-upload \
    --project-arn "$PROJECT_ARN" \
    --name "hotel-booking-app.apk" \
    --type "ANDROID_APP" \
    --output json)

APP_UPLOAD_ARN=$(echo $APP_UPLOAD | jq -r '.upload.arn')
APP_UPLOAD_URL=$(echo $APP_UPLOAD | jq -r '.upload.url')

echo "Uploading app APK to AWS..."
curl -T "$APP_APK" "$APP_UPLOAD_URL"

# 2. Upload Test APK
echo -e "${BLUE}📤 Uploading test APK...${NC}"
TEST_UPLOAD=$(aws devicefarm create-upload \
    --project-arn "$PROJECT_ARN" \
    --name "hotel-booking-test.apk" \
    --type "INSTRUMENTATION_TEST_PACKAGE" \
    --output json)

TEST_UPLOAD_ARN=$(echo $TEST_UPLOAD | jq -r '.upload.arn')
TEST_UPLOAD_URL=$(echo $TEST_UPLOAD | jq -r '.upload.url')

echo "Uploading test APK to AWS..."
curl -T "$TEST_APK" "$TEST_UPLOAD_URL"

# 3. Wait for uploads to complete
echo -e "${BLUE}⏳ Waiting for uploads to process...${NC}"
sleep 30

# 4. Get default device pool
echo -e "${BLUE}📱 Getting device pool...${NC}"
DEVICE_POOLS=$(aws devicefarm list-device-pools --arn "$PROJECT_ARN" --output json)
DEVICE_POOL_ARN=$(echo $DEVICE_POOLS | jq -r '.devicePools[] | select(.name == "Top Devices") | .arn')

if [[ "$DEVICE_POOL_ARN" == "null" ]]; then
    # Use first available device pool
    DEVICE_POOL_ARN=$(echo $DEVICE_POOLS | jq -r '.devicePools[0].arn')
fi

echo "Using device pool: $DEVICE_POOL_ARN"

# 5. Schedule test run
echo -e "${BLUE}🏃 Starting test run...${NC}"
RUN_RESULT=$(aws devicefarm schedule-run \
    --project-arn "$PROJECT_ARN" \
    --app-arn "$APP_UPLOAD_ARN" \
    --device-pool-arn "$DEVICE_POOL_ARN" \
    --name "hotel-booking-patrol-$(date +%Y%m%d-%H%M%S)" \
    --test type="INSTRUMENTATION",testPackageArn="$TEST_UPLOAD_ARN" \
    --output json)

RUN_ARN=$(echo $RUN_RESULT | jq -r '.run.arn')
RUN_NAME=$(echo $RUN_RESULT | jq -r '.run.name')

echo -e "${GREEN}✅ Test run scheduled!${NC}"
echo "Run ARN: $RUN_ARN"
echo "Run Name: $RUN_NAME"

# 6. Monitor test progress
echo -e "${BLUE}📊 Monitoring test progress...${NC}"
echo "You can also view progress at: https://us-west-2.console.aws.amazon.com/devicefarm/home"

while true; do
    RUN_STATUS=$(aws devicefarm get-run --arn "$RUN_ARN" --output json)
    STATUS=$(echo $RUN_STATUS | jq -r '.run.status')
    RESULT=$(echo $RUN_STATUS | jq -r '.run.result')
    
    echo "Status: $STATUS | Result: $RESULT"
    
    case $STATUS in
        "COMPLETED")
            if [[ "$RESULT" == "PASSED" ]]; then
                echo -e "${GREEN}🎉 Tests PASSED!${NC}"
            else
                echo -e "${RED}❌ Tests FAILED!${NC}"
            fi
            break
            ;;
        "RUNNING"|"PENDING"|"PROCESSING")
            echo "Test still running... (waiting 30s)"
            sleep 30
            ;;
        *)
            echo -e "${RED}❌ Test run failed with status: $STATUS${NC}"
            break
            ;;
    esac
done

# 7. Get results
echo -e "${BLUE}📋 Getting test results...${NC}"
aws devicefarm list-jobs --arn "$RUN_ARN" --output table

echo -e "${GREEN}✅ AWS Device Farm test completed!${NC}"
echo "View detailed results at: https://us-west-2.console.aws.amazon.com/devicefarm/home"