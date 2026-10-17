########################### ROLE EC2 INSTANCE
data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_secu_ec2" {
  name               = "role_secu_ec2"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name = var.ec2_iam_profile_name
  role = aws_iam_role.role_secu_ec2.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role = aws_iam_role.role_secu_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role = aws_iam_role.role_secu_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_instance_policy" {
  role = aws_iam_role.role_secu_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

################################ ROLE MAINTENANCE WINDOW
data "aws_iam_policy_document" "assume_role_mw" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role_secu_mw" {
  name               = "role_secu_mw"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_mw.json
}

resource "aws_iam_role_policy_attachment" "mw_policy" {
  role       = aws_iam_role.role_secu_mw.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

data "aws_iam_policy_document" "mw_create_image" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateImage", "ec2:DescribeImages"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.role_secu_mw.arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "mw_create_image" {
  name   = "mw-create-image"
  role   = aws_iam_role.role_secu_mw.id
  policy = data.aws_iam_policy_document.mw_create_image.json
}
