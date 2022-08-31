locals {
  # List of all node_sets except general (to ensure general is always [0])
  self_managed_node_sets = [for k, v in var.self_managed_node_groups : {
    name    = v.autoscaling_group_name
    minSize = v.autoscaling_group_min_size
    maxSize = v.autoscaling_group_max_size
    } if k != "general"
  ]
}
resource "helm_release" "autoscaler" {
  namespace = var.helm_namespace

  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "resources.limits.cpu"
    value = "50m"
  }
  set {
    name  = "resources.limits.memory"
    value = "150Mi"
  }
  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }
  set {
    name  = "resources.requests.memory"
    value = "89.7Mi"
  }

  set {
    name  = "tolerations[0].key"
    value = "CriticalAddonsOnly"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.iam_role_arn
  }

 # workaround added due to bug in latest version https://github.com/kubernetes/autoscaler/issues/5128
  set {
    name = "cloudConfigPath"
    value = "false"
  }
  set {
    name  = "extraArgs.expander"
    value = var.autoscaler_expander_method
  }
  dynamic "set" {
    for_each = var.extraArgs
    content {
      name  = "extraArgs.${set.key}"
      value = set.value
    }
  }
}

