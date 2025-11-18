resource "aws_subnet" "private" {
    count = length(var.private_subnets)

    vpc_id = aws_vpc.this.id
    cidr_block = var.private_subnets[count.index]
    availability_zone = var.azs[count.index]

    tags = merge(
        {
            "Name" = "${var.env}-private-${var.azs[count.index]}"
            "karpenter.sh/discovery" = var.eks_full_name
            "kubernetes.io/cluster/${var.eks_full_name}" = "shared"
        },
        var.private_subnet_tags
    )
}

resource "aws_subnet" "public" {
    count = length(var.public_subnets)

    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnets[count.index]
    availability_zone = var.azs[count.index]

    tags = merge(
        {
            "Name" = "${var.env}-public-${var.azs[count.index]}"
            "kubernetes.io/cluster/${var.eks_full_name}" = "shared"
        },
        var.public_subnet_tags
    )
}