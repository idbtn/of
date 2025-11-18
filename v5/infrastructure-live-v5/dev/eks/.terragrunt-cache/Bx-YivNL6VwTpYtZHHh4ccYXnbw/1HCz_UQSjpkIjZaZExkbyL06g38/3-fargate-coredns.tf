resource "aws_iam_role" "coredns-fargate-role" {
    count = var.deploy_fargate_coredns ? 1 : 0

    name = "aws-eks-${var.env}-${var.project_name}-coredns-fargate-role"
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

resource "aws_iam_role_policy_attachment" "coredns-fargate-role-policy-attachment" {
    role = aws_iam_role.coredns-fargate-role[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

resource "aws_eks_fargate_profile" "coredns" {
    count = var.deploy_fargate_coredns ? 1 : 0

    cluster_name = aws_eks_cluster.this.name
    fargate_profile_name = "aws-eks-${var.env}-${var.project_name}-coredns-fargate-profile"
    pod_execution_role_arn = aws_iam_role.coredns-fargate-role[0].arn

    subnet_ids = var.subnet_ids

    selector {
        namespace = "kube-system"
        labels = {
            k8s-app = "kube-dns"
        }
    }

    tags = {
        Name = "${aws_eks_cluster.this.name}-coredns-fargate"
    }
}

resource "aws_eks_addon" "coredns" {
    count = var.deploy_fargate_coredns ? 1 : 0

    cluster_name = aws_eks_cluster.this.name
    addon_name = "coredns"

    configuration_values = jsonencode({
        computeType = "Fargate"
    })

    depends_on = [
        aws_eks_fargate_profile.coredns[0]
    ]
}