# Random suffix for unique bucket name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# S3 Bucket
resource "aws_s3_bucket" "main_bucket" {
  bucket = "main-bucket-${random_string.suffix.result}"

  tags = {
    Name = "main-bucket"
  }
}

# Enable S3 Versioning
resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  bucket = aws_s3_bucket.main_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Policy (Combined)
resource "aws_s3_bucket_policy" "main_bucket_policy" {
  bucket = aws_s3_bucket.main_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Deny Public Access
      {
        Sid       = "DenyPublicAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource  = "${aws_s3_bucket.main_bucket.arn}/*"
      },
      # Allow ECS Task Role Access
      {
        Sid       = "AllowECSAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.ecs_task_role_arn
        }
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource  = [
          "${aws_s3_bucket.main_bucket.arn}",
          "${aws_s3_bucket.main_bucket.arn}/*"
        ]
      }
    ]
  })
}
