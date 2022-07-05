variable "cluster_name" {}

### Karpenter IAM variables
variable "worker_iam_role_name" {
  default = ""
}

variable "iam_path" {
  default = "/delegatedadmin/developer/"
}

variable "permissions_boundary" {
  default = "arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"
}


### Helm variables
variable "helm_namespace" {
  default = "kube-system"
}

variable "helm_name" {
  default = "auto-scaler"
}

variable "general_asg_name" {}
variable "runner_asg_name" {}
variable "batcave_website_asg_name" {}
variable "batcave_nightlight_asg_name" {}

variable "general_asg_min" {
  default = "1"
}

variable "general_asg_max" {
  default = "5"
}

variable "runner_asg_min" {
  default = "0"
}

variable "runner_asg_max" {
  default = "0"
}

variable "batcave_website_asg_max" {
  default = "5"
}

variable "batcave_website_asg_min" {
  default = "1"
}

variable "batcave_nightlight_asg_max" {
  default = "5"
}

variable "batcave_nightlight_asg_min" {
  default = "1"
}


# ENIConfig Variables
variable "vpc_eni_subnets" {
  type = map(any)
}

variable "worker_security_group_id" {
  type = string
}

variable "rotate_nodes_after_eniconfig_creation" {
  type = bool
  default = true
}
