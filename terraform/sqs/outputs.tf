output "main_queue_url" {
  description = "The URL of the main SQS queue"
  value       = aws_sqs_queue.main_queue.id
}

output "main_queue_arn" {
  description = "The ARN of the main SQS queue"
  value       = aws_sqs_queue.main_queue.arn
}

output "dead_letter_queue_url" {
  description = "The URL of the dead-letter queue"
  value       = aws_sqs_queue.dead_letter_queue.id
}

output "dead_letter_queue_arn" {
  description = "The ARN of the dead-letter queue"
  value       = aws_sqs_queue.dead_letter_queue.arn
}