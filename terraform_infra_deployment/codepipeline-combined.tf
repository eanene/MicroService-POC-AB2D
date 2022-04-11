#################################################
############### Service 1 #######################
#################################################

resource "aws_codepipeline" "app_pipeline" {
  for_each = {
    "node" = tomap(
      {
        "name"             = "node"
        "FullRepositoryId" = "sb-ebukaanene/ab2d-nodeapp-service"
        "config"           = templatefile("./templates/node.tftpl", {
          config = {
            env                = var.env
            aws_region         = var.aws_region
            aws_account_number = var.aws_account_number
          }
        })
        "output.artifact" = "BuildArtifact"
        "serviceName"     = var.aws_ecs_node_app_service_name
        "input_artifacts" = "build_output"
      }
    )
    "python" = tomap(
      {
        "name"             = "python"
        "FullRepositoryId" = "sb-ebukaanene/Python-Service-2"
        "config"           = templatefile("./templates/node.tftpl", {
          config = {
            env                = var.env
            aws_region         = var.aws_region
            aws_account_number = var.aws_account_number
          }
        })
        "output.artifact" = "BuildArtifact"
        "serviceName"     = var.aws_ecs_python_app_service_name
        "input_artifacts" = "BuildArtifact"
      }
    )
    "go" = tomap(
      {
        "name"             = "go"
        "FullRepositoryId" = "sb-ebukaanene/Go-Service-3"
        "config"           = templatefile("./templates/node.tftpl", {
          config = {
            env                = var.env
            aws_region         = var.aws_region
            aws_account_number = var.aws_account_number
          }
        })
        "output.artifact" = "BuildArtifact"
        "serviceName"     = var.aws_ecs_go_app_service_name
        "input_artifacts" = "BuildArtifact"
      }
    )

  }


  name     = each.value["name"]
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  tags     = {
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
        FullRepositoryId = each.value["FullRepositoryId"]
        #Owner                = "AB2D"
        #PollForSourceChanges = "false"
        #Repo                 = "Python-Service-2"
        BranchName       = "main"
        #OAuthToken           = data.aws_ssm_parameter.oauth.value
      }
    }
  }
  stage {
    name = "Build"

    action {
      category      = "Build"
      configuration = {
        "EnvironmentVariables" = each.value["config"]
        "ProjectName"          = aws_codebuild_project.containerAppBuild.name
      }
      input_artifacts = [
        "SourceArtifact"
      ]
      name             = "Build"
      output_artifacts = [
        each.value["output.artifact"]
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
      category      = "Deploy"
      configuration = {
        "ClusterName" = var.aws_ecs_cluster_name
        "ServiceName" = each.value["serviceName"]
        "FileName"    = "imagedefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        each.value["input_artifacts"]
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

