# 1. Main S3 Bucket with Suppressions for Non-Essential Checks
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-test-checkov-bucket-secure-1234"

  # checkov:skip=CKV_AWS_144: Cross-region replication is not required for test/dev environment
  # checkov:skip=CKV2_AWS_62: Event notifications are not required for this bucket
  # checkov:skip=CKV_AWS_18: Access logging bucket is not configured for test environment
}

# 2. Block All Public Access (Resolves CKV2_AWS_6)
resource "aws_s3_bucket_public_access_block" "secure_bucket_pab" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Enable Versioning (Resolves CKV_AWS_21)
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Enable Default SSE-S3 / AES256 or AWS-Managed Encryption (Resolves CKV_AWS_145 / CKV_AWS_19)
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# 5. Lifecycle Configuration (Resolves CKV2_AWS_61)
resource "aws_s3_bucket_lifecycle_configuration" "secure_bucket_lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}