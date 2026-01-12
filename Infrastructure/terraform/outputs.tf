# ============================================================================
# General Outputs
# ============================================================================

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

# ============================================================================
# Bedrock Agent Outputs
# ============================================================================

output "bedrock_agent_id" {
  description = "ID of the Bedrock Agent"
  value       = module.bedrock_agent.agent_id
}

output "bedrock_agent_arn" {
  description = "ARN of the Bedrock Agent"
  value       = module.bedrock_agent.agent_arn
}

# output "bedrock_agent_name" {
#   description = "Name of the Bedrock Agent"
#   value       = module.bedrock_agent.agent_name
# }

# ============================================================================
# Knowledge Base Outputs
# ============================================================================

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = module.bedrock_knowledge_base.knowledge_base_id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = module.bedrock_knowledge_base.knowledge_base_arn
}

output "opensearch_collection_endpoint" {
  description = "OpenSearch Serverless collection endpoint"
  value       = module.opensearch.collection_endpoint
}

# ============================================================================
# Lambda Function Outputs
# ============================================================================

output "lambda_generate_function_name" {
  description = "Name of the generate_synthetic_data Lambda function"
  value       = module.lambda.generate_function_name
}

output "lambda_generate_function_arn" {
  description = "ARN of the generate_synthetic_data Lambda function"
  value       = module.lambda.generate_function_arn
}

output "lambda_validate_function_name" {
  description = "Name of the validate_schema Lambda function"
  value       = module.lambda.validate_function_name
}

output "lambda_validate_function_arn" {
  description = "ARN of the validate_schema Lambda function"
  value       = module.lambda.validate_function_arn
}

output "lambda_metrics_function_name" {
  description = "Name of the calculate_quality_metrics Lambda function"
  value       = module.lambda.metrics_function_name
}

output "lambda_metrics_function_arn" {
  description = "ARN of the calculate_quality_metrics Lambda function"
  value       = module.lambda.metrics_function_arn
}

# ============================================================================
# Storage Outputs
# ============================================================================

output "generated_data_bucket_name" {
  description = "Name of the S3 bucket for generated data"
  value       = module.s3.generated_data_bucket_name
}

output "generated_data_bucket_arn" {
  description = "ARN of the S3 bucket for generated data"
  value       = module.s3.generated_data_bucket_arn
}

output "knowledge_base_bucket_name" {
  description = "Name of the S3 bucket for knowledge base"
  value       = module.s3.knowledge_base_bucket_name
}

output "knowledge_base_bucket_arn" {
  description = "ARN of the S3 bucket for knowledge base"
  value       = module.s3.knowledge_base_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB generation history table"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB generation history table"
  value       = module.dynamodb.table_arn
}

# ============================================================================
# IAM Outputs
# ============================================================================

output "bedrock_agent_role_arn" {
  description = "ARN of the Bedrock Agent IAM role"
  value       = module.iam.bedrock_agent_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  value       = module.iam.lambda_execution_role_arn
}

output "knowledge_base_role_arn" {
  description = "ARN of the Knowledge Base IAM role"
  value       = module.iam.knowledge_base_role_arn
}

# ============================================================================
# KMS Outputs
# ============================================================================

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = var.enable_kms ? module.kms[0].kms_key_id : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = var.enable_kms ? module.kms[0].kms_key_arn : null
}

# ============================================================================
# VPC Outputs
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.enable_vpc ? module.vpc[0].private_subnet_ids : null
}

output "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  value       = var.enable_vpc ? module.vpc[0].lambda_security_group_id : null
}

# ============================================================================
# CloudWatch Outputs
# ============================================================================

output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value       = module.cloudwatch.log_group_names
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}

# ============================================================================
# WAF Outputs
# ============================================================================

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = var.enable_waf ? module.waf[0].web_acl_id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_waf ? module.waf[0].web_acl_arn : null
}

# ============================================================================
# Usage Instructions Output
# ============================================================================
# NOTE: Commented out until modules are implemented, as placeholder modules return null values

# output "usage_instructions" {
#   description = "Instructions for using the deployed infrastructure"
#   value       = <<-EOT
#     
#     ============================================================================
#     Synthetic Data Generator Agent - Infrastructure Deployed
#     ============================================================================
#     
#     Environment: ${var.environment}
#     Region: ${var.aws_region}
#     
#     Bedrock Agent:
#       - Agent ID: ${module.bedrock_agent.agent_id}
#       - Foundation Model: ${var.bedrock_foundation_model}
#     
#     Lambda Functions:
#       - Generate: ${module.lambda.generate_function_name}
#       - Validate: ${module.lambda.validate_function_name}
#       - Metrics: ${module.lambda.metrics_function_name}
#     
#     Storage:
#       - Generated Data Bucket: ${module.s3.generated_data_bucket_name}
#       - Knowledge Base Bucket: ${module.s3.knowledge_base_bucket_name}
#       - DynamoDB Table: ${module.dynamodb.table_name}
    
#     Knowledge Base:
#       - KB ID: ${module.bedrock_knowledge_base.knowledge_base_id}
#       - OpenSearch Endpoint: ${module.opensearch.collection_endpoint}
#     
#     Monitoring:
#       - CloudWatch Dashboard: ${module.cloudwatch.dashboard_name}
#     
#     Next Steps:
#       1. Upload schema templates to: s3://${module.s3.knowledge_base_bucket_name}/schemas/
#       2. Sync knowledge base: aws bedrock-agent start-ingestion-job
#       3. Test agent via AWS Console or API
#       4. Monitor execution in CloudWatch Logs
#     
#     ============================================================================
#   EOT
# }
