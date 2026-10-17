mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::acme-prod-artifacts"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name = "acme-prod-artifacts"
}

run "blocks_every_form_of_public_access" {
  command = plan
  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this.block_public_acls,
      aws_s3_bucket_public_access_block.this.block_public_policy,
      aws_s3_bucket_public_access_block.this.ignore_public_acls,
      aws_s3_bucket_public_access_block.this.restrict_public_buckets,
    ])
    error_message = "all four public access blocks must be on"
  }
  assert {
    condition     = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership == "BucketOwnerEnforced"
    error_message = "ACLs must be disabled via BucketOwnerEnforced"
  }
}

run "defaults_to_sse_s3_and_versioning" {
  command = plan
  assert {
    condition     = output.sse_algorithm == "AES256"
    error_message = "default encryption must be AES256"
  }
  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "versioning must be enabled by default"
  }
  assert {
    condition     = aws_s3_bucket.this.force_destroy == false
    error_message = "force_destroy must default to false"
  }
}

run "uses_kms_with_bucket_keys_when_given_a_key" {
  command = plan
  variables {
    kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = output.sse_algorithm == "aws:kms"
    error_message = "kms key must switch to aws:kms"
  }
  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.this.rule).bucket_key_enabled == true
    error_message = "bucket keys must be enabled with KMS to cut KMS costs"
  }
}

run "policy_denies_plaintext_and_old_tls" {
  command = apply
  assert {
    condition     = contains([for s in data.aws_iam_policy_document.this.statement : s.sid], "DenyInsecureTransport")
    error_message = "policy must deny non-TLS access"
  }
  assert {
    condition     = contains([for s in data.aws_iam_policy_document.this.statement : s.sid], "DenyOutdatedTLS")
    error_message = "policy must deny TLS < 1.2"
  }
  assert {
    condition     = !contains([for s in data.aws_iam_policy_document.this.statement : s.sid], "AllowReadOnly")
    error_message = "no allow statement without principals"
  }
}

run "grants_read_only_to_named_principals" {
  command = apply
  variables {
    read_principal_arns = ["arn:aws:iam::123456789012:role/reader"]
  }
  assert {
    condition     = contains([for s in data.aws_iam_policy_document.this.statement : s.sid], "AllowReadOnly")
    error_message = "reader principals must get an allow statement"
  }
}

run "lifecycle_rules_follow_inputs" {
  command = plan
  variables {
    transition_to_ia_days = 60
  }
  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this.rule) == 3
    error_message = "expected multipart-abort, noncurrent-expiry and IA rules"
  }
}

run "no_noncurrent_rule_without_versioning" {
  command = plan
  variables {
    versioning = false
  }
  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this.rule) == 1
    error_message = "only the multipart-abort rule should remain"
  }
}

run "rejects_invalid_bucket_name" {
  command = plan
  variables {
    name = "Invalid_Bucket"
  }
  expect_failures = [var.name]
}

run "rejects_too_early_ia_transition" {
  command = plan
  variables {
    transition_to_ia_days = 10
  }
  expect_failures = [var.transition_to_ia_days]
}
