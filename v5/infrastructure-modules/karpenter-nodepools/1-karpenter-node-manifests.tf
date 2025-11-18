resource "kubernetes_manifest" "ec2-nodeclass-default" {
    count = var.karpenter_enabled ? 1 : 0

    manifest = {
        apiVersion = "karpenter.k8s.aws/v1"
        kind = "EC2NodeClass"
        metadata = {
            name = "default"
        }
        spec = {
            amiFamily = "AL2023"
            role = var.karpenter_node_role
            subnetSelectorTerms = [
                {
                    tags = {
                        "karpenter.sh/discovery" = var.eks_full_name
                    }
                }
            ]
            securityGroupSelectorTerms = [
                {
                    tags = {
                        "karpenter.sh/discovery" = var.eks_full_name
                    }
                }
            ]
            amiSelectorTerms = [
                {
                    alias = "al2023@latest"
                }
            ]
        }
    }
}

resource "kubernetes_manifest" "nodepool-on-demand-amd64" {
    count = var.karpenter_enabled ? 1 : 0

    manifest = {
        apiVersion = "karpenter.sh/v1"
        kind = "NodePool"
        metadata = {
            name = "on-demand-amd64"
        }
        spec = {
            template = {
                metadata = {
                    labels = {
                        "nodepool" = "on-demand-amd64"
                        "karpenter.sh/capacity-type" = "on-demand"
                    }
                }
                spec = {
                    nodeClassRef = {
                        group = "karpenter.k8s.aws"
                        kind = "EC2NodeClass"
                        name = "default"
                    }
                    requirements = [
                        {
                            key = "kubernetes.io/arch"
                            operator = "In"
                            values = ["amd64"]
                        },
                        {
                            key = "karpenter.sh/capacity-type"
                            operator = "In"
                            values = ["on-demand"]
                        },
                        {
                            key = "node.kubernetes.io/instance-type"
                            operator = "In"
                            values = ["t3.micro", "c7i-flex.large", "m7i-flex.large"]
                        },
                    ]
                }
            }
            disruption = {
                consolidateAfter = "2m"
                consolidationPolicy = "WhenEmptyOrUnderutilized"
            }
        }
    }

    depends_on = [kubernetes_manifest.ec2-nodeclass-default[0]]
}

resource "kubernetes_manifest" "nodepool-on-demand-arm64" {
    count = var.karpenter_enabled ? 1 : 0

    manifest = {
        apiVersion = "karpenter.sh/v1"
        kind = "NodePool"
        metadata = {
            name = "on-demand-arm64"
        }
        spec = {
            template = {
                metadata = {
                    labels = {
                        "nodepool" = "on-demand-arm64"
                        "karpenter.sh/capacity-type" = "on-demand"
                    }
                }
                spec = {
                    nodeClassRef = {
                        group = "karpenter.k8s.aws"
                        kind = "EC2NodeClass"
                        name = "default"
                    }
                    requirements = [
                        {
                            key = "kubernetes.io/arch"
                            operator = "In"
                            values = ["arm64"]
                        },
                        {
                            key = "karpenter.sh/capacity-type"
                            operator = "In"
                            values = ["on-demand"]
                        },
                        {
                            key = "node.kubernetes.io/instance-type"
                            operator = "In"
                            values = [ "t4g.micro", "t4g.small" ]
                        }
                    ]
                }
            }
            disruption = {
                consolidateAfter = "2m"
                consolidationPolicy = "WhenEmptyOrUnderutilized"
            }
        }
    }

    depends_on = [kubernetes_manifest.ec2-nodeclass-default[0]]
}