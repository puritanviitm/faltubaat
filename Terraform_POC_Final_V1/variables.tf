variable "available_regions" {
  description = "Available AWS regions"
  type = map(string)
  default = {
    "us-east-1"      = "US East (N. Virginia)"
    "us-east-2"      = "US East (Ohio)"
    "us-west-1"      = "US West (N. California)"
    "us-west-2"      = "US West (Oregon)"
    "eu-west-1"      = "Europe (Ireland)"
    "eu-central-1"   = "Europe (Frankfurt)"
    "ap-south-1"     = "Asia Pacific (Mumbai)"
    "ap-southeast-1" = "Asia Pacific (Singapore)"
    "ap-northeast-1" = "Asia Pacific (Tokyo)"
  }
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region (failover)"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "ami_os_options" {
  description = "OS filter options for AMI lookup"
  type        = map(string)
  default = {
    "amazon_linux" = "amzn2-ami-hvm*"
    "ubuntu"       = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    "rhel"         = "RHEL-9.*x86_64*"
    "windows"      = "Windows_Server-2019-English-Full-Base-*"
  }
}

variable "primary_os" {
  description = "Select OS for primary region: amazon_linux | ubuntu | rhel | windows"
  type        = string
}

variable "secondary_os" {
  description = "Select OS for secondary region: amazon_linux | ubuntu | rhel | windows"
  type        = string
}

variable "instance_types" {
  description = "All major AWS EC2 instance types by size"
  type = map(string)
  default = {
    "nano"     = "t3.nano"
    "micro"    = "t2.micro"
    "small"    = "t3.small"
    "medium"   = "t3.medium"
    "large"    = "t3.large"
    "xlarge"   = "t3.xlarge"
    "2xlarge"  = "t3.2xlarge"
    "c5"       = "c5.large"
    "c5a"      = "c5a.large"
    "m5"       = "m5.large"
    "m5a"      = "m5a.large"
    "r5"       = "r5.large"
    "r6g"      = "r6g.large"
    "t4g"      = "t4g.micro"
  }
}

variable "primary_instance_type" {
  description = "Choose your instance size for primary region (nano, micro, small, medium, etc.)"
  type        = string
}

variable "secondary_instance_type" {
  description = "Choose your instance size for secondary region (nano, micro, small, medium, etc.)"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route53 failover"
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID for Route53"
  type        = string
}