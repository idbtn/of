variable "env" {
    description = "environment name"
    type = string
}

variable "project_name" {
    description = "project name"
    type = string
}

variable "eks_full_name" {
    description = "eks cluster name"
    type = string
}

variable "cluster_ca_data" {
    description = "EKS cluster CA certificate"
    type = string
}

variable "enable_cluster_autoscaler" {
    description = "determines whether to deploy Cluster Autoscaler"
    type = bool
    default = false
}

variable "cluster_autoscaler_helm_version" {
    description = "Cluster Autoscaler Helm version"
    type = string
}

variable "openid_provider_arn" {
    description = "IAM OpenID Connect Provider ARN"
    type = string
}

variable "openid_provider_url" {
    description = "IAM OpenID Connect Provider URL"
    type = string
}