variable "name" {
  description = "Globally unique bucket name."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.name)) && !can(regex("\\.\\.", var.name))
    error_message = "name must be a valid S3 bucket name (3-63 chars, lowercase, digits, dots, hyphens)."
  }
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN. Null = SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "versioning" {
  description = "Enable object versioning (recommended; required for object lock / replication)."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Delete noncurrent object versions after N days; 0 keeps them forever."
  type        = number
  default     = 90
}

variable "transition_to_ia_days" {
  description = "Move current objects to STANDARD_IA after N days; 0 disables."
  type        = number
  default     = 0
  validation {
    condition     = var.transition_to_ia_days == 0 || var.transition_to_ia_days >= 30
    error_message = "S3 requires at least 30 days before STANDARD_IA transitions."
  }
}

variable "force_destroy" {
  description = "Allow terraform destroy on a non-empty bucket. Never enable in prod."
  type        = bool
  default     = false
}

variable "read_principal_arns" {
  description = "IAM principals granted read-only access through the bucket policy."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
