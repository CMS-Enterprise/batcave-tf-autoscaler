# batcave-tf-autoscaler

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_admin"></a> [iam\_assumable\_role\_admin](#module\_iam\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.30.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_values"></a> [additional\_values](#input\_additional\_values) | Map of key/value pairs to pass to the autoscaler chart. | `map(any)` | `{}` | no |
| <a name="input_autoscaler_expander_method"></a> [autoscaler\_expander\_method](#input\_autoscaler\_expander\_method) | Method by which CA will select a new instance to launch. Current options: random, most-pods, least-waste. See: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders | `string` | `"least-waste"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | n/a | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The version of the cluster.  Used to determine the version of the autoscaler to deploy. Defaults to the most recent version known by this module. | `string` | `""` | no |
| <a name="input_cpu_limits"></a> [cpu\_limits](#input\_cpu\_limits) | Pod limit values | `string` | `"50m"` | no |
| <a name="input_cpu_requests"></a> [cpu\_requests](#input\_cpu\_requests) | n/a | `string` | `"10m"` | no |
| <a name="input_extraArgs"></a> [extraArgs](#input\_extraArgs) | List of extraArgs values to pass to the autoscaler chart.  See: https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml#L165 | `map(any)` | `{}` | no |
| <a name="input_helm_namespace"></a> [helm\_namespace](#input\_helm\_namespace) | ## Helm variables | `string` | `"kube-system"` | no |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path) | n/a | `string` | `"/delegatedadmin/developer/"` | no |
| <a name="input_memory_limits"></a> [memory\_limits](#input\_memory\_limits) | n/a | `string` | `"512Mi"` | no |
| <a name="input_memory_requests"></a> [memory\_requests](#input\_memory\_requests) | n/a | `string` | `"50Mi"` | no |
| <a name="input_monitoring_enabled"></a> [monitoring\_enabled](#input\_monitoring\_enabled) | Enable monitoring for the cluster autoscaler; Note that this should _not_ be enabled before bigbang is deployed, as it will fail to deploy since the monitoring namespace does not exist yet. | `bool` | `false` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | n/a | `string` | `""` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | n/a | `string` | `"arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_iam_role_arn"></a> [oidc\_iam\_role\_arn](#output\_oidc\_iam\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
