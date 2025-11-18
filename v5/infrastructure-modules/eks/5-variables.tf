variable "env" {
    description = "environment name"
    type = string
}

variable "eks_version" {
    description = "desired Kubernetes control-plane version"
    type = string
}

variable "project_name" {
    description = "project name"
    type = string
}

variable "subnet_ids" {
    description = "list of Subnet IDs - must be in at least two different Availability Zones"
    type = list(string)
}

variable "node_iam_policies" {
    description = "list of IAM Policies to attach to EKS-managed nodes"
    type = map(any)
    default = {
        1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
}

variable "enable_irsa" {
    description = "determines whether to create an OpenID Connect Provider for EKS"
    type = bool
    default = true
}

variable "deploy_fargate_coredns" {
    description = "determines whether to deploy CoreDNS on Fargate"
    type = bool
    default = false
}