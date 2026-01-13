# ============================================================================
# Bedrock Agent Module
# ============================================================================
# This module manages AWS Bedrock Agent resources including:
# - Agent configuration with Claude 3 Sonnet
# - Action groups with Lambda function integrations
# - Agent alias for deployment
# - Knowledge base association (optional)
# ============================================================================

terraform {
  required_version = ">= 1.6.0"
}

# Local variables for resource naming and configuration
locals {
  agent_name = "${var.project_name}-${var.environment}-agent"
  action_group_name = "data-generation-actions"
  alias_name = "LIVE"
  
  # Default agent instructions if not provided
  default_instructions = file("${path.module}/agent-instructions.txt")
}

# ============================================================================
# Bedrock Agent
# ============================================================================

resource "aws_bedrockagent_agent" "main" {
  agent_name              = local.agent_name
  agent_resource_role_arn = var.execution_role_arn
  foundation_model        = var.foundation_model
  description             = "Synthetic Data Generator Agent for QA testing workflows - ${var.environment} environment"
  
  # Agent instructions define behavior and capabilities
  instruction = coalesce(var.agent_instruction, local.default_instructions)
  
  # Session configuration
  idle_session_ttl_in_seconds = var.idle_session_ttl
  
  # Prepare agent after creation
  prepare_agent = true
  
  tags = merge(
    var.tags,
    {
      Name        = local.agent_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "BedrockAgent"
    }
  )
}

# ============================================================================
# Action Group - Data Generation Actions
# ============================================================================

resource "aws_bedrockagent_agent_action_group" "data_generation" {
  # Only create if Lambda ARN exists and is not empty
  count = (
    length(var.lambda_function_arns) > 0 && 
    lookup(var.lambda_function_arns, "generate_synthetic_data", null) != null &&
    lookup(var.lambda_function_arns, "generate_synthetic_data", "") != ""
  ) ? 1 : 0
  
  agent_id      = aws_bedrockagent_agent.main.id
  agent_version = "DRAFT"
  
  action_group_name = local.action_group_name
  description       = "Action group for synthetic data generation, validation, and quality metrics"
  
  # Action group executor using Lambda
  action_group_executor {
    lambda = lookup(var.lambda_function_arns, "generate_synthetic_data", "")
  }
  
  # API Schema from external file
  api_schema {
    payload = file("${path.module}/openapi-schema.json")
  }
  
  # Enable action group
  action_group_state = "ENABLED"
  
  # Skip resource in use check during deletion
  skip_resource_in_use_check = true
}

# ============================================================================
# Knowledge Base Association (Optional)
# ============================================================================

resource "aws_bedrockagent_agent_knowledge_base_association" "main" {
  # Only create if Knowledge Base ID exists and is not empty/null
  count = (
    var.knowledge_base_id != null && 
    var.knowledge_base_id != ""
  ) ? 1 : 0
  
  agent_id             = aws_bedrockagent_agent.main.id
  agent_version        = "DRAFT"
  knowledge_base_id    = var.knowledge_base_id
  description          = "Schema templates and data generation patterns"
  knowledge_base_state = "ENABLED"
}

# ============================================================================
# Agent Alias
# ============================================================================

resource "aws_bedrockagent_agent_alias" "live" {
  agent_id         = aws_bedrockagent_agent.main.id
  agent_alias_name = local.alias_name
  description      = "Live production alias for ${var.environment} environment"
  
  tags = merge(
    var.tags,
    {
      Name        = "${local.agent_name}-${local.alias_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ============================================================================
