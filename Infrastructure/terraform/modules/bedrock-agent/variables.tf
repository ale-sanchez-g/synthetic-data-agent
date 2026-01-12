variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "agent_name" {
  description = "Agent name"
  type        = string
}

variable "foundation_model" {
  description = "Foundation model ID"
  type        = string
}

variable "agent_instruction" {
  description = "Agent instruction"
  type        = string
}

variable "idle_session_ttl" {
  description = "Idle session timeout in seconds"
  type        = number
  default     = 600
}

variable "execution_role_arn" {
  description = "IAM execution role ARN"
  type        = string
}

variable "knowledge_base_id" {
  description = "Knowledge Base ID"
  type        = string
  default     = ""
}

variable "lambda_function_arns" {
  description = "Lambda function ARNs for action group"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
