terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  # credentials = file("${var.credentials}")

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_cloud_scheduler_job" "start_db_1" {
  project          = var.project_id
  name             = "start-cloudsql-instance"
  description      = "Start Cloud SQL instance "
  schedule         = "every day 23:59"
  time_zone        = "Europe/Amsterdam"  

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.function.https_trigger_url
    body        = base64encode("{\"action\":\"start\", \"db_instance_name\":\"${var.db_instance_name}\"}")
    oidc_token {
      service_account_email = google_service_account.service_account.email
    }
  }

  depends_on = [
    google_cloudfunctions_function.function,
    google_cloudfunctions_function_iam_member.invoker
  ]
}

resource "google_cloud_scheduler_job" "stop_db_1" {
  project          = var.project_id
  name             = "stop-cloudsql-instance"
  description      = "Stop Cloud SQL instance"
  schedule         = "every day 00:02"
  time_zone        = "Europe/Amsterdam"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.function.https_trigger_url
    body        = base64encode("{\"action\":\"stop\", \"db_instance_name\":\"${var.db_instance_name}\"}")
    oidc_token {
      service_account_email = google_service_account.service_account.email
    }
  }

  depends_on = [
    google_cloudfunctions_function.function,
    google_cloudfunctions_function_iam_member.invoker
  ]
}