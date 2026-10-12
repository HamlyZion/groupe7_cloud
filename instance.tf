resource "aws_instance" "amazon-linux" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_groups
  iam_instance_profile = aws_iam_instance_profile.ec2_iam_profile.name 

  tags = {
    Name = "Group_7_EC2"
    Patch_Group = "Group_7_PatchLinuxAmz" 
  }
}
