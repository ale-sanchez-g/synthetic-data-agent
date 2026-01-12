# ============================================================================
# General Configuration
# ============================================================================

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sdga"
}

variable "environment" {
  description = "Environment name (dev, stg, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stg, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain or bounded context (datagen, schema, quality, infra)"
  type        = string
  default     = "datagen"
}

variable "owner" {
  description = "Team or individual owner"
  type        = string
  default     = "data-platform-team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Bedrock Agent Configuration
# ============================================================================

variable "bedrock_agent_name" {
  description = "Name of the Bedrock Agent"
  type        = string
  default     = "synthetic-data-generator-agent"
}

variable "bedrock_foundation_model" {
  description = "Foundation model for Bedrock Agent"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "bedrock_agent_idle_timeout" {
  description = "Idle session timeout in seconds"
  type        = number
  default     = 600
}

variable "bedrock_embedding_model_arn" {
  description = "ARN of the embedding model for knowledge base"
  type        = string
  default     = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
}

# ============================================================================
# Lambda Configuration
# ============================================================================

variable "lambda_generate_memory" {
  description = "Memory allocation for generate_synthetic_data function (MB)"
  type        = number
  default     = 1024

  validation {
    condition     = var.lambda_generate_memory >= 128 && var.lambda_generate_memory <= 10240
    error_message = "Lambda memory must be between 128 and 10240 MB."
  }
}

variable "lambda_generate_timeout" {
  description = "Timeout for generate_synthetic_data function (seconds)"
  type        = number
  default     = 300

  validation {
    condition     = var.lambda_generate_timeout >= 1 && var.lambda_generate_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

variable "lambda_validate_memory" {
  description = "Memory allocation for validate_schema function (MB)"
  type        = number
  default     = 512
}

variable "lambda_validate_timeout" {
  description = "Timeout for validate_schema function (seconds)"
  type        = number
  default     = 60
}

variable "lambda_metrics_memory" {
  description = "Memory allocation for calculate_quality_metrics function (MB)"
  type        = number
  default     = 512
}

variable "lambda_metrics_timeout" {
  description = "Timeout for calculate_quality_metrics function (seconds)"
  type        = number
  default     = 120
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrent executions for Lambda functions"
  type        = number
  default     = -1 # -1 means unreserved
}

# ============================================================================
# S3 Configuration
# ============================================================================

variable "s3_generated_data_retention_days" {
  description = "Number of days to retain generated data"
  type        = number
  default     = 90
}

variable "s3_lifecycle_ia_days" {
  description = "Days before transitioning to Infrequent Access"
  type        = number
  default     = 90
}

variable "s3_lifecycle_glacier_days" {
  description = "Days before transitioning to Glacier"
  type        = number
  default     = 180
}

variable "s3_lifecycle_expiration_days" {
  description = "Days before object expiration"
  type        = number
  default     = 365
}

variable "s3_versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "mfa_delete_enabled" {
  description = "Enable MFA delete for S3 buckets"
  type        = bool
  default     = false
}

variable "s3_cross_region_replication" {
  description = "Enable cross-region replication for S3 buckets"
  type        = bool
  default     = false
}

variable "s3_replication_region" {
  description = "Target region for S3 cross-region replication"
  type        = string
  default     = "us-west-2"
}

# ============================================================================
# DynamoDB Configuration
# ============================================================================

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "dynamodb_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB"
  type        = bool
  default     = false
}

variable "dynamodb_ttl_enabled" {
  description = "Enable TTL for DynamoDB table"
  type        = bool
  default     = true
}

variable "dynamodb_ttl_days" {
  description = "Number of days before TTL expiration"
  type        = number
  default     = 90
}

# ============================================================================
# OpenSearch Configuration
# ============================================================================

variable "opensearch_capacity_units" {
  description = "OpenSearch Serverless capacity units (OCU)"
  type        = number
  default     = 2

  validation {
    condition     = var.opensearch_capacity_units >= 2
    error_message = "OpenSearch capacity must be at least 2 OCU."
  }
}

# ============================================================================
# CloudWatch Configuration
# ============================================================================

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.cloudwatch_log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "cloudwatch_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "cloudwatch_alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

# ============================================================================
# Security Configuration
# ============================================================================

variable "enable_kms" {
  description = "Enable KMS encryption for resources"
  type        = bool
  default     = true
}

variable "kms_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty for threat detection"
  type        = bool
  default     = false
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub for compliance monitoring"
  type        = bool
  default     = false
}

variable "enable_config" {
  description = "Enable AWS Config for resource compliance"
  type        = bool
  default     = false
}

# ============================================================================
# VPC Configuration
# ============================================================================

variable "enable_vpc" {
  description = "Enable VPC for Lambda functions"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_az_count" {
  description = "Number of availability zones for VPC"
  type        = number
  default     = 2

  validation {
    condition     = var.vpc_az_count >= 2 && var.vpc_az_count <= 3
    error_message = "VPC must span at least 2 and at most 3 availability zones."
  }
}

variable "enable_s3_endpoint" {
  description = "Enable VPC endpoint for S3"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable VPC endpoint for DynamoDB"
  type        = bool
  default     = true
}

variable "enable_bedrock_endpoint" {
  description = "Enable VPC endpoint for Bedrock"
  type        = bool
  default     = true
}

# ============================================================================
# WAF Configuration
# ============================================================================

variable "enable_waf" {
  description = "Enable AWS WAF for API protection"
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "WAF rate limit per 5 minutes"
  type        = number
  default     = 2000
}

variable "waf_allowed_ip_cidrs" {
  description = "List of allowed IP CIDR blocks for WAF"
  type        = list(string)
  default     = []
}

variable "waf_blocked_ip_cidrs" {
  description = "List of blocked IP CIDR blocks for WAF"
  type        = list(string)
  default     = []
}

# ============================================================================
# Budget Configuration
# ============================================================================

variable "budget_limit_monthly" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 200
}

variable "enable_cost_anomaly_detection" {
  description = "Enable AWS Cost Anomaly Detection"
  type        = bool
  default     = false
}
