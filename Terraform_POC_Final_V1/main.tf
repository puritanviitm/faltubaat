module "s3_primary" {
  source      = "./modules/s3_backend"
  providers   = {
    aws = aws.primary
  }
  region      = var.primary_region
  environment = var.environment
}

module "s3_secondary" {
  source      = "./modules/s3_backend"
  providers   = {
    aws = aws.secondary
  }
  region      = var.secondary_region
  environment = var.environment
}

module "vpc_primary" {
  source      = "./modules/vpc"
  providers   = {
    aws = aws.primary
  }
  region      = var.primary_region
  environment = var.environment
  vpc_cidr    = "10.1.0.0/16"
  hosted_zone_id = var.hosted_zone_id  
}

module "vpc_secondary" {
  source      = "./modules/vpc"
  providers   = {
    aws = aws.secondary
  }
  region      = var.secondary_region
  environment = var.environment
  vpc_cidr    = "10.2.0.0/16"
  hosted_zone_id = var.hosted_zone_id  
}

module "iam_primary" {
  source      = "./modules/iam"
  providers   = {
    aws = aws.primary
  }
  region      = var.primary_region
  environment = var.environment
}

module "key_primary" {
  source      = "./modules/keypair"
  providers   = {
    aws = aws.primary
  }
  region      = var.primary_region
  environment = var.environment
}

module "iam_secondary" {
  source      = "./modules/iam"
  providers   = {
    aws = aws.secondary
  }
  region      = var.secondary_region
  environment = var.environment
}

module "key_secondary" {
  source      = "./modules/keypair"
  providers   = {
    aws = aws.secondary
  }
  region      = var.secondary_region
  environment = var.environment
}

module "dynamodb" {
  source           = "./modules/dynamodb"
  providers        = {
    aws = aws.primary
  }
  environment      = var.environment
  secondary_region = var.secondary_region
}

module "ec2_primary" {
  source           = "./modules/ec2"
  providers        = {
    aws = aws.primary
  }
  region           = var.primary_region
  environment      = var.environment
  selected_os      = var.primary_os
  ami_name_filter  = local.primary_ami_filter_name
  instance_type    = local.instance_type_primary
  keypair_name     = module.key_primary.key_name
  iam_profile_name = module.iam_primary.iam_profile_name
  vpc_id           = module.vpc_primary.vpc_id
  subnet_ids       = module.vpc_primary.public_subnet_ids  # Change back to subnet_ids
  security_group_ids = [module.vpc_primary.web_security_group_id]
}

module "ec2_secondary" {
  source           = "./modules/ec2"
  providers        = {
    aws = aws.secondary
  }
  region           = var.secondary_region
  environment      = var.environment
  selected_os      = var.secondary_os
  ami_name_filter  = local.secondary_ami_filter_name
  instance_type    = local.instance_type_secondary
  keypair_name     = module.key_secondary.key_name
  iam_profile_name = module.iam_secondary.iam_profile_name
  vpc_id           = module.vpc_secondary.vpc_id
  subnet_ids       = module.vpc_secondary.public_subnet_ids  # Change back to subnet_ids
  security_group_ids = [module.vpc_secondary.web_security_group_id]
}


module "alb_primary" {
  source           = "./modules/alb"
  providers        = {
    aws = aws.primary
  }
  region           = var.primary_region
  environment      = var.environment
  vpc_id           = module.vpc_primary.vpc_id
  subnet_ids       = module.vpc_primary.public_subnet_ids
  security_group_ids = [module.vpc_primary.alb_security_group_id]
  instance_ids     = module.ec2_primary.instance_ids
  domain_name      = var.domain_name
}

module "alb_secondary" {
  source           = "./modules/alb"
  providers        = {
    aws = aws.secondary
  }
  region           = var.secondary_region
  environment      = var.environment
  vpc_id           = module.vpc_secondary.vpc_id
  subnet_ids       = module.vpc_secondary.public_subnet_ids
  security_group_ids = [module.vpc_secondary.alb_security_group_id]
  instance_ids     = module.ec2_secondary.instance_ids
  domain_name      = var.domain_name
}

module "route53" {
  source            = "./modules/route53"
  providers        = {
    aws = aws.primary
  }
  primary_alb_dns   = module.alb_primary.alb_dns_name
  primary_alb_zone_id = module.alb_primary.alb_zone_id
  secondary_alb_dns = module.alb_secondary.alb_dns_name
  secondary_alb_zone_id = module.alb_secondary.alb_zone_id
  hosted_zone_id    = var.hosted_zone_id
  domain_name       = var.domain_name
}

output "primary_alb_url" {
  description = "Primary ALB URL"
  value       = "http://${module.alb_primary.alb_dns_name}"
}

output "secondary_alb_url" {
  description = "Secondary ALB URL"
  value       = "http://${module.alb_secondary.alb_dns_name}"
}

output "primary_instance_url" {
  description = "Primary instance direct URL"
  value       = "http://${module.ec2_primary.instance_ip}"
}

output "secondary_instance_url" {
  description = "Secondary instance direct URL"
  value       = "http://${module.ec2_secondary.instance_ip}"
}

output "route53_domain" {
  description = "Route53 domain URL"
  value       = "http://${var.domain_name}"
}

output "deployment_summary" {
  description = "Deployment summary"
  value = <<EOT
Multi-Region Deployment Complete!

Primary Region (${var.primary_region}):
  ALB URL: http://${module.alb_primary.alb_dns_name}
  Instance: http://${module.ec2_primary.instance_ip}
  OS: ${var.primary_os}

Secondary Region (${var.secondary_region}):
  ALB URL: http://${module.alb_secondary.alb_dns_name}
  Instance: http://${module.ec2_secondary.instance_ip}
  OS: ${var.secondary_os}

Route53 Domain: http://${var.domain_name}

Access application via the Route53 domain for automatic failover.
EOT
}