variable "namespace" {
  description = "Organisation or product prefix, e.g. \"acme\"."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.namespace))
    error_message = "namespace must be 2-10 lowercase alphanumerics starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, staging, prod."
  }
}

variable "component" {
  description = "Component / workload name, e.g. \"api\"."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,23}[a-z0-9]$", var.component))
    error_message = "component must be 2-25 chars of lowercase letters, digits and hyphens."
  }
}

variable "owner" {
  description = "Team or person accountable for the resources (tag)."
  type        = string
  default     = "platform"
}

variable "extra_tags" {
  description = "Additional tags merged over the defaults (cannot override mandatory keys)."
  type        = map(string)
  default     = {}
}
