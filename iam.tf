locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "autoscaler-aws-cluster-autoscaler"
}

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
  role       = var.self_managed_node_groups.general.iam_role_name
  policy_arn = aws_iam_policy.batcave_autoscaler.arn
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "cluster-autoscaler"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
  role_path                     = "/delegatedadmin/developer/"
  role_permissions_boundary_arn = "arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"
}
