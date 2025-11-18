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

variable "karpenter_enabled" {
    description = "karpenter enablement check"
    type = bool
}

variable "karpenter_node_role" {
    description = "karpenter node IAM role"
    type = string
}