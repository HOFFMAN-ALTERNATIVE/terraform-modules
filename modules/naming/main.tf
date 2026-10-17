locals {
  env_short = {
    dev     = "d"
    staging = "s"
    prod    = "p"
  }[var.environment]

  # e.g. acme-prod-api ; DNS / S3 / k8s safe, max 63 chars
  name = substr("${var.namespace}-${var.environment}-${var.component}", 0, 63)

  # compact variant for resources with tight limits (e.g. 24 chars)
  short_name = substr("${var.namespace}${local.env_short}${replace(var.component, "-", "")}", 0, 24)

  mandatory_tags = {
    Namespace   = var.namespace
    Environment = var.environment
    Component   = var.component
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  # mandatory keys always win
  tags = merge(var.extra_tags, local.mandatory_tags)
}
