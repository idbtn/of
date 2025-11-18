data "aws_eks_cluster" "this" {
    name = var.eks_full_name
}

resource "aws_ec2_tag" "karpenter-discovery-sg" {
    resource_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    key = "karpenter.sh/discovery"
    value = var.eks_full_name
}