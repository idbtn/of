variable "env" {
    description = "environment name"
    type = string
}

variable "aws_region" {
    description = "AWS region name"
    type = string
}

variable "project_name" {
    description = "project name"
    type = string
}

variable "eks_full_name" {
    description = "EKS cluster full name"
    type = string
}

variable "eks_cluster_endpoint" {
    description = "EKS cluster endpoint"
    type = string
}

variable "cluster_ca_data" {
    description = "EKS cluster CA certificate"
    type = string
}

variable "openid_provider_url" {
    description = "OIDC provider URL"
    type = string
}

variable "openid_provider_arn" {
    description = "OIDC provider ARN"
    type = string
}

variable "subnet_ids" {
    description = "list of Subnet IDs - must be in at least two different Availability Zones"
    type = list(string)
}

variable "karpenter_node_iam_policies" {
    description = "list of IAM policies to attach to Karpenter nodes IAM Role"
    type = map(any)
    default = {
        1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
}

variable "enable_karpenter" {
    description = "determines whether to deploy Karpenter"
    type = bool
    default = false
}

variable "karpenter_helm_version" {
    description = "Karpenter Helm version"
    type = string
}

variable "karpenter_namespace" {
    description = "Kubernetes namespace to deploy karpenter into"
    type = string
}

