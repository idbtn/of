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
    source = "../../../infrastructure-modules/eks"
}

inputs = {
    env = include.env.locals.env
    eks_version = "1.34"
    project_name = include.root.locals.project_name
    subnet_ids = dependency.vpc.outputs.private_subnet_ids

    node_groups = {
        # general = {
        #     capacity_type = "ON_DEMAND"
        #     ami_type = "AL2023_ARM_64_STANDARD"
        #     instance_types = ["t4g.small"]
        #     scaling_config = {
        #         desired_size = 1
        #         max_size = 10
        #         min_size = 0
        #     }
        # }
    }
}

dependency "vpc" {
    config_path = "../vpc"

    mock_outputs = {
        private_subnet_ids = ["subnet-1234", "subnet-5678"]
    }
}