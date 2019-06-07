# ------------------------------------------------------------------------------
# WEBSITE OUTPUTS
# ------------------------------------------------------------------------------

output "website_url" {
  description = "URL of the website"
  value       = module.static_site.website_url
}

output "website_bucket" {
  description = "Self link to the website bucket"
  value       = module.static_site.website_bucket
}

output "website_bucket_name" {
  description = "Name of the website bucket"
  value       = module.static_site.website_bucket_name
}

