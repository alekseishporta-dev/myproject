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
    type = string
    description = "Имя окружения (dev или prod)"
}

resource "helm_release" "monitoring_stack" {
    name = "${var.env_name}-monitoring"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    namespace = var.env_name
    create_namespace = true

values = [
    <<-EOF
    grafana:
      adminPassword: "admin"
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi
      service:
        type: NodePort
        nodePort: ${var.env_name == "dev" ? 32000 : 32001}    

    prometheus:
      prometheusSpec:
        resources:
          limits:
            cpu: 300m
            memory: 512Mi
          requests:
            cpu: 150m
            memory: 256Mi
    EOF
 ]
 set {
    name = "prometheus-node-exporter.enabled"
    value = contains(["dev", "prod"], var.env_name)
 }
}