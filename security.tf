resource "aws_security_group" "elb-external" {
  name        = "${var.name}-tf-${var.environment}-elb-external"
  vpc_id      = "${var.vpc_id}"
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Docker Swarm ELB from outside"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}-tf-${var.environment}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "swarm-cluster" {
  name        = "${var.name}-tf-${var.environment}-swarm-cluster"
  vpc_id      = "${var.vpc_id}"
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Docker Swarm Cluster"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${cidrsubnet(data.aws_vpc.swarm-vpc.cidr_block, 4, 1)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}-tf-${var.environment}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "swarm-manager" {
  name        = "${var.name}-tf-${var.environment}-swarm-manager"
  vpc_id      = "${var.vpc_id}"
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Docker Swarm master"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2377
    to_port   = 2377
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.swarm-node.id}",
    ]
  }

  ingress {
    from_port = 4789
    to_port   = 4789
    protocol  = "udp"

    security_groups = [
      "${aws_security_group.swarm-node.id}",
    ]
  }

  ingress {
    from_port = 7946
    to_port   = 7946
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.swarm-node.id}",
    ]
  }

  ingress {
    from_port = 7946
    to_port   = 7946
    protocol  = "udp"

    security_groups = [
      "${aws_security_group.swarm-node.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}-tf-${var.environment}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "swarm-node" {
  name        = "${var.name}-tf-${var.environment}-swarm-node"
  vpc_id      = "${var.vpc_id}"
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Docker Swarm Nodes"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${cidrsubnet(data.aws_vpc.swarm-vpc.cidr_block, 4, 1)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 2374
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 2376
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}-tf-${var.environment}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
