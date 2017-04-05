data "template_file" "swarm-manager" {
  template = "${file("${path.module}/user_data/swarm-manager.sh.tpl")}"

  vars {
    BASE_SIZE                 = "${var.docker_volume_size}"
    EXTERNAL_LB               = "${var.elb_id}"

    AWS_REGION                = "${var.region}"
    ACCOUNT_ID                = "${var.aws_account}"
    VPC_ID                    = "${var.vpc_id}"

    MANAGER_SECURITY_GROUP_ID = "${aws_security_group.swarm-manager.id}"
    WORKER_SECURITY_GROUP_ID  = "${aws_security_group.swarm-node.id}"

    DYNAMODB_TABLE            = "${aws_dynamodb_table.dyndb.id}"
    SWARM_QUEUE               = "${aws_sqs_queue.swarm-sqs.id}"
    CLEANUP_QUEUE             = "${aws_sqs_queue.swarm-cleanup.id}"

    RUN_VACUUM                = "yes"

    ENABLE_CLOUDWATCH_LOGS    = "no"
    LOG_GROUP_NAME            = "${var.name}-tf-${var.environment}-lg"
  }
}

resource "aws_launch_configuration" "swarm-manager" {
  name_prefix = "${var.name}-${var.environment}-swarm-manager-"

  image_id      = "${lookup(var.image_id, var.region)}"
  instance_type = "${var.instance_type}"
  ebs_optimized = "${var.instance_ebs_optimized}"

  iam_instance_profile = "${aws_iam_instance_profile.ProxyInstanceProfile.name}"
  key_name             = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.swarm-manager.id}",
    "${aws_security_group.swarm-cluster.id}",
  ]

  user_data                   = "${data.template_file.swarm-manager.rendered}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  # root
  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }

  # docker
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = "${var.docker_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "swarm-manager" {
  name = "${var.name}-tf-${var.environment}-swarm-manager"

  launch_configuration = "${aws_launch_configuration.swarm-manager.name}"
  vpc_zone_identifier  = ["${var.external_subnets}"]
  min_size             = 3
  max_size             = 5
  desired_capacity     = 3
  termination_policies = ["OldestLaunchConfiguration", "Default"]

  load_balancers            = ["${var.elb_id}"]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.name}-tf-${var.environment}-swarm-manager"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster"
    value               = "${var.name}-tf-${var.environment}-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "swarm-node-type"
    value               = "master"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_dynamodb_table.dyndb"
  ]
}

resource "aws_autoscaling_policy" "swarm-manager-scale-up" {
  name                   = "${var.name}-tf-${var.environment}-ecs-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.swarm-manager.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "swarm-manager-scale-down" {
  name                   = "${var.name}-tf-${var.environment}-ecs-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.swarm-manager.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "swarm-manager-upgrade" {
  name                   = "${var.name}-tf-${var.environment}-swarm-manager-upgrade-hook"
  autoscaling_group_name = "${aws_autoscaling_group.swarm-manager.name}"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 2000
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"

  notification_target_arn = "${aws_sqs_queue.swarm-sqs.arn}"
  role_arn                = "${aws_iam_role.ProxyRole.arn}"
}
