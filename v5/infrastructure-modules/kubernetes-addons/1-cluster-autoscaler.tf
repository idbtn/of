data "aws_iam_policy_document" "cluster-autoscaler-policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        condition {
            test = "StringEquals"
            variable = "${replace(var.openid_provider_url, "https://", "")}:sub"
            values = ["system:serviceaccount:kube-system:cluster-autoscaler"]
        }

        condition {
            test = "StringEquals"
            variable = "${replace(var.openid_provider_url, "https://", "")}:aud"
            values = ["sts.amazonaws.com"]
        }

        principals {
            identifiers = [var.openid_provider_arn]
            type = "Federated"
        }
    }
}

resource "aws_iam_role" "cluster-autoscaler-role" {
    count = var.enable_cluster_autoscaler ? 1 : 0

    description = "Cluster Autoscaler IAM Role"
    assume_role_policy = data.aws_iam_policy_document.cluster-autoscaler-policy.json
    name = "eks-${var.env}-${var.project_name}-cluster-autoscaler-role"
}

resource "aws_iam_role_policy" "cluster-autoscaler-role-policy" {
    count = var.enable_cluster_autoscaler ? 1 : 0

    name = "eks-${var.env}-${var.project_name}-cluster-autoscaler-role-policy"

    role = aws_iam_role.cluster-autoscaler-role[0].name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "autoscaling:DescribeAutoScalingGroups",
                    "autoscaling:DescribeAutoScalingInstances",
                    "autoscaling:DescribeLaunchConfigurations",
                    "autoscaling:DescribeScalingActivities",
                    "ec2:DescribeInstanceTypes",
                    "ec2:DescribeLaunchTemplateVersions"
                ]
                Effect = "Allow"
                Resource = "*"
            },
            {
                Action = [
                    "autoscaling:SetDesiredCapacity",
                    "autoscaling:TerminateInstanceInAutoScalingGroup"
                ]
                Effect = "Allow"
                Resource = "*"
            },
        ]
    })
}

resource "helm_release" "cluster-autoscaler-helm-release" {
    count = var.enable_cluster_autoscaler ? 1 : 0

    name = "${var.env}-${var.project_name}"
    repository = "https://kubernetes.github.io/autoscaler"
    chart = "cluster-autoscaler"
    namespace = "kube-system"
    version = var.cluster_autoscaler_helm_version

    set = [
        {
            name = "rbac.serviceAccount.name"
            value = "cluster-autoscaler"
        },
        {
            name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
            value = aws_iam_role.cluster-autoscaler-role[0].arn
        },
        {
            name = "autoDiscovery.clusterName"
            value = var.eks_full_name
        }
    ]
}