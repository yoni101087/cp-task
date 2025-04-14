output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_sg_id" {
  description = "The ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_task_sg.id
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "app1_task_definition_arn" {
  description = "The ARN of the ECS task definition for app 1"
  value       = aws_ecs_task_definition.app1.arn
}

output "app2_task_definition_arn" {
  description = "The ARN of the ECS task definition for app 2"
  value       = aws_ecs_task_definition.app2.arn
}

output "app1_service_name" {
  description = "The name of the ECS service for app 1"
  value       = aws_ecs_service.app1.name
}

output "app2_service_name" {
  description = "The name of the ECS service for app 2"
  value       = aws_ecs_service.app2.name
}

output "app1_listener_rule_arn" {
  description = "ARN of App1 Listener Rule"
  value       = aws_lb_listener_rule.app1.arn
}

output "app2_listener_rule_arn" {
  description = "ARN of App2 Listener Rule"
  value       = aws_lb_listener_rule.app2.arn
}
