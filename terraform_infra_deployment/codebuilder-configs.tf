 locals {
  config_map = tomap(
    {
      "aggregator-service" = tomap(
        {
          "name"             = "${var.env}-aggregator-service"
          "FullRepositoryId" = "sb-ebukaanene/Python-Service-2"
          "config"           = "./templates/aggregator-service.tftpl"
          "output.artifact" = "BuildArtifact"
          "serviceName"     = "ab2d-aggregator-service"
          "input_artifacts" = "BuildArtifact"
        }
      )
      "api-service" = tomap(
        {
          "name"             = "${var.env}-api-service"
          "FullRepositoryId" = "CMSgov/ab2d-api"
          "config"           = "./templates/api-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-api-service"
          "input_artifacts" = "build_output"
        }
      )
      "audit-service" = tomap(
        {
          "name"             = "${var.env}-audit-service"
          "FullRepositoryId" = "sb-ebukaanene/Go-Service-3"
          "config"           = "./templates/audit-service.tftpl"
          "output.artifact" = "BuildArtifact"
          "serviceName"     = var.aws_ecs_go_app_service_name
          "input_artifacts" = "BuildArtifact"
        }
      )
      "contract-service" = tomap(
        {
          "name"             = "${var.env}-contract-service"
          "FullRepositoryId" = "CMSgov/ab2d-contracts"
          "config"           = "./templates/contract-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-contract-service"
          "input_artifacts" = "build_output"
        }
      )
      "coverage-service" = tomap(
        {
          "name"             = "${var.env}-coverage-service"
          "FullRepositoryId" = "CMSgov/ab2d-coverage"
          "config"           = "./templates/coverage-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-coverage-service"
          "input_artifacts" = "build_output"
        }
      )
      "eob-fetcher-service" = tomap(
        {
          "name"             = "${var.env}-eob-fetcher-service"
          "FullRepositoryId" = "CMSgov/ab2d-eob-fetcher"
          "config"           = "./templates/eob-fetcher-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-eob-fetcher-service"
          "input_artifacts" = "build_output"
        }
      )
      "events-service" = tomap(
        {
          "name"             = "${var.env}-events-service"
          "FullRepositoryId" = "CMSgov/ab2d-events"
          "config"           = "./templates/events-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-events-service"
          "input_artifacts" = "build_output"
        }
      )
      "jobs-service" = tomap(
        {
          "name"             = "${var.env}-jobs-service"
          "FullRepositoryId" = "CMSgov/ab2d-jobs"
          "config"           = "./templates/jobs-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-jobs-service"
          "input_artifacts" = "build_output"
        }
      )
      "parameter-service" = tomap(
        {
          "name"             = "${var.env}-parameter-service"
          "FullRepositoryId" = "CMSgov/ab2d-parameter"
          "config"           = "./templates/parameter-service.tftpl"
          "output.artifact" = "build_output"
          "serviceName"     = "ab2d-contract-service"
          "input_artifacts" = "build_output"
        }
      )
    }
  )
}



