
#################################################
############### Service 1 #######################
#################################################

resource "aws_codepipeline" "node_app_pipeline" {
  name     = "node-app-pipeline-ab2d"
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      
      # configuration = {
      #   "BranchName"           = var.nodejs_project_repository_branch
      #   # "PollForSourceChanges" = "false"
      #   "RepositoryName"       = var.nodejs_project_repository_name
      # }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact"
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      #run_order = 1
      version   = "1"
      # tried to use version 2 but terraform won't run apply

      configuration = {
        
        Owner      = var.repo_owner
        #Repo       = var.repo_name
        Repo       = "Nnode-Service-1"
        Branch     = "main"
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
              value = "micro-services-demo"
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "service1"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = "nodeAppContainer"
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild.name
      }
      input_artifacts = [
        "SourceArtifact"
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
        "ClusterName" = var.aws_ecs_cluster_name
        "ServiceName" = var.aws_ecs_node_app_service_name
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