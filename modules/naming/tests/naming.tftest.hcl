variables {
  namespace   = "acme"
  environment = "prod"
  component   = "payments-api"
}

run "builds_canonical_names" {
  command = plan
  assert {
    condition     = output.name == "acme-prod-payments-api"
    error_message = "unexpected canonical name: ${output.name}"
  }
  assert {
    condition     = output.short_name == "acmeppaymentsapi"
    error_message = "unexpected short name: ${output.short_name}"
  }
  assert {
    condition     = output.is_production
    error_message = "prod must be flagged as production"
  }
}

run "mandatory_tags_cannot_be_overridden" {
  command = plan
  variables {
    extra_tags = { ManagedBy = "clickops", CostCenter = "42" }
  }
  assert {
    condition     = output.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy must stay terraform"
  }
  assert {
    condition     = output.tags["CostCenter"] == "42"
    error_message = "extra tags must be merged"
  }
}

run "short_name_is_capped_at_24" {
  command = plan
  variables {
    namespace = "longnamesp"
    component = "very-long-component-name"
  }
  assert {
    condition     = length(output.short_name) <= 24
    error_message = "short_name exceeds 24 chars"
  }
}

run "rejects_unknown_environment" {
  command = plan
  variables {
    environment = "qa"
  }
  expect_failures = [var.environment]
}

run "rejects_uppercase_namespace" {
  command = plan
  variables {
    namespace = "ACME"
  }
  expect_failures = [var.namespace]
}
