terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("../gcp.json")

  project = "earthapi-351012"
  region  = "europe-west9"
  zone    = "europe-west9-a"
}