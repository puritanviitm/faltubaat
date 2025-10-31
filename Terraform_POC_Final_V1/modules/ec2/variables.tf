variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ami_name_filter" {
  description = "AMI name filter"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "keypair_name" {
  description = "Key pair name"
  type        = string
}

variable "iam_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "selected_os" {
  description = "Selected operating system"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "eip_id" {
  description = "Elastic IP allocation ID"
  type        = string
  default     = ""
}