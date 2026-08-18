terraform {
    required_providers {
        helm = {
            source = "hashicorp/helm"
            version = "~> 2.12.0"
        }
    }
}

provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}

variable "env_name" {
  type        = string
  description = "Имя окружения (dev или prod)"
}

resource "helm_release" "vault" {
  name             = "${var.env_name}-vault"
  chart            = "./vault-helm-0.34.1.tar.gz"

  # Настройки Vault передаем через блок values
  values = [
    <<-EOF
    server:
      # Включаем режим standalone (для одной ноды K3s)
      standalone:
        enabled: true
      
      # Ограничиваем ресурсы, чтобы не перегрузить виртуалку
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi

      # Открываем веб-интерфейс Vault наружу через NodePort
      service:
        type: NodePort
        nodePort: ${var.env_name == "dev" ? 31000 : 31001}

      dataStorage:
         enabled: true
         size: 1Gi
         storageClass: "local-path"

    # Отключаем встроенный инжектор секретов (пока он нам не нужен для простоты)
    injector:
      enabled: false

    # Включаем удобный графический веб-интерфейс Vault (UI)
    ui:
      enabled: true
      serviceType: "NodePort"
    EOF
  ]
}