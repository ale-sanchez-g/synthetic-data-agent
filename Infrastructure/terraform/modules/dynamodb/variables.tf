variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity units"
  type        = number
  default     = null
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL"
  type        = bool
  default     = true
}

variable "ttl_attribute_name" {
  description = "TTL attribute name"
  type        = string
  default     = "ttl"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
