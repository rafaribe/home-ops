resource "doppler_project" "home-ops" {
  name        = "home-ops"
  description = "Home infrastructure repository"
}

resource "doppler_environment" "dev" {
  project = doppler_project.home-ops.name
  slug    = "dev"
  name    = "dev"
  depends_on = [
    doppler_project.home-ops
  ]
}

