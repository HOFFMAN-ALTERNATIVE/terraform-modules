# 0001. Test modules against mocked providers, not a sandbox account

Status: accepted
Date: 2026-10-17

## Context
The modules must be tested on every commit, including from forks, with no cloud
credentials in CI and no bill. The logic worth testing is ours: CIDR math, NAT
topology, policies, tags and input validation.

## Options
1. Terratest against a real AWS sandbox: proves AWS accepts the plan, but needs
   long-lived credentials in CI, minutes per run, cleanup of leaked resources and a budget.
2. `terraform validate` and linters only: free, but proves syntax, not behaviour.
3. Native `terraform test` with `mock_provider "aws"`: deterministic and free,
   asserts on planned values and on `expect_failures` for each validation rule.

## Decision
Option 3, run on two Terraform versions (1.9 and 1.12), with tflint and Checkov next
to it. It tests what the modules decide, which is where the bugs would be ours.

## Consequences
- 28 test runs across three modules and the full example, with no credentials.
- Fork PRs get the same CI as the main branch.
- Mocks accept anything AWS would reject: quotas, SCPs, region quirks, invalid
  combinations the provider only catches at apply time.
- A real-account smoke test is still needed before a release that changes resources.
  It belongs in a separate pipeline with manual approval.
