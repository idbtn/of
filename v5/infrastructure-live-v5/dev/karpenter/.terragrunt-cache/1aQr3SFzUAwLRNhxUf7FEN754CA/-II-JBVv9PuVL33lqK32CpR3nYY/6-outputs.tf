output "eks_full_name" {
    value = var.eks_full_name
}

output "eks_cluster_endpoint" {
    value = var.eks_cluster_endpoint
}

output "cluster_ca_data" {
    value = var.cluster_ca_data
}

output "karpenter_enabled" {
    value = var.enable_karpenter
}

output "karpenter_node_role" {
    value = var.enable_karpenter ? aws_iam_role.karpenter-node-role[0].name : ""
}

output "karpenter_aws_auth_role_mapping" {
    value = var.enable_karpenter ? [
        {
            rolearn = aws_iam_role.karpenter-node-role[0].arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups = [
                "system:bootstrappers",
                "system:nodes",
                "system:node-proxier",
            ]
        }
    ] : []
}

