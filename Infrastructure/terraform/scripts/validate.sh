#!/bin/bash
# ============================================================================
# Terraform Validate Script
# ============================================================================
# This script validates Terraform configuration files.
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

# Main execution
main() {
    # Change to terraform directory if not already there
    if [ ! -f "versions.tf" ]; then
        cd "$(dirname "$0")/.."
    fi
    
    info "Validating Terraform configuration"
    
    # Run terraform fmt check
    info "Checking code formatting..."
    if terraform fmt -check -recursive .; then
        info "✓ Code formatting is correct"
    else
        error "✗ Code formatting issues found. Run 'terraform fmt -recursive .' to fix"
        exit 1
    fi
    
    # Run terraform validate
    info "Validating configuration..."
    terraform validate
    
    info "✓ Configuration is valid"
}

main "$@"
