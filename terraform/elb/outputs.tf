output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.application_lb.arn
}

output "app1_target_group_arn" {
  description = "The ARN of the Target Group for app 1"
  value       = aws_lb_target_group.app1_tg.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.application_lb.dns_name
}

output "elb_sg_id" {
  description = "The ID of the security group for the ELB"
  value       = aws_security_group.elb_sg.id
}