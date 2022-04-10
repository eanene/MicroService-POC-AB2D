resource "aws_ecs_task_definition" "ab2d-eob-fetcher-service-task-definition" {
  family = "eob-fetcher-service-task-definition"
  network_mode = "awsvpc"
  execution_role_arn = data.aws_iam_role.ecs-task-definition-role.arn
  # volume {
  #   name      = "efs"
  #   host_path = "/mnt/efs"

  # }
  container_definitions = jsonencode([
    {
      name      = "eob-fetcher-service-container"
      image     = var.eob_fetcher_service_image
      cpu       = 4096
      memory    = 14745
      essential = true
      environment = [
        {
          name = "AB2D_DB_DATABASE"
          value = var.database_name
        },
        {
          name = "AB2D_DB_USER"
          value = "cmsadmin"
        }

      ]
      portMappings = [
        {
          containerPort = 400
          hostPort      = 400
        }
      ]
    }
    
  ])
}