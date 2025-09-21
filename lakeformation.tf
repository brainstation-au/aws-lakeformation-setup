resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [
    data.aws_iam_role.current.arn
  ]
}
