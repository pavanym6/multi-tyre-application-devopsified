resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

# ✅ ArgoCD installation

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.0"

  create_namespace = false

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}


# ✅ Lightweight Monitoring Stack (FIXED VERSION)

resource "helm_release" "monitoring" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.21.0"

  timeout          = 600
  create_namespace = false
  cleanup_on_fail = true
  force_update    = true
  recreate_pods   = true


  values = [
    yamlencode({

      # ✅ Grafana (lightweight)
      grafana = {
        service = {
          type = "ClusterIP"
        }
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
        }
      }

      # ✅ Prometheus (VERY IMPORTANT FIX)
      prometheus = {
        service = {
          type = "ClusterIP"
        }
        prometheusSpec = {
          resources = {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }
        }
      }

      # ✅ Alertmanager (lightweight)
      alertmanager = {
        service = {
          type = "ClusterIP"
        }
        alertmanagerSpec = {
          resources = {
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
          }
        }
      }

      # ✅ kube-state-metrics fix (important)
      kubeStateMetrics = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
        }
      }

      # ✅ OPTIONAL: reduce node exporter pressure
      nodeExporter = {
        resources = {
          requests = {
            cpu    = "20m"
            memory = "50Mi"
          }
        }
      }

    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}

