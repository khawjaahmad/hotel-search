#!/bin/bash

# =============================================================================
# GITHUB ACTIONS FIREBASE TEST TRIGGER SCRIPT
# =============================================================================
# This script provides easy triggering of Firebase Test Lab via GitHub Actions
# Supports various trigger modes and device configurations
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
WORKFLOW_FILE="firebase-tests.yml"
REPO_URL="https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')"

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
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not found. Please install from: https://cli.github.com/"
        exit 1
    fi
    
    # Check authentication
    if ! gh auth status &> /dev/null; then
        print_warning "Not authenticated with GitHub. Running authentication..."
        gh auth login
    fi
    
    print_success "Prerequisites check completed"
}

# Show workflow status
show_workflow_status() {
    print_header "📊 GITHUB ACTIONS WORKFLOW STATUS"
    
    print_step "Fetching recent workflow runs..."
    
    gh run list --workflow="$WORKFLOW_FILE" --limit=10 || {
        print_warning "Could not fetch workflow runs. Checking if workflow exists..."
        gh workflow list | grep -q "$WORKFLOW_FILE" || print_error "Workflow file $WORKFLOW_FILE not found in repository"
    }
}

# Trigger workflow with parameters
trigger_workflow() {
    local platform="$1"
    local device_matrix="$2"
    local wait_for_completion="$3"
    
    print_step "Triggering Firebase Test Lab workflow..."
    print_info "Platform: $platform"
    print_info "Device Matrix: $device_matrix"
    
    # Trigger the workflow
    local run_output
    run_output=$(gh workflow run "$WORKFLOW_FILE" \
        --field test_platform="$platform" \
        --field device_matrix="$device_matrix" \
        2>&1)
    
    if [[ $? -eq 0 ]]; then
        print_success "Workflow triggered successfully"
        
        # Extract run ID if possible
        sleep 3
        local latest_run_id=$(gh run list --workflow="$WORKFLOW_FILE" --limit=1 --json databaseId --jq '.[0].databaseId')
        
        if [[ -n "$latest_run_id" ]]; then
            local run_url="$REPO_URL/actions/runs/$latest_run_id"
            print_info "Workflow URL: $run_url"
            
            # Open in browser if possible
            if command -v open &> /dev/null; then
                open "$run_url"
            elif command -v xdg-open &> /dev/null; then
                xdg-open "$run_url"
            fi
            
            # Wait for completion if requested
            if [[ "$wait_for_completion" == "true" ]]; then
                print_step "Waiting for workflow completion..."
                gh run watch "$latest_run_id"
                
                # Show final status
                local final_status=$(gh run view "$latest_run_id" --json status,conclusion --jq '.conclusion')
                case "$final_status" in
                    "success")
                        print_success "Workflow completed successfully! ✅"
                        ;;
                    "failure")
                        print_error "Workflow failed ❌"
                        print_info "Check the logs: gh run view $latest_run_id"
                        ;;
                    "cancelled")
                        print_warning "Workflow was cancelled ⏹️"
                        ;;
                    *)
                        print_info "Workflow status: $final_status"
                        ;;
                esac
            else
                print_info "Workflow is running in the background"
                print_info "Monitor progress: gh run watch $latest_run_id"
            fi
        fi
    else
        print_error "Failed to trigger workflow"
        echo "$run_output"
        exit 1
    fi
}

# Quick trigger functions
trigger_both_platforms() {
    local device_matrix="${1:-standard}"
    local wait="${2:-false}"
    
    print_header "🚀 TRIGGERING BOTH PLATFORMS"
    trigger_workflow "both" "$device_matrix" "$wait"
}

trigger_ios_only() {
    local device_matrix="${1:-standard}"
    local wait="${2:-false}"
    
    print_header "🍎 TRIGGERING IOS ONLY"
    trigger_workflow "ios" "$device_matrix" "$wait"
}

trigger_android_only() {
    local device_matrix="${1:-standard}"
    local wait="${2:-false}"
    
    print_header "🤖 TRIGGERING ANDROID ONLY"
    trigger_workflow "android" "$device_matrix" "$wait"
}

