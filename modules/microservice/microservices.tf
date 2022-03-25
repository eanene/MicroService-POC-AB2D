terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


module "policies" {
    source = "./iam"

    env = var.env
    aws_account_number = var.aws_account_number
}

module "codebuild" {
    source = "./codebuild"

    env = var.env
    codebuild_project_name = var.codebuild_project_name
    buildspec_file_path = var.buildspec_file_path

    service_role_arn = module.policies.codebuild_role.arn
}

# TODO use dynamic block or count to enumerate microservice items
module "microservice_a" {
    source = "./codepipeline"

    env = var.env
    aws_account_number = var.aws_account_number
    aws_region = var.aws_region
    repo_name = var.repo_name
    repo_owner = var.repo_owner
    repo_branch = var.repo_branch
    github_token = var.github_token
    artifacts_bucket_name = var.artifacts_bucket_name
    pipeline_name = var.pipeline_name
    ecs_cluster_name = var.ecs_cluster_name
    ecs_app_service_name = var.ecs_app_service_name
    codebuild_project_name = var.codebuild_project_name

    role_arn = module.policies.codepipeline_role.arn
}

# module "microservice_b" {
#     source = "./codepipeline"
# }

# module "microservice_c" {
#     source = "./codepipeline"
# }