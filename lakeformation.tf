resource "aws_lakeformation_data_lake_settings" "this" {
  admins = [
    data.aws_iam_role.current.arn,
    aws_iam_role.lakeformation_admin.arn,
  ]
}

resource "aws_lakeformation_resource" "this" {
  arn      = "${module.lakeformation_s3.s3_bucket_arn}/data/"
  role_arn = aws_iam_role.lakeformation_service_role.arn
}

resource "aws_lakeformation_lf_tag" "sensitivity" {
  key    = "sensitivity"
  values = ["pii", "financial", "internal"]
}

resource "aws_lakeformation_lf_tag" "owner" {
  key    = "owner"
  values = ["team_a", "team_b", "team_c"]
}

resource "aws_lakeformation_resource_lf_tags" "raw_data" {
  database {
    name = aws_glue_catalog_database.raw_data.name
  }

  lf_tag {
    key   = "sensitivity"
    value = "internal"
  }

  lf_tag {
    key   = "owner"
    value = "team_b"
  }
}

resource "aws_lakeformation_resource_lf_tags" "raw_asic_business_names" {
  table {
    database_name = aws_glue_catalog_database.raw_data.name
    name          = aws_glue_catalog_table.raw_asic_business_names.name
  }

  lf_tag {
    key   = "sensitivity"
    value = "internal"
  }

  lf_tag {
    key   = "owner"
    value = "team_b"
  }
}

resource "aws_lakeformation_permissions" "raw_data" {
  principal   = aws_iam_role.lakeformation_data_access.arn
  permissions = ["DESCRIBE"]

  lf_tag_policy {
    resource_type = "DATABASE"

    expression {
      key    = "sensitivity"
      values = ["internal"]
    }

    expression {
      key    = "owner"
      values = ["team_c"]
    }
  }
}

resource "aws_lakeformation_permissions" "raw_asic_business_names" {
  principal   = aws_iam_role.lakeformation_data_access.arn
  permissions = ["DESCRIBE", "SELECT"]

  lf_tag_policy {
    resource_type = "TABLE"

    expression {
      key    = "sensitivity"
      values = ["internal"]
    }
  }
}
