terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

# Настройка провайдера для работы с локальным Docker-демоном
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

  # Инструкция для автоматической сборки образа из нашего Dockerfile

data "docker_network" "private_network" {
  name = "${var.env_name}_network"
}

# 1. Скачиваем официальный образ Nginx
resource "docker_image" "nginx_image" {
  name         = "nginx:latest"
  }


# 2. Запускаем контейнер на основе скачанного образа
resource "docker_image" "postgres_image" {
   name = "postgres:15-alpine"
   keep_locally = false
}

resource "docker_container" "postgres_container" {
   image = docker_image.postgres_image.image_id
   name = "${var.env_name}-terraform-db"
  lifecycle {
    # Запрещаем создавать новый контейнер, пока не удален старый конфликтующий
    create_before_destroy = false
  }

   networks_advanced {
      name = data.docker_network.private_network.name
}

env = [
  "POSTGRES_USER=${var.db_user}",
  "POSTGRES_PASSWORD=${var.db_password}",
  "POSTGRES_DB=prod_vmdbs"
]

}

resource "docker_container" "nginx_container" {
  image = docker_image.nginx_image.image_id
  name  = "${var.env_name}-terraform-web-server"
  

  lifecycle {
    # Запрещаем создавать новый контейнер, пока не удален старый конфликтующий
    create_before_destroy = false
  }

  networks_advanced {
      name = data.docker_network.private_network.name
} 

  ports {
    internal = 80
    external = var.web_port
  }

volumes {
  # Указываем фиксированный абсолютный путь в обход ограничений Snap
  host_path      = "/root/myproject/infrastructure-modules/src"
  container_path = "/usr/share/nginx/html"
}
 
 depends_on = [docker_container.postgres_container]
}