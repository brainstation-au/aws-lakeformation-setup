resource "aws_iam_role" "lakeformation_workflow" {
  name        = "LFWorkflowRole"
  description = "Permissions to use LF Workflow feature"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lakeformation_workflow" {
  for_each = toset([
    "service-role/AWSGlueServiceRole"
  ])
  role       = aws_iam_role.lakeformation_workflow.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_role_policy" "lakeformation_workflow" {
  name = "LFWorkflowPermissions"
  role = aws_iam_role.lakeformation_workflow.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lakeformation:GetDataAccess",
          "lakeformation:GrantPermissions"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.lakeformation_workflow.arn
      }
    ]
  })
}

resource "aws_iam_role" "lakeformation_admin" {
  name = "LakeFormationAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lakeformation_admin" {
  for_each = toset([
    "AWSLakeFormationDataAdmin",
    "AWSGlueConsoleFullAccess",
    "CloudWatchLogsReadOnlyAccess",
    "AWSLakeFormationCrossAccountManager",
    "AmazonAthenaFullAccess",
    "AWSCloudFormationReadOnlyAccess"
  ])
  role       = aws_iam_role.lakeformation_admin.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_role_policy" "lakeformation_admin_policy" {
  name = "LakeFormationAdmin"
  role = aws_iam_role.lakeformation_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "lakeformation.amazonaws.com"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "iam:PutRolePolicy"
        Resource = "arn:aws:iam::${local.account_id}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.lakeformation_workflow.arn,
          "arn:aws:iam::${local.account_id}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ram:AcceptResourceShareInvitation",
          "ram:RejectResourceShareInvitation",
          "ec2:DescribeAvailabilityZones",
          "ram:EnableSharingWithAwsOrganization"
        ]
        Resource = "*"
      }
    ]
  })
}
