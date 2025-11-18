terraform {
    backend "s3" {}

    required_version = ">= 1.13.3"

    required_providers {
        helm = {
            source = "hashicorp/helm"
            version = "~> 3.1.0"
        }
    }
}