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

# Permissions for data access role to see and query databases
resource "aws_lakeformation_permissions" "data_access_database_raw" {
  permissions = ["DESCRIBE"]
  principal   = aws_iam_role.lakeformation_data_access.arn

  database {
    name = aws_glue_catalog_database.raw_data.name
  }
}

resource "aws_lakeformation_permissions" "data_access_database_processed" {
  permissions = ["DESCRIBE"]
  principal   = aws_iam_role.lakeformation_data_access.arn

  database {
    name = aws_glue_catalog_database.processed_data.name
  }
}

resource "aws_lakeformation_permissions" "data_access_database_aggregated" {
  permissions = ["DESCRIBE"]
  principal   = aws_iam_role.lakeformation_data_access.arn

  database {
    name = aws_glue_catalog_database.aggregated_data.name
  }
}

# Table-level permissions for data access role
resource "aws_lakeformation_permissions" "data_access_table" {
  permissions = ["SELECT", "DESCRIBE"]
  principal   = aws_iam_role.lakeformation_data_access.arn

  table {
    database_name = aws_glue_catalog_table.raw_asic_business_names.database_name
    name          = aws_glue_catalog_table.raw_asic_business_names.name
  }
}

# Data location access for data access role
resource "aws_lakeformation_permissions" "data_access_location" {
  permissions = ["DATA_LOCATION_ACCESS"]
  principal   = aws_iam_role.lakeformation_data_access.arn

  data_location {
    arn = module.lakeformation_s3.s3_bucket_arn
  }
}
