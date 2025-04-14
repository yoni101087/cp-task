variable "ecs_task_role_arn" {
  description = "ARN of the ECS task execution role that needs access to S3"
  type        = string
  default     = ""
}