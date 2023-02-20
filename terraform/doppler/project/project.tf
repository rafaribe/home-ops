locals {
  project_description = var.project_description != "" ? var.project_description : "Project for ${var.project_name}"
}
resource "doppler_project" "project" {
  name        = var.project_name
  description = local.project_description
}
resource "doppler_environment" "environment" {
  for_each = toset(var.environments)
  project  = doppler_project.project.name
  slug     = each.value
  name     = each.value
}
