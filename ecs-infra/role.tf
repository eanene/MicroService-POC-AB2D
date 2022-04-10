

data "aws_iam_role" "ecs-task-definition-role" {
  name = "Ab2dEast${var.env}InstanceRole"
  
}