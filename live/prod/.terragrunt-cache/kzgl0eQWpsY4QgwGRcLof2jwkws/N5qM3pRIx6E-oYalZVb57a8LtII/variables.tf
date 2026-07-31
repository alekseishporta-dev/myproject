variable "web_port" {
  description = "Внешний порт для доступа к веб-серверу"
  type        = number
  default     = 8080  # Изменим порт на 8080 для проверки обновлений
}

variable "db_user" {
  description = "imypolzovatela"
  type = string
  default = "db_admin"
}

variable "db_password" {
  description = "test38546"
  type = string
  sensitive = true
  default = "SuperSecretPassword123"
}

variable "env_name" {
  description = "Название окружения (dev, prod, stage)"
  type  = string
}
