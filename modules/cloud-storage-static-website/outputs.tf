output "website_url" {
  description = "URL of the website"
  value       = "${var.create_dns_entry ? var.website_domain_name : format("%s.storage.googleapis.com", var.website_domain_name)}"
}

output "website_bucket" {
  description = "Self link to the website bucket"
  value       = "${google_storage_bucket.website.self_link}"
}

output "access_logs_bucket" {
  description = "Self link to the access logs bucket"
  value       = "${google_storage_bucket.access_logs.self_link}"
}
