resource "aws_iam_policy" "batcave_autoscaler" {
  name = "autoscaler-policy-${var.cluster_name}"
  path = var.iam_path
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "autoscaler_policy_attachment" {
  role       = var.worker_iam_role_name
  policy_arn = aws_iam_policy.batcave_autoscaler.arn
}
