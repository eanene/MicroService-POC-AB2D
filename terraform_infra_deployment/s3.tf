resource "aws_s3_bucket" "cicd_bucket" {
  bucket = var.artifacts_bucket_name 

}

resource "aws_s3_bucket_acl" "cicd_bucket" {
  bucket = aws_s3_bucket.cicd_bucket.id
  acl    = "private"
}