data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# provider "helm" {
#   kubernetes {
#     host                   = var.cluster_endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.cluster_certificate_authority_data)
#     token = data.aws_eks_cluster_auth.cluster.token
#   }
# }

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}
