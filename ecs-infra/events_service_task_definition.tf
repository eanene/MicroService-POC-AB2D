resource "aws_ecs_task_definition" "ab2d-event-service-task-definition" {
  family = "event-service-task-definition"
  network_mode = "awsvpc"
  execution_role_arn = data.aws_iam_role.ecs-task-definition-role.arn
  # volume {
  #   name      = "efs"
  #   host_path = "/mnt/efs"

  # }

  container_definitions = jsonencode([
    {
      name      = "event-service-container"
      image     = var.events_service_image
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