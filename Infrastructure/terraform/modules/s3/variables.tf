variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for bucket encryption"
  type        = string
  default     = null
}

variable "retention_days" {
  description = "Data retention in days"
  type        = number
  default     = 90
}

variable "lifecycle_ia_days" {
  description = "Days before transitioning to IA storage"
  type        = number
  default     = 30
}

variable "lifecycle_glacier_days" {
  description = "Days before transitioning to Glacier"
  type        = number
  default     = 90
}

variable "lifecycle_expiration_days" {
  description = "Days before expiration"
  type        = number
  default     = 365
}

variable "versioning_enabled" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "Replication destination region"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
