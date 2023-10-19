locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "autoscaler-aws-cluster-autoscaler"
}

module "iam_assumable_role_admin" {
  ##  https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name                        = "${var.cluster_name}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]
  role_path                        = var.iam_path
  role_permissions_boundary_arn    = var.permissions_boundary
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
    }
  }
}
