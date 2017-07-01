# General Settings
variable "aws_account" {
  description = "The AWS Account to use"
}

variable "environment" {
  description = "Desired environment to use in custom ids and names EG: \"staging\""
  default     = "dev"
}

variable "name" {
  description = "The cluster name, e.g cdn"
}

variable "ssh_key_name" {
  description = "The aws ssh key name."
}

variable "region" {
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

# Swarm config
variable "image_id" {
  default = {
    eu-central-1 = "ami-2acd1845"
    us-east-2    = "ami-fcc19b99"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_ebs_optimized" {
  description = "When set to true the instance will be launched with EBS optimized turned on"
  default     = false
}

variable "autoscale_min" {
  default     = "2"
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
  default     = "10"
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
  default     = "2"
  description = "Desired autoscale (number of EC2)"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  default     = 20
}

variable "docker_volume_size" {
  description = "Attached EBS volume size in GB"
  default     = 30
}

# Network
variable "vpc_id" {
  description = "ID of the VPC to use"
}

variable "external_subnets" {
  description = "External subnets of the VPC"
  type        = "list"
}

variable "associate_public_ip_address" {
  description = "Should created instances be publicly accessible (if the SG allows)"
  default     = false
}

variable "elb_id" {
  description = "External ELB to use to balance the cluster"
}

# Network Security
variable "ingress_allow_security_groups" {
  description = "A list of security group IDs to allow traffic from"
  type        = "list"
  default     = []
}

variable "ingress_allow_cidr_blocks" {
  description = "A list of CIDR blocks to allow traffic from"
  type        = "list"
  default     = []
}
