variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "rate_limit" {
  description = "Rate limit per 5 minutes"
  type        = number
  default     = 2000
}

variable "allowed_ip_cidrs" {
  description = "Allowed IP CIDR blocks"
  type        = list(string)
  default     = []
}

variable "blocked_ip_cidrs" {
  description = "Blocked IP CIDR blocks"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
