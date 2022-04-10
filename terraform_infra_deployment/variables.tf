variable "aws_region" {
  description = "AWS region to launch servers."
  #default     = "us-east-1"
}
variable "env" {
  description = "Targeted Depolyment environment"
  #default     = "impl"
}
variable "nodejs_project_repository_name" {
  description = "Nodejs Project Repository name to connect to"
  #default     = "nodeapp"
}
variable "nodejs_project_repository_branch" {
  description = "Nodejs Project Repository branch to connect to"
  default     = "master"
}

variable "python_project_repository_name" {
  description = "Python Project Repository name to connect to"
  default     = "pythonapp"
}

variable "python_project_repository_branch" {
  description = "Python Project Repository branch to connect to"
  default     = "master"
}

variable "golang_project_repository_name" {
  description = "Go Lang Project Repository name to connect to"
  default     = "goapp"
}
variable "golang_project_repository_branch" {
  description = "Python Project Repository branch to connect to"
  default     = "master"
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "microservice-artifact-impl-bucket-ab2d"
}

variable "aws_ecs_cluster_name" {
  description = "Target Amazon ECS Cluster Name"
  #default     = "Microservice-Cluster"
}

variable "aws_ecs_node_app_service_name" {
  description = "Target Amazon ECS Cluster NodeJs App Service name"
  default     = "nodeAppService"
}

variable "aws_ecs_python_app_service_name" {
  description = "Target Amazon ECS Cluster Python App Service name"
  default     = "pythonAppService"
}

variable "aws_ecs_go_app_service_name" {
  description = "Target Amazon ECS Cluster Go App Service name"
  default     = "goAppService"
}
variable "aws_account_number" {
  default = "330810004472"
}
variable "AWS_ACCOUNT_ID" {
  default = "330810004472"
  
}
variable "github_token" {
  type = string
  
}
variable "repo_owner" {
  type = string
  
}
