
variable "env" {
  description = "Targeted Depolyment environment"
  default     = "impl"
}

variable "repo_name" {
  description = "GitHub repository name to connect to"
  default     = ""
}

variable "repo_owner" {
  description = "GitHub repository project owner"
  default     = ""
}

variable "repo_branch" {
  description = "GitHub repository branch"
  default     = ""
}

variable "github_token" {
  description = "GitHub repository OAuth token"
  default     = ""
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "microservice-artifact-impl-bucket-ab2d"
}

variable "pipeline_name" {
  description = "AWS CodePipeline name"
  default     = ""
}

variable "codebuild_project_name" {
  description = "AWS CodeBuild project name"
  default     = ""
}

variable "role_arn" {
  description = "AWS ARN of the IAM Service Role for the CodePipeline project to use"
  default     = ""
}

variable "ecs_cluster_name" {
  description = "Target Amazon ECS Cluster Name"
  default     = "Microservice-Cluster"
}

variable "ecs_app_service_name" {
  description = "Target Amazon ECS Cluster NodeJs App Service name"
  default     = "nodeAppService"
}

variable "aws_account_number" {
  default = ""
}

variable "aws_region" {
  default = "us-east-1"
}

