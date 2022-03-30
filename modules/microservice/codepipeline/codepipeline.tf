# TODO: one S3 bucket per microservice? or artifactory
resource "aws_s3_bucket" "cicd_bucket" {
  bucket = var.artifacts_bucket_name 

}

# TODO don't use ACL
resource "aws_s3_bucket_acl" "cicd_bucket" {
  bucket = aws_s3_bucket.cicd_bucket.id
  acl    = "private"
}

resource "aws_codepipeline" "microservice" {
  name     = var.pipeline_name
  role_arn = var.role_arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    # TODO: update to codestarconnections https://docs.aws.amazon.com/codepipeline/latest/userguide/update-github-action-connections.html
    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.repo_owner
        Repo       = var.repo_name
        Branch     = var.repo_branch
        OAuthToken = var.github_token
      }
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
            {
              name  = "AWS_DEFAULT_REGION"
              type  = "PLAINTEXT"
              value = var.aws_region
            },
            {
              name  = "AWS_ACCOUNT_ID"
              type  = "PLAINTEXT"
              value = var.aws_account_number
            },
            {
              name  = "IMAGE_REPO_NAME"
              type  = "PLAINTEXT"
              value = "javaapp"
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = "javaapp"
            },
          ]
        )
        "ProjectName" = var.codebuild_project_name
      }
      input_artifacts = [
        "source_output"
      ]
      name = "Build"
      output_artifacts = [
        "build_output"
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName" = var.ecs_cluster_name
        "ServiceName" = var.ecs_app_service_name
        "FileName"    = "imagedefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        "build_output"
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ECS"
      run_order        = 1
      version          = "1"
    }
  }
}
