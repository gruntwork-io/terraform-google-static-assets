output "website_url" {
  description = "URL of the website"
  value       = var.create_dns_entry == "true" ? var.website_domain_name : format("storage.googleapis.com/%s", var.website_domain_name)
}

output "website_bucket" {
  description = "Self link to the website bucket"
  value       = google_storage_bucket.website.self_link
}

output "access_logs_bucket" {
  description = "Self link to the access logs bucket"
  value       = google_storage_bucket.access_logs.self_link
}

output "website_bucket_name" {
  description = "Name of the website bucket"
  value       = google_storage_bucket.website.name
}

output "access_logs_bucket_name" {
  description = "Name of the access logs bucket"
  value       = google_storage_bucket.access_logs.name
}

