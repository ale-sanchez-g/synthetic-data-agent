# ============================================================================
# Local Variables
# ============================================================================

locals {
  # Resource naming prefix
  resource_prefix = "sdga-${var.domain}-${var.environment}"

  # Common tags to be applied to all resources
  common_tags = merge(
    var.tags,
    {
      Project     = "Synthetic Data Generator Agent"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Domain      = var.domain
      Owner       = var.owner
      CostCenter  = var.cost_center
    }
  )

  # Account ID and region data
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# ============================================================================
# Data Sources
# ============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# KMS Module - Encryption Keys
# ============================================================================

module "kms" {
  source = "./modules/kms"

  count = var.enable_kms ? 1 : 0

  project_name        = var.project_name
  environment         = var.environment
  enable_key_rotation = var.kms_key_rotation

  tags = local.common_tags
}

# ============================================================================
# VPC Module - Optional Private Networking
# ============================================================================

module "vpc" {
  source = "./modules/vpc"

  count = var.enable_vpc ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  az_count     = var.vpc_az_count

  # VPC Endpoints
  enable_s3_endpoint       = var.enable_s3_endpoint
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint
  enable_bedrock_endpoint  = var.enable_bedrock_endpoint

  tags = local.common_tags
}

# ============================================================================
# S3 Module - Storage Buckets
# ============================================================================

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment

  # Lifecycle policies
  retention_days            = var.s3_generated_data_retention_days
  lifecycle_ia_days         = var.s3_lifecycle_ia_days
  lifecycle_glacier_days    = var.s3_lifecycle_glacier_days
  lifecycle_expiration_days = var.s3_lifecycle_expiration_days

  # Cross-region replication
  enable_replication = var.s3_cross_region_replication
  replication_region = var.s3_replication_region

  # Encryption
  kms_key_id = var.enable_kms ? module.kms[0].kms_key_arn : null

  # Versioning
  versioning_enabled = var.s3_versioning_enabled

  tags = local.common_tags
}

# ============================================================================
# DynamoDB Module - Generation History Table
# ============================================================================

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment

  # Billing
  billing_mode = var.dynamodb_billing_mode

  # Backup and recovery
  enable_point_in_time_recovery = var.dynamodb_point_in_time_recovery

  # TTL
  enable_ttl = var.dynamodb_ttl_enabled

  # Encryption
  kms_key_id = var.enable_kms ? module.kms[0].kms_key_arn : null

  tags = local.common_tags
}

# ============================================================================
# OpenSearch Module - Vector Store for Knowledge Base
# ============================================================================

module "opensearch" {
  source = "./modules/opensearch"

  project_name = var.project_name
  environment  = var.environment

  # Capacity
  capacity_units = var.opensearch_capacity_units

  # Encryption
  kms_key_id = var.enable_kms ? module.kms[0].kms_key_arn : null

  # VPC endpoints
  vpc_endpoint_ids = var.enable_vpc ? [module.vpc[0].opensearch_endpoint_id] : []

  tags = local.common_tags
}

# ============================================================================
# Lambda Layers Module - Shared Dependencies
# ============================================================================

module "lambda_layers" {
  source = "./modules/lambda-layers"

  project_name = var.project_name
  environment  = var.environment

  tags = local.common_tags
}

# ============================================================================
# Lambda Module - Action Group Functions
# ============================================================================

module "lambda" {
  source = "./modules/lambda"

  project_name = var.project_name
  environment  = var.environment

  # Function configurations
  generate_memory  = var.lambda_generate_memory
  generate_timeout = var.lambda_generate_timeout

  validate_memory  = var.lambda_validate_memory
  validate_timeout = var.lambda_validate_timeout

  metrics_memory  = var.lambda_metrics_memory
  metrics_timeout = var.lambda_metrics_timeout

  reserved_concurrency = var.lambda_reserved_concurrency

  # Lambda layers
  layer_arns = [
    module.lambda_layers.common_layer_arn,
    module.lambda_layers.datagen_layer_arn,
    module.lambda_layers.validation_layer_arn
  ]

  # Environment variables resources
  s3_bucket_name      = module.s3.generated_data_bucket_name
  dynamodb_table_name = module.dynamodb.table_name

  # IAM
  execution_role_arn = module.iam.lambda_execution_role_arn

