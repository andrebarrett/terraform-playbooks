variable "region" {
  description = "Default region for provider"
  type = string
  default = "us-east-1"
}

variable "ami" {
    description = "ID for AWS machine image to deploy on instance"
    type = string
    default = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
}

variable "instance_type" {
  description = "The type of instance launched on AWS"
  type = string
  default = "t2.micro"
}

# variable "bucket_prefix" {
#   description = "prefix of s3 bucket"
#   type = string
# }

# variable "domain" {
#   description = "Route 53 Zone to be created"
#   type = string
# }


# variable "db_name" {
#   description = "Database name inside of RDS"
#   type = string
# }

# variable "db_user" {
#   description = "Database user inside of RDS"
#   type = string
# }

# variable "db_pass" {
#   description = "Database password inside of RDS"
#   type = string
# }

variable "cidr_block" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(map(any))
  description = "Public subnets to be created in the vpc"
  default = [
    { name="public-1", block= "10.0.0.0/20", az="us-east-1a"},
    { name="public-2", block= "10.0.16.0/20", az="us-east-1b" },
    { name="public-3", block= "10.0.32.0/20", az="us-east-1c" },
    { name="public-4", block= "10.0.48.0/20", az="us-east-1d" }
  ]
}


variable "private_subnets" {
  type = list(map(any))
  description = "Private subnets to be created in the vpc"
  default = [
    { name="private-1", block= "10.0.80.0/20", az="us-east-1a"},
    { name="private-2", block= "10.0.96.0/20", az="us-east-1b" },
    { name="private-3", block= "10.0.112.0/20", az="us-east-1c" },
    { name="private-4", block= "10.0.128.0/20", az="us-east-1d" }
  ]
}