# ============================================================================
# Development Environment Configuration
# ============================================================================

# General
environment = "dev"
aws_region  = "us-east-1"
domain      = "datagen"
owner       = "data-platform-team"
cost_center = "engineering"

# Bedrock Agent
bedrock_agent_name          = "sdga-datagen-agent-dev"
bedrock_foundation_model    = "anthropic.claude-3-sonnet-20240229-v1:0"
bedrock_agent_idle_timeout  = 600
bedrock_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

# Lambda Configuration
lambda_generate_memory      = 1024
lambda_generate_timeout     = 300
lambda_validate_memory      = 512
lambda_validate_timeout     = 60
lambda_metrics_memory       = 512
lambda_metrics_timeout      = 120
lambda_reserved_concurrency = 5

# S3 Storage
s3_generated_data_retention_days = 30
s3_lifecycle_ia_days             = 30
s3_lifecycle_glacier_days        = 60
s3_lifecycle_expiration_days     = 90
s3_versioning_enabled            = true
s3_cross_region_replication      = false
mfa_delete_enabled               = false

# DynamoDB
dynamodb_billing_mode           = "PAY_PER_REQUEST"
dynamodb_point_in_time_recovery = false
dynamodb_ttl_enabled            = true
dynamodb_ttl_days               = 30

# OpenSearch Serverless
opensearch_capacity_units = 2

# CloudWatch
cloudwatch_log_retention_days  = 7
cloudwatch_detailed_monitoring = false
enable_cloudwatch_alarms       = true
cloudwatch_alarm_sns_topic_arn = ""

# Security
enable_kms          = false
kms_key_rotation    = false
enable_guardduty    = false
enable_security_hub = false
enable_config       = false

# VPC
enable_vpc               = false
vpc_cidr                 = "10.0.0.0/16"
vpc_az_count             = 2
enable_s3_endpoint       = true
enable_dynamodb_endpoint = true
enable_bedrock_endpoint  = true

# WAF
enable_waf           = false
waf_rate_limit       = 2000
waf_allowed_ip_cidrs = []
waf_blocked_ip_cidrs = []

# Budget
budget_limit_monthly          = 200
enable_cost_anomaly_detection = false

# Additional Tags
tags = {
  DataClassification = "internal"
  BackupPolicy       = "none"
}
