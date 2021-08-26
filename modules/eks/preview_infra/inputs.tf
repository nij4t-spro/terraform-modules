variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "services" {
  type = list(map(any))
  # where any - { name: string, chart: string, repository: string, version: string, tag: string, values: list(string) } 
}

variable "domain" {
  type        = string
  description = "fqdn"
}

variable "namespace" {
  type        = string
  description = "hostname complient"
}

