#!/bin/bash
# ============================================================================
# Terraform Plan Script
# ============================================================================
# This script runs terraform plan with the appropriate variable file
# for the specified environment.
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check variables
check_variables() {
    if [ -z "$1" ]; then
        error "Environment parameter is required. Usage: $0 <dev|stg|prod> [plan-file]"
        exit 1
    fi
    
    ENVIRONMENT=$1
    PLAN_FILE=${2:-"tfplan-${ENVIRONMENT}"}
    
    if [[ ! "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]]; then
        error "Invalid environment. Must be one of: dev, stg, prod"
        exit 1
    fi
    
    info "Planning changes for environment: $ENVIRONMENT"
}

# Function to check if DynamoDB lock table exists
check_lock_table() {
    local lock_table="sdga-infra-tfstate-${ENVIRONMENT}-lock"
    
    if ! aws dynamodb describe-table --table-name "$lock_table" --region us-east-1 >/dev/null 2>&1; then
        warn "DynamoDB lock table '$lock_table' not found in us-east-1"
        
        if [ "$ENVIRONMENT" = "dev" ]; then
            warn "Running without state locking for dev environment"
            LOCK_FLAG="-lock=false"
        else
            error "Lock table required for $ENVIRONMENT environment"
            error "Run './scripts/setup-backend.sh $ENVIRONMENT' first"
            exit 1
        fi
    else
        LOCK_FLAG=""
    fi
}

# Function to run terraform plan
run_plan() {
    local var_file="environments/${ENVIRONMENT}.tfvars"
    
    if [ ! -f "$var_file" ]; then
        error "Variable file not found: $var_file"
        exit 1
    fi
    
    info "Using variable file: $var_file"
    
    # Check lock table availability
    check_lock_table
    
    # Run terraform plan
    terraform plan \
        -var-file="$var_file" \
        $LOCK_FLAG \
        -out="$PLAN_FILE"
    
    info "Plan saved to: $PLAN_FILE"
}

# Main execution
main() {
    # Change to terraform directory if not already there
    if [ ! -f "versions.tf" ]; then
        cd "$(dirname "$0")/.."
    fi
    
    check_variables "$@"
    run_plan
    
    info "Planning completed for environment: $ENVIRONMENT"
    info ""
    info "Next steps:"
    info "1. Review the plan output above"
    info "2. Apply changes: ./scripts/deploy.sh $ENVIRONMENT $PLAN_FILE"
}

main "$@"
