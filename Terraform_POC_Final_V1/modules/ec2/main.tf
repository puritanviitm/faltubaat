data "aws_ami" "os_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  user_data_script = (
    var.selected_os == "ubuntu" ? templatefile("${path.module}/user_data/ubuntu.sh", {
      region      = var.region
      environment = var.environment
    }) :
    var.selected_os == "rhel" || var.selected_os == "amazon_linux" ? templatefile("${path.module}/user_data/amazon_linux.sh", {
      region      = var.region
      environment = var.environment
    }) :
    var.selected_os == "windows" ? templatefile("${path.module}/user_data/windows.ps1", {
      region      = var.region
      environment = var.environment
    }) :
    "#!/bin/bash\necho 'Unsupported OS'"
  )
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.os_image.id
  instance_type               = var.instance_type
  key_name                    = var.keypair_name
  iam_instance_profile        = var.iam_profile_name
  subnet_id                   = var.subnet_ids[0]  # Use first subnet from the list
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  user_data                   = local.user_data_script

  tags = {
    Name        = "web-${var.environment}-${var.region}"
    Environment = var.environment
  }
}


resource "aws_eip_association" "web_eip_assoc" {
  count         = var.eip_id != "" ? 1 : 0
  instance_id   = aws_instance.web.id
  allocation_id = var.eip_id
}

output "instance_dns" {
  value = aws_instance.web.public_dns
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}

# Output for instance IDs (for ALB target group)
output "instance_ids" {
  value = [aws_instance.web.id]
}