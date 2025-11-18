resource "aws_iam_role" "karpenter-fargate-role" {
    count = var.enable_karpenter ? 1 : 0

    name = "aws-eks-${var.env}-${var.project_name}-karpenter-fargate-role"
    assume_role_policy = jsonencode(
        {
            Statement = [{
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks-fargate-pods.amazonaws.com"
                }
            }]
            Version = "2012-10-17"
        }
    )
}

resource "aws_iam_role_policy_attachment" "karpenter-fargate-role-policy-attachment" {
    role = aws_iam_role.karpenter-fargate-role[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

resource "aws_eks_fargate_profile" "karpenter" {
    count = var.enable_karpenter ? 1 : 0

    cluster_name = var.eks_full_name
    fargate_profile_name = "aws-eks-${var.env}-${var.project_name}-karpenter-fargate-profile"
    pod_execution_role_arn = aws_iam_role.karpenter-fargate-role[0].arn

    subnet_ids = var.subnet_ids

    selector {
        namespace = var.karpenter_namespace
    }
}