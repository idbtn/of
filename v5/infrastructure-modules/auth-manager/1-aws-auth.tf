data "kubernetes_config_map_v1" "aws_auth_existing" {
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }
}

locals {
    existing_map_roles_yaml = (
        lookup(data.kubernetes_config_map_v1.aws_auth_existing.data, "mapRoles", "")
    )

    existing_map_roles = length(local.existing_map_roles_yaml) > 0 ? yamldecode(local.existing_map_roles_yaml) : []

    karpenter_node_role_mapping = var.karpenter_aws_auth_role_mapping

    merged_map_roles = concat(
        local.existing_map_roles,
        local.karpenter_node_role_mapping,
    )
}

resource "kubernetes_config_map_v1" "aws_auth" {
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }
    data = merge(
        data.kubernetes_config_map_v1.aws_auth_existing.data,
        {
            mapRoles = yamlencode(local.merged_map_roles)
        }
    )
}