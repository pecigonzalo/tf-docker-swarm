/*# General
output "name" {
  value = "${var.name}"
}

output "environment" {
  value = "${var.environment}"
}

# Swarm

output "iam_role" {
  value = "${aws_iam_role.ecs_service_role.arn}"
}

# Network
output "vpc" {
  value = "${aws_vpc.main.id}"
}

output "subnets" {
  value = ["${aws_subnet.main.*.id}"]
}

output "cidr_blocks" {
  value = "${aws_vpc.main.cidr_block}"
}
*/

# Security
output "security_group_id" {
  value = "${aws_security_group.elb-external.id}"
}
