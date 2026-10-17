# Security

## Reporting

Use GitHub's private "Report a vulnerability" button on this repository. I aim to reply within 72 hours. Please do not open public issues for exploitable misconfigurations.

## Threat model

- **Assets:** the AWS resources these modules create, especially bucket contents and VPC traffic metadata.
- **Actors:** anyone on the internet, and over-privileged principals inside the account.
- **Entry points:** module inputs, the S3 bucket policy, network routes and security groups.
- **Defaults that matter:** all S3 public access blocked, ACLs disabled, encryption on (SSE-S3 or KMS with bucket keys), non-TLS and TLS below 1.2 denied, `force_destroy = false`; default security group stripped of rules, no auto-assigned public IPs, VPC flow logs on with a role scoped to one log group.
- **Verification:** `terraform test` asserts these defaults on every commit, and Checkov runs in CI. Skipped checks and the reasons are listed in the README.

## Not provided

- No state backend configuration. Use an encrypted, versioned, access-logged backend of your own.
- No IAM for workloads or humans. Least privilege for callers is your responsibility.
