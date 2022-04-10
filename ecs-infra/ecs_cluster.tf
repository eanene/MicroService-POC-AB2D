# terraform {
#     backend "s3" {
#         bucket = "ab2d-ecs-state"
#         key    = "state.tfstate"
#     }
# }

# resource "aws_ecr_repository" "ab2d-ecr-repo" {
#     name  = "ab2d-${var.environment}"
# }
resource "aws_ecs_cluster" "ab2d_ecs_cluster" {
    name  = "ab2d-${var.environment}-microservice-cluster"
}

resource "aws_ecs_service" "contract_service" {
  name          = "ab2d-contract-service"
  cluster       = aws_ecs_cluster.ab2d_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ab2d-contract-service-task-definition.arn
  desired_count = 1
  launch_type = "EC2"
  #iam_role = 
  
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
#   load_balancer {
#     target_group_arn = aws_lb_target_group.foo.arn
#     container_name   = "xxxx"
#     container_port   = 8080
#   }
  network_configuration {
    subnets = data.aws_subnets.ab2d-private-subnets.ids
    #assign_public_ip = false
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_service" "aggregator_service" {
  name          = "ab2d-aggregator-service"
  cluster       = aws_ecs_cluster.ab2d_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ab2d-aggregator-service-task-definition.arn
  desired_count = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
#   load_balancer {
#     target_group_arn = aws_lb_target_group.foo.arn
#     container_name   = "xxxx"
#     container_port   = 8080
#   }
  network_configuration {
    subnets = data.aws_subnets.ab2d-private-subnets.ids
    #assign_public_ip = false
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}


##### create other service for the other ab2d-services and modify thier task def and name and logical nbame######


