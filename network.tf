data "aws_vpc" "swarm-vpc" {
  id = "${var.vpc_id}"
}
