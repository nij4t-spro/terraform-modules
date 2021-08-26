locals {
  cluster_name = var.cluster_name
  region       = var.region
  namespace    = var.namespace
  domain       = var.domain
  services     = var.services
}

provider "aws" {
  region = local.region
}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "kubernetes_namespace" "preview" {
  // TODO: add managed-by annotation
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "service" {
  count = length(local.services)

  name       = local.services[count.index].name
  namespace  = kubernetes_namespace.preview.metadata[0].name
  repository = local.services[count.index].repository
  chart      = local.services[count.index].chart
  version    = local.services[count.index].version

  # values = lookup(local.services[count.index], "values", [])
  set {
    name = "image.tag"
    value = local.services[count.index].imageTag != "" ? local.services[count.index].imageTag : "dev"
  }
}

data "aws_route53_zone" "selected" {
  name = "${local.domain}."
}

resource "aws_route53_record" "preview" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${kubernetes_namespace.preview.metadata[0].name}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.lb.status[0].load_balancer[0].ingress[0].hostname]
}

data "kubernetes_service" "lb" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "nginx-ingress"
  }
}

// TODO: Generate 1 ingress resource for all services
resource "kubernetes_ingress" "preview" {
  metadata {
    name      = "preview"
    namespace = kubernetes_namespace.preview.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
      # TODO: force redirect to https
    }
  }


  spec {
    // TODO: Add tls
    dynamic "rule" {
      for_each = local.services
      content {
        host = "${local.namespace}.${local.domain}"
        http {
          path {
            backend {
              service_name = rule.value["name"]
              service_port = "http"
            }

            path = "/api/${rule.value["name"]}/(.*)"
          }
        }
      }
    }
  }
}
