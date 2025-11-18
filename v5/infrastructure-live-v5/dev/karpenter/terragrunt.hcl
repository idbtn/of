include "root" {
    path = find_in_parent_folders("root.hcl")
    expose = true
}

include "env" {
    path = find_in_parent_folders("env.hcl")
    expose = true
    merge_strategy = "no_merge"
}

terraform {
    source = "../../../infrastructure-modules/karpenter"
}

inputs = {
    env = include.env.locals.env
    aws_region = include.root.locals.aws_region
    project_name = include.root.locals.project_name
    eks_full_name = dependency.eks.outputs.eks_full_name
    eks_cluster_endpoint = dependency.eks.outputs.cluster_endpoint
    cluster_ca_data = dependency.eks.outputs.cluster_ca_data
    openid_provider_url = dependency.eks.outputs.openid_provider_url
    openid_provider_arn = dependency.eks.outputs.openid_provider_arn
    subnet_ids = dependency.eks.outputs.subnet_ids

    enable_karpenter = true

    karpenter_helm_version = "1.8.1"
    karpenter_namespace = "karpenter"
}

generate "helm_provider" {
    path = "helm-provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
provider "helm" {
    kubernetes = {
        host = var.eks_cluster_endpoint
        cluster_ca_certificate = base64decode(var.cluster_ca_data)
        exec = {
            api_version = "client.authentication.k8s.io/v1beta1"
            args = ["eks", "get-token", "--cluster-name", var.eks_full_name]
            command = "aws"
        }
    }
}
EOF
}

dependency "eks" {
    config_path = "../eks"

    mock_outputs = {
        eks_full_name = "eks-${include.env.locals.env}-${include.root.locals.project_name}-cluster"
        cluster_endpoint = "https://${include.env.locals.env}-${include.root.locals.project_name}-mock-endpoint"
        cluster_ca_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUREVENDQWZXZ0F3SUJBZ0lVTFBlckpRSS9KWWx0UW4rYXdJZTl6YUNtSzhnd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0ZqRVVNQklHQTFVRUF3d0xiVzlqYXkxbGEzTXRZMkV3SGhjTk1qVXhNVEUzTVRnd016UXdXaGNOTXpVeApNVEUxTVRnd016UXdXakFXTVJRd0VnWURWUVFEREF0dGIyTnJMV1ZyY3kxallUQ0NBU0l3RFFZSktvWklodmNOCkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFLSC9yWGxLSnl3UmNsYjZ5YmJBalMxQTZBUVF4czhXQk45ekRxUzcKcEI1c1Y4dUJicEhzWDNXS3ZPcFlBOVk1elFhbnI1ZzhUNms2RjNyQ3hGNThqSUhrd2Zic1dXQjkxUk9QbElVYQpxZUR3aFh4U28xekdDVjlNWDVSM2JjNEpIRUlnYWVGOVd5ZVpZd3BNOGR4RlptbjNTYVdTRzhrUU9oVVFhYlNiCng1NFgrRmRNbVdLd0lhK0J5TFN4akRDTzJKWEhtRlArSjUxQW96MlNqUDJ3SXVSMGlqYkF3VjJzYmNiWldUL0oKbUdaK3NrUjUwN1RhcStjcWVqdWZRYjFERkxUUTAySWMyc0VJZEtXWjgzUzIyRmtqTHN5ck9KS3YvMUQzcUtoTAprQ3RueXNydk8zMkpCa2J3NncreVNjM0krMS85Zk5MS0F1ZzFIRkg0U01UR3g3Y0NBd0VBQWFOVE1GRXdIUVlEClZSME9CQllFRkM2VjhUNG9QRm9WbUFVbHgvaGI1SURJTVJWdk1COEdBMVVkSXdRWU1CYUFGQzZWOFQ0b1BGb1YKbUFVbHgvaGI1SURJTVJWdk1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQgpBSGRYc1hEU2NSdnZqZE9LbXFUTWFrMjdRTGZWdkg3Vm9VcDVzQzFIZDVaR1krenh2ZUFlYWFjVVo2ZGpRVFJrCkRlVjBuN01zODIxeGtrL2E1SDJMa2duZG51SmhSeXZ0V1dRaHI1YndTd2pYcFBLRnp5aVUzOUY5S0FWRzNJZUwKdjVYVk9oUjVvM1YyeVpNZFI5cUp2cDY1eGYzVSt0SHI3SGRlWEVuMHArazRxTTRUUXBBeGx2bGQ0T1RHSlYveApQUTlrckhYcEtXSTlGYTVia3QyQXNrTXNsd2YxdjdrcXBUR1BHRzJxa0V0RlJkUTMwR0pDOU9YN0tCL1NsMjY3CllwbGxxc09ETkM5NUc4elZ3bkxTN1kxd0oyMTZGeDZlbjEwWTRNSXlmemROTGtwN3liK2tOQUxCdDdhRnh0MncKZGFiWm1qdEU2a244UW0yVWMwUFMrcXc9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K" # base64("mock_cluster_ca_data")
        openid_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.${include.root.locals.aws_region}.amazonaws.com/id/123456789012345"
        openid_provider_url = "https://oidc.eks.${include.root.locals.aws_region}.amazonaws.com/id/123456789012345"
        subnet_ids = ["subnet-1234", "subnet-5678"]
    }
    mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

generate "kubernetes_provider" {
    path = "kubernetes-provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
provider "kubernetes" {
    host = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_data)
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args = ["eks", "get-token", "--cluster-name", var.eks_full_name]
        command = "aws"
    }
}
EOF
}