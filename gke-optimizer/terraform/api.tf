data "google_client_config" "default" {}

/* ensure that the image registry bucket is created by pushing an empty image to it */
resource "null_resource" "docker-registry" {
  
  provisioner "local-exec" { 
    working_dir = path.module
    command = <<EOT
    cd ../api
    ls -a
    gcloud components install docker-credential-gcr && \
    docker-credential-gcr configure-docker && \
    docker build -t eu.gcr.io/${var.project_id}/api-skaffold:v1 . && \
    docker push eu.gcr.io/${var.project_id}/api-skaffold:v1
    cd ..
   EOT
  }
  depends_on = [google_project_service.containerregistry]
}

/* Assign access to defualt service used by Kubernetes to bucket created for Container registry  */

resource "google_project_service" "containerregistry" {
  service          = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "kn" {
  metadata {
    name = "api-skaffold-namespace"
  }
}


resource "kubernetes_deployment" "api_skaffold" {
  metadata {
    name      = "api-skaffold"
    namespace = kubernetes_namespace.kn.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "api-skaffold"
      }
    }
    template {
      metadata {
        labels = {
          app = "api-skaffold"
        }
      }
      spec {
        container {
          image = "eu.gcr.io/earthapi-351012/api-skaffold:v1"
          name  = "api-skaffold"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api_skaffold_service" {
  metadata {
    name      = "api-skaffold"
    namespace = kubernetes_namespace.kn.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.api_skaffold.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}
