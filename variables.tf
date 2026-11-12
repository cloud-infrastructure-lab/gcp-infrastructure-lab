variable "project_id" {
  description = "GCP Infrastructure Lab project"
  type        = string
  default     = "quiet-mechanic-510301-h5"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}