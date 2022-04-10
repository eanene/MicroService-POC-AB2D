# output "address" {
#   value = aws_elb.web.dns_name
# }

output "code_build_project" {
  value = aws_codebuild_project.containerAppBuild.arn
}
output "contract_service_pipeline_project" {
  value = aws_codepipeline.contract_service_pipeline.arn
}

output "coverage_service_pipeline_project" {
  value = aws_codepipeline.coverage_service_pipeline.arn
}

output "aggregator_service_pipeline_project" {
  value = aws_codepipeline.aggregator_service_pipeline.arn
}