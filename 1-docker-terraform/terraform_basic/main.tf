terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
    credentials = "./terraform-runner.json"
  project = "dulcet-bastion-419415"
  region  = "us-central1"
}

resource "google_storage_bucket" "terraform-demo-bucket" {
  name          = "dulcet-bastion-419415-terra-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}