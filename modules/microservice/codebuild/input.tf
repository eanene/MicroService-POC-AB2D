variable "env" {
  description = "Targeted Depolyment environment"
  default     = "impl"
}

variable "codebuild_project_name" {
  description = "AWS CodeBuild project name"
  default     = ""
}

variable "buildspec_file_path" {
  description = "Path to buildspec.yaml file"
  default     = "buildspec.yaml"
}

variable "service_role_arn" {
  description = "AWS ARN of the IAM Service Role for the CodeBuild project to use"
  default     = ""
}
