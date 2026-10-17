output "name" {
  description = "Canonical resource name: <namespace>-<environment>-<component>."
  value       = local.name
}

output "short_name" {
  description = "Compact name (<= 24 chars) for resources with tight length limits."
  value       = local.short_name
}

output "tags" {
  description = "Tag map with mandatory governance keys."
  value       = local.tags
}

output "is_production" {
  description = "True when environment is prod — drive protective defaults from this."
  value       = var.environment == "prod"
}
