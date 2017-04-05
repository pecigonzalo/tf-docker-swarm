variable "cloudflare_email" {}

variable "cloudflare_token" {}

variable "ssh_key_name" {}

variable "aws_account" {}

variable "region" {
  default = "us-east-2"
}

variable "environment" {
  default = "testENV"
}

variable "name" {
  default = "swarm"
}

variable "dns_name" {
  default = "swarmcluster"
}

variable "domain" {}
