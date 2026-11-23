
resource "google_cloudbuild_trigger" "dev_catalog" {
  project     = var.project_id
  location    = var.region
  name        = "dev-catalog-trigger"
  description = "Build and push catalog-service Docker image on dev branch"

  service_account = google_service_account.backend_build.id

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.region}/connections/CloudBuild-GitHub-Connection/repositories/catalog-service"

    push {
      branch = "^dev$"
    }
  }

  substitutions = {
    _PROJECT_ID = var.project_id
    _REGION     = var.region
    _REPOSITORY = google_artifact_registry_repository.services["catalog"].repository_id
    _IMAGE_NAME = "catalog-service"
  }

  build {
    step {
      id   = "build-image"
      name = "gcr.io/cloud-builders/docker"

      args = [
        "build",
        "-t",
        "$${_REGION}-docker.pkg.dev/$${_PROJECT_ID}/$${_REPOSITORY}/$${_IMAGE_NAME}:$SHORT_SHA",
        "."
      ]
    }

    step {
      id   = "push-image"
      name = "gcr.io/cloud-builders/docker"

      args = [
        "push",
        "$${_REGION}-docker.pkg.dev/$${_PROJECT_ID}/$${_REPOSITORY}/$${_IMAGE_NAME}:$SHORT_SHA"
      ]

      wait_for = ["build-image"]
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }
}
