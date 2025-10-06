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

resource "aws_glue_catalog_table" "raw_asic_business_names" {
  name          = "raw_asic_business_names"
  database_name = aws_glue_catalog_database.raw_data.name

  storage_descriptor {
    location      = "s3://${module.lakeformation_s3.s3_bucket_id}/raw/asic/business-names/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim"            = "\t"
        "skip.header.line.count" = "1"
      }
    }

    columns {
      name = "register_name"
      type = "string"
    }

    columns {
      name = "bn_name"
      type = "string"
    }

    columns {
      name = "bn_status"
      type = "string"
    }

    columns {
      name = "bn_reg_dt"
      type = "string"
    }

    columns {
      name = "bn_cancel_dt"
      type = "string"
    }

    columns {
      name = "bn_state_num"
      type = "string"
    }

    columns {
      name = "bn_state_of_reg"
      type = "string"
    }

    columns {
      name = "bn_abn"
      type = "string"
    }
  }

  table_type = "EXTERNAL_TABLE"
}
