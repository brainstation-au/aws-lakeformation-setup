resource "aws_glue_catalog_database" "raw_data" {
  name         = "raw"
  description  = "Database for raw data"
  location_uri = "${module.lakeformation_s3.s3_bucket_arn}/raw/"
}

resource "aws_glue_catalog_database" "processed_data" {
  name         = "processed"
  description  = "Database for processed data"
  location_uri = "${module.lakeformation_s3.s3_bucket_arn}/processed/"
}

resource "aws_glue_catalog_database" "aggregated_data" {
  name         = "aggregated"
  description  = "Database for aggregated data"
  location_uri = "${module.lakeformation_s3.s3_bucket_arn}/aggregated/"
}
