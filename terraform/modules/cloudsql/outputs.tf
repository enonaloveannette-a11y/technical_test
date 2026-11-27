output "connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.connection_name
}
