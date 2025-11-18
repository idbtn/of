locals {
    project_name = 
    aws_region = 
    aws_allowed_account_id = 
    environment = basename(get_terragrunt_dir())
}

remote_state {
    backend = "s3"
    config = {
        bucket = 
        key = "${path_relative_to_include()}/terraform.tfstate"
        region = local.aws_region
        encrypt = true
        use_lockfile = true
    }
}

generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
provider "aws" {
    region = "${local.aws_region}"
    allowed_account_ids = ${jsonencode(local.aws_allowed_account_id)}
}
EOF
}
