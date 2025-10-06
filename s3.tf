resource "random_string" "s3_suffix" {
  length  = 8
  special = false
  upper   = false
}

module "lakeformation_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = "lakeformation-${random_string.s3_suffix.result}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id = "empty-recycle-bin"

      abort_incomplete_multipart_upload_days = 3

      noncurrent_version_expiration = {
        noncurrent_days = 7
      }

      expiration = {
        expired_object_delete_marker = true
      }

      status = "Enabled"
    },
    {
      id     = "empty-athena-results"
      prefix = "output/"
      status = "Enabled"

      expiration = {
        days = 1
      }
    }
  ]
}