  # VPC configuration
  vpc_subnet_ids         = var.enable_vpc ? module.vpc[0].private_subnet_ids : []
  vpc_security_group_ids = var.enable_vpc ? [module.vpc[0].lambda_security_group_id] : []

  # Encryption
  kms_key_arn = var.enable_kms ? module.kms[0].kms_key_arn : null

  tags = local.common_tags

  depends_on = [
    module.s3,
    module.dynamodb,
    module.lambda_layers,
    module.iam
  ]
}

# ============================================================================
# IAM Module - Roles and Policies
# ============================================================================

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment

  # Resource ARNs for policy attachments
  s3_bucket_arns = [
    module.s3.generated_data_bucket_arn,
    module.s3.knowledge_base_bucket_arn
  ]
  dynamodb_table_arn        = module.dynamodb.table_arn
  opensearch_collection_arn = module.opensearch.collection_arn

  # KMS key ARNs
  kms_key_arns = var.enable_kms ? [module.kms[0].kms_key_arn] : []

  tags = local.common_tags

  depends_on = [
    module.s3,
    module.dynamodb,
    module.opensearch
  ]
}

# ============================================================================
# Bedrock Knowledge Base Module
# ============================================================================

module "bedrock_knowledge_base" {
  source = "./modules/bedrock-knowledge-base"

  project_name        = var.project_name
  environment         = var.environment
  knowledge_base_name = "${local.resource_prefix}-kb"

  # OpenSearch configuration
  opensearch_collection_arn = module.opensearch.collection_arn

  # S3 data source
  s3_bucket_arn = module.s3.knowledge_base_bucket_arn

  # IAM role
  execution_role_arn = module.iam.knowledge_base_role_arn

  # Embedding model
  embedding_model_arn = var.bedrock_embedding_model_arn

  tags = local.common_tags

  depends_on = [
    module.opensearch,
    module.s3,
    module.iam
  ]
}

# ============================================================================
# Bedrock Agent Module
# ============================================================================

module "bedrock_agent" {
  source = "./modules/bedrock-agent"

  project_name = var.project_name
  environment  = var.environment

  # Agent configuration
  agent_name        = var.bedrock_agent_name
  foundation_model  = var.bedrock_foundation_model
  agent_instruction = "You are a synthetic data generation agent specialized in creating realistic test data for QA testing."
  idle_session_ttl  = var.bedrock_agent_idle_timeout

  # Knowledge base
  knowledge_base_id = module.bedrock_knowledge_base.knowledge_base_id

  # Action group Lambda functions
  lambda_function_arns = {
    generate = module.lambda.generate_function_arn
    validate = module.lambda.validate_function_arn
    metrics  = module.lambda.metrics_function_arn
  }

  # IAM role
  execution_role_arn = module.iam.bedrock_agent_role_arn

  tags = local.common_tags

  depends_on = [
    module.bedrock_knowledge_base,
    module.lambda,
    module.iam
  ]
}

# ============================================================================
# CloudWatch Module - Monitoring and Logging
# ============================================================================

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name = var.project_name
  environment  = var.environment

  # Log retention
  log_retention_days = var.cloudwatch_log_retention_days

  # Alarms
  enable_alarms       = var.enable_cloudwatch_alarms
  alarm_sns_topic_arn = var.cloudwatch_alarm_sns_topic_arn

  # Lambda functions for log groups
  lambda_function_names = [
    module.lambda.generate_function_name,
    module.lambda.validate_function_name,
    module.lambda.metrics_function_name
  ]

  # Encryption
  kms_key_id = var.enable_kms ? module.kms[0].kms_key_arn : null

  tags = local.common_tags

  depends_on = [module.lambda]
}

# ============================================================================
# WAF Module - Optional API Protection
# ============================================================================

module "waf" {
  source = "./modules/waf"

  count = var.enable_waf ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  # Rate limiting
  rate_limit = var.waf_rate_limit

  # IP filtering
  allowed_ip_cidrs = var.waf_allowed_ip_cidrs
  blocked_ip_cidrs = var.waf_blocked_ip_cidrs

  tags = local.common_tags
}

# ============================================================================
# Outputs
# ============================================================================

# Note: Detailed outputs are defined in outputs.tf
