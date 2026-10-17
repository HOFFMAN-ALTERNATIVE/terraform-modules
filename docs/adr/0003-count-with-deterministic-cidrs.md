# 0003. Index subnets with count and a fixed CIDR layout

Status: accepted
Date: 2026-10-17

## Context
Subnets are created per AZ, for 1 to 6 AZs. Reviewers read plans, so subnet
addresses should be predictable from the inputs alone, and the public and private
ranges must never overlap.

## Options
1. `for_each` keyed by AZ name: stable keys, but addresses then depend on how AZ names
   map to indices, and the plan is harder to read in review.
2. Caller-supplied subnet lists: full control, and every caller re-does the CIDR math
   and can get it wrong.
3. `count` over `az_count`, with `cidrsubnet(cidr_block, subnet_newbits, i)` for public
   and `i + 8` for private subnets.

## Decision
Option 3. The address of every subnet follows from three inputs, and the offset of 8
keeps the public and private blocks apart for up to 6 AZs.

## Consequences
- Plans are easy to review: public subnet `i` and private subnet `i` always get the
  same blocks for the same inputs. Overlap is covered by tests.
- Defaults give `/20` subnets out of a `/16`. Changing `subnet_newbits` later moves
  every subnet and forces replacement.
- AZs come from the first `az_count` available zones. If AWS changes that list, indices
  shift and subnets would be replaced. Pin zones yourself if that matters (this is why
  Checkov's CKV_AWS_394 is skipped).
- IPv4 only.
