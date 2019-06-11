output "website_url" {
  description = "URL of the website"
  value       = var.create_dns_entry ? var.website_domain_name : module.load_balancer.load_balancer_ip_address
}

output "load_balancer_ip_address" {
  description = "IP address of the HTTP Cloud Load Balancer"
  value       = module.load_balancer.load_balancer_ip_address
}

output "website_bucket" {
  description = "Self link to the website bucket"
  value       = module.site_bucket.website_bucket
}

output "access_logs_bucket" {
  description = "Self link to the access logs bucket"
  value       = module.site_bucket.access_logs_bucket
}

output "website_bucket_name" {
  description = "Name of the website bucket"
  value       = module.site_bucket.website_bucket_name
}

output "access_logs_bucket_name" {
  description = "Name of the access logs bucket"
  value       = module.site_bucket.access_logs_bucket_name
}

