terraform {
    backend "s3" {}

    required_version = ">= 1.13.3"

    required_providers {
        kubernetes = {
            version = ">= 2.38.0"
        }
    }
}