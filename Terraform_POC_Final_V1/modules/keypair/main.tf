

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated" {
  key_name   = "key-${var.environment}-${var.region}"
  public_key = tls_private_key.key.public_key_openssh
}

output "key_name" {
  value = aws_key_pair.generated.key_name
}