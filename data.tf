data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "this" {}

data "aws_iam_role" "current" {
  name = regex("assumed-role/(.*?)/", data.aws_caller_identity.current.arn)[0]
}
