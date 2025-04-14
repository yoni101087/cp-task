# ECS Service for App1
resource "aws_ecs_service" "app1" {
  name            = "app1-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app1.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.app1_target_group_arn
    container_name   = "app1-container"
    container_port   = 5000
  }

  # Ensure LB listener exists before creating ECS Service
  depends_on = [
    aws_lb_listener_rule.app1
  ]
}

# ECS Service for App2
resource "aws_ecs_service" "app2" {
  name            = "app2-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app2.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.ecs_subnets
    security_groups  = local.ecs_security_groups
    assign_public_ip = true
  }


  # Ensure LB listener exists before creating ECS Service
  depends_on = [
    aws_lb_listener_rule.app2
  ]
}
