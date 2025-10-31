resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-${var.environment}-${var.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "profile" {
  name = "ec2-profile-${var.environment}-${var.region}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ])
  role       = aws_iam_role.ec2_role.name
  policy_arn = each.key
}

output "iam_profile_name" {
  value = aws_iam_instance_profile.profile.name
}