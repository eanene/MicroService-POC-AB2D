
#################################################
############### Parameter Service #################
#################################################

# resource "aws_codestarconnections_connection" "ab2d-github-connection" {
#   name          = "GITHUB-connection"
#   provider_type = "GitHub"

# }

resource "aws_codepipeline" "parameter_service_pipeline" {
  name     = "${var.env}-parameter-service"
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
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.ab2d-github-connection.arn
        FullRepositoryId = "CMSgov/ab2d-parameter"
        #Owner                = "AB2D"
        #PollForSourceChanges = "false"
        #Repo                 = "Python-Service-2"
        BranchName               = "main"
        #OAuthToken           = data.aws_ssm_parameter.oauth.value
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
              value = "${var.env}-services"
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "parameter-service"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = "parameter-service-container"
            },
            {
              name  = "SONAR_LOGIN"
              type  = "PLAINTEXT"
              value = "xxx"
            },
            {
              name  = "SONAR_HOST"
              type  = "PLAINTEXT"
              value = "https://sonarqube.cloud.cms.gov"
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
        "ServiceName" = "ab2d-contract-service"
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

