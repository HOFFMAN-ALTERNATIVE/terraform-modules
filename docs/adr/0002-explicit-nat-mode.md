# 0002. Make NAT topology an explicit input

Status: accepted
Date: 2026-10-17

## Context
NAT gateways are billed per hour and per GB in every AZ where they run, and they are
the most common surprise on small AWS bills. Production wants one NAT per AZ so an AZ
outage does not cut egress for the others. Dev and test usually do not.

## Options
1. Always one NAT per AZ: most resilient, and the most expensive default for every
   dev environment.
2. A boolean `enable_nat`: simple, but hides the difference between one shared NAT
   and one per AZ.
3. `nat_mode` with three values: `none`, `single` (one NAT shared by all private
   route tables) and `per_az` (one NAT and route table per AZ).

## Decision
Option 3, default `single`. The cost and resilience trade-off is visible in the
input, and the full example derives it from `naming.is_production`.

## Consequences
- Private subnets get one route table per AZ in every mode, so switching between
  `single` and `per_az` changes routes, not subnets.
- Tests assert the NAT count and which NAT each private route table uses, per mode.
- With `single`, an outage in the NAT's AZ removes egress for all private subnets.
- `none` leaves private subnets without internet egress. VPC endpoints are not part
  of this module.
