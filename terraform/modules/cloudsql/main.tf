# Documentation: https://docs.cloud.google.com/sql/docs?hl=fr

resource "google_sql_database_instance" "instance" {
  name                = var.instance_name
  region              = var.region
  project             = var.project_id
  database_version    = "MYSQL_8_0"
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = var.db_password
  project  = var.project_id
}
