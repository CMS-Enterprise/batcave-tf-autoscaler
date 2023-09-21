locals {
  # List of all node_sets except general (to ensure general is always [0])
  self_managed_node_sets = [
    for k, v in var.self_managed_node_groups : {
      name    = v.autoscaling_group_name
      minSize = v.autoscaling_group_min_size
      maxSize = v.autoscaling_group_max_size
    } if k != "general"
  ]

  version_tag_map = {
    # Update the map for new versions here: https://github.com/kubernetes/autoscaler/releases
    "1.24" = "v1.24.2"
    "1.25" = "v1.25.3"
    "1.26" = "v1.26.4"
    "1.27" = "v1.27.3"
    "1.28" = "v1.28.0"
  }
  latest_cluster_version = sort(keys(local.version_tag_map))[length(local.version_tag_map) - 1]
  latest_image_version   = lookup(local.version_tag_map, local.latest_cluster_version, "v1.28.0")
}
resource "helm_release" "autoscaler" {
  namespace = var.helm_namespace

  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  set {
    name  = "serviceMonitor.enabled"
    value = "false"
  }
  set {
    name  = "prometheusRule.enabled"
    value = "false"
  }
  set {
    name  = "image.tag"
    value = lookup(local.version_tag_map, var.cluster_version, local.latest_image_version)
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "resources.limits.cpu"
    value = var.cpu_limits
  }
  set {
    name  = "resources.limits.memory"
    value = var.memory_limits
  }
  set {
    name  = "resources.requests.cpu"
    value = var.cpu_requests
  }
  set {
    name  = "resources.requests.memory"
    value = var.memory_requests
  }

  set {
    name  = "tolerations[0].key"
    value = "bat_app"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[0].value"
    value = "utility_belt"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[1].key"
    value = "CriticalAddonsOnly"
  }

  set {
    name  = "tolerations[1].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[1].effect"
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
    name  = "cloudConfigPath"
    value = "false"
  }
  set {
    name  = "extraArgs.expander"
    value = var.autoscaler_expander_method
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  
  dynamic "set" {
    for_each = var.extraArgs
    content {
      name  = "extraArgs.${set.key}"
      value = set.value
    }
  }
}
