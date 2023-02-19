resource "doppler_project" "project" {
  name        = var.project-name
  description = "Home infrastructure repository"
}
resource "doppler_environment" "environment" {
  for_each = toset(var.environments)
  project  = doppler_project.project.name
  slug     = each.value
  name     = each.value
}
