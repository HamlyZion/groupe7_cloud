resource "aws_ssm_patch_baseline" "al_patch" {
  name             = "Group_7_PatchLinuxAmz"
  operating_system = "AMAZON_LINUX_2023"

  approval_rule {
    approve_after_days = 7
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "PRODUCT"
      values = ["AmazonLinux2023"]
    }
  
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }
  
    patch_filter {
      key    = "SEVERITY"
      values = ["Critical"]
    }
  }
}

resource "aws_ssm_patch_group" "al_patch_group" {
  baseline_id = aws_ssm_patch_baseline.al_patch.id
  patch_group = "Group_7_PatchGroupLinuxAmz"
}
