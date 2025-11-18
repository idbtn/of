terraform {
    backend "s3" {}

    required_version = ">= 1.13.3"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.20"
        }
    }
}