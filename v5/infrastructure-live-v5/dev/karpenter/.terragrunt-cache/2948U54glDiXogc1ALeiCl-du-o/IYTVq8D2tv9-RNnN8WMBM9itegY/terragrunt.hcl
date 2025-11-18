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

dependency "eks" {
    config_path = "../eks"

    mock_outputs = {
        eks_full_name = "eks-${include.env.locals.env}-${include.root.locals.project_name}-cluster"
        cluster_endpoint = "https://${include.env.locals.env}-${include.root.locals.project_name}-mock-endpoint"
        cluster_ca_data = "Cg==" # base64("mock_cluster_ca_data")
        openid_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.${include.root.locals.aws_region}.amazonaws.com/id/123456789012345"
        openid_provider_url = "https://oidc.eks.${include.root.locals.aws_region}.amazonaws.com/id/123456789012345"
        subnet_ids = ["subnet-1234", "subnet-5678"]
    }
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