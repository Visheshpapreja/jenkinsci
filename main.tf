provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"

  module "iam_account" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-account"

  account_alias = "Production"

  minimum_password_length = 37
  require_numbers         = false
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_arns = [
    "arn:aws:iam::307990089504:root",

  ]

  create_role = true

  role_name         = "Prod-ci-role"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonCognitoReadOnly",
  ]
  number_of_custom_role_policy_arns = 2
}



module "iam_assumable_roles" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"

  trusted_role_arns = [
    "arn:aws:iam::307990089504:root",
  ]

  create_admin_role = true

  create_poweruser_role = true
  poweruser_role_name   = "prod-dev"

  create_readonly_role       = true
  readonly_role_requires_mfa = false
}



module "iam_group_with_assumable_roles_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"

  name = "prod-readonly"

  assumable_roles = [
    "arn:aws:iam::835367859855:role/readonly"  # these roles can be created using `iam_assumable_roles` submodule
  ]

  group_users = [
    "user1",
    "user2"
  ]
}


module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name = "prodadmins"

  group_users = [
    "user1",
    "user2"
  ]

  attach_iam_self_management_policy = true

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  custom_group_policies = [
    {
      name   = "AllowS3Listing"
      policy = data.aws_iam_policy_document.sample.json
    }
  ]
}


module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "prod-co"
  path        = ""
  description = "prod-ci-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"

  name          = "prod-user"
  force_destroy = true

  pgp_key = "keybase:test"

  password_reset_required = false
}

#  resource "aws_instance" "Ec2" {
#  ami           = ami-084e8c05825742534.id
#  instance_type = "t2.micro"

#  tags = {
#    Name = "HelloWorld"
#  }
#}

  # (Optional) the MFA token for Account A.
  # token      = "123456"

#  assume_role {
    # The role ARN within Account B to AssumeRole into. Created in step 1.
#    role_arn    = "arn:aws:iam::01234567890:role/role_in_account_b"
    # (Optional) The external ID created in step 1c.
#    external_id = "my_external_id"
#  }
}
