terraform {
  backend "s3" {
    # Backend configuration is provided via backend config file or CLI
    # Example: terraform init -backend-config=backend-dev.hcl

    # Required configuration (provided at init):
    # - bucket: S3 bucket name for state storage
    # - key: Path to state file within bucket
    # - region: AWS region for S3 bucket
    # - dynamodb_table: DynamoDB table for state locking
    # - encrypt: Enable server-side encryption

    # These values are environment-specific and should be provided via:
    # 1. Backend config file: backend-{environment}.hcl
    # 2. Or during terraform init: terraform init -backend-config="bucket=my-bucket"
  }
}

# Note: Before running terraform init, you must:
# 1. Manually create the S3 bucket for state storage
# 2. Manually create the DynamoDB table for state locking
# 3. See scripts/setup-backend.sh for automation
