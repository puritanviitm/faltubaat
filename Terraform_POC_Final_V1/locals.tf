locals {
  primary_ami_filter_name   = lookup(var.ami_os_options, var.primary_os, "amzn2-ami-hvm*")
  secondary_ami_filter_name = lookup(var.ami_os_options, var.secondary_os, "amzn2-ami-hvm*")
  
  instance_type_primary   = lookup(var.instance_types, var.primary_instance_type, "t2.micro")
  instance_type_secondary = lookup(var.instance_types, var.secondary_instance_type, "t2.micro")
}