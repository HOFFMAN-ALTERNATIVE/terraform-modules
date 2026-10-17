variable "name" {
  description = "Name prefix for every resource (use the naming module)."
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR. Must be an RFC 1918 /16-/24 block."
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.cidr_block, 0)) && tonumber(split("/", var.cidr_block)[1]) >= 16 && tonumber(split("/", var.cidr_block)[1]) <= 24
    error_message = "cidr_block must be a valid CIDR between /16 and /24."
  }
}

variable "az_count" {
  description = "How many availability zones to spread subnets across."
  type        = number
  default     = 3
  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6
    error_message = "az_count must be between 1 and 6."
  }
}

variable "subnet_newbits" {
  description = "Bits added to the VPC prefix for each subnet (/16 + 4 = /20)."
  type        = number
  default     = 4
}

variable "nat_mode" {
  description = "none | single (cost-optimised) | per_az (highly available)."
  type        = string
  default     = "single"
  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_mode)
    error_message = "nat_mode must be none, single or per_az."
  }
}

variable "flow_logs_retention_days" {
  description = "CloudWatch retention for VPC flow logs; 0 disables flow logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
