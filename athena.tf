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
