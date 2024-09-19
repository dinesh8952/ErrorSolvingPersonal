provider "aws" {
  region = "us-east-1" # Update to your desired region
}

# Create IAM Group
resource "aws_iam_group" "clops_admins" {
  name = "CLOpsAdmins"
}

# Attach AdministratorAccess policy to the group
resource "aws_iam_group_policy_attachment" "clops_admins_admin_access" {
  group     = aws_iam_group.clops_admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create IAM User
resource "aws_iam_user" "clopes_user" {
  name = "Clopes_user"
}

# Create IAM User Access Key (Password is not supported directly in Terraform)
resource "aws_iam_access_key" "clopes_user_key" {
  user = aws_iam_user.clopes_user.name
}

# Attach user to the group
resource "aws_iam_user_group_membership" "clopes_user_group" {
  user   = aws_iam_user.clopes_user.name
  groups = [aws_iam_group.clops_admins.name]
}

# Create IAM Role for EC2 admin
resource "aws_iam_role" "clops_admin_role" {
  name = "CLopsAdmin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach EC2 Admin policy to the role
resource "aws_iam_role_policy_attachment" "clops_admin_role_policy" {
  role       = aws_iam_role.clops_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Output the user access key (password not stored in Terraform, so retrieve manually)
output "clopes_user_access_key_id" {
  value = aws_iam_access_key.clopes_user_key.id
  sensitive = true
}

output "clopes_user_secret_access_key" {
  value     = aws_iam_access_key.clopes_user_key.secret
  sensitive = true
}
