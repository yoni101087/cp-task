resource "aws_sqs_queue" "main_queue" {
  name = "main-queue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  delay_seconds              = 0

}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = "dlq"

  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue_policy" "main_queue_policy" {
  queue_url = aws_sqs_queue.main_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowDeadLetterQueue"
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.dead_letter_queue.arn
      }
    ]
  })
}