data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_namespace_v1" "ecom" {
  metadata {
    name = "ecom"
    labels = {
      "app.kubernetes.io/part-of" = "e-commerce"
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_config_map_v1" "product_service" {
  metadata {
    name      = "product-service-config"
    namespace = kubernetes_namespace_v1.ecom.metadata[0].name
  }

  data = {
    SPRING_PROFILES_ACTIVE = "default"
  }
}

resource "kubernetes_deployment_v1" "product_service" {
  metadata {
    name      = "product-service"
    namespace = kubernetes_namespace_v1.ecom.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "product-service"
    }
  }

  spec {
    replicas = 2

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "0"
        max_surge       = "1"
      }
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "product-service"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "product-service"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name              = "product-service"
          image             = "${aws_ecr_repository.product_service.repository_url}:v1"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.product_service.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem   = true

            capabilities {
              drop = ["ALL"]
            }
          }

          startup_probe {
            http_get {
              path = "/actuator/health"
              port = 8080
            }
            failure_threshold = 30
            period_seconds    = 10
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8080
            }
            period_seconds = 10
          }

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8080
            }
            period_seconds = 20
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [module.eks, aws_ecr_repository.product_service]
}

resource "kubernetes_service_v1" "product_service" {
  metadata {
    name      = "product-service"
    namespace = kubernetes_namespace_v1.ecom.metadata[0].name
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "product-service"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment_v1.product_service]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "product_service" {
  metadata {
    name      = "product-service"
    namespace = kubernetes_namespace_v1.ecom.metadata[0].name
  }

  spec {
    min_replicas = 2
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.product_service.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.product_service]
}
