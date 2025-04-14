locals {
  alb_port = 80
  app_port = 5000
}

# Security Group for ALB
resource "aws_security_group" "elb_sg" {
  name        = "elb-sg"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.alb_port
    to_port     = local.alb_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_inbound_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }
}

# ALB Resource
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false

  tags = {
    Name = "application-lb"
  }
}

# Target Group for app1
resource "aws_lb_target_group" "app1_tg" {
  name        = "app1-tg"
  port        = local.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "app1-tg"
  }
}

# Listener for app1
resource "aws_lb_listener" "app1_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = local.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1_tg.arn
  }
}
