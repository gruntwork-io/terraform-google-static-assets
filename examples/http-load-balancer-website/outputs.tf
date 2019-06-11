# ------------------------------------------------------------------------------
# WEBSITE OUTPUTS
# ------------------------------------------------------------------------------

output "website_url" {
  description = "URL of the website"
  value       = module.static_site.website_url
}

output "load_balancer_ip_address" {
  description = "Public IP address of the HTTP Load Balancer"
  value       = module.static_site.load_balancer_ip_address
}

output "website_bucket" {
  description = "Self link of the website bucket"
  value       = module.static_site.website_bucket
}

output "website_bucket_name" {
  description = "Name of the website bucket"
  value       = module.static_site.website_bucket_name
}

output "access_logs_bucket" {
  description = "Self link of the access logs bucket"
  value       = module.static_site.access_logs_bucket
}

output "access_logs_bucket_name" {
  description = "Name of the access logs bucket"
  value       = module.static_site.access_logs_bucket_name
}

