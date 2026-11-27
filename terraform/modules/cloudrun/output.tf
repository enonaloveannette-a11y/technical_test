output "service_name" {
  description = "Name of the cloud run service"
  value       = google_cloud_run_v2_service.service.name
}

output "service_url" {
  description = "Public URL"
  value       = google_cloud_run_v2_service.service.uri
}
