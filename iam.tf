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

resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role = aws_iam_role.role_secu_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
