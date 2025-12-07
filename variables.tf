variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "google_credentials" {
  type        = string
  description = "GCP credentials JSON"
  sensitive   = true
}

variable "service_account_name" {
  type        = string
  description = "Cloud Composer service account name"
}

variable "service_account_display_name" {
  type        = string
  description = "Cloud Composer service account display name"
}

variable "composer_bucket_name" {
  type        = string
  description = "Cloud Composer storage bucket name"
}

variable "composer_environment_name" {
  type        = string
  description = "Cloud Composer environment name"
}

variable "composer_bucket_iam_bindings" {
  type = list(object({
    member = string
    role   = string
  }))
  description = "IAM bindings for Cloud Composer bucket"
  default     = []
}
