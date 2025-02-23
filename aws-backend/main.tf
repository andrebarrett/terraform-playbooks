terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "ts_bucket" {
  bucket        = "terraform-playbooks-state"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "ts_bucket_versioning" {
  bucket = aws_s3_bucket.ts_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ts_bucket_encryption" {
  bucket = aws_s3_bucket.ts_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_dynamodb_table" "tf_state_lock" {
  name = "tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}