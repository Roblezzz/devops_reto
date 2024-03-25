output "db-arn" {
  value = aws_dynamodb_table.db.arn
}

output "api_url" {
    value = aws_api_gateway_deployment.deploy.invoke_url
}