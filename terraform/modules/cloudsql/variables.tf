variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region where the cloud sql is created"
}

variable "instance_name" {
  type        = string
  description = "Name of the instance"
}

variable "database_name" {
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
