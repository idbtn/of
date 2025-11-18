output "eks_full_name" {
    value = aws_eks_cluster.this.name
}

output "openid_provider_arn" {
    value = var.enable_irsa ? aws_iam_openid_connect_provider.this[0].arn : null
}

output "openid_provider_url" {
    value = var.enable_irsa ? aws_iam_openid_connect_provider.this[0].url : null
}

output "cluster_endpoint" {
    value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_data" {
    value = aws_eks_cluster.this.certificate_authority[0].data
}

output "subnet_ids" {
    value = var.subnet_ids
}