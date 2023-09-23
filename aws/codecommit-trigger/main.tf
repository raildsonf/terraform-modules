resource "aws_codecommit_trigger" "main" {
  repository_name = var.repository_name

  trigger {
    name            = var.trigger_name
    events          = var.trigger_name
    destination_arn = var.aws_sns_topic
  }
}