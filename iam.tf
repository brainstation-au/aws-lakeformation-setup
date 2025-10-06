resource "aws_iam_role" "lakeformation_workflow" {
  name        = "LFWorkflowRole"
  description = "Permissions to use LF Workflow feature"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["lakeformation.amazonaws.com", "glue.amazonaws.com"]
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

resource "aws_iam_role_policy" "lakeformation_admin" {
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
          aws_iam_role.lakeformation_service_role.arn,
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

resource "aws_iam_role" "lakeformation_data_access" {
  name = "LakeFormationDataAccessRole"

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

resource "aws_iam_role_policy_attachment" "lakeformation_data_access" {
  for_each = toset([
    "AmazonAthenaFullAccess"
  ])
  role       = aws_iam_role.lakeformation_data_access.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_role_policy" "lakeformation_data_access" {
  name = "LakeFormationDataAccess"
  role = aws_iam_role.lakeformation_data_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lakeformation:GetDataAccess",
          "glue:GetTable",
          "glue:GetTables",
          "glue:SearchTables",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetPartitions",
          "lakeformation:GetResourceLFTags",
          "lakeformation:ListLFTags",
          "lakeformation:GetLFTag",
          "lakeformation:SearchTablesByLFTags",
          "lakeformation:SearchDatabasesByLFTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${module.lakeformation_s3.s3_bucket_arn}",
          "${module.lakeformation_s3.s3_bucket_arn}/output/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lakeformation_service_role" {
  name = "LakeFormationServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lakeformation_service_role" {
  name = "LakeFormationServiceRole"
  role = aws_iam_role.lakeformation_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "${module.lakeformation_s3.s3_bucket_arn}/data/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = module.lakeformation_s3.s3_bucket_arn
      },
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "logs:CreateLogStream",
      #     "logs:CreateLogGroup",
      #     "logs:PutLogEvents"
      #   ]
      #   Resource = "*"
      # },
    ]
  })
}

resource "aws_iam_role" "athena_iam_idc_service_role" {
  name = "AthenaIAMIDCServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "athena_iam_idc_service_role" {
  name = "AthenaIAMIDCServiceAccess"
  role = aws_iam_role.athena_iam_idc_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Athena",
        "Effect" : "Allow",
        "Action" : [
          "athena:GetPreparedStatement",
          "athena:UpdatePreparedStatement",
          "athena:GetNamedQuery",
          "athena:UpdateNamedQuery",
          "athena:ListTableMetadata",
          "athena:GetTableMetadata",
          "athena:ListDatabases",
          "athena:GetDatabase",
          "athena:ListDataCatalogs",
          "athena:GetDataCatalog"
        ],
        "Resource" : [
          "arn:aws:athena:ap-southeast-2:442122590055:workgroup/iam-idc"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      },
      {
        "Sid" : "Glue",
        "Effect" : "Allow",
        "Action" : [
          "glue:CreateDatabase",
          "glue:DeleteDatabase",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:UpdateDatabase",
          "glue:CreateTable",
          "glue:DeleteTable",
          "glue:BatchDeleteTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:BatchCreatePartition",
          "glue:CreatePartition",
          "glue:DeletePartition",
          "glue:BatchDeletePartition",
          "glue:UpdatePartition",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition"
        ],
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      },
      {
        "Sid" : "S3Bucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          module.lakeformation_s3.s3_bucket_arn
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      },
      {
        "Sid" : "S3AccessGrants",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetDataAccess",
          "s3:GetAccessGrantsInstanceForPrefix"
        ],
        "Resource" : [
          "arn:aws:s3:ap-southeast-2:442122590055:access-grants/default"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      },
      {
        "Sid" : "Lakeformation",
        "Effect" : "Allow",
        "Action" : [
          "lakeformation:GetDataAccess"
        ],
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      }
    ]
  })
}
