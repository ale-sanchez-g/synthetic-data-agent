# ============================================================================
# Production Environment Backend Configuration
# ============================================================================
# Usage: terraform init -backend-config=backend-configs/backend-prod.hcl
# ============================================================================

bucket         = "sdga-infra-tfstate-prod-backend"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "sdga-infra-tfstate-prod-lock"
kms_key_id     = "alias/sdga-infra-terraform-prod"

# State locking settings
skip_credentials_validation = false
skip_metadata_api_check     = false

# Additional security for production
workspace_key_prefix = "workspaces"
