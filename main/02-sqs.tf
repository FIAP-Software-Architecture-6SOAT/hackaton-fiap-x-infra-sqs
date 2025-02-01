data "aws_iam_policy_document" "iam_policy_sqs" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_sqs_queue" "sqs_video_to-process_deadletter" {
  name                       = "${local.env}-video-to-process-deadletter"
  policy                     = data.aws_iam_policy_document.iam_policy_sqs.json
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 10
}

resource "aws_sqs_queue" "sqs_video_to-process" {
  name                       = "${local.env}-video-to-process"
  policy                     = data.aws_iam_policy_document.iam_policy_sqs.json
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_video_to-process_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_ssm_parameter" "sqs_video_to-process" {
  name  = "${local.env}-sqs-video-to-process"
  type  = "String"
  value = aws_sqs_queue.sqs_video_to-process.arn
}

resource "aws_ssm_parameter" "sqs_video_to-process_endpoint" {
  name  = "${local.env}-sqs-video-to-process-endpoint"
  type  = "String"
  value = aws_sqs_queue.sqs_video_to-process.id
}
