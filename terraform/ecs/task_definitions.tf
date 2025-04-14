locals {
  ecs_cpu    = 256
  ecs_memory = 512
}

# Task definition for app1
resource "aws_ecs_task_definition" "app1" {
  family                   = "app1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_cpu
  memory                   = local.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app1-container"
      image     = var.app1_image
      memory    = local.ecs_memory
      cpu       = local.ecs_cpu
      essential = true
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "QUEUE_URL", value = var.sqs_queue_url },
        { name = "TOKEN_PARAM_NAME", value = var.ssm_param_name }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app1"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Task definition for app2
resource "aws_ecs_task_definition" "app2" {
  family                   = "app2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_cpu
  memory                   = local.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app2-container"
      image     = var.app2_image
      memory    = local.ecs_memory
      cpu       = local.ecs_cpu
      essential = true
      environment = [
        { name = "QUEUE_URL", value = var.sqs_queue_url },
        { name = "BUCKET_NAME", value = var.s3_bucket_name }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app2"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
