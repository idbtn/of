# Infrastructure Setup Guide

Current IaC project deploys AWS infrastructure required to run an EKS cluster with:
* Karpenter running Fargate containers
* CoreDNS running Fargate containers
* Karpenter managed compute workers

### Modules:
- `vpc` - VPC + 2 PrivSubnets + 2 PubSubnets + 1 IgW + 1 NAT + Private & Public Routes and Associations
- `eks` - EKS Cluster + IAM Resources + IRSA + CoreDNS Fargate Profile
- `karpenter` - Karpenter Helm Chart + IAM Resources + Karpenter Fargate Profile + SQS + EKS SecurityGroup Tags
- `karpenter-nodepools` - Karpenter EC2 NodeClass + X86 NodePool + ARM64 NodePool
- `auth-manager` - EKS Cluster aws-auth role mappings

## Requirements

- An AWS account  
- `awscliv2`  
- `helm`  
- `kubectl`  
- `terraform`  
- `terragrunt`

---

## AWS Preparation

### Create S3 bucket for Terraform states
In AWS S3, create a bucket for storing Terraform state files.

### Configure AWS CLI
Run:

```sh
aws configure
```

Provide:
* AWS Access Key ID
* AWS Secret Access Key

### Populate Terragrunt Variables
(RE-)Run the populate.sh script to set the required variables that will populate the:
`./v5/infrastructure-live-v5/root.hcl` and `./v5/infrastructure-live-v5/dev/env.hcl`

### Run the script

```sh
sh populate.sh
```

Provide the following variables:
* `project_name`
* `env`
* `eks_version`
* `aws_region`
* `aws_allowed_account_id`
* `s3_bucket`

### Deploy Infrastructure with Terragrunt
Change directory to: `./v5/infrastructure-live-v5/dev/`

Run:

```sh
cd ./v5/infrastructure-live-v5/dev/
terragrunt run --all init
terragrunt run --all plan # Throws error if "eks" module is not deployed.
terragrunt run --all apply
```

### Set kubeconfig file

```sh
aws eks list-clusters
aws eks update-kubeconfig --name $EKS_CLUSTER --region $REGION
```

### Test Karpenter NodePool

Create a deployment to test Karpenter node provisioning:

```sh
kubectl create deployment test --image=nginx --replicas=3
```

## Destroy the Stack

When finished, run:

```sh
terragrunt run --all destroy
```
