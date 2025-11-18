resource "aws_iam_role" "eks-role" {
    name = "eks-${var.env}-${var.project_name}-role"

    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-role-policy-attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks-role.name
}

resource "aws_eks_cluster" "this" {
    name = "eks-${var.env}-${var.project_name}-cluster"
    version = var.eks_version
    role_arn = aws_iam_role.eks-role.arn

    vpc_config {
        endpoint_private_access = false # needs to be enabled while connecting from a vpn
        endpoint_public_access = true # needs to be false while connecting from a vpn

        subnet_ids = var.subnet_ids
    }

    depends_on = [aws_iam_role_policy_attachment.eks-role-policy-attachment]
}