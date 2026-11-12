terraform {
  backend "gcs" {
    bucket = "infrastructure-lab-tf-state"
  }
}