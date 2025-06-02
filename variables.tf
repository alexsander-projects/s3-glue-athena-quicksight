variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing the data"
  type        = string
}

variable "iam_role_name" {
  description = "IAM role name for Glue and S3 access"
  type        = string
  default     = "glue-s3-access-role"
}

variable "glue_database_name" {
  description = "AWS Glue database name"
  type        = string
  default     = "airlines_db"
}

variable "glue_crawler_name" {
  description = "AWS Glue crawler name"
  type        = string
  default     = "airlines_crawler"
}

