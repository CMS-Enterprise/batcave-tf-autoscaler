variable "cluster_name" {
  type = string
}
variable "cluster_endpoint" {
  type = string
}
variable "cluster_certificate_authority_data" {
  type = string
}
variable "cluster_version" {
  default     = ""
  type        = string
  description = "The version of the cluster.  Used to determine the version of the autoscaler to deploy. Defaults to the most recent version known by this module."
}

variable "iam_path" {
  default = "/delegatedadmin/developer/"
  type    = string
}

variable "permissions_boundary" {
  default = "arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"
  type    = string
}


### Helm variables
variable "helm_namespace" {
  default = "kube-system"
  type    = string
}

variable "oidc_provider_arn" {
  type    = string
  default = ""
}

variable "autoscaler_expander_method" {
  default     = "least-waste"
  type        = string
  description = "Method by which CA will select a new instance to launch. Current options: random, most-pods, least-waste. See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders"
}

variable "extraArgs" {
  default     = {}
  type        = map(any)
  description = "List of extraArgs values to pass to the autoscaler chart.  See: https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml#L165"
}

# Pod limit values
variable "cpu_limits" {
  default = "50m"
  type    = string
}

variable "cpu_requests" {
  default = "10m"
  type    = string
}

variable "memory_limits" {
  default = "512Mi"
  type    = string
}

variable "memory_requests" {
  default = "50Mi"
  type    = string
}

variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "additional_values" {
  default     = {}
  description = "Map of key/value pairs to pass to the autoscaler chart."
  type        = map(any)
}

variable "monitoring_enabled" {
  default     = false
  type        = bool
  description = "Enable monitoring for the cluster autoscaler; Note that this should _not_ be enabled before bigbang is deployed, as it will fail to deploy since the monitoring namespace does not exist yet."
}
