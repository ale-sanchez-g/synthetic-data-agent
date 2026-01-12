#!/bin/bash
# ============================================================================
# Terraform Deploy Script
# ============================================================================
# This script applies terraform changes for the specified environment.
# It requires a plan file to be provided for safety.
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
    
    if [ ! -f "$PLAN_FILE" ]; then
        error "Plan file not found: $PLAN_FILE"
        error "Run './scripts/plan.sh $ENVIRONMENT' first"
        exit 1
    fi
    
    info "Deploying to environment: $ENVIRONMENT"
}

# Function to confirm deployment
confirm_deployment() {
    if [ "$ENVIRONMENT" = "prod" ]; then
        warn "⚠️  WARNING: You are about to deploy to PRODUCTION ⚠️"
        echo ""
        read -p "Type 'yes' to confirm: " confirmation
        
        if [ "$confirmation" != "yes" ]; then
            error "Deployment cancelled"
            exit 1
        fi
    else
        read -p "Deploy to $ENVIRONMENT? (yes/no): " confirmation
        
        if [ "$confirmation" != "yes" ]; then
            error "Deployment cancelled"
            exit 1
        fi
    fi
}

# Function to check if DynamoDB lock table exists
check_lock_table() {
    local lock_table="sdga-infra-tfstate-${ENVIRONMENT}-lock"
    
    if ! aws dynamodb describe-table --table-name "$lock_table" --region us-east-1 >/dev/null 2>&1; then
        warn "DynamoDB lock table '$lock_table' not found in us-east-1"
        
        if [ "$ENVIRONMENT" = "dev" ]; then
            warn "Running without state locking for dev environment"
            USE_LOCK_FLAG=true
        else
            error "Lock table required for $ENVIRONMENT environment"
            error "Run './scripts/setup-backend.sh $ENVIRONMENT' first"
            exit 1
        fi
    else
        USE_LOCK_FLAG=false
    fi
}

# Function to apply terraform changes
apply_changes() {
    # Check lock table availability
    check_lock_table
    
    if [ "$USE_LOCK_FLAG" = true ]; then
        # Apply without plan file when locking is disabled
        # because terraform apply <plan-file> still tries to acquire a lock
        warn "Applying directly without plan file (locking disabled)"
        
        local var_file="environments/${ENVIRONMENT}.tfvars"
        
        if [ ! -f "$var_file" ]; then
            error "Variable file not found: $var_file"
            exit 1
        fi
        
        info "Using variable file: $var_file"
        
        terraform apply \
            -var-file="$var_file" \
            -lock=false \
            -auto-approve
        
        # Remove plan file
        rm "$PLAN_FILE"
        info "Plan file removed: $PLAN_FILE"
    else
        # Normal apply with plan file and locking
        info "Applying changes from plan file: $PLAN_FILE"
        
        terraform apply "$PLAN_FILE"
        
        # Remove plan file after successful apply
        rm "$PLAN_FILE"
        info "Plan file removed: $PLAN_FILE"
    fi
}

# Function to show outputs
show_outputs() {
    info "Deployment outputs:"
    terraform output
}

# Main execution
main() {
    # Change to terraform directory if not already there
    if [ ! -f "versions.tf" ]; then
        cd "$(dirname "$0")/.."
    fi
    
    check_variables "$@"
    confirm_deployment
    apply_changes
    show_outputs
    
    info "Deployment completed successfully for environment: $ENVIRONMENT"
}

main "$@"
