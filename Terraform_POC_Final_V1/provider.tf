terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"  # Changed from >= 4.0 to >= 3.0
    }
  }
}

# Default provider 
provider "aws" {
  region = var.primary_region
}

# Provider for primary region
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

# Provider for secondary region  
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}