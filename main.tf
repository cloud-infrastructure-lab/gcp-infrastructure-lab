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

########   GCP Storage  ############
####################################
# Placeholder prefix for each microservice's manifests
resource "google_storage_bucket_object" "service_folders" {
  for_each = local.service_names

  name    = "${each.key}-service/"
  bucket  = google_storage_bucket.deployments.name
  content = " "
}

########   Service account  ########
####################################

# Shared service account for backend application CI/CD
resource "google_service_account" "backend_build" {
  project      = var.project_id
  account_id   = "backend-build-sa"
  display_name = "Backend Services Cloud Build"
}

# Allow backend builds to write Cloud Build logs
resource "google_project_iam_member" "backend_build_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.backend_build.email}"
}

# Allow backend builds to push Docker images to service repositories
resource "google_artifact_registry_repository_iam_member" "backend_build_writer" {
  for_each = google_artifact_registry_repository.services

  project    = var.project_id
  location   = var.region
  repository = each.value.repository_id

  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.backend_build.email}"
}
