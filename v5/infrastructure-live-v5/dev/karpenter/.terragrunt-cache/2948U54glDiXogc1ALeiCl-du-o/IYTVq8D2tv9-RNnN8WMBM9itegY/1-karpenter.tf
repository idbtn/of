resource "helm_release" "karpenter-helm-release" {
    count = var.enable_karpenter ? 1 : 0

    name = "karpenter"
    repository = "oci://public.ecr.aws/karpenter"
    chart = "karpenter"
    namespace = var.karpenter_namespace
    create_namespace = true
    version = var.karpenter_helm_version
    depends_on = [aws_eks_fargate_profile.karpenter]

    set = [
        {
            name = "serviceAccount.name"
            value = "karpenter"
        },
        {
            name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
            value = aws_iam_role.karpenter-controller-role[0].arn
        },
        {
            name = "settings.clusterName"
            value = var.eks_full_name
        },
        {
            name = "settings.clusterEndpoint"
            value = var.eks_cluster_endpoint
        },
        {
            name = "settings.eksControlPlane"
            value = true
        },
        {
            name = "settings.interruptionQueue"
            value = aws_sqs_queue.karpenter-sqs-queue[0].name
        }
    ]
}