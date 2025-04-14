module "vpc" {
  source  = "./vpc"

  name                = "vpc"
  cidr                = "10.0.0.0/16"
  availability_zones = ["us-west-2a"]

  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "Name" = "public-subnet"
    "Service" = "ecs"
  }

  private_subnet_tags = {
    "Name" = "private-subnet"
    "Service" = "ecs"
  }

}

module "s3" {
  source            = "./s3"
  ecs_task_role_arn = module.ecs.ecs_task_role_arn
}

module "sqs" {
  source = "./sqs"
}

module "elb" {
  source               = "./elb"
  vpc_id               = var.vpc_id
  subnets              = var.subnets
  allowed_inbound_cidr = var.allowed_inbound_cidr
}

module "ecs" {
  source                = "./ecs"
  vpc_id                = var.vpc_id
  subnets               = var.subnets
  elb_security_group_id = module.elb.elb_sg_id
  app1_image            = module.ecr.app1_repository_url
  app2_image            = module.ecr.app2_repository_url
  sqs_queue_url         = module.sqs.main_queue_url
  s3_bucket_name        = module.s3.bucket_name
  ssm_param_name        = module.ssm.ssm_parameter_name
  app1_target_group_arn = module.elb.app1_target_group_arn
}

module "ssm" {
  source      = "./ssm"
  token_value = var.token_value
}

module "ecr" {
  source = "./ecr"
}
