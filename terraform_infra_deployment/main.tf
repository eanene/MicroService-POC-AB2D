terraform {
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
      

    }
  }
  required_version = "~> 1.0"
  #region = var.aws_region
}

# provider "aws" {
#   region = var.aws_region
#   access_key = "ASIAU2BOQCP4CXAKUN4Z"
#   secret_key = "gk68nf4SbJ4uQRnEG3VrsCUFyeDo15XGhT9bc1TL"
#   #AWS_SESSION_TOKEN = FwoGZXIvYXdzEO///////////wEaDK4elVHc/WodvFvDCSKoAT1v3eKuMw7Y3nAb+pu3VT5mkbc0yLOWXTAKdKmwro1ACdsrGrYDmw5RzdlFmEW6YupbfxVYcefswIFigQiS7q9frvm1n3B5cMlBccwMyJktLdMH68bJQm8uHYpWqONeOuxEXbuVClsI5Ik+69HTg8XbD+tJn+VqG/TYXWXOUv91MxQKY/KGmwjC2AHVTs8Wb6QzVyitGL33jf4AQrhRuOdnzIsDJwS/Oyjau/ORBjItRuzirJ8mig+gIpdYfY57TSPnVNi0m9v8aIoVZeIz0zT1omGEVVkZbfOYZ2gg
# }

# data "aws_codecommit_repository" "nodeapp_repo" {
#   repository_name = var.nodejs_project_repository_name
# }
# data "aws_codecommit_repository" "pythonapp_repo" {
#   repository_name = var.python_project_repository_name
# }
# data "aws_codecommit_repository" "goapp_repo" {
#   repository_name = var.golang_project_repository_name
# }

resource "aws_iam_role" "containerAppBuildProjectRole" {
  name = "containerAppBuildProjectRole"
  path   = "/delegatedadmin/developer/"
  permissions_boundary = "arn:aws:iam::${var.aws_account_number}:policy/cms-cloud-admin/developer-boundary-policy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "containerAppBuildProjectRolePolicy" {
  role = aws_iam_role.containerAppBuildProjectRole.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "ecs:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "*"
         ]
      }
  ]
}
POLICY
}

resource "aws_codebuild_project" "containerAppBuild" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "container-app-build"
  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    # name                   = "container-app-code-${var.env}"
    # override_artifact_name = false
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
    # buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

resource "aws_iam_role" "apps_codepipeline_role" {
  name = "apps-code-pipeline-role"
  path   = "/delegatedadmin/developer/"
  permissions_boundary = "arn:aws:iam::${var.aws_account_number}:policy/cms-cloud-admin/developer-boundary-policy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apps_codepipeline_role_policy" {
  name = "apps-codepipeline-role-policy"
  role = aws_iam_role.apps_codepipeline_role.id

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "*"
         ]
      }
    ],
    "Version": "2012-10-17"
}
EOF
}
# resource "aws_s3_bucket" "cicd_bucket" {
#   bucket = var.artifacts_bucket_name 
 
# }
resource "aws_s3_bucket" "cicd_bucket" {
  bucket = var.artifacts_bucket_name 

}

resource "aws_s3_bucket_acl" "cicd_bucket" {
  bucket = aws_s3_bucket.cicd_bucket.id
  acl    = "private"
}
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
      configuration = {
        "BranchName"           = var.nodejs_project_repository_branch
        # "PollForSourceChanges" = "false"
        "RepositoryName"       = var.nodejs_project_repository_name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact"
      ]
      owner     = "AWS"
      provider  = "CodeCommit"
      run_order = 1
      version   = "1"
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
              value = "nodeapp"
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
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
resource "aws_codepipeline" "python_app_pipeline" {
  name     = "python-app-pipeline-ab2d"
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
      configuration = {
        "BranchName"           = var.python_project_repository_branch
        # "PollForSourceChanges" = "false"
        "RepositoryName"       = var.python_project_repository_name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "source_output"
      ]
      owner     = "AWS"
      provider  = "CodeCommit"
      run_order = 1
      version   = "1"
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
              type  = "PARAMETER_STORE"
              value = "ACCOUNT_ID"
            },
            {
              name  = "IMAGE_REPO_NAME"
              type  = "PLAINTEXT"
              value = "nodeapp"
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = "pythonAppContainer"
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild.name
      }
      input_artifacts = [
        "source_output"
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact"
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
        "ServiceName" = var.aws_ecs_python_app_service_name
        "FileName"    = "imagedefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        "BuildArtifact"
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


resource "aws_codepipeline" "go_app_pipeline" {
  name     = "go-app-pipeline-ab2d"
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
      configuration = {
        "BranchName"           = var.golang_project_repository_branch
        # "PollForSourceChanges" = "false"
        "RepositoryName"       = var.golang_project_repository_name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact"
      ]
      owner     = "AWS"
      provider  = "CodeCommit"
      run_order = 1
      version   = "1"
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
              type  = "PARAMETER_STORE"
              value = "ACCOUNT_ID"
            },
            {
              name  = "IMAGE_REPO_NAME"
              type  = "PLAINTEXT"
              value = "nodeapp"
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = "goAppContainer"
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact"
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
        "ServiceName" = var.aws_ecs_go_app_service_name
        "FileName"    = "imagedefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        "BuildArtifact"
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