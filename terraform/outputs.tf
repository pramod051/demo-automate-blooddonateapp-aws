output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "dynamodb_tables" {
  description = "DynamoDB table names"
  value = {
    users     = aws_dynamodb_table.users.name
    donors    = aws_dynamodb_table.donors.name
    requests  = aws_dynamodb_table.requests.name
    inventory = aws_dynamodb_table.inventory.name
  }
}
