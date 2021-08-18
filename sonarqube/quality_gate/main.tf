terraform {
  required_providers {
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "0.0.7"
    }
  }
}

variable "conditions" {
  type = map(any)
  description = "Map of metrics and a tupple of condition operator and value"
}

locals {
  # Map of metrics and a tupple of condition operator and value
  quality_gate_map = var.conditions
  # Bake a list of metrics
  metrics = keys(local.quality_gate_map)
}

resource "sonarqube_qualitygate" "main" {
  name = "Common"
}

resource "sonarqube_qualitygate_condition" "default" {
  count = length(local.metrics)
  
  gatename  = sonarqube_qualitygate.main.id
  metric    = local.metrics[count.index]
  op        = lookup(local.quality_gate_map, local.metrics[count.index])[0]
  threshold = lookup(local.quality_gate_map, local.metrics[count.index])[1]
}
