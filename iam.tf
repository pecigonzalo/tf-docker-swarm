# Render policies
data "aws_iam_policy_document" "DynDBPolicies" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
    ]

    resources = [
      "${aws_dynamodb_table.dyndb.arn}",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "SwarmSQSCleanupPolicy" {
  statement {
    actions = [
      "sqs:*",
    ]

    resources = [
      "${aws_sqs_queue.swarm-cleanup.arn}",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "SwarmSQSPolicy" {
  statement {
    actions = [
      "sqs:*",
    ]

    resources = [
      "${aws_sqs_queue.swarm-sqs.arn}",
    ]

    effect = "Allow"
  }
}

# Policies
resource "aws_iam_role" "ProxyRole" {
  name               = "${var.name}-tf-${var.environment}-ProxyRole"
  assume_role_policy = "${file("${path.module}/policies/ProxyRole.json")}"
}

resource "aws_iam_instance_profile" "ProxyInstanceProfile" {
  name = "${var.name}-tf-${var.environment}-ProxyInstanceProfile"
  role = "${aws_iam_role.ProxyRole.name}"
}

resource "aws_iam_role_policy" "ProxyPolicies" {
  name   = "${var.name}-tf-${var.environment}-ProxyPolicies"
  policy = "${file("${path.module}/policies/ProxyPolicies.json")}"
  role   = "${aws_iam_role.ProxyRole.name}"
}

resource "aws_iam_role_policy" "DynDBPolicies" {
  name   = "${var.name}-tf-${var.environment}-DynDBPolicies"
  policy = "${data.aws_iam_policy_document.DynDBPolicies.json}"
  role   = "${aws_iam_role.ProxyRole.name}"

  depends_on = [
    "aws_dynamodb_table.dyndb",
  ]
}

resource "aws_iam_role_policy" "SwarmAPIPolicy" {
  name   = "${var.name}-tf-${var.environment}-SwarmAPIPolicy"
  policy = "${file("${path.module}/policies/SwarmAPIPolicy.json")}"
  role   = "${aws_iam_role.ProxyRole.name}"
}

resource "aws_iam_role_policy" "SwarmAutoscalePolicy" {
  name   = "${var.name}-tf-${var.environment}-SwarmAutoscalePolicy"
  policy = "${file("${path.module}/policies/SwarmAutoscalePolicy.json")}"
  role   = "${aws_iam_role.ProxyRole.name}"
}

resource "aws_iam_role_policy" "SwarmSQSCleanupPolicy" {
  name   = "${var.name}-tf-${var.environment}-SwarmSQSCleanupPolicy"
  policy = "${data.aws_iam_policy_document.SwarmSQSCleanupPolicy.json}"
  role   = "${aws_iam_role.ProxyRole.name}"
}

resource "aws_iam_role_policy" "SwarmSQSPolicy" {
  name   = "${var.name}-tf-${var.environment}-SwarmSQSPolicy"
  policy = "${data.aws_iam_policy_document.SwarmSQSPolicy.json}"
  role   = "${aws_iam_role.ProxyRole.name}"
}
