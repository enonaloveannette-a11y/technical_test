# Documentation:  https://docs.cloud.google.com/run/docs/securing/service-identity
resource "google_service_account" "run" {
  account_id   = "app-runner"
  display_name = "Cloud Run service account"
  project      = var.project_id
}

# Allows the service account to connect to Cloud SQL:
#  Documentation: https://docs.cloud.google.com/sql/docs/mysql/connect-run
resource "google_project_iam_member" "run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.run.email}"
}

# Port 8080 by default
#  Documentation: https://docs.cloud.google.com/run/docs/container-contract
resource "google_cloud_run_v2_service" "service" {
  name                = var.service_name
  location            = var.region
  project             = var.project_id
  deletion_protection = false

  template {
    service_account = google_service_account.run.email

    containers {
      image = var.image

      ports {
        container_port = 8080
      }

      env {
        name  = "APP_ENV"
        value = var.environment
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${var.db_connection_name}"
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name  = "DB_USER"
        value = var.db_user
      }
      env {
        name  = "DB_PASS"
        value = var.db_password
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"

      cloud_sql_instance {
        instances = [var.db_connection_name]
      }
    }
  }
}

# For public access 
#  Documentation: https://docs.cloud.google.com/run/docs/authenticating/public
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.service.name
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
