###############################################################################
# Kubernetes provider configuration
###############################################################################

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "null_resource" "eniconfig_daemonsets" {
  depends_on = [
    helm_release.autoscaler
  ]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
      kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone
    EOT
  }

}

resource "kubernetes_manifest" "eni_crd" {

  depends_on = [
    null_resource.eniconfig_daemonsets
  ]

  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "eniconfigs.crd.k8s.amazonaws.com"
      labels = {
        "app.kubernetes.io/name" = "aws-node"
        "app.kubernetes.io/instance" = "aws-vpc-cni"
        "app.kubernetes.io/version" = "v1.10.1"
        "k8s-app" = "aws-node"
      }
    }
    spec = {
      scope = "Cluster"
      group = "crd.k8s.amazonaws.com"
      preserveUnknownFields = false
      versions = [{
        name = "v1alpha1"
        served = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            x-kubernetes-preserve-unknown-fields = true
          }
        }
      }]
      names = {
        plural = "eniconfigs"
        singular = "eniconfig"
        kind = "ENIConfig"
      }
    }

  }
}

resource "kubernetes_manifest" "eniconfig_subnets"{

  for_each = var.vpc_eni_subnets

  depends_on = [
    kubernetes_manifest.eni_crd
  ]

  manifest = {
    "apiVersion" = "crd.k8s.amazonaws.com/v1alpha1"
    "kind" = "ENIConfig"
    "metadata" = {
      "name" = "${each.key}"
    }
    "spec" = {
      "subnet" = "${each.value}"
      "securityGroups" = [
        "${var.worker_security_group_id}"
      ]
    }
  }

}

resource "null_resource" "rotate_nodes_after_eniconfig_creation" {
  depends_on = [
    kubernetes_manifest.eniconfig_subnets
  ]

  count = var.rotate_nodes_after_eniconfig_creation ? 1 : 0

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filter "Name=tag:Name,Values=$CLUSTER_NAME-general" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId]" --output text) --output text
    EOT
  }

}
