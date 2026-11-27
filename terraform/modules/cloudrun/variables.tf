variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region where the cloud run is created"
}

variable "service_name" {
  type        = string
  description = "Name of the cloudrun service"
}

variable "image" {
  type        = string
  description = " Docker image"
}

variable "db_connection_name" {
  type        = string
  description = "Database connection"
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

variable "environment" {
  type        = string
  description = "Environment"
}

