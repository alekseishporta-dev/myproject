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
# ==========================================
# Скачивание образов
# ==========================================

# 1. Скачиваем официальный образ Nginx
resource "docker_image" "nginx_image" {
  name         = "nginx:latest"
  }

# 2. Запускаем контейнер на основе скачанного образа
resource "docker_image" "postgres_image" {
   name = "postgres:15-alpine"
   keep_locally = true 
}

resource "docker_image" "prometheus_image" {
  name = "prom/prometheus:latest"
  keep_locally = true 
}

resource "docker_image" "grafana_image" {
  name         = "grafana/grafana:latest"
  keep_locally = true 
}

resource "docker_image" "node_exporter_image" {
  name         = "prom/node-exporter:latest"
  keep_locally = true 
}

# ==========================================
# Ресурс Постгрес
# ==========================================

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

# ==========================================
# Ресурс Nginx
# ==========================================

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
# ==========================================
# МОНИТОРИНГ (PROMETHEUS & GRAFANA)
# ==========================================

resource "docker_container" "prometheus_container" {
  image = docker_image.prometheus_image.image_id
  name = "${var.env_name}-prometheus"

  lifecycle {
    create_before_destroy = false
  }

  networks_advanced {
    name = data.docker_network.private_network.name
  }

  command = ["--config.file=/etc/prometheus/prometheus.yml"]

  user = "root"
}

resource "docker_container" "grafana_container" {
  image = docker_image.grafana_image.image_id
  name = "${var.env_name}-grafana"

  lifecycle {
    create_before_destroy = false
  }

  networks_advanced {
    name = data.docker_network.private_network.name
  }

  ports {
    internal = 3000
    external = var.env_name == "dev" ? 3000:3001
  }
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=admin",
    "GF_USERS_ALLOW_SIGN_UP=false"
  ]
  depends_on = [docker_container.prometheus_container]
}

resource "docker_container" "node_exporter_container" {
  image = docker_image.node_exporter_image.image_id
  name = "${var.env_name}-node-exporter"

  lifecycle {
    create_before_destroy = false
  }

  networks_advanced {
    name = data.docker_network.private_network.name
  }

  volumes {
    host_path = "/proc"
    container_path = "/host/proc"
    read_only = true
  }

volumes {
    host_path = "/sys"
    container_path = "/host/sys"
    read_only = true
  }

volumes {
    host_path = "/"
    container_path = "/rootfs"
    read_only = true
  }

  command = [
    "--path.procfs=/host/proc",
    "--path.sysfs=/host/sys",
    "--path.rootfs=/rootfs"
  ]
}
