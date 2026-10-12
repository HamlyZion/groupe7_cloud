resource "aws_sns_topic" "patching_topic" {
  name = "Group_7_Patching-Notification"
  display_name = "Group_7_Patching-Notification"
}

resource "aws_sns_topic_subscription" "patching_topic_email_target" {
  topic_arn = aws_sns_topic.patching_topic.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}
