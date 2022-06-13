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

resource "kubernetes_manifest" "eniconfig_subnets"{

  for_each = var.vpc_eni_subnets

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
      "env" = [
        { 
        "name" = "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG"
        "value" = "true"
        },
        { 
        "name" = "ENI_CONFIG_LABEL_DEF"
        "value" = "failure-domains.beta.kubernetes.io/zone"
        }
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
