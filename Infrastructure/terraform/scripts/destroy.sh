#!/bin/bash
# ============================================================================
# Terraform Destroy Script
# ============================================================================
# This script destroys terraform-managed infrastructure for the specified
# environment. Use with extreme caution!
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
        error "Environment parameter is required. Usage: $0 <dev|stg|prod>"
        exit 1
    fi
    
    ENVIRONMENT=$1
    
    if [[ ! "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]]; then
        error "Invalid environment. Must be one of: dev, stg, prod"
        exit 1
    fi
    
    warn "⚠️  DANGER: You are about to DESTROY all resources in $ENVIRONMENT ⚠️"
}

# Function to confirm destruction
confirm_destruction() {
    echo ""
    error "This will DELETE ALL infrastructure in the $ENVIRONMENT environment!"
    error "This action CANNOT be undone!"
    echo ""
    
    read -p "Type the environment name '$ENVIRONMENT' to confirm: " confirmation
    
    if [ "$confirmation" != "$ENVIRONMENT" ]; then
        error "Destruction cancelled"
        exit 1
    fi
    
    if [ "$ENVIRONMENT" = "prod" ]; then
        error "Production environment requires additional confirmation"
        read -p "Type 'DELETE PRODUCTION' to confirm: " prod_confirmation
        
        if [ "$prod_confirmation" != "DELETE PRODUCTION" ]; then
            error "Destruction cancelled"
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

# Function to destroy resources
destroy_resources() {
    local var_file="environments/${ENVIRONMENT}.tfvars"
    
    if [ ! -f "$var_file" ]; then
        error "Variable file not found: $var_file"
        exit 1
    fi
    
    info "Using variable file: $var_file"
    
    # Check lock table availability
    check_lock_table
    
    # Run terraform destroy
    terraform destroy \
        -var-file="$var_file" \
        $LOCK_FLAG \
        -auto-approve
    
    info "Resources destroyed successfully"
}

# Main execution
main() {
    # Change to terraform directory if not already there
    if [ ! -f "versions.tf" ]; then
        cd "$(dirname "$0")/.."
    fi
    
    check_variables "$@"
    confirm_destruction
    destroy_resources
    
    warn "All resources destroyed for environment: $ENVIRONMENT"
}

main "$@"
