mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/test-vpc-flow-logs"
    }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:eu-central-1:123456789012:log-group:/vpc/test/flow-logs"
    }
  }
}

variables {
  name       = "acme-dev-core"
  cidr_block = "10.20.0.0/16"
  tags       = { Environment = "dev" }
}

run "lays_out_non_overlapping_subnets" {
  command = apply
  assert {
    condition     = output.public_subnet_cidrs == ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
    error_message = "unexpected public layout: ${jsonencode(output.public_subnet_cidrs)}"
  }
  assert {
    condition     = output.private_subnet_cidrs == ["10.20.128.0/20", "10.20.144.0/20", "10.20.160.0/20"]
    error_message = "unexpected private layout: ${jsonencode(output.private_subnet_cidrs)}"
  }
  assert {
    condition     = length(setintersection(output.public_subnet_cidrs, output.private_subnet_cidrs)) == 0
    error_message = "public and private subnets overlap"
  }
  assert {
    condition     = length(output.private_subnet_ids) == 3 && length(output.public_subnet_ids) == 3
    error_message = "expected one subnet per tier per AZ"
  }
}

run "public_subnets_never_auto_assign_public_ips" {
  command = plan
  assert {
    condition     = alltrue([for s in aws_subnet.public : s.map_public_ip_on_launch == false])
    error_message = "public subnets must not auto-assign public IPs"
  }
}

run "single_nat_is_shared_by_all_private_route_tables" {
  command = apply
  assert {
    condition     = output.nat_gateway_count == 1 && length(aws_route.private_nat) == 3
    error_message = "single mode must create 1 NAT and 3 private default routes"
  }
  assert {
    condition     = length(distinct([for r in aws_route.private_nat : r.nat_gateway_id])) == 1
    error_message = "all private routes must target the same NAT in single mode"
  }
}

run "per_az_nat_keeps_traffic_zonal" {
  command = apply
  variables {
    nat_mode = "per_az"
  }
  assert {
    condition     = output.nat_gateway_count == 3
    error_message = "per_az must create one NAT per AZ"
  }
  assert {
    condition     = length(distinct([for r in aws_route.private_nat : r.nat_gateway_id])) == 3
    error_message = "each private route table must use its own zonal NAT"
  }
}

run "no_nat_means_isolated_private_subnets" {
  command = plan
  variables {
    nat_mode = "none"
  }
  assert {
    condition     = length(aws_nat_gateway.this) == 0 && length(aws_route.private_nat) == 0 && length(aws_eip.nat) == 0
    error_message = "nat_mode=none must not create NAT, EIPs or default routes"
  }
}

run "flow_logs_on_by_default_and_scoped" {
  command = apply
  assert {
    condition     = length(aws_flow_log.this) == 1 && aws_flow_log.this[0].traffic_type == "ALL"
    error_message = "flow logs must capture ALL traffic by default"
  }
  assert {
    condition     = aws_cloudwatch_log_group.flow[0].retention_in_days == 30
    error_message = "default retention must be 30 days"
  }
}

run "flow_logs_can_be_disabled" {
  command = plan
  variables {
    flow_logs_retention_days = 0
  }
  assert {
    condition     = length(aws_flow_log.this) == 0 && length(aws_iam_role.flow) == 0
    error_message = "retention 0 must disable flow logs and their IAM role"
  }
}

run "respects_az_count" {
  command = plan
  variables {
    az_count = 2
  }
  assert {
    condition     = length(aws_subnet.private) == 2 && length(aws_route_table.private) == 2
    error_message = "az_count=2 must create 2 private subnets / route tables"
  }
}

run "rejects_too_large_cidr" {
  command = plan
  variables {
    cidr_block = "10.0.0.0/8"
  }
  expect_failures = [var.cidr_block]
}

run "rejects_unknown_nat_mode" {
  command = plan
  variables {
    nat_mode = "double"
  }
  expect_failures = [var.nat_mode]
}
