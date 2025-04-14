output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the token"
  value       = aws_ssm_parameter.token.name
}

output "ssm_parameter_arn" {
  description = "The ARN of the SSM parameter storing the token"
  value       = aws_ssm_parameter.token.arn
}