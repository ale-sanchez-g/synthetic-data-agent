# ============================================================================
# IAM Module Outputs
# ============================================================================

output "bedrock_agent_role_arn" {
  description = "Bedrock Agent IAM role ARN"
  value       = aws_iam_role.bedrock_agent.arn
}

output "bedrock_agent_role_name" {
  description = "Bedrock Agent IAM role name"
  value       = aws_iam_role.bedrock_agent.name
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Lambda execution role name"
  value       = aws_iam_role.lambda_execution.name
}

output "knowledge_base_role_arn" {
  description = "Knowledge Base IAM role ARN"
  value       = aws_iam_role.knowledge_base.arn
}

output "knowledge_base_role_name" {
  description = "Knowledge Base IAM role name"
  value       = aws_iam_role.knowledge_base.name
}
