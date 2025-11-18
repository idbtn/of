locals {
    events = {
        health_event = {
            name = "HealthEvent"
            description = "Karpenter interrupt - AWS health event"
            event_pattern = {
                source = ["aws.health"]
                detail-type = ["AWS Health Event"]
            }
        }
        spot_interrupt = {
            name = "SpotInterrupt"
            description = "Karpenter interrupt - EC2 spot instance interruption warning"
            event_pattern = {
                source = ["aws.ec2"]
                detail-type = ["EC2 Spot Instance Interruption Warning"]
            }
        }
        instance_rebalance = {
            name = "InstanceRebalance"
            description = "Karpenter interrupt - EC2 instance rebalance recommendation"
            event_pattern = {
                source = ["aws.ec2"]
                detail-type = ["EC2 Instance Rebalance Recommendation"]
            }
        }
        instance_state_change = {
            name = "InstanceStateChange"
            description = "Karpenter interrupt - EC2 instance state-change notification"
            event_pattern = {
                source = ["aws.ec2"]
                detail-type = ["EC2 Instance State-Change Notification"]
            }
        }
    }
}

resource "aws_sqs_queue" "karpenter-sqs-queue" {
    count = var.enable_karpenter ? 1 : 0

    name = "eks-${var.env}-${var.project_name}-karpenter-sqs-queue"
    message_retention_seconds = 300
    sqs_managed_sse_enabled = true
}

data "aws_iam_policy_document" "karpenter-queue-policy-document" {
    statement {
        actions = ["sqs:SendMessage"]
        resources = [aws_sqs_queue.karpenter-sqs-queue[0].arn]
        principals {
            type = "Service"
            identifiers = [
                "events.amazonaws.com",
                "sqs.amazonaws.com",
            ]
        }
        sid = "SqsWrite"
    }
}

resource "aws_sqs_queue_policy" "karpenter-sqs-queue-policy" {
    queue_url = aws_sqs_queue.karpenter-sqs-queue[0].url
    policy = data.aws_iam_policy_document.karpenter-queue-policy-document.json
}

resource "aws_cloudwatch_event_rule" "karpenter-cloudwatch-event-rule" {
    for_each = { for k, v in local.events : k => v }
    name_prefix = "karpenter-${each.value.name}-"
    description = each.value.description
    event_pattern = jsonencode(each.value.event_pattern)
}

resource "aws_cloudwatch_event_target" "karpenter-cloudwatch-event-target" {
    for_each = { for k, v in local.events : k => v }
    rule = aws_cloudwatch_event_rule.karpenter-cloudwatch-event-rule[each.key].name
    target_id = "KarpenterInterruptionQueueTarget"
    arn = aws_sqs_queue.karpenter-sqs-queue[0].arn
}