resource "aws_ecs_task_definition" "app1" {
  family                   = "app1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app1-container"
      image     = var.app1_image
      memory    = 512
      cpu       = 256
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

resource "aws_ecs_task_definition" "app2" {
  family                   = "app2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app2-container"
      image     = var.app2_image
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = []
      mountPoints = []
      volumesFrom = []
      systemControls = []
      environment = [
        { name = "QUEUE_URL", value = var.sqs_queue_url },
        { name = "BUCKET_NAME", value = var.s3_bucket_name },
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