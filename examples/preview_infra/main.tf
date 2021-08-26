module "preview-infra" {
  # TODO: extract to yaml spec
  source       = "../../modules/eks/preview_infra"
  region       = "us-east-1"
  cluster_name = "example"
  namespace    = "preview"
  domain       = "example.com"
  services = [
    {
      name       = "podinfo"
      chart      = "podinfo"
      repository = "https://stefanprodan.github.io/podinfo"
      version    = "6.0.0"
    }
  ]
}

output "preview_host" {
  value = module.preview-infra.preview_host
}

output "service_urls" {
  value = module.preview-infra.service_urls
}

