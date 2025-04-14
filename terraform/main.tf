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
