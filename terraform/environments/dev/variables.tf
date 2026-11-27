variable "project_id" {
  type        = string
  description = "Project ID for GCP"
}

variable "region" {
  type        = string
  description = "GCP region for the ressources"
  default     = "europe-west1"
}

variable "bucket_name" {
  type        = string
  description = "Cloud Storage name"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "db_user" {
  type        = string
  description = "User name"
}

variable "db_password" {
  type        = string
  description = "DB password for the user"
  sensitive   = true
}

variable "image" {
  type        = string
  description = " Docker image"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "dev"
}
