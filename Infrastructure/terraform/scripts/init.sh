#!/bin/bash
# ============================================================================
# Terraform Initialization Script
# ============================================================================
# This script initializes Terraform with the appropriate backend configuration
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
    
    info "Initializing Terraform for environment: $ENVIRONMENT"
}

# Function to initialize Terraform
init_terraform() {
    local backend_config="backend-configs/backend-${ENVIRONMENT}.hcl"
    
    if [ ! -f "$backend_config" ]; then
        error "Backend configuration file not found: $backend_config"
        exit 1
    fi
    
    info "Using backend configuration: $backend_config"
    
    # Initialize Terraform
    terraform init \
        -backend-config="$backend_config" \
        -upgrade \
        -reconfigure
    
    info "Terraform initialized successfully"
}

# Main execution
main() {
    # Change to terraform directory if not already there
    if [ ! -f "versions.tf" ]; then
        cd "$(dirname "$0")/.."
    fi
    
    check_variables "$@"
    init_terraform
    
    info "Initialization completed for environment: $ENVIRONMENT"
    info ""
    info "Next steps:"
    info "1. Validate configuration: terraform validate"
    info "2. Plan changes: ./scripts/plan.sh $ENVIRONMENT"
    info "3. Apply changes: ./scripts/deploy.sh $ENVIRONMENT"
}

main "$@"
