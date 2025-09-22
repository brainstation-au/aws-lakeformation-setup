resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [
    data.aws_iam_role.current.arn,
    aws_iam_role.lakeformation_admin.arn,
  ]
}

resource "aws_lakeformation_resource" "this" {
  arn      = module.lakeformation_s3.s3_bucket_arn
  role_arn = aws_iam_role.lakeformation_service_role.arn
}
