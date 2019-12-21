module "networking" {
  source                                      = "cn-terraform/networking/aws"
  version                                     = "2.0.3"
  name_preffix                                = local.prefix
  profile                                     = local.profile
  region                                      = local.aws_region
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19", "192.168.96.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19", "192.168.224.0/19"]
}

module "ecs-fargate" {
  source                       = "cn-terraform/ecs-fargate/aws"
  version                      = "2.0.7"
  name_preffix                 = local.prefix
  region                       = local.aws_region
  profile                      = local.profile
  ecs_cluster_name             = local.cluster_name
  subnets                      = module.networking.private_subnets_ids
  container_port               = local.container_port
  vpc_id                       = module.networking.vpc_id
  availability_zones           = module.networking.availability_zones
  public_subnets_ids           = module.networking.public_subnets_ids
  private_subnets_ids          = module.networking.private_subnets_ids
  container_name               = local.container_name
  container_image              = local.container_image
  entrypoint                   = "/service"
  container_cpu                = 1024
  container_memory             = 1024
  container_memory_reservation = 256
  essential                    = true
  ecs_cluster_arn              = ""
  task_definition_arn          = ""
  enable_ecs_managed_tags      = true

}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  subnets            = module.networking.private_subnets_ids
  vpc_id             = module.networking.vpc_id
  http_tcp_listeners = list(map("port", "80", "protocol", "HTTP"))
  target_groups = [
    {
      name             = "Alb-tg",
      backend_protocol = "HTTP",
      backend_port     = "80",
      health_check = {
        enabled             = true
        interval            = "10"
        path                = "/__healthcheck__"
        port                = "80"
        healthy_threshold   = "3"
        unhealthy_threshold = "9"
        timeout             = "3"
        protocol            = "http"
      }
    }
  ]
}
