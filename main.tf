terraform {
  required_version = ">= 1.0"
  required_providers {
    helm = {
      version = "~> 2.11.0"
    }
    kubernetes = {
      version = "~> 2.23.0"
    }
    aws = {
      version = ">= 5.0.0"
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
