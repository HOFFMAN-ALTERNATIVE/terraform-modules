# Wires all modules together with a mocked AWS provider — no credentials, no cloud calls.
mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = { names = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/mock" }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = { arn = "arn:aws:logs:eu-central-1:123456789012:log-group:mock" }
  }
  mock_resource "aws_s3_bucket" {
    defaults = { arn = "arn:aws:s3:::mock" }
  }
}

run "dev_is_cost_optimised" {
  command = apply
  assert {
    condition     = module.network.nat_gateway_count == 1
    error_message = "dev should use a single NAT gateway"
  }
  assert {
    condition     = output.artifacts_bucket == "acme-dev-platform-artifacts"
    error_message = "bucket name must come from the naming module"
  }
  assert {
    condition     = length(output.private_subnet_ids) == 3
    error_message = "expected 3 private subnets"
  }
}

run "prod_is_highly_available_and_protected" {
  command = apply
  variables {
    environment = "prod"
  }
  assert {
    condition     = module.network.nat_gateway_count == 3
    error_message = "prod should use one NAT per AZ"
  }
  assert {
    condition     = module.artifacts.bucket_id == "acme-prod-platform-artifacts"
    error_message = "unexpected prod bucket name"
  }
}
