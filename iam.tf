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

data "aws_iam_policy_document" "put_object_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.reporting_bucket.arn}/Patch_history/*"]
  }
}

resource "aws_iam_role_policy" "put_object_s3" {
  name   = "put_object_s3"
  role   = aws_iam_role.role_secu_ec2.id
  policy = data.aws_iam_policy_document.put_object_s3.json
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

data "aws_iam_policy_document" "publish_on_topic" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.patching_topic.arn]
  }
}

resource "aws_iam_role_policy" "publish_on_topic" {
  name   = "publish_on_topic"
  role   = aws_iam_role.role_secu_mw.id
  policy = data.aws_iam_policy_document.publish_on_topic.json
}
