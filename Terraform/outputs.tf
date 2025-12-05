# Endereço IP público da instância EC2 (para acesso à aplicação)
output "app_public_ip" {
  description = "IP público da instância onde a aplicação está rodando"
  value       = aws_instance.app.public_ip
}

# URL de acesso à aplicação
output "app_url" {
  description = "URL para acessar a aplicação Flask"
  value       = "http://${aws_instance.app.public_ip}:5000"
}

# Nome do bucket S3 criado
output "s3_bucket_name" {
  description = "Nome do bucket S3 provisionado para uso"
  value       = aws_s3_bucket.state_bucket.bucket
}

# ID da instância EC2 (útil para troubleshooting)
output "instance_id" {
  description = "ID da instância EC2 provisionada"
  value       = aws_instance.app.id
}

# Security Group ID
output "security_group_id" {
  description = "ID do Security Group associado à instância"
  value       = aws_security_group.app_sg.id
}