resource "aws_s3_bucket" "s3_example" {
  bucket = "azmi1-terraform-ci-bucket-20241030"
  #checkov:skip=CKV2_AWS_62:Skip event notifications
  #checkov:skip=CKV_AWS_144:Skip cross-region replication
  #checkov:skip=CKV_AWS_145:Skip KMS encryption
  #checkov:skip=CKV_AWS_18:Skip Access Logging
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_example.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.s3_example.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle_config" {
  bucket = aws_s3_bucket.s3_example.id

  rule {
    id     = "expire"
    status = "Enabled"
    filter {
      prefix = "logs/"
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 90
    }
  }
  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {}
    id     = "log"
    status = "Enabled"
  }

}