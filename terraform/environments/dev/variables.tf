variable "project_id" {
  type        = string
  description = "Projetc ID for GCP"
}

variable "region" {
  type        = string
  description = "Région GCP des ressources"
  default     = "europe-west1"
}