# Batch testing modes
trigger_comprehensive_testing() {
    print_header "🎯 COMPREHENSIVE TESTING MODE"
    
    print_info "This will trigger multiple test runs with different configurations"
    print_warning "This may consume significant Firebase Test Lab quota"
    
    read -p "Continue with comprehensive testing? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Comprehensive testing cancelled"
        return
    fi
    
    # Trigger minimal tests first
    print_step "Step 1/3: Minimal device testing..."
    trigger_workflow "both" "minimal" "false"
    sleep 10
    
    # Trigger standard tests
    print_step "Step 2/3: Standard device testing..."
    trigger_workflow "both" "standard" "false"
    sleep 10
    
    # Trigger extended tests
    print_step "Step 3/3: Extended device testing..."
    trigger_workflow "both" "extended" "false"
    
    print_success "Comprehensive testing triggered!"
    print_info "Monitor all runs: gh run list --workflow=$WORKFLOW_FILE"
}

trigger_regression_testing() {
    print_header "🔄 REGRESSION TESTING MODE"
    
    print_info "This will trigger focused regression tests on key devices"
    
    # Trigger iOS regression
    print_step "Triggering iOS regression tests..."
    trigger_workflow "ios" "standard" "false"
    sleep 5
    
    # Trigger Android regression  
    print_step "Triggering Android regression tests..."
    trigger_workflow "android" "standard" "false"
    
    print_success "Regression testing triggered!"
}

# Monitoring and management
monitor_active_runs() {
    print_header "👀 MONITORING ACTIVE RUNS"
    
    print_step "Fetching active workflow runs..."
    
    local active_runs=$(gh run list --workflow="$WORKFLOW_FILE" --status="in_progress" --limit=10)
    
    if [[ -z "$active_runs" ]]; then
        print_info "No active workflow runs found"
        return
    fi
    
    echo "$active_runs"
    echo ""
    
    # Ask which run to monitor
    read -p "Enter run ID to monitor (or press Enter to skip): " run_id
    
    if [[ -n "$run_id" ]]; then
        print_step "Monitoring run: $run_id"
        gh run watch "$run_id"
    fi
}

cancel_active_runs() {
    print_header "⏹️ CANCEL ACTIVE RUNS"
    
    print_step "Fetching active workflow runs..."
    
    local active_runs=$(gh run list --workflow="$WORKFLOW_FILE" --status="in_progress" --json databaseId,displayTitle --jq '.[] | "\(.databaseId) - \(.displayTitle)"')
    
    if [[ -z "$active_runs" ]]; then
        print_info "No active workflow runs to cancel"
        return
    fi
    
    echo "$active_runs"
    echo ""
    
    print_warning "This will cancel ALL active Firebase Test Lab runs"
    read -p "Continue? [y/N]: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        gh run list --workflow="$WORKFLOW_FILE" --status="in_progress" --json databaseId --jq '.[].databaseId' | while read -r run_id; do
            print_step "Cancelling run: $run_id"
            gh run cancel "$run_id"
        done
        print_success "All active runs cancelled"
    else
        print_info "Cancellation aborted"
    fi
}

# Results and reporting
download_latest_artifacts() {
    print_header "📥 DOWNLOAD LATEST ARTIFACTS"
    
    print_step "Fetching latest completed run..."
    
    local latest_run_id=$(gh run list --workflow="$WORKFLOW_FILE" --status="completed" --limit=1 --json databaseId --jq '.[0].databaseId')
    
    if [[ -z "$latest_run_id" ]]; then
        print_warning "No completed runs found"
        return
    fi
    
    print_info "Latest run ID: $latest_run_id"
    
    # Create download directory
    local download_dir="firebase-artifacts-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$download_dir"
    
    print_step "Downloading artifacts to: $download_dir"
    
    # Download all artifacts
    gh run download "$latest_run_id" --dir "$download_dir"
    
    print_success "Artifacts downloaded to: $download_dir"
    
    # List downloaded content
    print_info "Downloaded content:"
    ls -la "$download_dir"
}

view_latest_results() {
    print_header "📊 VIEW LATEST RESULTS"
    
    print_step "Fetching latest run details..."
    
    local latest_run_id=$(gh run list --workflow="$WORKFLOW_FILE" --limit=1 --json databaseId --jq '.[0].databaseId')
    
    if [[ -z "$latest_run_id" ]]; then
        print_warning "No workflow runs found"
        return
    fi
    
    # Show run details
    gh run view "$latest_run_id"
    
    echo ""
    print_info "View full logs: gh run view $latest_run_id --log"
    print_info "Download artifacts: gh run download $latest_run_id"
}

