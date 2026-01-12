variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs for policy attachments"
  type        = list(string)
  default     = []
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN for policy attachments"
  type        = string
  default     = ""
}

variable "opensearch_collection_arn" {
  description = "OpenSearch collection ARN for policy attachments"
  type        = string
  default     = ""
}

variable "kms_key_arns" {
  description = "KMS key ARNs for encryption permissions"
  type        = list(string)
  default     = []
}

variable "lambda_function_names" {
  description = "Lambda function names for Bedrock Agent action group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
