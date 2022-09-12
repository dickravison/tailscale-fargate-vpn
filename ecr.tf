#Create ECR repo
resource "aws_ecr_repository" "tailscale" {
  name = var.service_name
}

#Add lifecycle policy to ECR to only keep upto 5 images
resource "aws_ecr_lifecycle_policy" "tailscale" {
  repository = aws_ecr_repository.tailscale.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 5 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5  
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}