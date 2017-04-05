resource "aws_dynamodb_table" "dyndb" {
  name           = "${var.name}-tf-${var.environment}-swarm"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "node_type"

  attribute {
    name = "node_type"
    type = "S"
  }

  tags {
    Name        = "demo-landing-tf-${var.environment}"
    Environment = "${var.environment}"
  }
}
