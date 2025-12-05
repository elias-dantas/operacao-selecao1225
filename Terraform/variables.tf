variable "aws_region" {
  description = "Região da AWS para provisionamento dos recursos"
  type        = string
  default     = "us-west-1"
}

variable "aws_user" {
  description = "Identificador do usuário candidato (usado no nome do bucket S3)"
  type        = string
  default    = "eliasdantas.candidatoinfra1226"
}

variable "root_volume_size" {
  description = "Tamanho do volume EBS raiz da instância EC2 (máximo permitido: 10 GB)"
  type        = number
  default     = 10
  validation {
    condition     = var.root_volume_size <= 10
    error_message = "O tamanho do volume raiz não pode exceder 10 GB conforme política de segurança."
  }
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3a.micro"
  validation {
    condition     = var.instance_type == "t3a.micro"
    error_message = "Apenas instâncias do tipo t3a.micro são permitidas pela política de segurança."
  }
}