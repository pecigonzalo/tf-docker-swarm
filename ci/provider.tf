provider "aws" {
  region = "${var.region}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

module "vpc" {
  source = "../modules/tf-vpc"

  environment = "${var.environment}"
  name        = "${var.name}"
}

module "elb" {
  source = "../modules/tf-elb"

  # General settings
  environment = "${var.environment}"
  name        = "${var.name}"
  internal    = false

  # Network
  subnet_ids      = ["${module.vpc.external_subnets}"]
  security_groups = ["${module.docker-swarm.security_group_id}"]

  # External Settings
  dns_name = "${var.dns_name}"
  domain   = "${var.domain}"

  # Node checks
  port                = 44554
  healthcheck_path    = "/"
  protocol            = "HTTP"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 2
  interval            = 10
}

module "docker-swarm" {
  source = "../"

  name         = "${var.name}"
  environment  = "${var.environment}"
  region       = "${var.region}"
  ssh_key_name = "${var.ssh_key_name}"
  aws_account  = "${var.aws_account}"

  vpc_id           = "${module.vpc.id}"
  external_subnets = "${module.vpc.external_subnets}"

  elb_id = "${module.elb.id}"
}
