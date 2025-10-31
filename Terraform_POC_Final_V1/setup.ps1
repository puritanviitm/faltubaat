#!/usr/bin/env pwsh

# Check if AWS CLI is configured
Write-Host "Checking AWS CLI configuration..." -ForegroundColor Yellow
try {
    $callerIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    if (-not $callerIdentity) {
        throw "AWS CLI not configured"
    }
    Write-Host "AWS CLI configured for account: $($callerIdentity.Account)" -ForegroundColor Green
}
catch {
    Write-Host "AWS CLI not configured or credentials invalid" -ForegroundColor Red
    Write-Host "Please run: aws configure" -ForegroundColor Yellow
    exit 1
}

Write-Host "Terraform Multi-Region Setup Tool" -ForegroundColor Green

$ENVIRONMENT = Read-Host "Enter environment (dev/test/prod)"

Write-Host "`nAvailable AWS Regions:" -ForegroundColor Yellow
Write-Host "us-east-1, us-east-2, us-west-1, us-west-2, eu-west-1, eu-central-1, ap-south-1, ap-southeast-1, ap-northeast-1"
$PRIMARY_REGION = Read-Host "Enter Primary AWS Region"
$SECONDARY_REGION = Read-Host "Enter Secondary AWS Region (for failover)"

Write-Host "`nAvailable Instance Sizes:" -ForegroundColor Yellow
Write-Host "nano, micro, small, medium, large, xlarge, 2xlarge, c5, c5a, m5, m5a, r5, r6g, t4g"
$PRIMARY_INSTANCE_SIZE = Read-Host "Select instance size for PRIMARY region"
$SECONDARY_INSTANCE_SIZE = Read-Host "Select instance size for SECONDARY region"

Write-Host "`nAvailable Operating Systems:" -ForegroundColor Yellow
Write-Host "amazon_linux, ubuntu, rhel, windows"
$PRIMARY_OS = Read-Host "Select OS for PRIMARY region"
$SECONDARY_OS = Read-Host "Select OS for SECONDARY region"

Write-Host ""
$DOMAIN_NAME = Read-Host "Enter domain name (e.g. app.example.com)"
$HOSTED_ZONE_ID = Read-Host "Enter Route53 hosted zone ID"

$BACKEND_BUCKET_NAME = "tfstate-$ENVIRONMENT-$PRIMARY_REGION-$(Get-Date -UFormat %s)"
Write-Host "`nCreating S3 backend bucket: $BACKEND_BUCKET_NAME in $PRIMARY_REGION..." -ForegroundColor Yellow

# Create S3 bucket with proper error handling and wait
try {
    # Check if bucket already exists
    $bucketExists = aws s3api head-bucket --bucket "$BACKEND_BUCKET_NAME" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ S3 bucket already exists: $BACKEND_BUCKET_NAME" -ForegroundColor Green
    } else {
        # Create new bucket
        if ($PRIMARY_REGION -eq "us-east-1") {
            # us-east-1 has different syntax
            aws s3api create-bucket `
                --bucket "$BACKEND_BUCKET_NAME" `
                --region "$PRIMARY_REGION" *>$null
        } else {
            aws s3api create-bucket `
                --bucket "$BACKEND_BUCKET_NAME" `
                --region "$PRIMARY_REGION" `
                --create-bucket-configuration LocationConstraint="$PRIMARY_REGION" *>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "S3 bucket created successfully: $BACKEND_BUCKET_NAME" -ForegroundColor Green
            
            # Wait for bucket to be fully created
            Write-Host "Waiting for bucket to be ready..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        } else {
            throw "Failed to create bucket"
        }
    }
}
catch {
    Write-Host "Failed to create or verify S3 bucket: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check your AWS credentials and permissions" -ForegroundColor Yellow
    exit 1
}

# Enable versioning
try {
    aws s3api put-bucket-versioning `
        --bucket "$BACKEND_BUCKET_NAME" `
        --versioning-configuration Status=Enabled *>$null
    Write-Host "Versioning enabled on S3 bucket" -ForegroundColor Green
}
catch {
    Write-Host "Failed to enable versioning" -ForegroundColor Red
}

Write-Host ""

# Create terraform.tfvars
@"
environment         = "$ENVIRONMENT"
primary_region      = "$PRIMARY_REGION"
secondary_region    = "$SECONDARY_REGION"
primary_instance_type = "$PRIMARY_INSTANCE_SIZE"
secondary_instance_type = "$SECONDARY_INSTANCE_SIZE"
primary_os          = "$PRIMARY_OS"
secondary_os        = "$SECONDARY_OS"
domain_name         = "$DOMAIN_NAME"
hosted_zone_id      = "$HOSTED_ZONE_ID"
"@ | Out-File -FilePath "terraform.tfvars" -Encoding UTF8

Write-Host "terraform.tfvars created:" -ForegroundColor Green
Get-Content terraform.tfvars
Write-Host ""

# Create backend.tf
@"
terraform {
  backend "s3" {
    bucket         = "$BACKEND_BUCKET_NAME"
    key            = "state/$ENVIRONMENT.tfstate"
    region         = "$PRIMARY_REGION"
    encrypt        = true
  }
}
"@ | Out-File -FilePath "backend.tf" -Encoding UTF8

Write-Host "Backend configuration file written to backend.tf" -ForegroundColor Green
Write-Host ""

# Remove any existing .terraform directory to force fresh initialization
if (Test-Path ".terraform") {
    Remove-Item -Recurse -Force ".terraform"
    Write-Host "Removed existing .terraform directory" -ForegroundColor Green
}

Write-Host "Initializing Terraform with backend..." -ForegroundColor Yellow
terraform init -reconfigure -input=false

if ($LASTEXITCODE -eq 0) {
    Write-Host "Terraform initialized successfully" -ForegroundColor Green
    Write-Host "`nApplying Terraform configuration..." -ForegroundColor Yellow
    terraform apply -auto-approve
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "=== Deployment Summary ===" -ForegroundColor Cyan
        Write-Host "Primary Region: $PRIMARY_REGION" -ForegroundColor White
        Write-Host "Secondary Region: $SECONDARY_REGION" -ForegroundColor White
        Write-Host "Primary OS: $PRIMARY_OS" -ForegroundColor White
        Write-Host "Secondary OS: $SECONDARY_OS" -ForegroundColor White
        Write-Host "Primary Instance Type: $PRIMARY_INSTANCE_SIZE" -ForegroundColor White
        Write-Host "Secondary Instance Type: $SECONDARY_INSTANCE_SIZE" -ForegroundColor White
        Write-Host "Backend Bucket: $BACKEND_BUCKET_NAME" -ForegroundColor White
        Write-Host "Domain Name: $DOMAIN_NAME" -ForegroundColor White
        Write-Host "Hosted Zone ID: $HOSTED_ZONE_ID" -ForegroundColor White
        Write-Host "Terraform deployment completed successfully!" -ForegroundColor Green
        Write-Host "Terraform state is stored in S3 backend." -ForegroundColor Green
    } else {
        Write-Host " Terraform apply failed" -ForegroundColor Red
    }
} else {
    Write-Host "Terraform initialization failed." -ForegroundColor Red
    Write-Host "Please check for duplicate required_providers blocks in modules" -ForegroundColor Yellow
}