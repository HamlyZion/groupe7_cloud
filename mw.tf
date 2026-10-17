##########################
resource "aws_ssm_maintenance_window" "patch_window" {
  name     = "Group_7_mw"
  description = "Patch MW"
  allow_unassociated_targets = false
  schedule = "cron(00 17 ? * * *)"
  duration = 1
  cutoff   = 0
}

#########################
resource "aws_ssm_maintenance_window_target" "patch_target" {
  window_id     = aws_ssm_maintenance_window.patch_window.id
  name          = "Group_7_target"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Name"
    values = ["Group_7_EC2"]
  }
}

################################
resource "aws_ssm_maintenance_window_task" "patch_task" {
  max_concurrency = 2
  max_errors      = 10
  priority        = 1
  task_arn        = "AWS-CreateImage"
  task_type       = "AUTOMATION"
  window_id       = aws_ssm_maintenance_window.patch_window.id
  service_role_arn = aws_iam_role.role_secu_mw.arn 

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_target.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "InstanceId"
        values = ["{{TARGET_ID}}"]
      }

      parameter {
        name   = "NoReboot"
        values = ["true"]
      }
    }
  }
}

#############################
resource "aws_ssm_maintenance_window_task" "command_task" {
  max_concurrency = 50
  max_errors      = 10
  priority        = 2
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.patch_window.id
  service_role_arn = aws_iam_role.role_secu_mw.arn 

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket     = aws_s3_bucket.reporting_bucket.id
      output_s3_key_prefix = "Patch_history"
      service_role_arn     = aws_iam_role.role_secu_mw.arn
      timeout_seconds      = 600

      notification_config {
        notification_arn    = aws_sns_topic.patching_topic.arn
        notification_events = ["All"]
        notification_type   = "Command"
      }

      parameter {
        name   = "Operation"
        values = ["Install"]
      }

      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }
}
