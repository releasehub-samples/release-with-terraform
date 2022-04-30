data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

### ECS example adapted from the link below (refer to it or detail):
# https://registry.terraform.io/modules/umotif-public/ecs-fargate/aws/latest

resource "aws_ecs_cluster" "cluster" {
  name = "release-terraform-demo"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

module "ecs-fargate" {
  source = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix        = "release-ecs-example"
  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnets.all.ids
  cluster_id         = aws_ecs_cluster.cluster.id

  task_container_image   = "marcincuber/2048-game:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512

  task_container_port             = 80
  task_container_assign_public_ip = true

  load_balanced =  true
  
  target_groups = [
    {
      target_group_name = "release-ecs-demo-tg"
      container_port    = 80
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }
}

# Terraform's "terraform_remote_state" data source allows one Terraform configuration
# to read the output of a remote state file. So, if you need to share state between
# different containers within the same environment, one way of accomplishing this is
# by writing outputs to state as shown below. To reference this value, you'll likely
# need to run your other Terraform as a job within the same environment / App Template
# so that the other job *also* has the same environment variables that tell it the 
# proper environment ID to know where you're storing your state:
output "ecs_service_arn" {
  value = module.ecs-fargate.service_arn
}

# We write our ephemeral Lambda's function name to AWS Parameter Store. This is
# just an example of an alternate way of sharing ephemeral Terraform outputs outside of
# your Release environment.
resource "aws_ssm_parameter" "ecs_service_arn" {
  name  = "/release/${local.unique_prefix}/ecs_service_arn"
  type  = "String"
  value = module.ecs-fargate.service_arn
}