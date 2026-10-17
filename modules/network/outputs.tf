output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "availability_zones" {
  description = "AZs the subnets were placed in."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs (one per AZ)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ)."
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  value       = local.public_cidrs
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  value       = local.private_cidrs
}

output "nat_gateway_count" {
  description = "Number of NAT gateways created."
  value       = local.nat_count
}
