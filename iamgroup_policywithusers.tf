resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/"
}

resource "aws_iam_group_policy" "my_developer_policy" {
  name  = "my_developer_policy"
  group = aws_iam_group.developers.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "iamassumedrole"
        Resource = aws_iam_role.eks_readonly_role.arn
      },
    ]
  })
}

resource "aws_iam_user" "eksreadonly_user1" {
  name = "${var.env}-eksreadonly1"
  path = "/"
  //force_destroy = true
  tags = {
    name = "${var.env}-localtags"
  }
}

resource "aws_iam_user" "eksreadonly_user2" {
  name = "${var.env}-eksreadonly2"
  path = "/"
  //force_destroy = true
  tags = {
    name = "${var.env}-localtags"
  }
}

resource "aws_iam_group_membership" "eksreadonly" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.eksreadonly_user1.name,
    aws_iam_user.eksreadonly_user2.name
  ]

  group = aws_iam_group.developers.name
}