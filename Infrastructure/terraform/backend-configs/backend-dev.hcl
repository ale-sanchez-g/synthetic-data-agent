# ============================================================================
# Development Environment Backend Configuration
# ============================================================================
# Usage: terraform init -backend-config=backend-configs/backend-dev.hcl
# ============================================================================

bucket         = "sdga-infra-tfstate-dev-backend"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "sdga-infra-tfstate-dev-lock"
# kms_key_id   = "alias/sdga-infra-terraform-dev"  # Commented out - using AWS-managed encryption

# State locking settings
skip_credentials_validation = false
skip_metadata_api_check     = false
