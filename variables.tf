variable "project_id" {
  type = string
}
variable "region" {
  type    = string
  default = "europe-west3"
}

variable "google_credentials" {
  description = "GCP credentials in JSON format"
  type        = string
  sensitive   = true
}

variable "service_account_name" {
  type        = string
  description = "Name for the Cloud Composer service account"
}

variable "service_account_display_name" {
  type        = string
  description = "Display name for the Cloud Composer service account"
}

variable "composer_environment_name" {
  type        = string
  description = "Name for the Cloud Composer environment"
}

variable "composer_bucket_name" {
  type        = string
  description = "Name for the Cloud Composer storage bucket"
}

variable "composer_bucket_location" {
  type        = string
  description = "Location for the Cloud Composer storage bucket. Defaults to region if not specified."
  default     = null
}

variable "composer_bucket_iam_bindings" {
  type = list(object({
    member = string
    role   = string
  }))
  description = "List of IAM bindings for the Cloud Composer storage bucket. Each binding should have member (e.g., serviceAccount:...) and role (e.g., roles/storage.objectViewer)."
  default     = []
}
