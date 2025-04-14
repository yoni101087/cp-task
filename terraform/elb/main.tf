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
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
