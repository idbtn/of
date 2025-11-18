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
    source = "../../../infrastructure-modules/vpc"
}

inputs = {
    env = include.env.locals.env
    eks_full_name = "eks-${include.env.locals.env}-${include.root.locals.project_name}-cluster"
    azs = ["eu-central-1a", "eu-central-1b"]
    private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
    public_subnets = ["10.0.64.0/19", "10.0.96.0/19"]

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
        "kubernetes.io/cluster/eks-${include.env.locals.env}-${include.root.locals.project_name}-cluster" = "owned"
    }

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
        "kubernetes.io/cluster/eks-${include.env.locals.env}-${include.root.locals.project_name}-cluster" = "owned"
    }
}