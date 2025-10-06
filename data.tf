data "aws_caller_identity" "current" {}

data "aws_iam_role" "current" {
  name = regex("assumed-role/(.*?)/", data.aws_caller_identity.current.arn)[0]
}

data "aws_iam_roles" "roles" {
  name_regex  = "AWSReservedSSO_Redshift_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}
