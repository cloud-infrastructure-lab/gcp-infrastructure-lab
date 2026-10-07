terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "terraform_data" "pipeline_test" {
  input = {
    environment = var.environment
    message     = "Cloud Infrastructure Lab Terraform pipeline is working"
  }
}