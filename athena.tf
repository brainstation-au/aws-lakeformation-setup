resource "aws_athena_workgroup" "this" {
  name = "racq"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.lakeformation_s3.s3_bucket_id}/output/"
    }
  }
}

resource "aws_athena_workgroup" "iam_idc" {
  name = "iam-idc"

  configuration {
    execution_role = aws_iam_role.athena_iam_idc_service_role.arn
    identity_center_configuration {
      enable_identity_center       = true
      identity_center_instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
    }

    result_configuration {
      output_location = "s3://${module.lakeformation_s3.s3_bucket_id}/output/"
      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }
    }
  }
}
