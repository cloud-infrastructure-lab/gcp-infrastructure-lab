variable "project_id" {
  description = "GCP Infrastructure Lab project"
  type        = string
  default     = "quiet-mechanic-510301-h5"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in (optional if zonal cluster / required if regional)"
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Test"
}