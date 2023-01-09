resource "aws_iam_user" "user" {
 count = "${length(var.user_names)}"
 name = "${element(var.user_names, count.index)}"
}

resource "aws_iam_access_key" "newemp" {
  count = "${length(var.user_names)}"
  user = "${element(var.user_names,count.index)}"
}

resource "aws_iam_group" "dev_group" {
  name = "${var.environment}-group"
}

 resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = false
  allow_users_to_change_password = true
}


resource "aws_iam_role" "role" {
  name = "${var.environment}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "policy" {
  name        = "${var.environment}-ec2"
  description = "${var.environment}-policy"

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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_group_policy_attachment" "custom_policy" {
  group      = aws_iam_group.dev_group.name
  policy_arn = aws_iam_policy.policy.arn
}


resource "aws_iam_group_membership" "team" {
  group = aws_iam_group.dev_group.name
  users = var.user_names
  name = "tf-testing-group-membership"
}