resource "aws_s3_bucket" "data_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_object" "airlines_data" {
  bucket = aws_s3_bucket.data_bucket.id
  key    = "airlines.csv"
  source = "airlines.csv" # Assumes airlines.csv is in the same directory as Terraform files
  etag   = filemd5("airlines.csv")
}

resource "aws_iam_role" "glue_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue-s3-access-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = "s3:GetBucketLocation",
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:CreatePartition",
          "glue:BatchCreatePartition",
          "glue:GetUserDefinedFunctions"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_glue_catalog_database" "airlines_db" {
  name = var.glue_database_name
}

resource "aws_glue_crawler" "airlines_crawler" {
  name          = var.glue_crawler_name
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.airlines_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.data_bucket.id}/"
  }

  configuration = <<EOF
{
  "Version": 1.0,
  "CrawlerOutput": {
    "Partitions": { "AddOrUpdateBehavior": "InheritFromTable" },
    "Tables": { "AddOrUpdateBehavior": "MergeNewColumns" }
  },
  "Grouping": {
    "TableGroupingPolicy": "CombineCompatibleSchemas"
  }
}
EOF

  schema_change_policy {
    update_behavior = "LOG"
    delete_behavior = "LOG" # or "DEPRECATE_IN_DATABASE" or "DELETE_FROM_DATABASE"
  }

  depends_on = [
    aws_iam_role_policy.glue_s3_access,
    aws_s3_bucket_object.airlines_data
  ]
}

