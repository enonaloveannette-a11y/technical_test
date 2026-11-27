output "bucket_name" {
  description = "Name of the bucket containing the static files"
  value       = google_storage_bucket.bucket.name
}
