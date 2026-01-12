# ============================================================================
# Staging Environment Backend Configuration
# ============================================================================
# Usage: terraform init -backend-config=backend-configs/backend-stg.hcl
# ============================================================================

bucket         = "sdga-infra-tfstate-stg-backend"
key            = "stg/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "sdga-infra-tfstate-stg-lock"
kms_key_id     = "alias/sdga-infra-terraform-stg"

# State locking settings
skip_credentials_validation = false
skip_metadata_api_check     = false
