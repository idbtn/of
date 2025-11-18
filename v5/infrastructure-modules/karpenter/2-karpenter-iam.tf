resource "aws_iam_role" "karpenter-node-role" {
    count = var.enable_karpenter ? 1 : 0

    name = "eks-${var.env}-${var.project_name}-karpenter-node-role"
    assume_role_policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
    )
}

resource "aws_iam_role_policy_attachment" "karpenter-node-role-policy-attachment" {
    for_each = var.karpenter_node_iam_policies

    policy_arn = each.value
    role = aws_iam_role.karpenter-node-role[0].name
}

data "aws_iam_policy_document" "karpenter-controller-policy-document" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        condition {
            test = "StringEquals"
            variable = "${replace(var.openid_provider_url, "https://", "")}:sub"
            values = ["system:serviceaccount:karpenter:karpenter"]
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

resource "aws_iam_role" "karpenter-controller-role" {
    count = var.enable_karpenter ? 1 : 0

    description = "Karpenter Controller IAM Role"
    assume_role_policy = data.aws_iam_policy_document.karpenter-controller-policy-document.json
    name = "eks-${var.env}-${var.project_name}-karpenter-controller-role"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "karpenter-controller-role-policy" {
    count = var.enable_karpenter ? 1 : 0

    name = "eks-${var.env}-${var.project_name}-karpenter-controller-role-policy"

    role = aws_iam_role.karpenter-controller-role[0].name
    policy = jsonencode(
        {
            "Statement": [
                {
                    "Action": [
                        "ssm:GetParameter",
                        "ec2:DescribeImages",
                        "ec2:RunInstances",
                        "ec2:DescribeSubnets",
                        "ec2:DescribeSecurityGroups",
                        "ec2:DescribeLaunchTemplates",
                        "ec2:DescribeInstances",
                        "ec2:DescribeInstanceTypes",
                        "ec2:DescribeInstanceTypeOfferings",
                        "ec2:DescribeAvailabilityZones",
                        "ec2:DeleteLaunchTemplate",
                        "ec2:CreateTags",
                        "ec2:CreateLaunchTemplate",
                        "ec2:CreateFleet",
                        "ec2:DescribeSpotPriceHistory",
                        "pricing:GetProducts"
                    ],
                    "Effect": "Allow",
                    "Resource": "*",
                    "Sid": "Karpenter"
                },
                {
                    "Action": "ec2:TerminateInstances",
                    "Condition": {
                        "StringLike": {
                            "ec2:ResourceTag/karpenter.sh/nodepool": "*"
                        }
                    },
                    "Effect": "Allow",
                    "Resource": "*",
                    "Sid": "ConditionalEC2Termination"
                },
                {
                    "Action": "iam:PassRole",
                    "Effect": "Allow",
                    "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.karpenter-node-role[0].name}",
                    "Sid": "PassNodeIAMRole"
                },
                {
                    "Action": "eks:DescribeCluster",
                    "Effect": "Allow",
                    "Resource": "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_full_name}",
                    "Sid": "EKSClusterEndpointLookup"
                },
                {
                    "Action": "iam:CreateInstanceProfile",
                    "Effect": "Allow",
                    "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
                    "Condition": {
                        "StringEquals": {
                            "aws:RequestTag/kubernetes.io/cluster/${var.eks_full_name}": "owned",
                            "aws:RequestTag/eks:eks-cluster-name": "${var.eks_full_name}",
                            "aws:RequestTag/topology.kubernetes.io/region": "${var.aws_region}"
                        },
                        "StringLike": {
                            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
                        }
                    }
                    "Sid": "AllowScopedInstanceProfileCreationActions"
                },
                {
                    "Action": "iam:TagInstanceProfile",
                    "Effect": "Allow",
                    "Resource": "*",
                    "Condition": {
                        "StringEquals": {
                            "aws:ResourceTag/kubernetes.io/cluster/${var.eks_full_name}": "owned",
                            "aws:ResourceTag/topology.kubernetes.io/region": "${var.aws_region}",
                            "aws:RequestTag/kubernetes.io/cluster/${var.eks_full_name}": "owned",
                            "aws:RequestTag/topology.kubernetes.io/region": "${var.aws_region}"
                        },
                        "StringLike": {
                            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
                            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
                        }
                    },
                    "Sid": "AllowScopedInstanceProfileTagActions"
                },
                {
                    "Action": [
                        "iam:AddRoleToInstanceProfile",
                        "iam:RemoveRoleFromInstanceProfile",
                        "iam:DeleteInstanceProfile"
                    ],
                    "Effect": "Allow",
                    "Resource": "*",
                    "Condition": {
                        "StringEquals": {
                            "aws:ResourceTag/kubernetes.io/cluster/${var.eks_full_name}": "owned",
                            "aws:ResourceTag/topology.kubernetes.io/region": "${var.aws_region}"
                        },
                        "StringLike": {
                            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
                        }
                    },
                    "Sid": "AllowScopedInstanceProfileActions"
                },
                {
                    "Action": [
                        "iam:GetInstanceProfile",
                        "iam:ListInstanceProfiles"
                    ],
                    "Effect": "Allow",
                    "Resource": "*",
                    "Sid": "AllowInstanceProfileReadActions"
                },
                {
                    "Action": [
                        "sqs:DeleteMessage",
                        "sqs:GetQueueUrl",
                        "sqs:ReceiveMessage"
                    ],
                    "Effect": "Allow",
                    "Resource": "${aws_sqs_queue.karpenter-sqs-queue[0].arn}",
                    "Sid": "AllowInterruptionQueueActions"
                }
            ],
            "Version": "2012-10-17"
        }      
    )
}