# 1. KMS Key for Server-Side Encryption (Resolves CKV_AWS_145)
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for secure S3 bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

# Main Bucket Definition
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-test-checkov-bucket-secure-1234"
}

# 2. KMS Default Encryption Configuration (Resolves CKV_AWS_145)
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_crypto" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# 3. Lifecycle Rule Configuration (Resolves CKV2_AWS_61)
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

# 4. Access Logging Bucket & Configuration (Resolves CKV_AWS_18)
resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-test-checkov-bucket-logs-1234"
}

resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

# 5. Event Notifications (Resolves CKV2_AWS_62)
resource "aws_sns_topic" "bucket_topic" {
  name = "s3-event-notification-topic"
}

resource "aws_s3_bucket_notification" "secure_bucket_notification" {
  bucket = aws_s3_bucket.secure_bucket.id

  topic {
    topic_arn = aws_sns_topic.bucket_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}