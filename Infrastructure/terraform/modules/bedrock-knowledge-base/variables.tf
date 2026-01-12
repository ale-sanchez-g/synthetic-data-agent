variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "knowledge_base_name" {
  description = "Knowledge base name"
  type        = string
}

variable "embedding_model_arn" {
  description = "Embedding model ARN"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for knowledge base data"
  type        = string
}

variable "opensearch_collection_arn" {
  description = "OpenSearch collection ARN"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM execution role ARN"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
