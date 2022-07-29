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

  # Ensure general is the first autoscaling Group
  set {
    name  = "autoscalingGroups[0].name"
    value = var.self_managed_node_groups.general.autoscaling_group_name
  }
  set {
    name  = "autoscalingGroups[0].minSize"
    value = var.self_managed_node_groups.general.autoscaling_group_min_size
  }
  set {
    name  = "autoscalingGroups[0].maxSize"
    value = var.self_managed_node_groups.general.autoscaling_group_max_size
  }

  # Iterate over the rest of the self_managed_node_groups
  dynamic "set" {
    for_each = local.self_managed_node_sets
    content {
      name  = "autoscalingGroups[${set.key + 1}].name"
      value = set.value.name
    }
  }
  dynamic "set" {
    for_each = local.self_managed_node_sets
    content {
      name  = "autoscalingGroups[${set.key + 1}].minSize"
      value = set.value.minSize
    }
  }
  dynamic "set" {
    for_each = local.self_managed_node_sets
    content {
      name  = "autoscalingGroups[${set.key + 1}].maxSize"
      value = set.value.maxSize
    }
  }
  set {
    name  = "resources.limits.cpu"
    value = "1"
  }
  set {
    name  = "resources.limits.memory"
    value = "1Gi"
  }
  set {
    name  = "resources.requests.cpu"
    value = "0.5"
  }
  set {
    name  = "resources.requests.memory"
    value = "500m"
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

  # set {
  #   name = "rbac.create"
  #   value = "true"
  # }

  # set  {
  #   name = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
  #   value = "arn:aws:iam::373346310182:role/cluster-autoscaler"
  # }
}

