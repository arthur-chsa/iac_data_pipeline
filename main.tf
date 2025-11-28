terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.google_credentials
}

resource "google_project_iam_member" "cloud_composer" {
  member  = "serviceAccount:${google_service_account.cloud_composer.email}"
  project = var.project_id
  role    = "roles/composer.worker"
}

resource "google_service_account" "cloud_composer" {
  account_id   = var.service_account_name
  display_name = var.service_account_display_name
}

resource "google_storage_bucket" "composer_bucket" {
  name          = var.composer_bucket_name
  location      = var.region
  project       = var.project_id
  force_destroy = true
}

resource "google_composer_environment" "cloud_composer" {
  name   = var.composer_environment_name
  region = var.region
  config {
    enable_private_environment = true

    software_config {
      airflow_config_overrides = {
        # By enabling this, Airflow will create roles per folder inside the GCS bucket
        webserver-rbac_autoregister_per_folder_roles = "True"
      }

      image_version = "composer-3-airflow-3.1.0-build.2"
    }

    node_config {
      service_account = google_service_account.cloud_composer.name
    }

    airflow_config_overrides {
      webserver-rbac_autoregister_per_folder_roles = "True"
      webserver-rbac_user_registration_role = "UserNoDags"
    }
  }

  storage_config {
    bucket = google_storage_bucket.composer_bucket.name
  }

  depends_on = [google_storage_bucket.composer_bucket]
}

resource "google_storage_bucket_iam_member" "composer_bucket_iam" {
  for_each = {
    for idx, binding in var.composer_bucket_iam_bindings : "${binding.member}-${binding.role}" => binding
  }

  bucket     = google_storage_bucket.composer_bucket.name
  role       = each.value.role
  member     = each.value.member
  depends_on = [google_storage_bucket.composer_bucket]
}
