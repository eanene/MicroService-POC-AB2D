output "codebuild_role" {
    value = aws_iam_role.codebuild
}

output "codepipeline_role" {
    value = aws_iam_role.codepipeline
}