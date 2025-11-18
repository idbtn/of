variable "eks_full_name" {
    description = "EKS cluster full name"
    type = string
}

variable "cluster_endpoint" {
    description = "EKS cluster endpoint"
    type = string
}

variable "cluster_ca_data" {
    description = "EKS cluster CA certificate"
    type = string
}

variable "karpenter_aws_auth_role_mapping" {
    description = "karpenter node role mapping for aws-auth eks configmap"
    type = list(object({
        rolearn = string
        username = string
        groups = list(string)
    }))
}