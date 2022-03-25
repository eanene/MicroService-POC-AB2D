resource "aws_codebuild_project" "microservice" {
  badge_enabled  = false
  build_timeout  = 60
  name           = var.codebuild_project_name
  queued_timeout = 480
  service_role   = var.service_role_arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    name                   = "container-app-code-${var.env}"
    override_artifact_name = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = var.buildspec_file_path
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}