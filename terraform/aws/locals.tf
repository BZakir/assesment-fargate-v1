locals {
  aws_region      = "eu-west-1"
  prefix          = "task"
  profile         = "default"
  cluster_name    = "ecs_fargate_cluster"
  container_name  = "fargate_container"
  container_image = "nginx"
  container_port  = "80"
}
