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

    after_hook "remove_aws_auth_from_eks_state" {
        commands = ["apply"]
        execute = ["bash", "-c", <<EOT
set -euo pipefail
echo "[eks] Checking if aws-auth is in eks module state..."
if terraform state list 2>/dev/null | grep -q 'kubernetes_config_map_v1.aws_auth'; then
    echo "[eks] Removing kubernetes_config_map_v1.aws_auth from eks state..."
    terraform state rm kubernetes_config_map_v1.aws_auth
else
    echo "[eks] No kubernetes_config_map_v1.aws_auth in eks state, skipping state rm."
fi
EOT
        ]
    run_on_error = false # Avoid running hook on failed apply.
    }
}

inputs = {
    env = include.env.locals.env
    eks_version = include.env.locals.eks_version
    project_name = include.root.locals.project_name
    subnet_ids = dependency.vpc.outputs.private_subnet_ids

    enable_irsa = true
    deploy_fargate_coredns = true
}

dependency "vpc" {
    config_path = "../vpc"

    mock_outputs = {
        private_subnet_ids = ["subnet-1234", "subnet-5678"]
    }
}