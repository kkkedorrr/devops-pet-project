output "server_public_ip" {
  description = "Public IP of the K8s Server"
  value       = aws_instance.k8s_server.public_ip
}

output "ecr_registry_url" {
  description = "URL of the ECR Registry"
  value       = aws_ecr_repository.app_repo.repository_url
}
