output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the token"
  value       = module.ssm.ssm_parameter_name
}

output "ssm_parameter_arn" {
  description = "The ARN of the SSM parameter storing the token"
  value       = module.ssm.ssm_parameter_arn
}

output "app1_ecr_url" {
  description = "The ECR URL for app1"
  value       = module.ecr.app1_repository_url
}

output "app2_ecr_url" {
  description = "The ECR URL for app2"
  value       = module.ecr.app2_repository_url
}

output "sqs_queue_url" {
  description = "The URL of the main SQS queue"
  value       = module.sqs.main_queue_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "ecs_cluster_id" {
  description = "The ECS cluster id"
  value       = module.ecs.ecs_cluster_id
}

output "app1_task_definition_arn" {
  description = "The ARN of the ECS task definition for app1"
  value       = module.ecs.app1_task_definition_arn
}

output "app2_task_definition_arn" {
  description = "The ARN of the ECS task definition for app2"
  value       = module.ecs.app2_task_definition_arn
}

output "app1_service_name" {
  description = "The name of the ECS service for app1"
  value       = module.ecs.app1_service_name
}

output "app2_service_name" {
  description = "The name of the ECS service for app2"
  value       = module.ecs.app2_service_name
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.elb.alb_dns_name
}
