terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = var.credentials

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_compute_default_service_account" "default" {
}

resource "google_cloud_scheduler_job" "start" {
  name             = "start-cloudsql-instance"
  description      = "Start Cloud SQL instance "
  schedule         = "08 00 * * * "
  time_zone        = "Europe/Paris"  

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "<fucntion_uri_to_start>"
    oidc_token {
      service_account_email = data.google_compute_default_service_account.default.email
    }
  }
}

resource "google_cloud_scheduler_job" "stop" {
  name             = "stop-cloudsql-instance"
  description      = "Stop Cloud SQL instance"
  schedule         = "19 00 * * *"
  time_zone        = "Europe/Paris"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "<fucntion_uri_to_stop>"  
    oidc_token {
      service_account_email = data.google_compute_default_service_account.default.email
    }  
  }
}