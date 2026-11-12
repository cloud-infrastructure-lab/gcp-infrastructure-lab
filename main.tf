locals {
  service_names = toset(["catalog"])
}

# Shared deployment bucket for this environment
resource "google_storage_bucket" "deployments" {
  name                        = "${var.project_id}-deployment-${var.environment}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }
}

# Docker image repositories, one per microservice
resource "google_artifact_registry_repository" "services" {
  for_each = local.service_names

  location      = var.region
  repository_id = "${each.key}-${var.environment}"
  description   = "Docker images for ${each.key} in ${var.environment}"
  format        = "DOCKER"
}

# Placeholder prefix for each microservice's manifests
resource "google_storage_bucket_object" "service_folders" {
  for_each = local.service_names

  name    = "${each.key}-service/"
  bucket  = google_storage_bucket.deployments.name
  content = " "
}