# Configuration and setup
setup_workflow_triggers() {
    print_header "⚙️ SETUP WORKFLOW TRIGGERS"
    
    print_info "This will help you configure automated triggers for your workflow"
    
    # Check if workflow file exists
    local workflow_path=".github/workflows/$WORKFLOW_FILE"
    
    if [[ ! -f "$workflow_path" ]]; then
        print_error "Workflow file not found: $workflow_path"
        print_info "Please ensure the Firebase Test Lab workflow is properly set up"
        return
    fi
    
    print_success "Workflow file found: $workflow_path"
    
    # Show current triggers
    print_step "Current workflow triggers:"
    grep -A 10 "^on:" "$workflow_path" || print_warning "Could not parse workflow triggers"
    
    echo ""
    print_info "To modify triggers, edit: $workflow_path"
    print_info "Common triggers:"
    echo "  - push: [main, develop]"
    echo "  - pull_request: [main]"
    echo "  - schedule: ['0 2 * * *']  # Daily at 2 AM"
    echo "  - workflow_dispatch: {}   # Manual triggers"
}

# Help and usage
show_help() {
    print_header "🚀 GITHUB ACTIONS FIREBASE TRIGGER"
    
    echo -e "${GREEN}USAGE:${NC}"
    echo "  $0 [COMMAND] [OPTIONS]"
    echo ""
    echo -e "${GREEN}TRIGGER COMMANDS:${NC}"
    echo "  ${YELLOW}both [matrix] [wait]${NC}      - Trigger both iOS and Android tests"
    echo "  ${YELLOW}ios [matrix] [wait]${NC}       - Trigger iOS tests only"
    echo "  ${YELLOW}android [matrix] [wait]${NC}   - Trigger Android tests only"
    echo "  ${YELLOW}comprehensive${NC}             - Trigger comprehensive testing"
    echo "  ${YELLOW}regression${NC}                - Trigger regression testing"
    echo ""
    echo -e "${GREEN}MONITORING COMMANDS:${NC}"
    echo "  ${YELLOW}status${NC}                    - Show workflow status"
    echo "  ${YELLOW}monitor${NC}                   - Monitor active runs"
    echo "  ${YELLOW}cancel${NC}                    - Cancel active runs"
    echo "  ${YELLOW}results${NC}                   - View latest results"
    echo "  ${YELLOW}download${NC}                  - Download latest artifacts"
    echo ""
    echo -e "${GREEN}SETUP COMMANDS:${NC}"
    echo "  ${YELLOW}setup${NC}                     - Setup workflow triggers"
    echo ""
    echo -e "${GREEN}DEVICE MATRIX OPTIONS:${NC}"
    echo "  ${YELLOW}minimal${NC}    - Single device per platform"
    echo "  ${YELLOW}standard${NC}   - 2-3 devices per platform (default)"
    echo "  ${YELLOW}extended${NC}   - 4+ devices per platform"
    echo ""
    echo -e "${GREEN}WAIT OPTIONS:${NC}"
    echo "  ${YELLOW}true${NC}       - Wait for completion"
    echo "  ${YELLOW}false${NC}      - Trigger and return (default)"
    echo ""
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo "  $0 both                    # Standard testing on both platforms"
    echo "  $0 ios extended true       # Extended iOS testing, wait for completion"
    echo "  $0 android minimal         # Minimal Android testing"
    echo "  $0 comprehensive           # Full comprehensive testing"
    echo "  $0 monitor                 # Monitor active test runs"
    echo ""
    echo -e "${GREEN}QUICK START:${NC}"
    echo "  1. $0 status      # Check current workflow status"
    echo "  2. $0 both        # Trigger tests on both platforms"
    echo "  3. $0 monitor     # Monitor the running tests"
}

# Main script logic
main() {
    local command="${1:-help}"
    
    # Always check prerequisites except for help
    if [[ "$command" != "help" ]] && [[ "$command" != "-h" ]] && [[ "$command" != "--help" ]]; then
        check_prerequisites
    fi
    
    case "$command" in
        "both")
            trigger_both_platforms "$2" "$3"
            ;;
        "ios")
            trigger_ios_only "$2" "$3"
            ;;
        "android")
            trigger_android_only "$2" "$3"
            ;;
        "comprehensive")
            trigger_comprehensive_testing
            ;;
        "regression")
            trigger_regression_testing
            ;;
        "status")
            show_workflow_status
            ;;
        "monitor")
            monitor_active_runs
            ;;
        "cancel")
            cancel_active_runs
            ;;
        "results")
            view_latest_results
            ;;
        "download")
            download_latest_artifacts
            ;;
        "setup")
            setup_workflow_triggers
            ;;
        "help"|"-h"|"--help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"