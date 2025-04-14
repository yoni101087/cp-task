locals {
  ecs_subnets         = var.subnets
  ecs_security_groups = [aws_security_group.ecs_task_sg.id]
}
