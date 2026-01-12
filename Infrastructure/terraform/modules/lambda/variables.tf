variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "python_runtime" {
  description = "Python runtime version"
  type        = string
  default     = "python3.11"
}

variable "generate_memory" {
  description = "Memory for generate function in MB"
  type        = number
  default     = 1024
}

variable "generate_timeout" {
  description = "Timeout for generate function in seconds"
  type        = number
  default     = 180
}

variable "validate_memory" {
  description = "Memory for validate function in MB"
  type        = number
  default     = 512
}

variable "validate_timeout" {
  description = "Timeout for validate function in seconds"
  type        = number
  default     = 60
}

variable "metrics_memory" {
  description = "Memory for metrics function in MB"
  type        = number
  default     = 512
}

variable "metrics_timeout" {
  description = "Timeout for metrics function in seconds"
  type        = number
  default     = 60
}

variable "reserved_concurrency" {
  description = "Reserved concurrent executions"
  type        = number
  default     = -1
}

variable "layer_arns" {
  description = "Lambda layer ARNs"
  type        = list(string)
  default     = []
}

variable "vpc_subnet_ids" {
  description = "VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for environment variable encryption"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "IAM execution role ARN"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for data storage"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
