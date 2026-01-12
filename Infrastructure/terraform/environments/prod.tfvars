# ============================================================================
# Production Environment Configuration
# ============================================================================

# General
environment = "prod"
aws_region  = "us-east-1"
domain      = "datagen"
owner       = "data-platform-team"
cost_center = "engineering"

# Bedrock Agent
bedrock_agent_name          = "sdga-datagen-agent-prod"
bedrock_foundation_model    = "anthropic.claude-3-sonnet-20240229-v1:0"
bedrock_agent_idle_timeout  = 1800
bedrock_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

# Lambda Configuration
lambda_generate_memory      = 2048
lambda_generate_timeout     = 300
lambda_validate_memory      = 1024
lambda_validate_timeout     = 60
lambda_metrics_memory       = 1024
lambda_metrics_timeout      = 120
lambda_reserved_concurrency = 50

# S3 Storage
s3_generated_data_retention_days = 365
s3_lifecycle_ia_days             = 90
s3_lifecycle_glacier_days        = 180
s3_lifecycle_expiration_days     = 730
s3_versioning_enabled            = true
s3_cross_region_replication      = true
s3_replication_region            = "us-west-2"
mfa_delete_enabled               = true

# DynamoDB
dynamodb_billing_mode           = "PAY_PER_REQUEST"
dynamodb_point_in_time_recovery = true
dynamodb_ttl_enabled            = true
dynamodb_ttl_days               = 365

# OpenSearch Serverless
opensearch_capacity_units = 8

# CloudWatch
cloudwatch_log_retention_days  = 90
cloudwatch_detailed_monitoring = true
enable_cloudwatch_alarms       = true
cloudwatch_alarm_sns_topic_arn = "" # Add SNS topic ARN for production alerts

# Security
enable_kms          = true
kms_key_rotation    = true
enable_guardduty    = true
enable_security_hub = true
enable_config       = true

# VPC
enable_vpc               = true
vpc_cidr                 = "10.0.0.0/16"
vpc_az_count             = 3
enable_s3_endpoint       = true
enable_dynamodb_endpoint = true
enable_bedrock_endpoint  = true

# WAF
enable_waf           = true
waf_rate_limit       = 2000
waf_allowed_ip_cidrs = [] # Add allowed IPs if needed
waf_blocked_ip_cidrs = []

# Budget
budget_limit_monthly          = 2000
enable_cost_anomaly_detection = true

# Additional Tags
tags = {
  DataClassification = "confidential"
  Compliance         = "SOC2,GDPR"
  BackupPolicy       = "daily"
}
