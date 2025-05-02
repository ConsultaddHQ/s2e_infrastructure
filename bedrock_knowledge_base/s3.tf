

resource "aws_s3_bucket" "kb_s3" {
  bucket = var.kb_s3_bucket_name_prefix
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.kb_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket_public_access" {
  bucket = aws_s3_bucket.kb_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "pdf_files" {
  for_each = fileset("${path.module}/s3_files", "*.pdf")

  bucket = aws_s3_bucket.kb_s3.id
  key    = each.value                      
  source = "${path.module}/s3_files/${each.value}"
  etag   = filemd5("${path.module}/s3_files/${each.value}")
}
