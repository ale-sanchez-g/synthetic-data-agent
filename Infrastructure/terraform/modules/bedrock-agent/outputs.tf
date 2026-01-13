# ============================================================================
# Bedrock Agent Module Outputs
# ============================================================================

output "agent_id" {
  description = "The ID of the Bedrock Agent"
  value       = aws_bedrockagent_agent.main.id
}

output "agent_arn" {
  description = "The ARN of the Bedrock Agent"
  value       = aws_bedrockagent_agent.main.agent_arn
}

output "agent_name" {
  description = "The name of the Bedrock Agent"
  value       = aws_bedrockagent_agent.main.agent_name
}

output "agent_version" {
  description = "The version of the Bedrock Agent"
  value       = aws_bedrockagent_agent.main.agent_version
}

output "agent_alias_id" {
  description = "The ID of the agent alias"
  value       = aws_bedrockagent_agent_alias.live.agent_alias_id
}

output "agent_alias_arn" {
  description = "The ARN of the agent alias"
  value       = aws_bedrockagent_agent_alias.live.agent_alias_arn
}

output "action_group_id" {
  description = "The ID of the action group"
  value       = length(aws_bedrockagent_agent_action_group.data_generation) > 0 ? aws_bedrockagent_agent_action_group.data_generation[0].id : null
}

output "action_group_name" {
  description = "The name of the action group"
  value       = length(aws_bedrockagent_agent_action_group.data_generation) > 0 ? aws_bedrockagent_agent_action_group.data_generation[0].action_group_name : null
}
