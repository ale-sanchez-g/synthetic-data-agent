#!/bin/bash
# ============================================================================
# Terraform Backend Setup Script
# ============================================================================
# This script creates the S3 bucket and DynamoDB table for Terraform state
# backend in each environment. Run this once per environment before 
# initializing Terraform.
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

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    info "AWS CLI is installed"
}

# Function to check if required variables are set
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
    
    info "Setting up backend for environment: $ENVIRONMENT"
}

# Function to create S3 bucket for state
create_state_bucket() {
    local bucket_name="sdga-infra-tfstate-${ENVIRONMENT}-backend"
    
    info "Creating S3 bucket: $bucket_name"
    
    # Check if bucket exists
    if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        warn "Bucket $bucket_name already exists"
    else
        # Create bucket
        aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region us-east-1 \
            --create-bucket-configuration LocationConstraint=us-east-1 \
            2>/dev/null || aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region us-east-1
        
        info "Created bucket: $bucket_name"
    fi
    
    # Enable versioning
    info "Enabling versioning on $bucket_name"
    aws s3api put-bucket-versioning \
        --bucket "$bucket_name" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    info "Enabling encryption on $bucket_name"
    aws s3api put-bucket-encryption \
        --bucket "$bucket_name" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    # Block public access
    info "Blocking public access on $bucket_name"
    aws s3api put-public-access-block \
        --bucket "$bucket_name" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    # Add lifecycle policy
    info "Adding lifecycle policy to $bucket_name"
    aws s3api put-bucket-lifecycle-configuration \
        --bucket "$bucket_name" \
        --lifecycle-configuration file://<(cat <<EOF
{
    "Rules": [
        {
            "ID": "DeleteOldVersions",
            "Status": "Enabled",
            "NoncurrentVersionExpiration": {
                "NoncurrentDays": 90
            },
            "Filter": {}
        }
    ]
}
EOF
)
    
    # Add tags
    info "Adding tags to $bucket_name"
    aws s3api put-bucket-tagging \
        --bucket "$bucket_name" \
        --tagging "TagSet=[
            {Key=Project,Value=synthetic-data-generator-agent},
            {Key=Environment,Value=$ENVIRONMENT},
            {Key=ManagedBy,Value=terraform},
            {Key=Purpose,Value=terraform-state}
        ]"
    
    info "S3 bucket $bucket_name configured successfully"
}

# Function to create DynamoDB table for state locking
create_lock_table() {
    local table_name="sdga-infra-tfstate-${ENVIRONMENT}-lock"
    
    info "Creating DynamoDB table: $table_name"
    
    # Check if table exists
    if aws dynamodb describe-table --table-name "$table_name" 2>/dev/null; then
        warn "Table $table_name already exists"
    else
        # Create table
        aws dynamodb create-table \
            --table-name "$table_name" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --billing-mode PAY_PER_REQUEST \
            --tags \
                Key=Project,Value=synthetic-data-generator-agent \
                Key=Environment,Value="$ENVIRONMENT" \
                Key=ManagedBy,Value=terraform \
                Key=Purpose,Value=terraform-state-lock
        
        info "Created table: $table_name"
        
        # Wait for table to be active
        info "Waiting for table to become active..."
        aws dynamodb wait table-exists --table-name "$table_name"
    fi
    
    # Enable point-in-time recovery
    info "Enabling point-in-time recovery on $table_name"
    aws dynamodb update-continuous-backups \
        --table-name "$table_name" \
        --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
    
    info "DynamoDB table $table_name configured successfully"
}

# Function to create KMS key for encryption
create_kms_key() {
    local key_alias="alias/sdga-infra-terraform-${ENVIRONMENT}"
    
    info "Creating KMS key: $key_alias"
    
    # Check if key alias exists
    if aws kms describe-key --key-id "$key_alias" 2>/dev/null; then
        warn "KMS key $key_alias already exists"
        return
    fi
    
    # Create KMS key
    local key_id=$(aws kms create-key \
        --description "Terraform state encryption key for $ENVIRONMENT" \
        --tags TagKey=Project,TagValue=synthetic-data-generator-agent \
               TagKey=Environment,TagValue="$ENVIRONMENT" \
               TagKey=ManagedBy,TagValue=terraform \
        --query 'KeyMetadata.KeyId' \
        --output text)
    
    info "Created KMS key: $key_id"
    
    # Create alias
    aws kms create-alias \
        --alias-name "$key_alias" \
        --target-key-id "$key_id"
    
    # Enable key rotation
    aws kms enable-key-rotation --key-id "$key_id"
    
    info "KMS key $key_alias configured successfully"
}

# Main execution
main() {
    info "Starting Terraform backend setup"
    
    check_aws_cli
    check_variables "$@"
    
    create_state_bucket
    create_lock_table
    create_kms_key
    
    info "Backend setup completed successfully for environment: $ENVIRONMENT"
    info ""
    info "Next steps:"
    info "1. Initialize Terraform: ./scripts/init.sh $ENVIRONMENT"
    info "2. Plan changes: ./scripts/plan.sh $ENVIRONMENT"
    info "3. Apply changes: ./scripts/deploy.sh $ENVIRONMENT"
}

main "$@"
