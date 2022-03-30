
variable "env" {
  description = "Targeted Depolyment environment"
  default     = "impl"
}

variable "repo_name" {
  description = "GitHub repository name to connect to"
  default     = "simplespringapp"
}

variable "repo_owner" {
  description = "GitHub repository project owner"
  default     = "sb-wchaney"
}

variable "repo_branch" {
  description = "GitHub repository branch"
  default     = "master"
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
  default     = "java-microservice-pipeline"
}

variable "ecs_cluster_name" {
  description = "Target Amazon ECS Cluster Name"
  default     = "microservice-test"
}

variable "ecs_app_service_name" {
  description = "Target Amazon ECS Cluster NodeJs App Service name"
  default     = "javaAppService"
}

variable "aws_account_number" {
  default = ""
}

variable "aws_region" {
  default = "us-east-1"
}

variable "codebuild_project_name" {
  description = "AWS CodeBuild project name"
  default     = "microservices-codebuild-project"
}

variable "buildspec_file_path" {
  description = "Path to buildspec.yaml file"
  default     = "buildspec.yml"
}

# variable microservice_defs {
#   default = [
#     {

#     }
#   ]
# }