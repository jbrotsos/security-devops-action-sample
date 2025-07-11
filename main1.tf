################################################################################
# BADLY-CONFIGURED DEMO TEMPLATE — for Checkov training purposes only
################################################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws   = { source = "hashicorp/aws",   version = "~> 5.0" }
    random = { source = "hashicorp/random" }
  }
}

provider "aws" {
  region = "us-east-1"
}

################################################################################
# 1. Public, unencrypted S3 bucket
################################################################################
resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "insecure-demo-bucket-${random_id.rand.hex}"

  # CKV_AWS_57, CKV_AWS_52: public ACL, no bucket policy restrictions
  acl    = "public-read"

  # CKV_AWS_21: versioning disabled
  versioning {
    enabled = false
  }
}

# CKV_AWS_54: Do *not* block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.public_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

################################################################################
# 2. Wide-open security group
################################################################################
resource "aws_security_group" "open_sg" {
  name        = "open-to-world"
  description = "Allows all traffic from the internet"
  vpc_id      = "vpc-123456"   # replace with a real VPC for a live demo

  # CKV_AWS_24: 0.0.0.0/0 ingress on all ports
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #  CKV_AWS_23: unrestricted egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################################################
