locals {
        Rating = { A: 1, B: 2, C: 3, D: 4, E: 5 }
}

module "sonar_quality_gate" {
  source = "../../sonarqube/quality_gate"

  name = "Common"

  conditions = {
    coverage = [ "LT", 80 ]
    sqale_rating = [ "GT", local.Rating.B ]
    security_rating = ["GT", local.Rating.A ]
    reliability_rating = ["GT", local.Rating.A ]
    duplicated_lines_density = [ "GT", 1 ]
  }
}
