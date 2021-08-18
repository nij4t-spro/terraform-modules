locals {
        Rating = { A: 1, B: 2, C: 3, D: 4, E: 5 }
}

module "sonar_quality_gate" {
  source = "../../sonarqube/quality_gate"

  conditions = {
    coverage = [ "LT", 80 ]
    sqale_rating = [ "GT", local.Rating.B ]
    security_rating = ["GT", local.Rating.B ]
  }
}