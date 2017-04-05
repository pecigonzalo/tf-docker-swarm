resource "aws_sqs_queue" "swarm-sqs" {
  name                      = "${var.name}-tf-${var.environment}-swarm-sqs"
  message_retention_seconds = 43200
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "swarm-cleanup" {
  name                      = "${var.name}-tf-${var.environment}-swarm-cleanup"
  message_retention_seconds = 43200
  receive_wait_time_seconds = 10
}
