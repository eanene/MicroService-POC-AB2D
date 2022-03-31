
#################################################
############### TEST Pipeline ###################
#################################################

resource "aws_codepipeline" "TEST-pipeline" {
  name     = "${terraform.workspace}-TEST-4-cloning"
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
        FullRepositoryId = "sb-ebukaanene/ab2d-nodeapp-service"
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
}
  