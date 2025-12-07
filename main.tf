resource "google_project_iam_member" "cloud_composer" {
  member  = "serviceAccount:${google_service_account.cloud_composer.email}"
  project = var.project_id
  role    = "roles/composer.worker"

  depends_on = [google_service_account.cloud_composer]
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
        webserver-rbac_user_registration_role = "UserNoDags"
      }

      image_version = "composer-3-airflow-3.1.0-build.2"
    }

    node_config {
      service_account = google_service_account.cloud_composer.name
    }
    
  }

  storage_config {
    bucket = google_storage_bucket.composer_bucket.name
  }

  depends_on = [
    google_storage_bucket.composer_bucket,
    google_project_iam_member.cloud_composer,
    google_storage_bucket_iam_member.composer_bucket_iam
  ]
}

locals {
  # Default roles for Cloud Composer service account
  default_sa_roles = [
    {
      member = "serviceAccount:${google_service_account.cloud_composer.email}"
      role   = "roles/storage.objectAdmin"
    }
  ]
  
  # Concatenate default roles with provided bindings
  all_iam_bindings = concat(local.default_sa_roles, var.composer_bucket_iam_bindings)
}

resource "google_storage_bucket_iam_member" "composer_bucket_iam" {
  for_each = {
    for idx, binding in local.all_iam_bindings : "${binding.member}-${binding.role}" => binding
  }

  bucket     = google_storage_bucket.composer_bucket.name
  role       = each.value.role
  member     = each.value.member
  depends_on = [
    google_storage_bucket.composer_bucket,
    google_service_account.cloud_composer
  ]
}
