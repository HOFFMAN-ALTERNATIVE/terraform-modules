output "bucket_id" {
  description = "Bucket name (globally unique)."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "Bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "sse_algorithm" {
  description = "Server-side encryption algorithm in effect."
  value       = local.sse_algorithm
}
