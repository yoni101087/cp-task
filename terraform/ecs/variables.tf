variable "vpc_id" {
  description = "The VPC ID where the ECS cluster will be deployed"
  type        = string
}

variable "subnets" {
  description = "The list of public subnets for ECS tasks"
  type        = list(string)
}

variable "elb_security_group_id" {
  description = "The security group ID of the ELB"
  type        = string
}

variable "app1_image" {
  description = "The Docker image for app 1"
  type        = string
}

variable "app2_image" {
  description = "The Docker image for app 2"
  type        = string
}

variable "sqs_queue_url" {
  description = "The URL of the SQS queue"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "ssm_param_name" {
  description = "The name of the SSM parameter for the token"
  type        = string
}

variable "app1_target_group_arn" {
  description = "The ARN of the target group for app 1"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}