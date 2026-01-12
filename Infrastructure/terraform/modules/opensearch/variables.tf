variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "capacity_units" {
  description = "OpenSearch capacity units (OCU)"
  type        = number
  default     = 2
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "vpc_endpoint_ids" {
  description = "VPC endpoint IDs for network policy"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
