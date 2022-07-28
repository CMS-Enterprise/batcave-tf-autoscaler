# ###############################################################################
# # Kubernetes provider configuration
# ###############################################################################


# resource "kubernetes_manifest" "eniconfig_subnets"{

#   for_each = var.vpc_eni_subnets

#   depends_on = [
#     helm_release.autoscaler
#   ]

#   manifest = {
#     "apiVersion" = "crd.k8s.amazonaws.com/v1alpha1"
#     "kind" = "ENIConfig"
#     "metadata" = {
#       "name" = "${each.key}"
#     }
#     "spec" = {
#       "subnet" = "${each.value}"
#       "securityGroups" = [
#         "${var.worker_security_group_id}"
#       ]
#     }
#   }

# }

# resource "null_resource" "rotate_nodes_after_eniconfig_creation" {

#   count = var.rotate_nodes_after_eniconfig_creation ? 1 : 0
#   depends_on = [
#     kubernetes_manifest.eniconfig_subnets
#   ]

#   provisioner "local-exec" {
#     command = <<-EOT
#       aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filter "Name=tag:Name,Values=$CLUSTER_NAME-general" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId]" --output text) --output text
#     EOT
#   }

# }
