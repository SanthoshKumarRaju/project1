resource "aws_kms_key" "kms-key" {
  description = "Example KMS key"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "kms:*",
        Effect = "Allow",
        Principal = {
        AWS = "arn:aws:iam::312536711471:user/Santhosh123"
        },
        Resource = "*"
      }
    ]
  })
}